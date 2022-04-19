function plot_psd(report_path_sub, data, layout, desc)
%run FFT on the data
cfg = [];
cfg.channel = 'eeg';
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.taper = 'dpss';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foilim = [1 50];
% avg of all trials, PSD
freq_seg=ft_freqanalysis(cfg,data);
spectrum = figure('visible','on');
cfg.layout = layout;
semilogy(freq_seg.freq,freq_seg.powspctrm)
grid on
xlim([0 50]);
xlabel('frequency')
ylabel('power')
topo = figure('visible','on');
% find the indices of frequencies for the delta, theta, alpha and beta
% bands
freq_bounds = {find(freq_seg.freq<4); ...
    find(freq_seg.freq>4 & freq_seg.freq<7); ...
    find(freq_seg.freq>8 & freq_seg.freq<13); ...
    find(freq_seg.freq>14 & freq_seg.freq<30)};
fnames = {'delta', 'theta', 'alpha', 'beta'};
% plot them in subplots
for nfreq = 1:length(freq_bounds)
    temp_freq = freq_seg;
    subplot(2,2,nfreq)
    cfg.figure = 'gcf';
    temp_freq.freq = temp_freq.freq(freq_bounds{nfreq});
    temp_freq.powspctrm = temp_freq.powspctrm(:,freq_bounds{nfreq});
    ft_topoplotER(cfg, temp_freq); colorbar
    title(fnames{nfreq})
end
saveas(topo,[report_path_sub '/topo_' desc '.jpg'])
saveas(spectrum,[report_path_sub '/spectrum_' desc '.jpg'])
end