% clustering
load('layout.mat')
cfg = [];
cfg.layout = layout;
cfg.method = 'triangulation';
cfg.compress = 'yes';
cfg.feedback = 'yes';
neighbors = ft_prepare_neighbors(cfg);
