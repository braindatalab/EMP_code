%%load files
set_paths
% load trial indices
load([results_path 'trial_ind.mat'])
% load baseline corrected ERP data
load([results_path 'all_voltage.mat'],'all_voltage_bc','all_voltage_window')
% load power data
load([results_path 'all_time_freq.mat'])
%% load sample times from 1 subject
subs = dir([prep_path '*.mat']);
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
    % N1 component time
    n1_range = dsearchn(mstime',[100 200]')';
    % average over trials and channels to find minimum voltage time
    avg_data = squeeze(mean(mean(data_sub,1),2));
    [n1_amp,n1_idx] = min(avg_data(n1_range(1):n1_range(2)));
    n1_time = n1_idx+n1_range(1)-1;
    % get amplitude for this time 
    n1_manmade = squeeze(data_sub(:,n1_time,trial_ind(i).man))';
    n1_natural = squeeze(data_sub(:,n1_time,trial_ind(i).nat))'; 
    % effect of N1 (mean and var) 
    % mean difference
    ds(i,:) = mean(n1_manmade,1) - mean(n1_natural,1);  
    % variance 
    v_1 = var(n1_manmade,0,1);  
    v_2 = var(n1_natural,0,1); 
    vars(i, :) = v_1 ./ size(n1_manmade,1) + v_2 ./ size(n1_natural,1); 
end
[p_n1_uncorr, p_n1_fdr, z_re] = group_analysis(ds, vars,alpha);
save([results_path 'p/p_val_H1.mat'],'p_n1_uncorr','p_n1_fdr', 'z_re');
%% Hypothesis 2
% old vs new images
% EEG voltage at fronto-central channels 
% alpha at posterior channels
% theta at fronto-central channels
% get channel indices
fc_chans = find(~cellfun(@isempty,regexp(dat.label,'^FC')));
post_chans = [find(~cellfun(@isempty,regexp(dat.label,'^PO'))); ...
    find(~cellfun(@isempty,regexp(dat.label,'^O')))];
% find the 300-500 ms time range
load([results_path '/window_overlap_idx.mat'])
time_range = [30 50]; %in samples
windows = find(idx(:,1) > 30 & idx(:,1) < 50 & idx(:,2) < 52);
for i = 1:size(subs,1)
    disp(subs(i).name(1:end-4))
    % use averaged voltage over 100 ms windows with 5 ms overlap
    data_sub = all_voltage_window{i};
    data_sub_power = permute(log(all_time_freq{i}),[2 1 3 4]);
    % voltage data between [300;500] at FC channels - average amplitude between
    % channels and times
    voltage_old = permute(data_sub(fc_chans, windows, trial_ind(i).old),[3 1 2]);
    voltage_new = permute(data_sub(fc_chans, windows, trial_ind(i).new), [3 1 2]);
    % get alpha power at post channels and theta at fc channels
    % avg within freq band
    alpha_pow_old = squeeze(mean(data_sub_power(trial_ind(i).old,post_chans,f>=8&f<13,windows),3));
    alpha_pow_new = squeeze(mean(data_sub_power(trial_ind(i).new,post_chans,f>=8&f<13,windows),3));
    theta_pow_old = squeeze(mean(data_sub_power(trial_ind(i).old,fc_chans,f>=4&f<7,windows),3));
    theta_pow_new = squeeze(mean(data_sub_power(trial_ind(i).new,fc_chans,f>=4&f<7,windows),3));
    
    % Effect sizes calculation (mean and var)
    % voltage
    voltage_new_old_ds(i,:,:) = mean(voltage_new,1) - mean(voltage_old,1);  
    voltage_new_old_vars(i,:,:) = var(voltage_new,0,1)./ size(voltage_new,1)+ ...
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
[p_volt_uncorr, p_volt_fdr, z_re_volt] = group_analysis(voltage_new_old_ds,voltage_new_old_vars,alpha);
[p_alpha_uncorr, p_alpha_fdr, z_re_alpha]=group_analysis(alpha_ds,alpha_vars,alpha);
[p_theta_uncorr, p_theta_fdr, z_re_theta]=group_analysis(theta_ds,theta_vars,alpha);

save([results_path 'p/p_val_H2.mat'],'p_volt_fdr','p_volt_uncorr',...
    'p_alpha_fdr','p_alpha_uncorr',...
    'p_theta_fdr','p_theta_uncorr', 'z_re_volt','z_re_alpha','z_re_theta')
%% Hypothesis 3
% hit or miss
% EEG voltage (any channels/time)
% power (any channels/time)
for i = 1:size(subs,1)
    disp(subs(i).name(1:end-4))
    % use averaged voltage over 100 ms windows with 5 ms overlap
    data_sub = all_voltage_window{i};
    data_sub_power = permute(log(all_time_freq{i}),[2 1 3 4]);
    % voltage for all time windows + all channels
    voltage_hit = permute(data_sub(:, :, trial_ind(i).hit),[3 1 2]);
    voltage_miss = permute(data_sub(:, :, trial_ind(i).miss), [3 1 2]);
    % power for all time windows + all channels
    all_pow_hit = data_sub_power(trial_ind(i).hit,:,:,:);
    all_pow_miss = data_sub_power(trial_ind(i).miss,:,:,:);
    % effect sizes calculation (mean and var)
    % voltage
    voltage_hit_miss_ds(i,:,:) = mean(voltage_hit,1) - mean(voltage_miss,1);  
    voltage_hit_miss_vars(i,:,:) = var(voltage_hit,0,1)./ size(voltage_hit,1)+ ...
        var(voltage_miss,0,1) ./ size(voltage_miss,1); 
    % pow
   pow_hit_miss_ds(i,:,:, :) = mean(all_pow_hit,1) - mean(all_pow_miss,1);  % mean difference of both classes per subject
   pow_hit_miss_vars(i,:,:, :) = var(all_pow_hit,0,1) ./ size(all_pow_hit,1) + ...
        var(all_pow_miss,0,1) ./ size(all_pow_miss,1); 
end
[p_volt_uncorr, p_volt_fdr, z_re_volt] = group_analysis(voltage_hit_miss_ds,voltage_hit_miss_vars,alpha);
[p_pow_uncorr, p_pow_fdr, z_re_pow]=group_analysis(pow_hit_miss_ds, pow_hit_miss_vars,alpha);

save([results_path 'p/p_val_H3.mat'],'p_volt_fdr','p_volt_uncorr',...
    'p_pow_fdr','p_pow_uncorr', 'z_re_volt','z_re_pow')
