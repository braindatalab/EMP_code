%% compute ERP
prep_list = dir([prep_path 'EMP*']);
%% read data
for i = 1:length(prep_list)
disp(i)
load([prep_path prep_list(i).name])
% get trials
[trial_ind(i).man,trial_ind(i).nat,trial_ind(i).old,trial_ind(i).new,trial_ind(i).hit,trial_ind(i).miss,trial_ind(i).rem,trial_ind(i).forg] = find_trials(dat.trialinfo);
% generate array
data = cat(3,dat.trial{1,:});
data(65:66,:,:) = []; % removing mastoid channels
all_voltage{i} = data;
%% compute TFR
% cfg = [];
% cfg.trials = 'all';
% cfg.method = 'mtmconvol';
% cfg.output = 'pow';
% cfg.pad = 'nextpow2'; % improves speed
% cfg.tapsmofrq = 2;
% cfg.foi = 1:1:30; % 1 to 30 Hz
% cfg.toi = 1:1:100;
% cfg.t_ftimwin = ones(length(cfg.foi),1).*0.5; 
% cfg.channel = 'all';
% fft_res =ft_freqanalysis(cfg,data_seg_rs);
% all_tfr(i,:,:,:) = fft_res.powspctrm;
end
save('/home/space/uniml/veronika/results/EMP/all_voltage.mat','all_voltage')
save('/home/space/uniml/veronika/results/EMP/trial_ind.mat','trial_ind')