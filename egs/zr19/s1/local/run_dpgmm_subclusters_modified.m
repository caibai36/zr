function [z,post,cluster_ids] = run_dpgmm_subclusters_modified(data,data_test,start,dispOn,Mproc,sc,as,alpha, endtime, numits)
% RUN_DPGMM_SUBCLUSTERS - runs the Dirichlet process Gaussian mixture model
% with subcluster splits and merges
%    run_dpgmm_subclusters(data, start, dispOn, Mproc, sc, as, alpha,
%    endtime, numits)
%
%    data - a DxN matrix containing double valued data, where D is the
%       dimension, and N is the number of data points
%    start - the number of initial clusters to start with
%    dispOn - whether progress should be continuously displayed
%    Mproc - the number of threads to use
%    sc - whether super-clusters are used or not
%    as - whether the approximate sampler is used or not
%    alpha - concentration parameter
%    endtime - the total time in seconds to stop after
%    numits - the number of iterations to stop after
%
%   Notes:
%     (1) The display shows the running time of the algorithm without I/O
%     to and from Matlab. It also doesn't show time to display. This is
%     more accurate, since one can always run as many iterations with C++
%     as desired.
%
%   [1] J. Chang and J. W. Fisher II, "Parallel Sampling of DP Mixtures
%       Models using Sub-Cluster Splits". Neural Information Processing
%       Systems (NIPS 2013), Lake Tahoe, NV, USA, Dec 2013.
%
%   Copyright(c) 2013. Jason Chang, CSAIL, MIT. 

include_path='/project/nakamura-lab08/Work/bin-wu/share/tools/dpgmm/dpmm_subclusters_2014-08-06/Gaussian/include';
addpath(include_path);

if (~exist('dispOn','var') || isempty(dispOn))
    dispOn = false;
end
if (~exist('Mproc','var') || isempty(Mproc))
    Mproc = 1;
end
if (~exist('sc','var') || isempty(sc))
    sc = true;
end
if (~exist('as','var') || isempty(as))
    as = false;
end
if (~exist('endtime', 'var') || isempty(endtime))
    endtime = 1000;
end
if (~exist('numits', 'var') || isempty(numits))
    numits = 1000;
end

N = size(data,2);
D = size(data,1);

if (D>N)
    error('More dimensions than observations.  Check data.');
end

params.alpha = alpha;
params.kappa = 1;
params.nu = D+3;
params.theta = mean(data,2);
% params.delta = eye(D);
params.delta=cov(data');
params.its_crp = 20;
% params.its_ms = 1;
params.Mproc = Mproc;
params.useSuperclusters = logical(sc);
params.always_splittable = logical(as);

phi = rand(N,1)*start;
z = uint32(floor(phi));
clusters = initialize_clusters(data, phi, params);

numits = ceil(numits / params.its_crp);
time = zeros(numits*params.its_crp+1,1);
E = zeros(numits*params.its_crp+1,1);
E(1) = dpgmm_calc_posterior(data, z, params);
K = zeros(numits*params.its_crp+1,1);
K(1) = start;
NK = zeros(numits*params.its_crp+1,1);
NK(1) = max(hist(floor(phi), start));

colors = distinguishable_colors(50,[1 1 1]);

disp('Itr. - diff. time - abs. time - joint log likelihood - Clusters K');

cindex = 1;
for it=1:numits
    [clusters, timediffs, Es, Ks, NKs] = dpgmm_subclusters(data, phi, clusters, params);
    time(cindex+1:cindex+params.its_crp) = time(cindex) + cumsum(timediffs);
    E(cindex+1:cindex+params.its_crp) = Es;
    K(cindex+1:cindex+params.its_crp) = Ks;
    NK(cindex+1:cindex+params.its_crp) = NKs;
    cindex = cindex+params.its_crp;
        
    if (time(cindex)>endtime)
        disp(['Stopping: Runtime exceeding maximum time (' num2str(time(cindex)) ' > ' num2str(endtime) ')']);
        break;
    end
    
    if (dispOn)
        sfigure(1);
        subplot(2,1,1);
        plot(time(1:cindex),E(1:cindex));
        xlabel('Time (secs)');
        ylabel('Joint Log Likelihood');
        title(['Iteration: ' num2str(cindex) ' - Time: ' num2str(time(cindex))]);

        subplot(2,1,2);
        hold off;
        tz = floor(phi);
        left = (phi - tz) < 0.5;
        if (max(tz(:))+1 > size(colors,1))
            c = max(max(tz(:))+1, 2*size(colors,1));
            colors = distinguishable_colors(c,[1 1 1]);
        end
        for z=min(tz(:)):max(tz(:))
            k = find([clusters.z]==z);
            mask = tz==z & left;
            plot(data(1,mask), data(2,mask), 'o', 'Color', colors(z+1,:));
            hold on;
            if (any(mask))
                error_ellipse(clusters(k).Sigma_l, clusters(k).mu_l, 'color', [1 1 1],'Linewidth',3);
                error_ellipse(clusters(k).Sigma_l, clusters(k).mu_l, 'style','--','color', colors(z+1,:),'Linewidth',1);
            end
            mask = tz==z & ~left;
            plot(data(1,mask), data(2,mask), 'o', 'Color', colors(z+1,:));
            hold on;
            if (any(mask))
                error_ellipse(clusters(k).Sigma_r, clusters(k).mu_r, 'color', [1 1 1],'Linewidth',3);
                error_ellipse(clusters(k).Sigma_r, clusters(k).mu_r, 'style','--','color', colors(z+1,:),'Linewidth',1);
            end
        end
        drawnow;
    end
    
%disp([num2str(cindex, '%04d') ' - ' num2str(mean(time(2:cindex)-time(1:cindex-1)),'%0.4f') ' - ' num2str(time(cindex))]);
    disp([num2str(cindex, '%04d') ' - ' num2str(mean(time(2:cindex)-time(1:cindex-1)),'%0.4f') ' - ' num2str(time(cindex))  ' - ' num2str(E(cindex)) ' - ' num2str(K(cindex))]);
end

z = floor(phi);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Codes for computing the posteriorgram
% Adapted from the codes implemented by Michael Heck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% dim(dataT) = n x d;
% row: [Sample1;...;SampleN]
dataT = transpose(data_test);

% Computing all weighted probabilities: prior(k) * likelihood(x|k).
% dim(weighted_post) = n x K;
% row: [Sample1;...;SampleN]
% col: [cluster1,...,clusterK]
weighted_post = [];
for k=1:K(cindex)
  weighted_post = [weighted_post exp(clusters(k).logpi) * mvnpdf(dataT, transpose(clusters(k).mu), transpose(clusters(k).Sigma))];
end

% Summing over the clusters to get the marginals: marginal(x) = sum_of_k_clusters(prior(k) * likelihood(x|k))
% dim(marginal) = n x 1;
% row: [Sample1;...;SampleN]
marginal = sum(weighted_post, 2);

% Computing the posteriorgrams of posterior(k|x) = prior(k) * likeihood(x|k) / marginal(x)
% dim(posterigram) = n x K;
% row: [Sample1;...;SampleN]
% col: [cluster1,...,clusterK]
% Notes:
% the following function is the same as function of
% 'post = diag(1./marginal) * weighted_post;'
% but it saves memory.

n = length(marginal);
M = spdiags(marginal(:),0,n,n);
post = M^-1 * weighted_post;

%% ids of clusters of each column
cluster_ids = [];
for k=1:K(cindex)
  cluster_ids = [cluster_ids, clusters(k).z];
end
