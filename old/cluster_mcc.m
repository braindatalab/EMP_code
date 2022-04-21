%% cluster-level correction 
% prepare labels of neighbors in FT
load('layout.mat')
cfg = [];
cfg.layout = layout;
cfg.method = 'triangulation';
cfg.compress = 'yes';
cfg.feedback = 'yes';
neighbors_ft = ft_prepare_neighbours(cfg);
% get neighbor structure with indices
for c = 1:length(neighbors_ft)
    neighbors{c} = find(contains(layout.label,neighbors_ft(c).neighblabel));
end
