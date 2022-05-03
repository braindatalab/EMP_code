%% note: this script prepares the output in the right format for the data submission
%% prepare the data
% save preprocessed EEG data, rejected trials and channels
set_paths
output_path = [results_path 'data_for_submission_final/'];
subs = dir([prep_path '*.mat']);
for i = 1:length(subs)
    subj_id = subs(i).name(1:end-4);
    disp(subj_id)
    folder_name = [output_path 'Subj' subj_id(4:end) '/'];
    load([subs(i).folder '/' subs(i).name])
    load([report_path '/' subj_id '/info.mat'])
    if ~isfolder(folder_name)
        mkdir(folder_name)
    end
    % save file in fieldtrip format
    f1 = [folder_name 'Pre-processed time series data'];
    if ~isfolder(f1)
        mkdir(f1)
    end
    save([f1 '/' subs(i).name],'dat');
    % make text file with rejected trials
    f2 = [folder_name 'Excluded trials (txt files)'];
    if ~isfolder(f2)
        mkdir(f2)
    end
    fid = fopen([f2 '/' subj_id '_excluded_trials.txt'],'w');
    fprintf(fid, '%d ', info.badtrials);
    fclose(fid);
    % make text file with rejected and interpolated channels
    f3 = [folder_name 'Interpolated channels (txt files)'];
    if ~isfolder(f3)
        mkdir(f3)
    end
    fid = fopen([f3 '/' subj_id '_removed_and_interpolated_channels.txt'],'w');
    ch = info.badchans;
    ch(ch>64)=[]; % don't include non-EEG
    ch(ch==30)=[]; % don't include ref
    fprintf(fid, '%s ', dat.label{ch});
    fclose(fid);
end
%% export statistics in a csv file for final report
set_paths
load('layout.mat')
labels = layout.label;
% channels not used in analysis
labels(strcmp(labels,'POz'))=[];
labels(strcmp(labels,'M1'))=[];
labels(strcmp(labels,'M2'))=[];
fc_chans = labels(~cellfun(@isempty,regexp(labels,'^FC')));
post_chans = [labels(~cellfun(@isempty,regexp(labels,'^PO'))); ...
    labels(~cellfun(@isempty,regexp(labels,'^O')))];
% get list of time windows
load([results_path '/ms_window_idx.mat'])
ms_idx = ms_idx*1000; %get ms
for l = 1:length(ms_idx)
    timwin{l} = sprintf('%4.3f-%4.3f ms',ms_idx(l,1),ms_idx(l,2));
end
% load p and z values
for i = 1:4
    load([results_path 'p/indiv_fdr/p_val_H' num2str(i) '.mat'],'z_*')
end
load([results_path 'p/all_p_global_FDR.mat']);
%% make into tables
% hypothesis 1
h1 = table();
idx = ~isnan(p_n1_global);
h1.channel = labels(idx);
h1.pval = p_n1_global(idx);
h1.zval = z_re1(idx);
% hypothesis 2 
% voltage at frontal
h2_volt = stats_to_table(fc_chans,p_volt_global2,z_volt2,timwin(7:9));
h2_theta = stats_to_table(fc_chans,p_theta_global2,z_theta2,timwin(7:9));
h2_alpha = stats_to_table(post_chans,p_alpha_global2,z_alpha2,timwin(7:9));
% hypothesis 3
h3_volt = stats_to_table(labels,p_volt_global3,z_volt3,timwin);
h3_pow = stats_to_table(labels,reshape(p_pow_global3,63,26,15),...
    reshape(z_pow3,63,26,15),timwin);
% hypothesis 4
h4_volt = stats_to_table(labels,p_volt_global4,z_volt4,timwin);
h4_pow = stats_to_table(labels,reshape(p_pow_global4,63,26,15),...
    reshape(z_pow4,63,26,15),timwin);
% save
writetable(h1,[results_path 'data_for_submission/stats/h1.csv'])
writetable(h2_volt,[results_path 'data_for_submission/stats/h2_volt.csv'])
writetable(h2_theta,[results_path 'data_for_submission/stats/h2_theta.csv'])
writetable(h2_alpha,[results_path 'data_for_submission/stats/h2_alpha.csv'])
writetable(h3_volt,[results_path 'data_for_submission/stats/h3_volt.csv'])
writetable(h3_pow,[results_path 'data_for_submission/stats/h3_pow.csv'])
writetable(h4_volt,[results_path 'data_for_submission/stats/h4_volt.csv'])
writetable(h4_pow,[results_path 'data_for_submission/stats/h4_pow.csv'])