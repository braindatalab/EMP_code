%% EMP data analysis script
% FieldTrip 
ft_defaults
%% read data
datapath = '/Users/work/Desktop/EMP/EMP_data/';
fn = 'EMP01.set';
filepath = [datapath fn];
hdr = ft_read_header(filepath);
% read events
ev = ft_read_event(filepath);
% event triggers
triggers = readtable([datapath 'TriggerTable.csv'] );
% example for getting specific event triggers
% scene_mm = triggers.trigger(strcmp(triggers.scene_category,'man-made'));
% scene_nat = triggers.trigger(strcmp(triggers.scene_category,'natural'));
%% set preprocessing parameters
% TODO: discuss parameters, examine data to decide on artifact correction
cfg = [];
cfg.datafile = filepath;
cfg.bpfilter = 'yes'; % band-pass filter
cfg.bpfreq = [1 50];
cfg.bsfilter = 'yes';
cfg.bsfreq = [48 52];
cfg.reref = 'yes';
cfg.refmethod = 'avg';
cfg.refchannel = 'all'; % common average reference
data = ft_preprocessing(cfg);
%% equal length trials just for checking!!
% cfg.length = 5;
% cfg.overlap = 0;
% data_seg_eq = ft_redefinetrial(cfg,data);
%% regress out EOG - 71, 72
eogs = [71,72];
eeg_data = data.trial{1,1}';
eog_data = data.trial{1,1}(eogs,:)';
eeg_data = eeg_data - eog_data*(eog_data\eeg_data);
data.trial{1,1} = eeg_data';
%% define trials based on triggers
cfg = [];
cfg.trialfun = 'ft_trialfun_emp';
cfg.trialdef.prestim  = 1; % prestim for baseline
cfg.trialdef.poststim = 2; %500 ms for image presentation + 1 
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = triggers.trigger;
cfg.datafile = filepath;
cfg = ft_definetrial(cfg);
% split filtered data into trials
data_seg = ft_redefinetrial(cfg,data);
%% plots for sanity checks - spectra, topoplots
% fft
figure
cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 0.5;
cfg.foilim = [1 50];
cfg.channel = 'eeg';
freq_seg=ft_freqanalysis(cfg,data_seg);
semilogy(freq_seg.freq,freq_seg.powspctrm); grid on;