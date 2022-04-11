function badtrials = detect_bad_trials(outdir, data)
trials = (1:length(data.trial))';
vartrials = zeros(length(data.trial),1);
for ntri =1:1:length(data.trial)
    vartrials(ntri) = var(sum(data.trial{1,ntri})); 
end
outliers = isoutlier(vartrials); %outside of 3 scaled abs deviations from the median
badtrials = trials(outliers);
bad_trials_fig = figure('visible','off');
hold on
plot(1:length(data.trial),vartrials,'o')
plot(find(outliers),vartrials(outliers),'or')
xlabel('Trials')
ylabel('Variance')
title('Variance of trials')
saveas(bad_trials_fig,[outdir '/bad_trials.png'])
clearvars vartrials nbad