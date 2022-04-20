function [p_uncorr, p_fdr, z_re_all] = group_analysis(ds, vars, nch, alpha)
    ds_rs = reshape(ds, size(ds,1), []);
    vars_rs = reshape(vars, size(vars,1), []);
    for i = 1:size(ds_rs,2)
        [~, p_RE,~, z_RE] = equal_weighting(ds_rs(:,i), vars_rs(:,i));
        pval_eqw_re(i) = p_RE;
        z_re_all(i) = z_RE;
    end
    % uncorrected
    pval_eqw_re = pval_eqw_re';
    p_uncorr_tmp = pval_eqw_re;
    p_uncorr_tmp(p_uncorr_tmp > alpha) = NaN;
    % FDR
    p_fdr_tmp = fdr(pval_eqw_re);
    p_fdr_tmp(p_fdr_tmp > alpha) = NaN;
    % shape back
    p_uncorr = reshape(p_uncorr_tmp, nch, []);
    p_fdr = reshape(p_uncorr_tmp, nch, []);
    z_re_all = reshape(z_re_all, nch, []);
end