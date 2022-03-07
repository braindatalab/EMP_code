function badtrials = detect_bad_trials(output, chantype, data_seg)
trials = (1:length(data_seg.trial))';
vartrials = zeros(length(data_seg.trial),1);
for ntri =1:1:length(data_seg.trial)
    vartrials(ntri) = var(sum(data_seg.trial{1,ntri}(chantype,:))); 
end
outliers = isoutlier(vartrials); %outside of 3 scaled abs deviations from the median
badtrials = trials(outliers);
bad_trials_fig = figure('visible','off');
hold on
plot(1:length(data_seg.trial),vartrials,'o')
plot(find(outliers),vartrials(outliers),'or')
xlabel('Trials')
ylabel('Variance')
title('Variance of trials')
saveas(bad_trials_fig,[output '/bad_trials.png'])
clearvars vartrials nbad