% data_dir = 'C:\Users\Nikita\Documents\preprocessed\';
% current_dir = ['C:\Users\Nikita\Documents\Master thesis\Resources\matlab\nikita\eegmanypipelines\'];
% addpath(genpath([current_dir 'GroupStats-master']));
subs = dir(prep_path);
num_analysis = [3,2,1,0];
band_range = [4,8,12,30];
num_channels = 66;
alpha=0.05;
fsample=100;
%% Hypothesis 1
tic
t = num_analysis(1);
ds = zeros(size(subs,1)-2,66);
vars = zeros(size(subs,1)-2,66);
offset = 3;
for i=offset:size(subs,1)
    load([subs(i).folder '/' subs(i).name]);
    data_sub = zeros(length(dat.trial), size(dat.trial{1,1},1), size(dat.trial{1,1},2));
    for j=1:length(dat.trial)
        data_sub(j,:,:) = dat.trial{1,j};
    end
    tt = floor(dat.trialinfo(:) * 10^-t) - floor(dat.trialinfo(:) * 10^-(t+1))*10;
    
    % N1 amplitude calculation
    mstime = dat.time{1, 1}*1000;
    negpeaktime = dsearchn(mstime',[100 200]')';
    [erpMin,erpMinTime] = min(data_sub(:,:,negpeaktime(1):negpeaktime(2)), [], 3);
    erpMinTime = ( erpMinTime+negpeaktime(1)-1 );
    mserpMinTime = mstime( erpMinTime+negpeaktime(1)-1 );
    
    data_1 = erpMin(find(tt==1),:);
    data_2 = erpMin(find(tt==2),:);
    
    % Effect of N1 (mean and var) between natural and manmade pics using
    % the mean difference
    ds(i-offset+1,:) = mean(data_1,1) - mean(data_2,1);  % mean difference of both classes per subject
    v_1 = var(data_1,0,1);  v_2 = var(data_2,0,1);  % variances of both classes per subject
    vars(i-offset+1, :) = v_1 ./ size(data_1,1)  + v_2 ./ size(data_2,1); 
  
end

% Group analysis Equal weighting of mean difference 
for ic = 1:num_channels
    [p_FE, p_RE] = equal_weighting(ds(:,ic), vars(:,ic));
    %     ps_meanDiff_equal_FE(idx_nrep, idx_mu) = p_FE;  
    ps_meanDiff_equal_RE(ic) = p_RE; 
end
ps_meanDiff_equal_RE = ps_meanDiff_equal_RE';
sig_ps_meanDiff_equal_RE = ps_meanDiff_equal_RE;
sig_ps_meanDiff_equal_RE(sig_ps_meanDiff_equal_RE > (alpha)) = 0;

% FDR across channels
p_size = size(ps_meanDiff_equal_RE);
p = mafdr(ps_meanDiff_equal_RE,'BHFDR',true);
p = reshape(double(py.array.array('d', p)), [p_size])';
p(p > (alpha)) = 0;

% permutation based multiple test correction could be implemented
toc
%% Hypothesis 2
t = num_analysis(2); %The select the integer from the event code

% Get the times from a asample file
load([subs(3).folder '\' subs(3).name]);
time_range = [300 500];
mstime = dat.time{1, 1}*1000;
clearvars 'dat'
rtime = dsearchn(mstime',time_range')';
total_tnum = (((time_range(2) - time_range(1))*fsample)/1000) + 1;

% Initialising the arrays for storing the effect sizes and its variances
% for all the subjects and different EEG features
erp_ds = zeros(size(subs,1)-2, 66, total_tnum);
erp_vars = zeros(size(subs,1)-2, 66, total_tnum);

theta_ds = zeros(size(subs,1)-2, 66);
theta_vars = zeros(size(subs,1)-2, 66);
alpha_ds = zeros(size(subs,1)-2, 66);
alpha_vars = zeros(size(subs,1)-2, 66);

offset = 3;
for i=offset:size(subs,1)
    disp(i-offset+1)
    load([subs(i).folder '\' subs(i).name]); % loading the FT preprocessed data
    data_sub = zeros(length(dat.trial), size(dat.trial{1,1},1), size(dat.trial{1,1},2)); % Init an array trials x channels x num points
    for j=1:length(dat.trial)
        data_sub(j,:,:) = dat.trial{1,j};
    end
    tt = floor(dat.trialinfo(:) * 10^-t) - floor(dat.trialinfo(:) * 10^-(t+1))*10; % extracting the trial type (e.g. old vs new, manmade vs natural)
    
    mstime = dat.time{1, 1}*1000;
    erptime = dsearchn(mstime',time_range')'; % extracting the indexes in times array in the time_range [300 500]
    
    %ERP data between [300ms 500ms] calculation
    data_old = data_sub(find(tt==0),:,erptime(1):erptime(2));
    data_new = data_sub(find(tt==1),:,erptime(1):erptime(2)); 
   
    % Power calculation 
    % for old pics
    data_ch = permute(data_old, [3, 1, 2]);
    data_ch_size = size(data_ch);
    data_ch = data_ch(:,:);
    [p,f] = pspectrum(data_ch, fsample);
    data_ch = reshape(p,[length(f), data_ch_size(2), data_ch_size(3)]);
    thetatime = dsearchn(f,[4 8]')';
    alphatime = dsearchn(f,[8 12]')';    
    data_theta_old = squeeze(mean(data_ch(thetatime(1):thetatime(2), :,:),1));
    data_alpha_old = squeeze(mean(data_ch(alphatime(1):alphatime(2), :,:),1));
    
    % for new pics
    data_ch = permute(data_new, [3, 1, 2]);
    data_ch_size = size(data_ch);
    data_ch = data_ch(:,:);
    [p,f] = pspectrum(data_ch, fsample);
    data_ch = reshape(p,[length(f), data_ch_size(2), data_ch_size(3)]);
    thetatime = dsearchn(f,[4 8]')';
    alphatime = dsearchn(f,[8 12]')';    
    data_theta_new = squeeze(mean(data_ch(thetatime(1):thetatime(2), :,:),1));
    data_alpha_new = squeeze(mean(data_ch(alphatime(1):alphatime(2), :,:),1));

    % Effect sizes calculation (mean and var) between old and new pics using
    % the conditional mean difference
    
    % ERP
    erp_ds(i-offset+1,:,:) = mean(data_new,1) - mean(data_old,1);  % mean difference of both classes per subject
    v_new = var(data_new,0,1);  v_old = var(data_old,0,1);  % variances of both classes per subject
    erp_vars(i-offset+1, :,:) = v_new ./ size(data_new,1)  + v_old ./ size(data_old,1); 
    
    % Theta
    theta_ds(i-offset+1,:) = mean(data_theta_new,1) - mean(data_theta_old,1);  % mean difference of both classes per subject
    v_new = var(data_theta_new,0,1);  v_old = var(data_theta_old,0,1);  % variances of both classes per subject
    theta_vars(i-offset+1, :) = v_new ./ size(data_theta_new,1)  + v_old ./ size(data_theta_old,1); 

    %Alpha
    alpha_ds(i-offset+1,:) = mean(data_alpha_new,1) - mean(data_alpha_old,1);  % mean difference of both classes per subject
    v_new = var(data_alpha_new,0,1);  v_old = var(data_alpha_old,0,1);  % variances of both classes per subject
    alpha_vars(i-offset+1, :) = v_new ./ size(data_alpha_new,1)  + v_old ./ size(data_alpha_old,1); 
end

% Group analysis Equal weighting of mean difference
clearvars 'ps_meanDiff_equal_RE_theta' 'ps_meanDiff_equal_RE_alpha' 'ps_meanDiff_equal_RE_erp' 'sig_ps_meanDiff_equal_RE_theta' 'sig_ps_meanDiff_equal_RE_alpha' 'sig_ps_meanDiff_equal_RE_erp' 'p_theta' 'p_alpha' 'p_erp'
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

% Next step: permutation based multiple test correction could be implemented

%% Hypothesis 3
t = num_analysis(3); %The select the integer from the event code

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
    
    %ERP data between [300ms 500ms] calculation
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
