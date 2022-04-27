function t = stats_to_table(ch,p,z,timwin)
t = table();
if ndims(p)==2
    [i,j] = find(~isnan(p));
    if isempty(i) && isempty(j)
        disp('no significant values')
    else
        t.channel = ch(i);
        lin_idx = sub2ind(size(p), i,j);
        t.pval = p(lin_idx);
        t.zval = z(lin_idx);
        t.time_window = timwin(j)';
    end
else
    freqs = linspace(0,50,26);
    [i,j,k] = ind2sub(size(p),find(~isnan(p)));
    if isempty(i) && isempty(j)
        disp('no significant values')
    else
        t.channel = ch(i);
        lin_idx = find(~isnan(p));
        t.pval = p(lin_idx);
        t.zval = z(lin_idx);
        t.time_window = timwin(k)';
        t.freq = freqs(j)';
    end
end
end