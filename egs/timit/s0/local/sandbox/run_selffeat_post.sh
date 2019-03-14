mkdir -p exp/selffeat/post
# cp dpgmm/test/*vtln*.mfcc.m* dpgmm/test/*vtln*deltas*.mfcc{,.s*} exp/selffeat/post

echo ============================================================================
echo "    Get dpgmm posteriorgrams of the data set. (need access to matlab)     "
echo ============================================================================

for file in exp/selffeat/post/*; do
    echo $file
    /usr/local/MATLAB/R2018b/bin/matlab -r "addpath('local');run_dpgmm('$file');quit"
done

# (mlp) [bin-wu@ahcgpc02 s0]$(master) ls dpgmm/test/*vtln*.mfcc.m* dpgmm/test/*vtln*deltas*.mfcc{,.s*} | tr -s ' ' '\n'
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.s4t1
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.s4t4
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.s8t1
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.s8t4
# dpgmm/test/timit_test_raw.vtln.cmvn.deltas.mfcc.s8t8
# dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.merge.s4t4
# dpgmm/test/timit_test_raw.vtln.cmvn.mfcc.merge.s8t8
