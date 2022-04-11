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
cfg.channels = 'eeg';
manmade = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.trials = old;
cfg.channels = 'eeg';
natural = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.layout = 'biosemi64.lay';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, manmade, natural)
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
cfg.trials = rem; % new images
rem_img = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.trials = forg;
forg_img = ft_timelockanalysis(cfg, data_seg_rs);
cfg = [];
cfg.layout = 'biosemi64.lay';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
ft_multiplotER(cfg, rem_img, forg_img)