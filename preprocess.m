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
%% define trials based on triggers
% TODO: fix trial function
cfg = [];
cfg.trialfun = 'ft_trialfun_emp';
cfg.trialdef.prestim  = 0;
cfg.trialdef.poststim = 0;
cfg.datafile = '../EMP_data/EMP01.set';
cfg = ft_definetrial(cfg);
%% set preprocessing parameters
% TODO: discuss parameters, examine data to decide on artifact correction
cfg.dataset = datapath;
cfg.bpfilter = 'yes'; % band-pass filter
cfg.bpfreq = [1 45];
cfg.bsfilter = 'yes';
cfg.bsfreq = [48 52];
cfg.refchannel = 'all'; % common average reference
data = ft_preprocessing(cfg);
%% plots for sanity checks - spectra, topoplots
% FFT
cfg.method = 'mtmfft';
cfg.foi = 1:0.5:45; % frequency resolution - find length of trials
freq_data = ft_freqanalysis(cfg, data);
% topoplots
ft_topoplotER(cfg, freq) % power spectrum
ft_topoplotTFR(cfg, freq) % TFR
