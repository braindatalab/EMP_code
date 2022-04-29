%% plots
% this script contains plotting code for topomaps, voltage, tf and stats
% load a cell array of windowed voltage
load([results_path 'all_voltage.mat'],'all_voltage_window')
% load a cell array of time-freq data
load([results_path 'all_time_freq.mat']) 
%% Voltage topoplot - average / p-value
load('layout.mat')
for i = 1:length(trial_ind)
    c1 = trial_ind(i).manmade;
    c2 = trial_ind(i).natural;
    data_c1 = mean(all_voltage_window{i}(:,3,c1),3); % 110-210 ms
    data_c2 = mean(all_voltage_window{i}(:,3,c2),3);
end
% p-value
data = -log10(p_n1_global);
cfg = [];
cfg.layout = layout;
cfg.marker = 'labels';
ft_data.dimord = 'chan_time';
ft_data.label = layout.label(1:64);
ft_data.avg = [data(1:29); NaN; data(30:end)]; %insert a NaN at the reference channel
ft_data.time = 0;
ft_topoplotER(cfg,ft_data);
colorbar
%% Voltage plot
for nsub = 1:length(trial_ind)
    c1 = trial_ind(nsub).rem;
    c2 = trial_ind(nsub).forg;
    data = all_voltage_window{nsub};
    data_all_c1(nsub,:,:) = mean(data(:,:,c1),3);
    data_all_c2(nsub,:,:) = mean(data(:,:,c2),3);
end
channel = 50;
% time windows
ms_idx = linspace(10,710,15);
% plot
figure; hold on; grid on
plot(ms_idx, squeeze(mean(data_all_c1(:,channel,:),1)));
plot(ms_idx, squeeze(mean(data_all_c2(:,channel,:),1)));
% add significant region
t1 = 360;
t2 = 460;
ll = -5; % lower limit
ul = 3; % upper limit
patch([t1 t2 t2 t1],[ll ll ul ul],'k','FaceAlpha',0.3, 'EdgeAlpha',0)
legend('Remembered', 'Forgotten', 'Most significant')
title(['Grand average voltage at channel ' labels{channel}])
saveas(gcf,[sp 'h4_volt.png'])
%% Time-frequency
figure
channel = 16;
c1_name = 'Hit';
c2_name = 'Miss';
for nsub = 1:length(trial_ind)
data = log(all_time_freq{nsub});
c1 = trial_ind(nsub).hit;
c2 = trial_ind(nsub).miss;
data_tf_c1(nsub,:,:) = squeeze(mean(data(channel,c1,:,:),2));
data_tf_c2(nsub,:,:) = squeeze(mean(data(channel,c2,:,:),2));
end
subplot(1,3,1)
data1 = squeeze(mean(data_tf_c1,1));
imagesc(data1); axis xy
% set axes
xticklabels = ms_idx(1:2:end);
xticks = linspace(1, size(data1,2), length(xticklabels));
set(gca, 'xtick', xticks, 'xticklabel', xticklabels);
yticklabels = linspace(0,50,26);
yticks = linspace(1, size(data1,1), length(yticklabels));
set(gca, 'ytick', yticks, 'yticklabel', yticklabels);
xlabel('Time, ms')
ylabel('Freqs, Hz')
title(c1_name)
% set clim
caxis([min(data1,[],'all') max(data1,[],'all')])
colorbar
subplot(1,3,2)
data2 = squeeze(mean(data_tf_c2,1));
imagesc(data2); axis xy
title(c2_name)
% set axes
xticklabels = ms_idx(1:2:end);
xticks = linspace(1, size(data2,2), length(xticklabels));
set(gca, 'xtick', xticks, 'xticklabel', xticklabels);
yticklabels = linspace(0,50,26);
yticks = linspace(1, size(data2,1), length(yticklabels));
set(gca, 'ytick', yticks, 'yticklabel', yticklabels);
xlabel('Time, ms')
% set clim
caxis([min(data1,[],'all') max(data1,[],'all')])
colorbar
% plot difference
subplot(1,3,3)
imagesc(data1-data2); axis xy
title([c1_name ' - ' c2_name])
xticklabels = ms_idx(1:2:end);
xticks = linspace(1, size(data2,2), length(xticklabels));
set(gca, 'xtick', xticks, 'xticklabel', xticklabels);
yticklabels = linspace(0,50,26);
yticks = linspace(1, size(data2,1), length(yticklabels));
set(gca, 'ytick', yticks, 'yticklabel', yticklabels);
xlabel('Time, ms')
colorbar
sgtitle(['Grand average log(power) between hit and miss at channel' labels{channel}])
saveas(gcf,[sp 'h3_pow.png'])
%% Log p-values
figure
imagesc(-log10(p_volt_global2)); axis xy
xlabel('Time windows')
ylabel('Channels')
colorbar
