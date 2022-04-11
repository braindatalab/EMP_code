%% get voltage and time-frequency data
set_paths
prep_list = dir([prep_path 'EMP*']);
%% read data
for i = 1:length(prep_list)
    tic
    disp(['subject ' prep_list(i).name(1:end-4)])
    load([prep_path prep_list(i).name])
    %% get trials
    disp('getting trial indices')
    [trial_ind(i).man,trial_ind(i).nat,trial_ind(i).old,trial_ind(i).new,trial_ind(i).hit,trial_ind(i).miss,trial_ind(i).rem,trial_ind(i).forg] = find_trials(dat.trialinfo);
    %% get voltage from preprocessed data
    disp('getting voltage..')
    data = cat(3,dat.trial{1,:});
    ntri = size(data,3);
    data(65:66,:,:) = []; % removing mastoid channels
    nchan = size(data,1);
    all_voltage{i} = data;
    % remove baseline from voltage
    baseline = mean(data(:,1:20,:),2); % mean of 200 ms before stimulus
    data_bc = bsxfun(@minus,data,baseline);
    all_voltage_bc{i} = data_bc;
    %% compute time-frequency
    fprintf('\ncomputing time-frequency for %d channels, %d trials\n',nchan, ntri)
    for c = 1:nchan
        fprintf('channel %d\n', c)
        for t = 1:ntri
            data_i = squeeze(data(c,20:end,t));
            [p,f,~] = spectrogram(data_i,20,10,20,100);
            p_all(c,t,:,:) = p;
        end
    end
    p_all_abs = abs(p_all);
    all_time_freq{i} = p_all_abs;
    %imagesc(squeeze(p_all_abs(1,1,:,:))); axis xy
    % all_ch = squeeze(mean(p_all_abs,1));
    % imagesc(squeeze(mean(all_ch(trial_ind.miss,:,:),1))); axis xy
    % yt = get(gca,'Ytick');
    % frq = round(linspace(0,50,length(yt)),1);
    % set(gca, 'YTick',yt,'YTickLabel',frq)
    % xt = get(gca,'Xtick');
    % times1 = round(linspace(-0.2,0.8,length(xt)),2);
    % set(gca, 'XTick',xt,'XTickLabel',times1)
    % xlabel('Times, s')
    % ylabel('Freqs, Hz')
    % title('Pspectrum output for subject 1, miss trials, avg of all channels')
    % colorbar
    toc
end
save('/home/space/uniml/veronika/results/EMP/all_voltage.mat','all_voltage','all_voltage_bc')
save('/home/space/uniml/veronika/results/EMP/all_timefreq.mat','all_time_freq')
save('/home/space/uniml/veronika/results/EMP/trial_ind.mat','trial_ind')