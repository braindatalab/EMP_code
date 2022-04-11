% ERP plots
load('/home/space/uniml/veronika/results/EMP/trial_ind.mat')
load('/home/space/uniml/veronika/results/EMP/all_voltage.mat')
for i = 1:length(all_voltage)
    disp(i)
    data = all_voltage{i};
    data_man(i,:,:,:) = mean(data(:,:,trial_ind(i).man),3);
    data_nat(i,:,:,:) = mean(data(:,:,trial_ind(i).nat),3);
end
times = linspace(-0.1,0.9,101);
figure
hold on
title('Scene category, grand average')
plot(times,squeeze(mean(mean(data_man,2),1))','b')
plot(times,squeeze(mean(mean(data_nat,2),1))','r')
patch([0,0.5,0.5,0],[4,4,-3,-3],'black')
alpha(0.3)
xlabel('Time, s')
ylabel('Voltage')
legend({'Man-made','Natural','Stimulus'})
%% image novelty FC
for i = 1:length(all_voltage)
    disp(i)
    data = all_voltage{i};
    data_old(i,:,:,:) = mean(data(:,:,trial_ind(i).old),3);
    data_new(i,:,:,:) = mean(data(:,:,trial_ind(i).new),3); 
end
times = linspace(-0.1,0.9,101);
figure
hold on
title('Image novelty, average of FC channels')
load('/home/space/uniml/veronika/results/EMP/preprocessed/EMP01.mat')
fc_chans = find(~cellfun(@isempty,regexp(dat.label,'^FC')));
data_old_fc = squeeze(mean(mean(data_old(:,fc_chans,:),2),1));
data_new_fc = squeeze(mean(mean(data_new(:,fc_chans,:),2),1));
plot(times,squeeze(mean(mean(data_old,2),1))','b')
plot(times,squeeze(mean(mean(data_new,2),1))','r')
patch([0,0.5,0.5,0],[4,4,-3,-3],'black')
patch([0.3,0.5,0.5,0.3],[4,4,-3,-3],'red')
alpha(0.3)
xlabel('Time, s')
ylabel('Voltage')
legend({'Old images','New images','Stimulus','Hypothesis range'})
%% correct recognition
for i = 1:length(all_voltage)
    disp(i)
    data = all_voltage{i};
    data_hit(i,:,:,:) = mean(data(:,:,trial_ind(i).hit),3);
    data_miss(i,:,:,:) = mean(data(:,:,trial_ind(i).miss),3); 
end
times = linspace(-0.1,0.9,101);
figure
hold on
title('Correct recognition, all channels')
load('/home/space/uniml/veronika/results/EMP/preprocessed/EMP01.mat')
data_hit = squeeze(mean(mean(data_hit,2),1));
data_miss = squeeze(mean(mean(data_miss,2),1));
plot(times,data_hit','b')
plot(times,data_miss','r')
patch([0,0.5,0.5,0],[4,4,-3,-3],'black')
alpha(0.3)
xlabel('Time, s')
ylabel('Voltage')
legend({'Hits','Misses','Stimulus'})
%% subsequent memory
for i = 1:length(all_voltage)
    disp(i)
    data = all_voltage{i};
    data_rem(i,:,:,:) = mean(data(:,:,trial_ind(i).rem),3);
    data_forg(i,:,:,:) = mean(data(:,:,trial_ind(i).forg),3); 
end
times = linspace(-0.1,0.9,101);
figure
hold on
title('Subsequent memory, all channels')
load('/home/space/uniml/veronika/results/EMP/preprocessed/EMP01.mat')
data_rem = squeeze(mean(mean(data_rem,2),1));
data_forg = squeeze(mean(mean(data_forg,2),1));
plot(times,data_rem','b')
plot(times,data_forg','r')
patch([0,0.5,0.5,0],[4,4,-3,-3],'black')
alpha(0.3)
xlabel('Time, s')
ylabel('Voltage')
legend({'Remembered','Forgotten','Stimulus'})