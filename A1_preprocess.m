%% EMP data analysis script
% FieldTrip 
ft_defaults
%% read data
datapath = '../EMP_data/EMP01.set';
hdr = ft_read_header('../EMP_data/EMP01.set');
% read events
ev = ft_read_event('../EMP_data/EMP01.set');
% event triggers
triggers = readtable('../EMP_data/TriggerTable.csv');
% example for getting specific event triggers
% scene_mm = triggers.trigger(strcmp(triggers.scene_category,'man-made'));
% scene_nat = triggers.trigger(strcmp(triggers.scene_category,'natural'));
%% set preprocessing parameters
% TODO: discuss parameters, examine data to decide on artifact correction
cfg.datafile = datapath;
cfg.bpfilter = 'yes'; % band-pass filter
cfg.bpfreq = [1 50];
cfg.bsfilter = 'yes';
cfg.bsfreq = [48 52];
cfg.refchannel = 'all'; % common average reference
data = ft_preprocessing(cfg);
%% equal length trials just for checking!!
% epoch filtered data
cfg.length = 5;
cfg.overlap = 0;
data_seg_eq = ft_redefinetrial(cfg,data);
%% define trials based on triggers
cfg = [];
cfg.trialfun = 'ft_trialfun_emp';
cfg.trialdef.prestim  = 1; % prestim for baseline
cfg.trialdef.poststim = 1.5; %500 ms for image presentation + 1 
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = triggers.trigger;
cfg.datafile = datapath;
cfg_trl = ft_definetrial(cfg);
% epoch filtered data
cfg.continuous = 'yes';
data_seg = ft_preprocessing(cfg_trl);
%% plots for sanity checks - spectra, topoplots
% fft
cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.taper = 'dpss';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foilim = [1 50];
freq_seg=ft_freqanalysis(cfg,data_seg);
% topoplots
ft_topoplotER(cfg, freq_seg) % topo
figure
plot(freq_seg.freq, freq_seg.powspctrm) % power spectrum
%% compute ICA?

%% EOG channels - 71, 72 