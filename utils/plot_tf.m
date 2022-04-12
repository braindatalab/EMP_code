imagesc(squeeze(p_all_abs(1,1,:,:))); axis xy
all_ch = squeeze(mean(p_all_abs,1));
imagesc(squeeze(mean(all_ch(trial_ind.miss,:,:),1))); axis xy
yt = get(gca,'Ytick');
frq = round(linspace(0,50,length(yt)),1);
set(gca, 'YTick',yt,'YTickLabel',frq)
xt = get(gca,'Xtick');
times1 = round(linspace(-0.2,0.8,length(xt)),2);
set(gca, 'XTick',xt,'XTickLabel',times1)
xlabel('Times, s')
ylabel('Freqs, Hz')
title('Pspectrum output for subject 1, miss trials, avg of all channels')
colorbar