function plot_topomap(data, layout)
cfg = [];
cfg.layout = layout;
ft_data.dimord = 'chan_time';
ft_data.label = layout.label(1:64);
ft_data.avg = data;
ft_data.time = 0;
ft_topoplotER(cfg,ft_data);
colorbar
end