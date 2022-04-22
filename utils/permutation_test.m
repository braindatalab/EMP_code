function [p_orig_min, p_perm_min, prc] = permutation_test(data_sub, c1_idx, c2_idx, alpha)
% data_sub is trial x chan x time
% get means of every condition, mean difference, variance (normalized)
% perform group analysis
% 1000 permutations - permute trial indices and repeat
% original data
tic
disp('testing original data')
% loop over subjects
c1_data = data_sub(c1_idx,:,:);
c2_data = data_sub(c2_idx,:,:);
ds = mean(c1_data,1) - mean(c2_data,1);
vars = var(c1_data,0,1) ./ size(c1_data,1)+var(c1_data,0,1) ./ size(c1_data,1);
[p_uncorr, ~, ~] = group_analysis(ds, vars, size(c1_data,2),alpha);
p_orig_min = min(p_uncorr,[],'all');
if p_orig_min < 0.05
% permutations
p_perm_min = [];
all_p = [];
for iperm = 1:100
    fprintf('permutation %d\n', iperm)
    % loop over subjects
    tri_perm = randperm(length([c1_idx;c2_idx]))';
    c1_perm = tri_perm(1:length(c1_idx));
    c2_perm = tri_perm(length(c1_idx)+1:end);
    c1_data_perm = data_sub(c1_perm,:,:);
    c2_data_perm = data_sub(c2_perm,:,:);
    ds_perm = squeeze(mean(c1_data_perm,1) - mean(c2_data_perm,1));
    ds_perm_all(iperm, :, :) = ds_perm;
    vars_perm = var(c1_data_perm,0,1) ./ size(c1_data_perm,1)+...
        var(c2_data_perm,0,1) ./ size(c2_data_perm,1);
    %TODO: end 
    [p_uncorr_perm, ~, ~] = group_analysis(ds_perm, vars_perm, size(c1_data_perm,2),alpha);
    p_curr_min = min(p_uncorr_perm,[],'all');
    p_perm_min(iperm) = p_curr_min;
end
% get percentage
prc = length(find(p_perm_min < p_orig_min))/length(p_perm_min);
toc
else
    disp('no significant regions')
end
end