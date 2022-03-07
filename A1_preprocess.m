%% EMP data analysis script
% set paths to data and output folder
set_paths
% FieldTrip
ft_defaults
% list of subjects
subj_list = dir([eegpath '*.set']);
%% read data
for i = 2:length(subj_list)
    subj = subj_list(i).name;
    filepath = [eegpath subj];
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
    %% regress out EOG - 71, 72
    eogs = [71,72];
    eeg_data = data.trial{1,1}';
    eog_data = data.trial{1,1}(eogs,:)';
    eeg_data = eeg_data - eog_data*(eog_data\eeg_data);
    data.trial{1,1} = eeg_data';
    %% reject outlying channels
    % this part detects outlying channels for each sensor type
    % (outliers: 3 scaled median deviations from the median)
    % and interpolates them using a weighted average of
    % neighbors
    chanlist = 1:length(data.label);
    all_bad_ch = [];
    for chtype = 1:size(chantypes,2)
        [interdata, bc] = detect_bad_channels(save_report, chantypes(:,chtype), data, layout.mag);
        all_bad_ch = [all_bad_ch;bc];
    end
    clearvars bc
    info.badchans = all_bad_ch;
    %% find time between events
    event_diff = diff([ev.sample]);
    %% define trials based on triggers
    cfg = [];
    cfg.trialfun = 'ft_trialfun_emp';
    cfg.trialdef.prestim  = 0.1; % prestim for baseline
    cfg.trialdef.poststim = 1.5; %500 ms image, 200 ms cross, 800 ms pad
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
        %% reject outlier trials
        all_bad_tri = [];
        for chtype = 1:size(chantypes,2)
            bt = detect_bad_trials(save_report, chantypes(:,chtype), data_seg);
            all_bad_tri = [all_bad_tri;bt];
        end
        all_bad_tri = unique(all_bad_tri);
        disp('bad trials:');
        fprintf(1, '%d \n', all_bad_tri);
        info.badtrials = all_bad_tri;
        info.prcbadtri = num2str((length(all_bad_tri)/length(data_seg.trial))*100);
        % reject trials here and select only meg channels for saving
        cfg = [];
        cfg.trials = 1:length(data_seg.trial);
        cfg.trials(all_bad_tri) = [];
        cfg.channel = 'eeg';
        data_seg = ft_selectdata(cfg,data_seg);
       %% plot again for report
        plot_data(save_report, data_seg, layout.mag,'MEG*1', 'after_rej');
       %% save
        disp(['This data is saved in ' [save_prep subj] ' under the name' subj]);
        ft_write_data([save_prep subj], data_seg, 'dataformat', 'matlab');
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
    semilogy(freq_seg.freq,freq_seg.powspctrm); grid on;
    title(subj)
    xlim([0 50])
    saveas(gcf, [plots_path subj(1:end-4) '.png'])
    % %% plot PSD
    % data = data_seg_rs;
    % nchan = size(data.label,2);
    % ntri = size(data.trial{1,1},1);
    % nsam = size(data.trial{1,1},2);
    % data = cat(3,data.trial{1,:});
    % conn = data2spwctrgc(data, 101, 0, 0, 0, [], {'CS'});
    % psd_sensor = abs(cs2psd(conn.CS));
    % freqs = linspace(1,50,102);
    % figure
    % semilogy(freqs,psd_sensor(:,1:70)); grid on;
    % title(['PSD'])
    % xlabel('Power (log)')
    % ylabel('Frequency, Hz');
    % xlim([0 45])
    ft_write_data([prep_path subj], data_seg_rs, 'dataformat','matlab')
    close all
end