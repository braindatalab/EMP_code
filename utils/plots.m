%% plots
% this script contains plotting code for topomaps, voltage, tf and stats
% load a cell array of windowed voltage
load([results_path 'all_voltage.mat'],'all_voltage_window')
% load a cell array of time-freq data
load([results_path 'all_time_freq.mat']) 
%% Voltage topoplot
load('layout.mat')
data = all_voltage_window{1}(:,1,1); % 0 ms, trial 1
cfg = [];
cfg.layout = layout;
ft_data.dimord = 'chan_time';
ft_data.label = layout.label(1:64);
ft_data.avg = [data(1:29); NaN; data(30:end)]; %insert a NaN at the reference channel
ft_data.time = 0;
ft_topoplotER(cfg,ft_data);
colorbar
%% Voltage plot
for nsub = 1:length(trial_ind)
    c1 = trial_ind(nsub).hit;
    c2 = trial_ind(nsub).miss;
    data = all_voltage_window{nsub};
    data_all_c1(nsub,:,:) = mean(data(:,:,c1),3);
    data_all_c2(nsub,:,:) = mean(data(:,:,c2),3);
end
channel = 7;
% time windows
ms_idx = linspace(10,710,15);
% plot
figure; hold on; grid on
plot(ms_idx, squeeze(mean(data_all_c1(:,channel,:),1)));
plot(ms_idx, squeeze(mean(data_all_c2(:,channel,:),1)));
% add significant region
t1 = 210;
t2 = 310;
line([210 310],[2 2],'LineWidth',3)
legend('Hit', 'Miss', 'Significant')
title(['Grand average voltage at channel ' layout.label{channel}])
%% Time-frequency
figure
channel = 16;
for nsub = 1:length(trial_ind)
data = all_time_freq{nsub};
c1 = trial_ind(nsub).hit;
c2 = trial_ind(nsub).miss;
data_tf_c1(nsub,:,:) = squeeze(mean(data(channel,c1,:,:),2));
data_tf_c2(nsub,:,:) = squeeze(mean(data(channel,c2,:,:),2));
end
subplot(1,2,1)
imagesc(squeeze(mean(data_tf_c1,1))); axis xy
xlabel('Time, s')
ylabel('Freqs, Hz')
subplot(1,2,2)
imagesc(squeeze(mean(data_tf_c2,1))); axis xy
xlabel('Time, s')
ylabel('Freqs, Hz')
%% Log p-values
figure
imagesc(-log10(p_volt_global2)); axis xy
xlabel('Time windows')
ylabel('Channels')
colorbar