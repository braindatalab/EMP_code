set_paths
% load trial indices
load([results_path 'trial_ind.mat'])
% load baseline corrected ERP data
load([results_path 'all_voltage.mat'],'all_voltage_bc')
% load power data
load([results_path 'all_timefreq.mat'])
subs = dir([prep_path '*.mat']);
% load sample times from 1 subject
load([subs(1).folder '/' subs(1).name])
mstime = dat.time{1,1}*1000;
fsample = dat.fsample;
num_channels = 64;
alpha = 0.05;
%% Hypothesis 1
% N1 between man-made and natural images
for i=1:size(subs,1)
    disp(subs(i).name(1:end-4))
    data_sub = all_voltage_bc{i};
    % permute to match rest of code
    data_sub = permute(data_sub, [3 1 2]);
    % N1 component time
    n1_range = dsearchn(mstime',[100 200]')';
    % average over trials and channels to find min time
    avg_data = squeeze(mean(mean(data_sub,1),2));
    [n1_amp,n1_idx] = min(avg_data(n1_range(1):n1_range(2)));
    n1_time = n1_idx+n1_range(1)-1;
    % average for the found time within every condition
    n1_manmade = data_sub(trial_ind(i).man,:,n1_time);
    n1_natural = data_sub(trial_ind(i).nat,:,n1_time);
    
    % effect of N1 (mean and var) 
    % mean difference
    ds(i,:) = mean(n1_manmade,1) - mean(n1_natural,1);  
    % variance 
    v_1 = var(n1_manmade,0,1);  
    v_2 = var(n1_natural,0,1); 
    vars(i, :) = v_1 ./ size(n1_manmade,1) + v_2 ./ size(n1_natural,1); 
end
% Group analysis - equal weighting of mean difference 
for ic = 1:num_channels
    [p_FE, p_RE] = equal_weighting(ds(:,ic), vars(:,ic));
    pval_eqweight_re(ic) = p_RE; 
end
pval_eqweight_re = pval_eqweight_re';
sig_pval_randeff_eqweight = pval_eqweight_re;
sig_pval_randeff_eqweight(sig_pval_randeff_eqweight > (alpha)) = NaN;

% FDR across channels
p = mafdr(pval_eqweight_re,'BHFDR',true);
p(p > (alpha)) = NaN;
%% Hypothesis 2
% EEG voltage at fronto-central channels 
% alpha at fronto-central channels
% theta at posterior
% get channel indices
fc_chans = find(~cellfun(@isempty,regexp(dat.label,'^FC')));
post_chans = [find(~cellfun(@isempty,regexp(dat.label,'^PO'))); ...
    find(~cellfun(@isempty,regexp(dat.label,'^O')))];
% frequencies from spectrogram
freqs = linspace(0,50,11);
% time range
time_range = [300 500];
rtime = dsearchn(mstime',time_range')';
for i = size(subs,1)
    data_sub = all_voltage_bc{i};
    % permute to match rest of code
    data_sub = permute(data_sub, [3 1 2]);
    % extracting the indexes in times array in the time_range [300 500]
    erptime = dsearchn(mstime',time_range')'; 
    % ERP data between [300;500] at FC channels
    % 
    erp_old = data_sub(trial_ind(i).old,fc_chans,erptime(1):erptime(2));
    erp_new = data_sub(trial_ind(i).new,fc_chans,erptime(1):erptime(2));  
    % get alpha power at FC channels and theta at posterior
    data_sub_power = all_time_freq{i};
    alpha_pow_old = data_sub_power(fc_chans,trial_ind(i).old,freqs>8&freqs<13)';
    alpha_pow_new = data_sub_power(fc_chans,trial_ind(i).new,freqs>8&freqs<13)';
    theta_pow_old = data_sub_power(post_chans,trial_ind(i).old,freqs>4&freqs<7)';
    theta_pow_new = data_sub_power(post_chans,trial_ind(i).new,freqs>4&freqs<7)';
    
    % Effect sizes calculation (mean and var)
    % ERP
    erp_ds(i,:,:) = mean(erp_new,1) - mean(erp_old,1);  
    v_new = var(erp_new,0,1);  
    v_old = var(erp_old,0,1); 
    erp_vars(i, :,:) = v_new ./ size(erp_new,1)  + v_old ./ size(erp_old,1); 
    
    % theta
    theta_ds(i,:) = mean(theta_pow_new,1) - mean(theta_pow_old,1);  % mean difference of both classes per subject
    v_new = var(theta_pow_new,0,1);  
    v_old = var(theta_pow_old,0,1);  
    theta_vars(i, :) = v_new ./ size(theta_pow_new,1)  + v_old ./ size(theta_pow_old,1); 

    %Alpha
    alpha_ds(i,:) = mean(alpha_pow_new,1) - mean(alpha_pow_old,1);  % mean difference of both classes per subject
    v_new = var(alpha_pow_new,0,1);  
    v_old = var(alpha_pow_old,0,1);  
    alpha_vars(i, :) = v_new ./ size(alpha_pow_new,1)  + v_old ./ size(alpha_pow_old,1); 

end

% Group analysis - equal weighting of mean difference
% Power 
for ic = 1:num_channels
    [p_FE, p_RE] = equal_weighting(theta_ds(:,ic), theta_vars(:,ic)); % theta
    ps_meanDiff_equal_RE_theta(ic) = p_RE; % theta
    
    [p_FE, p_RE] = equal_weighting(alpha_ds(:,ic), alpha_vars(:,ic)); % alpha
    ps_meanDiff_equal_RE_alpha(ic) = p_RE; % alpha
end

ps_meanDiff_equal_RE_theta = ps_meanDiff_equal_RE_theta';
sig_ps_meanDiff_equal_RE_theta = ps_meanDiff_equal_RE_theta; % 
sig_ps_meanDiff_equal_RE_theta(sig_ps_meanDiff_equal_RE_theta > (alpha)) = 0; % sig_ps_meanDiff_equal_RE_theta contains p values without correction

ps_meanDiff_equal_RE_alpha = ps_meanDiff_equal_RE_alpha';
sig_ps_meanDiff_equal_RE_alpha = ps_meanDiff_equal_RE_alpha;
sig_ps_meanDiff_equal_RE_alpha(sig_ps_meanDiff_equal_RE_alpha > (alpha)) = 0; % sig_ps_meanDiff_equal_RE_alpha contains p values without correction

% FDR across channels
p_size = size(ps_meanDiff_equal_RE_theta);
p_theta = mafdr(ps_meanDiff_equal_RE_theta,'BHFDR',true);
p_theta = reshape(double(py.array.array('d', p_theta)), [p_size]);
p_theta(p_theta > (alpha)) = 0; % p_theta contains FDR corrected p values

p_size = size(ps_meanDiff_equal_RE_alpha);
p_alpha = mafdr(ps_meanDiff_equal_RE_alpha,'BHFDR',true);
p_alpha = reshape(double(py.array.array('d', p_alpha)), [p_size]);
p_alpha(p_alpha > (alpha)) = 0; % p_alpha contains FDR corrected p values

% Group analysis Equal weighting of mean difference  ERP
for ic = 1:size(erp_ds,2) % loop over channels
    for it = 1:size(erp_ds,3) % loop over timepoints
        [p_FE, p_RE] = equal_weighting(erp_ds(:,ic, it), erp_vars(:,ic, it)); 
        ps_meanDiff_equal_RE_erp(ic,it) = p_RE; 
    end
end
ps_meanDiff_equal_RE_erp = ps_meanDiff_equal_RE_erp';
sig_ps_meanDiff_equal_RE_erp = ps_meanDiff_equal_RE_erp;
sig_ps_meanDiff_equal_RE_erp(sig_ps_meanDiff_equal_RE_erp > (alpha)) = 0;

% FDR across timepoints of respective channels, no FDR across channels
for ic = 1:size(erp_ds,2)
    p_size = size(squeeze(ps_meanDiff_equal_RE_erp(:,ic,:)));
    tmp = mafdr(squeeze(ps_meanDiff_equal_RE_erp(:,ic,:)),'BHFDR',true);
    tmp = reshape(double(py.array.array('d', tmp)), [p_size])';
    tmp(tmp > (alpha)) = 0;
    p_erp(ic,:) = tmp';
end
p_erp = p_erp';

%% Hypothesis 3

for i=offset:size(subs,1)

    data_hit = data_sub(find(tt==1),:,:);
    data_miss = data_sub(find(tt==2),:,:); 
   
    % Power calculation
    data_pow_hit = permute(data_hit, [3, 1, 2]);
    data_pow_hit_size = size(data_pow_hit);
    data_pow_hit = data_pow_hit(:,:);
    [p,f] = pspectrum(data_pow_hit, fsample);
    data_pow_hit = reshape(p,[length(f), data_pow_hit_size(2), data_pow_hit_size(3)]); % num freq x num trials x num channels    
    data_pow_hit = permute(data_pow_hit, [2, 3, 1]);

    data_pow_miss = permute(data_miss, [3, 1, 2]);
    data_pow_miss_size = size(data_pow_miss);
    data_pow_miss = data_pow_miss(:,:);
    [p,f] = pspectrum(data_pow_miss, fsample);
    data_pow_miss = reshape(p,[length(f), data_pow_miss_size(2), data_pow_miss_size(3)]); % num freq x num trials x num channels    
    data_pow_miss = permute(data_pow_miss, [2, 3, 1]);
    
    % Effect sizes calculation (mean and var) between old and new pics using
    % the conditional mean difference
    
    % ERP
    erp_ds(i-offset+1,:,:) = mean(data_hit,1) - mean(data_miss,1);  % mean difference of both classes per subject
    v_hit = var(data_hit,0,1);  v_miss = var(data_miss,0,1);  % variances of both classes per subject
    erp_vars(i-offset+1, :,:) = squeeze(v_hit) ./ size(data_hit,1)  + squeeze(v_miss) ./ size(data_miss,1); 
    
    % Power
    pow_ds(i-offset+1,:,:) = squeeze(mean(data_pow_hit,1)) - squeeze(mean(data_pow_miss,1));  % mean difference of both classes per subject
    v_hit = var(data_pow_hit,0,1);  v_miss = var(data_pow_miss,0,1);  % variances of both classes per subject
    pow_vars(i-offset+1, :,:) = v_hit ./ size(data_pow_hit,1)  + v_miss ./ size(data_pow_miss,1); 
end

% Group analysis Equal weighting of mean difference
clearvars 'ps_meanDiff_equal_RE_pow' 'ps_meanDiff_equal_RE_erp' 'sig_ps_meanDiff_equal_RE_pow' 'sig_ps_meanDiff_equal_RE_erp' 'p_pow' 'p_erp'

% Group analysis Equal weighting of mean difference  ERP
for ic = 1:size(erp_ds,2) % loop over channels
    for it = 1:size(erp_ds,3) % loop over timepoints
        [p_FE, p_RE] = equal_weighting(erp_ds(:,ic, it), erp_vars(:,ic, it)); 
        ps_meanDiff_equal_RE_erp(ic,it) = p_RE; 
    end
end
ps_meanDiff_equal_RE_erp = ps_meanDiff_equal_RE_erp';
sig_ps_meanDiff_equal_RE_erp = ps_meanDiff_equal_RE_erp;
sig_ps_meanDiff_equal_RE_erp(sig_ps_meanDiff_equal_RE_erp > (alpha)) = 0;

% FDR across timepoints of respective channels, no FDR across channels
for ic = 1:size(erp_ds,2)
    p_size = size(squeeze(ps_meanDiff_equal_RE_erp(:,ic,:)));
    tmp = mafdr(squeeze(ps_meanDiff_equal_RE_erp(:,ic,:)),'BHFDR',true);
    tmp = reshape(double(py.array.array('d', tmp)), [p_size])';
    tmp(tmp > (alpha)) = 0;
    p_erp(ic,:) = tmp';
end
p_erp = p_erp'; % num timepoints x num channels

% Group analysis Equal weighting of mean difference  Power
for ic = 1:size(pow_ds,2) % loop over channels
    for it = 1:size(pow_ds,3) % loop over frequencies
        [p_FE, p_RE] = equal_weighting(pow_ds(:,ic, it), pow_vars(:,ic, it)); 
        ps_meanDiff_equal_RE_pow(ic,it) = p_RE; 
    end
end
ps_meanDiff_equal_RE_pow = ps_meanDiff_equal_RE_pow';
sig_ps_meanDiff_equal_RE_pow = ps_meanDiff_equal_RE_pow;
sig_ps_meanDiff_equal_RE_pow(sig_ps_meanDiff_equal_RE_pow > (alpha)) = 0;

% FDR across Frequencies of respective channels, no FDR across channels
for ic = 1:size(pow_ds,2)
    p_size = size(squeeze(ps_meanDiff_equal_RE_pow(:,ic,:)));
    tmp = mafdr(squeeze(ps_meanDiff_equal_RE_pow(:,ic,:)),'BHFDR',true);
    tmp = reshape(double(py.array.array('d', tmp)), [p_size])';
    tmp(tmp > (alpha)) = 0;
    p_pow(ic,:) = tmp';
end
p_pow = p_pow'; % num freqs x num channels

% Next step: permutation based multiple test correction could be implemented

%% Hypothesis 4
t = num_analysis(4); %The select the integer from the event code

clearvars 'erp_ds' 'erp_vars' 'pow_ds' 'pow_vars'
% Get the times from a asample file

offset = 3;
for i=offset:size(subs,1)
    disp(i-offset+1)
    load([subs(i).folder '\' subs(i).name]); % loading the FT preprocessed data
    data_sub = zeros(length(dat.trial), size(dat.trial{1,1},1), size(dat.trial{1,1},2)); % Init an array trials x channels x num points
    for j=1:length(dat.trial)
        data_sub(j,:,:) = dat.trial{1,j};
    end
    tt = floor(dat.trialinfo(:) * 10^-t) - floor(dat.trialinfo(:) * 10^-(t+1))*10; % extracting the trial type (e.g. old vs new, manmade vs natural)
    
    %ERP data 
    data_forgot = data_sub(find(tt==0),:,:);
    data_remember = data_sub(find(tt==1),:,:); 
   
    % Power calculation
    data_pow_forgot = permute(data_forgot, [3, 1, 2]);
    data_pow_forgot_size = size(data_pow_forgot);
    data_pow_forgot = data_pow_forgot(:,:);
    [p,f] = pspectrum(data_pow_forgot, fsample);
    data_pow_forgot = reshape(p,[length(f), data_pow_forgot_size(2), data_pow_forgot_size(3)]); % num freq x num trials x num channels    
    data_pow_forgot = permute(data_pow_forgot, [2, 3, 1]);

    data_pow_remember = permute(data_remember, [3, 1, 2]);
    data_pow_remember_size = size(data_pow_remember);
    data_pow_remember = data_pow_remember(:,:);
    [p,f] = pspectrum(data_pow_remember, fsample);
    data_pow_remember = reshape(p,[length(f), data_pow_remember_size(2), data_pow_remember_size(3)]); % num freq x num trials x num channels    
    data_pow_remember = permute(data_pow_remember, [2, 3, 1]);
    
    % Effect sizes calculation (mean and var) between old and new pics using
    % the conditional mean difference
    
    % ERP
    erp_ds(i-offset+1,:,:) = mean(data_forgot,1) - mean(data_remember,1);  % mean difference of both classes per subject
    v_forgot = var(data_forgot,0,1);  v_remember = var(data_remember,0,1);  % variances of both classes per subject
    erp_vars(i-offset+1, :,:) = squeeze(v_forgot) ./ size(data_forgot,1)  + squeeze(v_remember) ./ size(data_remember,1); 
    
    % Power
    pow_ds(i-offset+1,:,:) = squeeze(mean(data_pow_forgot,1)) - squeeze(mean(data_pow_remember,1));  % mean difference of both classes per subject
    v_forgot = var(data_pow_forgot,0,1);  v_remember = var(data_pow_remember,0,1);  % variances of both classes per subject
    pow_vars(i-offset+1, :,:) = v_forgot ./ size(data_pow_forgot,1)  + v_remember ./ size(data_pow_remember,1); 
end

% Group analysis Equal weighting of mean difference
clearvars 'ps_meanDiff_equal_RE_pow' 'ps_meanDiff_equal_RE_erp' 'sig_ps_meanDiff_equal_RE_pow' 'sig_ps_meanDiff_equal_RE_erp' 'p_pow' 'p_erp'

% Group analysis Equal weighting of mean difference  ERP
for ic = 1:size(erp_ds,2) % loop over channels
    for it = 1:size(erp_ds,3) % loop over timepoints
        [p_FE, p_RE] = equal_weighting(erp_ds(:,ic, it), erp_vars(:,ic, it)); 
        ps_meanDiff_equal_RE_erp(ic,it) = p_RE; 
    end
end
ps_meanDiff_equal_RE_erp = ps_meanDiff_equal_RE_erp';
sig_ps_meanDiff_equal_RE_erp = ps_meanDiff_equal_RE_erp;
sig_ps_meanDiff_equal_RE_erp(sig_ps_meanDiff_equal_RE_erp > (alpha)) = 0;

% FDR across timepoints of respective channels, no FDR across channels
for ic = 1:size(erp_ds,2)
    p_size = size(squeeze(ps_meanDiff_equal_RE_erp(:,ic,:)));
    tmp = mafdr(squeeze(ps_meanDiff_equal_RE_erp(:,ic,:)),'BHFDR',true);
    tmp = reshape(double(py.array.array('d', tmp)), [p_size])';
    tmp(tmp > (alpha)) = 0;
    p_erp(ic,:) = tmp';
end
p_erp = p_erp'; % num timepoints x num channels

% Group analysis Equal weighting of mean difference  Power
for ic = 1:size(pow_ds,2) % loop over channels
    for it = 1:size(pow_ds,3) % loop over frequencies
        [p_FE, p_RE] = equal_weighting(pow_ds(:,ic, it), pow_vars(:,ic, it)); 
        ps_meanDiff_equal_RE_pow(ic,it) = p_RE; 
    end
end
ps_meanDiff_equal_RE_pow = ps_meanDiff_equal_RE_pow';
sig_ps_meanDiff_equal_RE_pow = ps_meanDiff_equal_RE_pow;
sig_ps_meanDiff_equal_RE_pow(sig_ps_meanDiff_equal_RE_pow > (alpha)) = 0;

% FDR across Frequencies of respective channels, no FDR across channels
for ic = 1:size(pow_ds,2)
    p_size = size(squeeze(ps_meanDiff_equal_RE_pow(:,ic,:)));
    tmp = mafdr(squeeze(ps_meanDiff_equal_RE_pow(:,ic,:)),'BHFDR',true);
    tmp = reshape(double(py.array.array('d', tmp)), [p_size])';
    tmp(tmp > (alpha)) = 0;
    p_pow(ic,:) = tmp';
end
p_pow = p_pow'; % num freqs x num channels

% Next step: permutation based multiple test correction could be implemented
