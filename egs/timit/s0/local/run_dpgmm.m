function [] = run_dpgmm(mfcc_path)

%% function: run_dpgmm
%% input: the feature vector of each frame
%% output: the label and posteriorgram of each frame using dpgmm algorithm
%%
%% Usage: run_dpgmm(<path-to-feature-file>)
%% eg: run_dpgmm('analysis/si1392.mfcc')
%%
%% Notes: 
%% # input format:
%% # the feature vector of each frame  
%% [bin-wu@ahctitan02 dpgmm]$ head -3  analysis/si1392.mfcc
%% 39.00987 -28.51315 -7.556304 -8.882144 -12.18474 -6.569469 15.38711 -0.8894742 3.065244 -3.752501 -3.30743 -10.21967 -10.93673
%% 38.0705 -31.53392 -3.729169 -4.924562 -6.737076 -0.174294 5.925494 2.677303 10.05384 12.5983 1.072475 -13.83553 -13.76574
%% 35.25238 -30.36246 -6.673119 -10.94009 -5.353948 -3.83568 -2.798764 -2.316185 12.3292 18.41914 12.56297 7.194259 -2.685585
%%
%% # output format:
%% # the frame label of clusters 
%% [bin-wu@ahctitan02 dpgmm]$ head -3 analysis/si1392.dpmm.*
%% ==> analysis/si1392.dpmm.flabel <==
%% 6
%% 6
%% 6
%%
%% # the posteriorgram of each frame
%% ==> analysis/si1392.dpmm.post <==
%% 1.4117e-08,1.6195e-16,1.5116e-06,0.00031157,1.3513e-05,0.99967,4.7214e-10
%% 3.5207e-09,6.7736e-19,4.396e-09,1.1953e-07,1.5632e-07,1,1.65e-10
%% 1.3206e-10,2.6058e-17,8.5773e-09,8.2572e-11,5.3033e-07,1,2.0585e-07
%%  
%% # the cluster label of posteriorgram in order 
%% ==> analysis/si1392.dpmm.post.clabel <==
%% 0,1,3,4,5,6,7
%%
%% # grid-dev0: test passed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% path to the common libraries of different dpmm algorithms.
common_path='/project/nakamura-lab08/Work/bin-wu/share/tools/dpgmm/dpmm_subclusters_2014-08-06/common';
addpath(common_path);

% input the file of feature vector
disp(['Processing file: ' mfcc_path]);
% eg: M = dlmread('../dpgmm/si1392.mfcc');
M = dlmread(mfcc_path);
data = M';

% run the sampler
initialClusters = 10;
% dispOn = true;
dispOn=false
numProcessors = 12;
useSuperclusters = false;
approximateSampling = false;
alpha = 1;
endtime = 500000;
numits = 1500;

[z,post,cluster_ids]=run_dpgmm_subclusters(data, initialClusters, dispOn, numProcessors, ...
    useSuperclusters, approximateSampling, alpha, endtime, numits);

% eg.: dlmwrite('../dpgmm/si1392.mfcc.dpmm.flabel', z);
% eg.: dlmwrite('../dpgmm/si1392.mfcc.dpmm.post', post);
% eg.: dlmwrite('../dpgmm/si1392.mfcc.dpmm.post.clabel', cluster_ids);

% the frame label of clusters
dlmwrite(strcat(mfcc_path, '.dpmm.flabel'), z);
% the posteriorgram of each frame
dlmwrite(strcat(mfcc_path, '.dpmm.post'), post);
% the cluster label of posteriorgram in order 
dlmwrite(strcat(mfcc_path, '.dpmm.post.clabel'), cluster_ids);
