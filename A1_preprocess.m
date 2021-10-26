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
scene_mm = triggers.trigger(strcmp(triggers.scene_category,'man-made'));
scene_nat = triggers.trigger(strcmp(triggers.scene_category,'natural'));
%% set preprocessing parameters
% TODO: discuss parameters, examine data to decide on artifact correction
cfg.dataset = datapath;
cfg.continuous = 'yes';
cfg.bpfilter = 'yes'; % band-pass filter
cfg.bpfreq = [1 50];
cfg.bsfilter = 'yes';
cfg.bsfreq = [48 52];
cfg.refchannel = 'all'; % common average reference
data = ft_preprocessing(cfg);
%% define trials based on triggers
cfg = [];
cfg.trialfun = 'ft_trialfun_emp';
cfg.trialdef.prestim  = 0;
cfg.trialdef.poststim = 0.5; %500 ms for image presentation
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = triggers.trigger;
cfg.datafile = datapath;
cfg_trl = ft_definetrial(cfg);
%% epoch filtered data
cfg.continuous = 'yes';
data_seg = ft_preprocessing(cfg_trl);
%% plots for sanity checks - spectra, topoplots
% fft
cfg = [];
cfg.channel = 'all';
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.taper = 'dpss';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foilim = [1 50];
freq_seg=ft_freqanalysis(cfg,data);
% topoplots
ft_topoplotER(cfg, freq) % power spectrum
ft_topoplotTFR(cfg, freq) % TFR
%% compute ICA?

%% EOG channels - 71, 72 