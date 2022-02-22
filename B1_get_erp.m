% plotting ERP
%% effect of scene category
cfg = [];
cfg.trials = find(data_seg_rs.trialinfo<2000); %1 in the beginning indicates manmade
manmade = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.trials = find(data_seg_rs.trialinfo>2000);
natural = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.layout = 'biosemi64.lay';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, manmade, natural)
%% difference
% cfg = [];
% cfg.operation = 'subtract';
% cfg.parameter = 'avg';
% difference = ft_math(cfg, manmade, natural);
% cfg = [];
% cfg.layout = 'biosemi64.lay';
% cfg.interactive = 'yes';
% cfg.showoutline = 'yes';
% ft_multiplotER(cfg, difference);
%% image novelty voltage
cfg = [];
trials = num2str(data_seg_rs.trialinfo);
new = find(trials(:,2)=='0');
old = find(trials(:,2)=='1');
cfg.trials = new; % new images
manmade = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.trials = old;
natural = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.layout = 'biosemi64.lay';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, manmade, natural)
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
freq_seg_old =ft_freqanalysis(cfg,data_seg_rs);
fc_chans = find(~cellfun(@isempty,regexp(freq_seg_old.label,'^FC')));
oc_chans = [find(~cellfun(@isempty,regexp(freq_seg_old.label,'^PO'))); ...
    find(~cellfun(@isempty,regexp(freq_seg_old.label,'^O')))];
% PSD plots
figure
hold on
semilogy(freq_seg_old.freq,mean(freq_seg_old.powspctrm(fc_chans,:))); grid on;
semilogy(freq_seg_new.freq,mean(freq_seg_new.powspctrm(fc_chans,:))); grid on;
legend({'old','new'})
title('Average PSD of fronto-central (FC*) channels, old vs new image')
figure
hold on
semilogy(freq_seg_old.freq,mean(freq_seg_old.powspctrm(oc_chans,:))); grid on;
semilogy(freq_seg_new.freq,mean(freq_seg_new.powspctrm(oc_chans,:))); grid on;
legend({'old','new'})
title('Average PSD of posterior (O* and PO*) channels, old vs new image')
% TFR plots
ft_singleplotTFR(cfg,freq_seg_old);
%% correct recognition voltage
cfg = [];
trials = num2str(data_seg_rs.trialinfo);
hit = find(trials(:,3)=='1'); %3rd digit indicates hit = 1, miss = 2, na = 9, corrrej = 4, false alarm = 3
miss = find(trials(:,3)=='2');
cfg.trials = hit; % new images
hit_img = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.trials = miss;
miss_img = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.layout = 'biosemi64.lay';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, hit_img, miss_img)
%% remembered vs forgotten
cfg = [];
trials = num2str(data_seg_rs.trialinfo);
rem = find(trials(:,4)=='1'); %4th digit indicates rememembered vs forgotten
forg = find(trials(:,4)=='0');
cfg.trials = hit; % new images
rem_img = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.trials = forg;
forg_img = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.layout = 'biosemi64.lay';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, rem_img, forg_img)