% function get_tf(data)
% % this function performs time-frequency analysis of the data using
% % zero-padding and Hanning windows 
% end
% load power data
set_paths
load([results_path 'all_voltage.mat'],'all_voltage_bc')
data_sub = all_voltage_bc{1};
nchan = size(data_sub,1);
ntri = size(data_sub,3);
fs = 100;
%% add zero padding to spectrogram
clearvars p_all p_all_abs
for c = 1:1%nchan
    fprintf('channel %d\n', c)
    for t = 1:ntri
        data_tri = squeeze(data_sub(c,20:end,t));
        data_tri_zp = [zeros(59,1);data_tri';zeros(59,1)];
        [p,f,~] = spectrogram(data_tri_zp,40,20,50,100);
        p_all(c,t,:,:) = p;
    end
end
p_all_abs = abs(p_all);
t1 = squeeze(mean(p_all_abs(1,:,:,:),2));
imagesc(t1);
axis xy; xlim([2 8]); 
%% compare with ft
subs = dir([prep_path '*.mat']);
load([subs(1).folder '/' subs(1).name])
%%
cfg = [];
cfg.method = 'mtmconvol';
cfg.taper = 'hanning';
cfg.foi = 1:0.5:30;
cfg.t_ftimwin = ones(length(cfg.foi),1)*0.5;
cfg.toi = -0.2:0.05:0.8;
tf_ft = ft_freqanalysis(cfg,dat);
imagesc(squeeze(tf_ft.powspctrm(1,:,:)))