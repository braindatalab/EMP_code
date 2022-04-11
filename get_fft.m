%% ft fft
cfg = [];
cfg.trials = 'all';
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foi = 1:1:30; % 1 to 30 Hz
cfg.toi =-0.1:0.1:0.9;
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5; 
cfg.channel = 'eeg';
ft =ft_freqanalysis(cfg,dat);
cfg = [];
cfg.channel = 'eeg';
cfg.baselinetype  = 'absolute';
cfg.baseline      = [-inf 0];
cfg.masknans = 'yes';
ft_singleplotTFR(cfg,ft);
%% matlab fft 

% get time freq
v1 = squeeze(all_voltage{1}(1,:,1));
tf1 = pspectrum();
