% plot n1 across all trials - topomap
set_paths
% load baseline corrected ERP data
load([results_path 'all_voltage.mat'],'all_voltage_bc');
load([results_path 'trial_ind.mat'])
data_sub = all_voltage_bc{1};
load([subs(1).folder '/' subs(1).name])
mstime = dat.time{1,1}*1000;
% permute to match rest of code
data_sub = permute(data_sub, [3 1 2]);
% N1 component time
n1_range = dsearchn(mstime',[100 200]')';
% average over trials and channels to find min time
avg_data = squeeze(mean(mean(data_sub,1),2));
[n1_amp,n1_idx] = min(avg_data(n1_range(1):n1_range(2)));
n1_time = n1_idx+n1_range(1)-1;
% average for the found time within every condition
n1_manmade = mean(data_sub(trial_ind(1).man,:,n1_time),1);
n1_natural = mean(data_sub(trial_ind(1).nat,:,n1_time),1);
n1_all = mean(data_sub(:,:,n1_time),1);
%% get layout
cfg = [];
cfg.channel = 1:64;
layout = ft_prepare_layout(cfg,dat); 
%% topoplot
cfg = [];
cfg.layout = layout;
cfg.parameter = 'n1amp';
data.n1amp = n1_all';
data.freq = 1;
data.dimord = 'chan_freq';
ft_topoplotER(cfg,data);