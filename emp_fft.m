n = cat(3,dat.trial{:});
times = linspace(-0.1,0.9,101);
for i = 1:1172
    disp(i)
    n11 = squeeze(n(1,10:end,i));
    [p,f,t] = spectrogram(n11,20,10,20,100);
    %[p,f,t] = pspectrum(n11,'spectrogram','FrequencyLimits',[1, 30]);
    p_all(i,:,:) = p;
end
p_mean = squeeze(log(mean(abs(p_all.^2),1)));
imagesc(p_mean); axis xy 
yt = get(gca,'Ytick');
frq = round(linspace(1,30,length(yt)),1);
set(gca, 'YTick',yt,'YTickLabel',frq)
xt = get(gca,'Xtick');
times1 = round(linspace(-0.1,0.9,length(xt)),2);
set(gca, 'XTick',xt,'XTickLabel',times1)
xlabel('Times, s')
ylabel('Freqs, Hz')
%% ft mtm
cfg = [];
cfg.trials = 'all';
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foi = 1:1:30; % 1 to 30 Hz
cfg.toi =-0.1:0.05:0.9;
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5; 
cfg.channel = 'all';
ft =ft_freqanalysis(cfg,dat);
imagesc(squeeze(ft.powspctrm(1,:,:))); axis xy
xt = get(gca,'Xtick');
times1 = round(linspace(-0.1,0.9,length(xt)),2);
set(gca, 'XTick',xt,'XTickLabel',times1)
xlabel('Times, s')
ylabel('Freqs, Hz')
%% ft wavelet
cfg = [];
cfg.trials = 'all';
cfg.method = 'wavelet';
cfg.output = 'pow';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foi = 1:1:30; % 1 to 30 Hz
cfg.toi =-0.1:0.05:0.9;
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5; 
cfg.channel = 'all';
ft =ft_freqanalysis(cfg,dat);
imagesc(squeeze(ft.powspctrm(1,:,:))); axis xy
xt = get(gca,'Xtick');
times1 = round(linspace(-0.1,0.9,length(xt)),2);
set(gca, 'XTick',xt,'XTickLabel',times1)
xlabel('Times, s')
ylabel('Freqs, Hz')