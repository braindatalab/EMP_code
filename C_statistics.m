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
[p_n1_uncorr, p_n1_fdr] = group_analysis(ds, vars,alpha);
save([results_path 'p/p_val_H1.mat'],'p_n1_uncorr','p_n1_fdr');
%% Hypothesis 2
% EEG voltage at fronto-central channels 
% alpha at posterior channels
% theta at fronto-central channels
% get channel indices
fc_chans = find(~cellfun(@isempty,regexp(dat.label,'^FC')));
post_chans = [find(~cellfun(@isempty,regexp(dat.label,'^PO'))); ...
    find(~cellfun(@isempty,regexp(dat.label,'^O')))];
% frequencies from spectrogram
freqs = linspace(0,50,11);
% time range
time_range = [300 500];
rtime = dsearchn(mstime',time_range')';
for i = 1:size(subs,1)
    disp(subs(i).name(1:end-4))
    data_sub = all_voltage_bc{i};
    % permute to match rest of code
    data_sub = permute(data_sub, [3 1 2]);
    % extracting the indexes in times array in the time_range [300 500]
    time_idx = dsearchn(mstime',time_range')'; 
    % voltage data between [300;500] at FC channels - average amplitude between
    % channels and times
    voltage_old = data_sub(trial_ind(i).old,fc_chans,time_idx(1):time_idx(2));
    voltage_new = data_sub(trial_ind(i).new,fc_chans,time_idx(1):time_idx(2));
    
    % get alpha power at post channels and theta at fc channels 
    data_sub_power = all_time_freq{i};
    alpha_pow_old = data_sub_power(post_chans,trial_ind(i).old,freqs>8&freqs<13)';
    alpha_pow_new = data_sub_power(post_chans,trial_ind(i).new,freqs>8&freqs<13)';
    theta_pow_old = data_sub_power(fc_chans,trial_ind(i).old,freqs>4&freqs<7)';
    theta_pow_new = data_sub_power(fc_chans,trial_ind(i).new,freqs>4&freqs<7)';
    
    % Effect sizes calculation (mean and var)
    % voltage
    voltage_ds(i,:,:) = mean(voltage_new,1) - mean(voltage_old,1);  
    voltage_vars(i,:,:) = var(voltage_new,0,1)./ size(voltage_new,1)+ ...
        var(voltage_old,0,1) ./ size(voltage_old,1); 
    
    % theta
    theta_ds(i,:,:) = mean(theta_pow_new,1) - mean(theta_pow_old,1);  % mean difference of both classes per subject
    theta_vars(i,:,:) = var(theta_pow_new,0,1) ./ size(theta_pow_new,1) + ...
        var(theta_pow_old,0,1) ./ size(theta_pow_old,1); 

    % alpha
    alpha_ds(i,:,:) = mean(alpha_pow_new,1) - mean(alpha_pow_old,1);  % mean difference of both classes per subject
    alpha_vars(i,:,:) = var(alpha_pow_new,0,1) ./ size(theta_pow_new,1) + ...
        var(alpha_pow_old,0,1) ./ size(theta_pow_old,1); 
end
[p_volt_uncorr, p_volt_fdr] = group_analysis(voltage_ds,voltage_vars,alpha);
[p_alpha_uncorr, p_alpha_fdr]=group_analysis(alpha_ds,alpha_vars,alpha);
[p_theta_uncorr, p_theta_fdr]=group_analysis(theta_ds,theta_vars,alpha);

save([results_path 'p/p_val_H2.mat'],'p_erp_fdr','sig_pval_eqw_re_erp',...
    'p_alpha_fdr','sig_pval_eqw_re_alpha',...
    'p_theta_fdr','sig_pval_eqw_re_theta')
%% Hypothesis 3

