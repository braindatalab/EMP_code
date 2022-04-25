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
alpha = 0.05;
%% Hypothesis 1
hypothesis = 1;
% N1 between man-made and natural images
num_channels = size(all_voltage_bc{1},1);
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
[p_n1_uncorr1, p_n1_fdr1, z_re1] = group_analysis(ds, vars,num_channels,alpha);
save([results_path 'p/p_val_H1.mat'],'p_n1_uncorr1','p_n1_fdr1', 'z_re1');
plot_topomap(-log10(p_n1_fdr1));
%% Hypothesis 2
hypothesis = 2;
% old vs new images
% EEG voltage at fronto-central channels 
% alpha at posterior channels
% theta at fronto-central channels
% get channel indices
new_labels = dat.label;
new_labels([30 65 66]) = [];
fc_chans = find(~cellfun(@isempty,regexp(new_labels,'^FC')));
post_chans = [find(~cellfun(@isempty,regexp(new_labels,'^PO'))); ...
    find(~cellfun(@isempty,regexp(new_labels,'^O')))];
% find the 300-500 ms time range
load([results_path '/window_overlap_idx.mat'])
windows = find(idx(:,1) > 30 & idx(:,1) < 50 & idx(:,2) < 52);
for i = 1:size(subs,1)
    disp(subs(i).name(1:end-4))
    % use averaged voltage over 100 ms windows with 5 ms overlap
    data_sub = all_voltage_window{i};
    data_sub_power = permute(log(all_time_freq{i}),[2 1 3 4]);
    % voltage data between [300;500] at FC channels
    voltage_old = permute(data_sub(fc_chans, windows, trial_ind(i).old),[3 1 2]);
    voltage_new = permute(data_sub(fc_chans, windows, trial_ind(i).new), [3 1 2]);
    % get alpha power at post channels and theta at fc channels
    % avg within freq band
    alpha_pow_old = squeeze(mean(data_sub_power(trial_ind(i).old,post_chans,f>=8&f<13,windows),3));
    alpha_pow_new = squeeze(mean(data_sub_power(trial_ind(i).new,post_chans,f>=8&f<13,windows),3));
    theta_pow_old = squeeze(mean(data_sub_power(trial_ind(i).old,fc_chans,f>=4&f<7,windows),3));
    theta_pow_new = squeeze(mean(data_sub_power(trial_ind(i).new,fc_chans,f>=4&f<7,windows),3)); 
    % effect sizes calculation (mean and var)
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
    alpha_vars(i,:,:) = var(alpha_pow_new,0,1) ./ size(alpha_pow_new,1) + ...
        var(alpha_pow_old,0,1) ./ size(alpha_pow_old,1); 
end
[p_volt_uncorr2, p_volt_fdr2, z_re_volt2] = group_analysis(voltage_new_old_ds,voltage_new_old_vars,length(fc_chans),alpha);
[p_alpha_uncorr2, p_alpha_fdr2, z_re_alpha2]=group_analysis(alpha_ds,alpha_vars,length(post_chans),alpha);
[p_theta_uncorr2, p_theta_fdr2, z_re_theta2]=group_analysis(theta_ds,theta_vars,length(fc_chans),alpha);
save([results_path 'p/p_val_H2.mat'],'p_volt_fdr2','p_volt_uncorr2',...
    'p_alpha_fdr2','p_alpha_uncorr2',...
    'p_theta_fdr2','p_theta_uncorr2', 'z_re_volt2','z_re_alpha2','z_re_theta2')
%% Hypothesis 3
% hit or miss
% EEG voltage (any channels/time)
% power (any channels/time)
hypothesis = 3;
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
[p_volt_uncorr3, p_volt_fdr3, z_re_volt3] = group_analysis(voltage_hit_miss_ds,voltage_hit_miss_vars,num_channels,alpha);
[p_pow_uncorr3, p_pow_fdr3, z_re_pow3]=group_analysis(pow_hit_miss_ds, pow_hit_miss_vars,num_channels,alpha);
save([results_path 'p/p_val_H3.mat'],'p_volt_fdr3','p_volt_uncorr3',...
    'p_pow_fdr3','p_pow_uncorr3', 'z_re_volt3','z_re_pow3')
%% Hypothesis 4
hypothesis = 4;
% remembered or forgotten
% EEG voltage (any channels/time)
% power (any channels/time)
for i = 1:size(subs,1)
    disp(subs(i).name(1:end-4))
    % use averaged voltage over 100 ms windows with 5 ms overlap
    data_sub = all_voltage_window{i};
    data_sub_power = permute(log(all_time_freq{i}),[2 1 3 4]);
    % voltage for all time windows + all channels
    voltage_rem = permute(data_sub(:, :, trial_ind(i).rem),[3 1 2]);
    voltage_forg = permute(data_sub(:, :, trial_ind(i).forg), [3 1 2]);
    % power for all time windows + all channels
    all_pow_rem = data_sub_power(trial_ind(i).rem,:,:,:);
    all_pow_forg = data_sub_power(trial_ind(i).forg,:,:,:);
    % effect sizes calculation (mean and var)
    % voltage
    voltage_rem_forg_ds(i,:,:) = mean(voltage_rem,1) - mean(voltage_forg,1);  
    voltage_rem_forg_vars(i,:,:) = var(voltage_rem,0,1)./ size(voltage_rem,1)+ ...
        var(voltage_forg,0,1) ./ size(voltage_forg,1); 
    % pow
   pow_rem_forg_ds(i,:,:, :) = mean(all_pow_rem,1) - mean(all_pow_forg,1);  % mean difference of both classes per subject
   pow_rem_forg_vars(i,:,:, :) = var(all_pow_rem,0,1) ./ size(all_pow_rem,1) + ...
        var(all_pow_forg,0,1) ./ size(all_pow_forg,1); 
end
[p_volt_uncorr4, p_volt_fdr4, z_re_volt4] = group_analysis(voltage_rem_forg_ds,voltage_rem_forg_vars,num_channels,alpha);
[p_pow_uncorr4, p_pow_fdr4, z_re_pow4] = group_analysis(pow_rem_forg_ds, pow_rem_forg_vars,num_channels,alpha);

save([results_path 'p/p_val_H4.mat'],'p_volt_fdr4','p_volt_uncorr4',...
    'p_pow_fdr4','p_pow_uncorr4', 'z_re_volt4','z_re_pow4')