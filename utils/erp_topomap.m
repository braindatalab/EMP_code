% plot n1 across all trials - topomap
set_paths
subs = dir([prep_path '*.mat']);
load([subs(1).folder '/' subs(1).name]);

cfg = [];
layout = ft_prepare_layout(cfg,dat);  
all_n1 = mean(data_sub(:,:,n1_time));