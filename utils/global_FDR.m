% perform global FDR
set_paths
% get all p-values
for i = 1:4
    load([results_path 'p/fdr_indiv/p_val_H' num2str(i) '.mat'],'p_*_uncorr*')
end
% concatenate into column vector
p_all = vertcat(p_n1_uncorr1, p_volt_uncorr2(:),p_theta_uncorr2(:),p_alpha_uncorr2(:),...
    p_volt_uncorr3(:),p_pow_uncorr3(:),p_volt_uncorr4(:),p_pow_uncorr4(:));
% get fdr threshold
p_th = fdr(p_all, 0.05);
% correct
p_n1_global = mask_fdr(p_n1_uncorr1, p_th);
p_volt_global2 = mask_fdr(p_volt_uncorr2, p_th);
p_volt_global3 = mask_fdr(p_volt_uncorr3, p_th);
p_volt_global4 = mask_fdr(p_volt_uncorr4, p_th);
p_alpha_global2 = mask_fdr(p_alpha_uncorr2, p_th);
p_theta_global2 = mask_fdr(p_theta_uncorr2, p_th);
p_pow_global3 = mask_fdr(p_pow_uncorr3, p_th);
p_pow_global4 = mask_fdr(p_pow_uncorr4, p_th);

%save([results_path 'p/all_p_global_FDR.mat'],'p_n1_global')
function out = mask_fdr(data,threshold)
    data(data > threshold) = NaN;
    out = data;
end