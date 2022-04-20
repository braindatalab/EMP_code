% function get_tf(data)
% % this function performs time-frequency analysis of the data using
% % zero-padding and Hanning windows 
% end
% load power data
set_paths
load([results_path 'all_voltage.mat'],'all_voltage_bc')
fs = 100;
%% add zero padding to spectrogram
clearvars p_all p_all_abs
for i = 1:length(all_voltage_bc)
    fprintf('subject %d\n',i)
    data_sub = all_voltage_bc{i};
    nchan = size(data_sub,1);
    ntri = size(data_sub,3);
    for c = 1:nchan
        fprintf('channel %d\n', c)
        for t = 1:ntri
            data_tri = squeeze(data_sub(c,20:end,t));
            % 100 ms windows, 50 ms overlap
            [p,f,time] = spectrogram(data_tri,10,5,50,fs);
            p_all(c,t,:,:) = p;
        end
    end
    all_time_freq_new{i} = abs(p_all).^2;
end
save([results_path '/all_time_freq_new.mat'],'all_time_freq_new','f')
%% plot 1 subject 1 trial
c1 = squeeze(all_time_freq_new{1}(1,:,:,:));
t1 = squeeze(mean(c1,1));
imagesc(t1);
axis xy;
%% compare with ft
subs = dir([prep_path '*.mat']);
load([subs(1).folder '/' subs(1).name])
%%
cfg = [];
cfg.method = 'mtmconvol';
cfg.taper = 'hanning';
cfg.foi = 1:1:30;
cfg.t_ftimwin = ones(length(cfg.foi),1)*0.5;
cfg.toi = -0.2:0.05:0.8;
tf_ft = ft_freqanalysis(cfg,dat);
imagesc(squeeze(tf_ft.powspctrm(1,:,:)))