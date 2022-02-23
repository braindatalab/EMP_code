%% EMP data analysis script
% set paths to data and output folder
set_paths
% FieldTrip 
ft_defaults
%% read data
fn = 'EMP01.set';
filepath = [eegpath fn];
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
data = ft_preprocessing(cfg);
%% equal length trials for running pre-prep FFT
% cfg.length = 5;
% cfg.overlap = 0;
% data_seg_eq = ft_redefinetrial(cfg,data);
% % downsample
% cfg = [];
% cfg.resamplefs = 100;
% data_seg_eq_rs = ft_resampledata(cfg, data_seg_eq);
% % fft
% cfg = [];
% cfg.method = 'mtmfft';
% cfg.output = 'pow';
% cfg.pad = 'nextpow2'; % improves speed
% cfg.tapsmofrq = 2;
% cfg.foilim = [1 50];
% cfg.channel = 'eeg';
% freq_seg=ft_freqanalysis(cfg,data_seg_eq_rs);
% figure
% semilogy(freq_seg.freq,freq_seg.powspctrm); grid on;
% sgtitle('Fieldtrip FFT');
% xlim([0 50])
%% regress out EOG - 71, 72
eogs = [71,72];
eeg_data = data.trial{1,1}';
eog_data = data.trial{1,1}(eogs,:)';
eeg_data = eeg_data - eog_data*(eog_data\eeg_data);
data.trial{1,1} = eeg_data';
%% find time between events
event_diff = diff([ev.sample]);
%% define trials based on triggers
cfg = [];
cfg.trialfun = 'ft_trialfun_emp';
cfg.trialdef.prestim  = 0.5; % prestim for baseline
cfg.trialdef.poststim = 1.2; %500 ms image, 200 ms cross, 500 ms pad
cfg.trialdef.eventtype = 'trigger';
cfg.trialdef.eventvalue = triggers.trigger;
cfg.datafile = filepath;
cfg = ft_definetrial(cfg);
% split filtered data into trials
data_seg = ft_redefinetrial(cfg,data);
%% downsample
cfg = [];
cfg.resamplefs = 100;
data_seg_rs = ft_resampledata(cfg, data_seg);
%% ICA
cfg            = [];
cfg.method     = 'fastica';
comp           = ft_componentanalysis(cfg, data_seg_rs);
% plot ICA components
cfg           = [];
cfg.component = 1:20; 
cfg.layout    = 'biosemi64.lay'; 
cfg.comment   = 'no';
ft_topoplotIC(cfg, comp)
%% vis art rej
cfg          = [];
cfg.method   = 'summary';
tr        = ft_rejectvisual(cfg,data_seg_rs);
%% apply common average reference
cfg.reref = 'yes';
cfg.refmethod = 'avg';
cfg.refchannel = 'all'; % common average reference
data_seg_rs_avg = ft_preprocessing(cfg,data_seg_rs);
%% plots for sanity checks - spectra, topoplots
% fft
cfg = [];
cfg.method = 'mtmfft';
cfg.output = 'pow';
cfg.pad = 'nextpow2'; % improves speed
cfg.tapsmofrq = 2;
cfg.foilim = [1 50];
cfg.channel = 'eeg';
freq_seg=ft_freqanalysis(cfg,data_seg_rs);
figure
subplot(1,2,1)
plot(freq_seg.freq,freq_seg.powspctrm); grid on;
title('Linear y-axis')
subplot(1,2,2)
semilogy(freq_seg.freq,freq_seg.powspctrm); grid on;
title('Log y-axis')
sgtitle('Fieldtrip FFT');
xlim([0 50])
%% plot PSD
data = data_seg_rs;
nchan = size(data.label,2);
ntri = size(data.trial{1,1},1); 
nsam = size(data.trial{1,1},2);
data = cat(3,data.trial{1,:});
conn = data2spwctrgc(data, 101, 0, 0, 0, [], {'CS'});
psd_sensor = abs(cs2psd(conn.CS));
freqs = linspace(1,50,102);
figure
semilogy(freqs,psd_sensor(:,1:70)); grid on;
title(['PSD'])
xlabel('Power (log)')
ylabel('Frequency, Hz');
xlim([0 45])