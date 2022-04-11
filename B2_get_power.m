%% power analysis settings
prestim = 0.1;
poststim = 1;
step=0.05;
%% image novelty power
cfg = [];
cfg.trials = new;
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foilim = [1 50];
cfg.channel = 'all';
freq_seg_new =ft_freqanalysis(cfg,data_seg_rs);
cfg = [];
cfg.trials = old;
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foilim = [1 50];
cfg.channel = 'all';
freq_seg_new =ft_freqanalysis(cfg,data_seg_rs);
fc_chans = find(~cellfun(@isempty,regexp(freq_seg_new.label,'^FC')));
oc_chans = [find(~cellfun(@isempty,regexp(freq_seg_new.label,'^PO'))); ...
    find(~cellfun(@isempty,regexp(freq_seg_new.label,'^O')))];
% PSD plots
figure
hold on
semilogy(freq_seg_new.freq,mean(freq_seg_new.powspctrm(fc_chans,:))); grid on;
semilogy(freq_seg_new.freq,mean(freq_seg_new.powspctrm(fc_chans,:))); grid on;
legend({'old','new'})
title('Average PSD of fronto-central (FC*) channels, old vs new image')
figure
hold on
semilogy(freq_seg_new.freq,mean(freq_seg_new.powspctrm(oc_chans,:))); grid on;
semilogy(freq_seg_new.freq,mean(freq_seg_new.powspctrm(oc_chans,:))); grid on;
legend({'old','new'})
title('Average PSD of posterior (O* and PO*) channels, old vs new image')
%% time-frequency power
cfg = [];
cfg.trials = new;
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foi = 1:1:30; % 1 to 30 Hz
cfg.toi =-prestim:step:poststim;
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5; 
cfg.channel = 'all';
freq_seg_new =ft_freqanalysis(cfg,data_seg_rs);
fc_chans = find(~cellfun(@isempty,regexp(freq_seg_new.label,'^FC')));
oc_chans = [find(~cellfun(@isempty,regexp(freq_seg_new.label,'^PO'))); ...
    find(~cellfun(@isempty,regexp(freq_seg_new.label,'^O')))];
%% TFR plots - one chan type
cfg = [];
cfg.channel = fc_chans;
cfg.baselinetype  = 'absolute';
cfg.baseline      = [-inf 0];
cfg.masknans = 'yes';
ft_singleplotTFR(cfg,freq_seg_new);
%% TFR plot - all chans
cfg = [];
cfg.baselinetype  = 'relchange';
cfg.baseline      = [-inf 0];
ft_multiplotTFR(cfg, freq_seg_new);
%% correct recognition
% time-frequency
cfg = [];
cfg.trials = hit;
cfg.method = 'wavelet';
cfg.output = 'pow';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foi = 1:1:30; % 1 to 30 Hz
cfg.toi =-prestim:step:poststim;
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5; 
cfg.channel = 'all';
freq_seg_hit =ft_freqanalysis(cfg,data_seg_rs);
fc_chans = find(~cellfun(@isempty,regexp(freq_seg_hit.label,'^FC')));
oc_chans = [find(~cellfun(@isempty,regexp(freq_seg_hit.label,'^PO'))); ...
    find(~cellfun(@isempty,regexp(freq_seg_hit.label,'^O')))];
%% TFR plots - one chan type
cfg = [];
cfg.channel = 'all';
cfg.baselinetype  = 'absolute';
cfg.baseline      = [-prestim 0];
cfg.masknans = 'yes';
ft_singleplotTFR(cfg,freq_seg_hit);
%% TFR plot - all chans
cfg = [];
cfg.channels = 'eeg';
cfg.baselinetype  = 'absolute';
cfg.baseline      = [-prestim 0];
ft_multiplotTFR(cfg, freq_seg_miss);
%% difference
cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = '(x1-x2)/(x1+x2)';
diff = ft_math(cfg, freq_seg_hit, freq_seg_miss);
ft_multiplotTFR(cfg, diff);
%% correct recognition
% time-frequency
cfg = [];
cfg.trials = forg;
cfg.method = 'wavelet';
cfg.output = 'pow';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foi = 1:1:30; % 1 to 30 Hz
cfg.toi =-prestim:step:poststim;
cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5; 
cfg.channel = 'all';
freq_seg_forg =ft_freqanalysis(cfg,data_seg_rs);
fc_chans = find(~cellfun(@isempty,regexp(freq_seg_forg.label,'^FC')));
oc_chans = [find(~cellfun(@isempty,regexp(freq_seg_forg.label,'^PO'))); ...
    find(~cellfun(@isempty,regexp(freq_seg_forg.label,'^O')))];
%% TFR plots - one chan type
cfg = [];
cfg.channel = 'all';
cfg.baselinetype  = 'absolute';
cfg.baseline      = [-prestim 0];
cfg.masknans = 'yes';
ft_singleplotTFR(cfg,freq_seg_forg);