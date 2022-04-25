% perform global FDR
set_paths
% get all p-values
for i = 1:4
    load([results_path 'p/p_val_H' num2str(i) '.mat'],'p_*_uncorr*')
end
% concatenate
p1 = p_n1_uncorr1;
p21 = reshape(p_volt_uncorr2,[],1);
p22 = reshape(p_theta_uncorr2,[],1);
p23 = reshape(p_alpha_uncorr2,[],1);
p31 = reshape(p_volt_uncorr3, [],1);
p32 = reshape(p_pow_uncorr3, [],1);
p41 = reshape(p_volt_uncorr4,[],1);
p42 = reshape(p_pow_uncorr4,[],1);
p_all = vertcat(p1,p21,p22,p23,p31,p32,p41,p42);
% get fdr threshold
p_th = fdr(p_all, 0.05);
% correct
p_n1_global = p_n1_uncorr1;
p_n1_global(p_n1_global > p_th) = NaN;
p_volt_global2 = p_volt_uncorr2;
p_volt_global2(p_volt_global2 > p_th) = NaN;
p_volt_global3 = p_volt_uncorr3;
p_volt_global3(p_volt_global3 > p_th) = NaN;
p_volt_global4 = p_volt_uncorr4;
p_volt_global4(p_volt_global4 > p_th) = NaN;
p_alpha_global2 = p_alpha_uncorr2;
p_alpha_global2(p_alpha_global2 > p_th) = NaN;
p_theta_global2 = p_theta_uncorr2;
p_theta_global2(p_theta_global2 > p_th) = NaN;
p_pow_global3 = p_pow_uncorr3;
p_pow_global3(p_pow_global3 > p_th) = NaN;
p_pow_global4 = p_pow_uncorr4;
p_pow_global4(p_pow_global4 > p_th) = NaN;