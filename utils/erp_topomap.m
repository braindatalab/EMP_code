% plot n1 across all trials - topomap
set_paths
subs = dir([prep_path '*.mat']);
load('layout.mat');
for nsub = 1:5
    load([subs(nsub).folder '/' subs(nsub).name])
    %% make timelock data
    cfg = [];
    cfg.latency = [0.1 0.2];
    data = ft_timelockanalysis(cfg,dat);
    % find minimum
    [n1,n1_idx] = min(data.avg,[],2);
    data_n1 = data;
    data_n1.time = data.time(7);
    data_n1.avg = [];
    for i = 1:length(data.avg)
        data_n1.avg(i,1) = data.avg(i,n1_idx(i));
    end
    %% topoplot
    cfg = [];
    cfg.layout = layout;
    ft_topoplotER(cfg,data_n1);
    colorbar
    saveas(gcf,[plots_path 'n1_' subs(nsub).name(1:end-4) '.png'])
    close all
end