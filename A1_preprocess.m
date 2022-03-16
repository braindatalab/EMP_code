%% EMP data analysis script
% set paths to data and output folder
set_paths
% FieldTrip
ft_defaults
% list of subjects
subj_list = dir([eegpath '*.set']);
%% read data
for i = 1:1%length(subj_list)
    tic
    clear info
    subj = subj_list(i).name;
    sub_report_path = [report_path subj(1:end-4) '/']; 
    filepath = [eegpath subj];
    hdr = ft_read_header(filepath);
    % read events
    ev = ft_read_event(filepath);
    % event triggers
    triggers = readtable([datapath 'TriggerTable.csv'] );
    % example for getting specific event triggers
    % scene_mm = triggers.trigger(strcmp(triggers.scene_category,'man-made'));
    % scene_nat = triggers.trigger(strcmp(triggers.scene_category,'natural'));
    info.subject_id = subj;
    %% set preprocessing parameters
    % TODO: discuss parameters, examine data to decide on artifact correction
    cfg = [];
    cfg.datafile = filepath;
    cfg.bpfilter = 'yes'; % band-pass filter
    cfg.bpfreq = [1 50];
    info.freq = cfg.bpfreq;
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [48 52];
    info.bsfreq = cfg.bsfreq;
    data = ft_preprocessing(cfg);
    info.orig_sf = data.fsample;
    info.nchan = length(data.label);
    info.minutes = (size(data.time{1,1},2))/data.fsample/60;
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
    layout = ft_prepare_layout(cfg,data);
    chanlist = 1:length(data.label);
    all_bad_ch = [];
    [interdata, bc] = detect_bad_channels(sub_report_path,chanlist, data, layout);
    all_bad_ch = [all_bad_ch;bc];
    info.badch = all_bad_ch;
    clearvars bc
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
    info.rsfs = cfg.resamplefs;
    %% reject outlier trials
    all_bad_tri = [];
    bt = detect_bad_trials(sub_report_path, data_seg_rs);
    all_bad_tri = [all_bad_tri;bt];
    all_bad_tri = unique(all_bad_tri);
    disp('bad trials:');
    fprintf(1, '%d \n', all_bad_tri);
    % reject trials here and select only meg channels for saving
    cfg = [];
    cfg.trials = 1:length(data_seg_rs.trial);
    cfg.trials(all_bad_tri) = [];
    cfg.channel = 'eeg';
    data_seg_rs = ft_selectdata(cfg,data_seg_rs);
    info.badtri = all_bad_tri;
    %% plot
    plot_data(sub_report_path, data_seg_rs, layout, 'after')
    %% finish and save report
    timer = toc;
    info.time = timer;
    ft_write_data([prep_path subj], data_seg_rs, 'dataformat','matlab')
    save([sub_report_path 'info.mat'],'info');
    preproc_report(info,sub_report_path);
    % convert tex to pdf
    command = ['cd ', sub_report_path,'; ', 'yes " " | /usr/bin/pdflatex  ',...
        'report.tex;'];
    system(command);
    close all
end