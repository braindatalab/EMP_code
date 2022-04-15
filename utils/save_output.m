% this script saves the data in the required submission format
set_paths
output_path = [results_path 'data_for_submission/'];
subs = dir([prep_path '*.mat']);
for i = 1:length(subs)
    subj_id = subs(i).name(1:end-4);
    disp(subj_id)
    folder_name = [output_path subj_id];
    load([subs(i).folder '/' subs(i).name])
    load([report_path '/' subj_id '/info.mat'])
    if ~isfolder(folder_name)
        mkdir(folder_name)
    end
    % save file in fieldtrip format
    save([folder_name '/' subs(i).name],'dat');
    % make text file with rejected trials
    fid = fopen([folder_name '/rejected_trials.txt'],'w');
    fprintf(fid, '%d ', info.badtrials);
    % make text file with rejected and interpolated channels
    fid = fopen([folder_name '/rejected_interpolated_channels.txt'],'w');
    fprintf(fid, '%d ', info.badchans);
end