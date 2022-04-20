% group analysis 
function [p_uncorr, p_fdr, z_re_all] = group_analysis(ds, vars, alpha)
% get dimensions
[d1,d2] = size(squeeze(ds(1,:,:)));
if ndims(ds)==2
    for i = 1:d2
        % save zscores
        [~, p_RE,~, z_RE] = equal_weighting(ds(:,i), vars(:,i));
        pval_eqw_re(i) = p_RE;
        z_re_all(i) = z_RE;
    end
else
    
    for i = 1:d1
        for j = 1:d2
            [~,p_RE,~,z_RE] = equal_weighting(ds(:,i,j),vars(:,i,j));
            pval_eqw_re(i,j) = p_RE;
            z_re_all(i,j) = z_RE;
        end
    end
end
pval_eqw_re = pval_eqw_re';
p_uncorr = pval_eqw_re;
p_uncorr(p_uncorr > alpha) = NaN;

% FDR across channels
p_fdr = fdr(pval_eqw_re);
p_fdr(p_fdr > alpha) = NaN;
end