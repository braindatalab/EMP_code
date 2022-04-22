figure
imagesc(-log10(p_volt_fdr)); axis xy
xlabel('Time windows')
ylabel('Channels')
colorbar
title('Voltage')
saveas(gcf,[plots_path 'logp/hyp' num2str(hypothesis) '_volt.png'])
%% pow for 2
figure
imagesc(-log10(p_theta_fdr)); axis xy
xlabel('Time windows')
ylabel('Channels')
colorbar
title('Theta power')
saveas(gcf,[plots_path 'logp/hyp2_theta.png'])
figure
imagesc(-log10(p_alpha_fdr)); axis xy
xlabel('Time windows')
ylabel('Channels')
colorbar
title('Alpha power')
saveas(gcf,[plots_path 'logp/hyp2_alpha.png'])
%% pow for 3 and 4
pow = reshape(p_pow_fdr, 63, [], 15);
figure
nchan = 24;
imagesc(-log10(squeeze(pow(nchan,:,:)))); axis xy
xlabel('Time windows')
ylabel('Channels')
colorbar
title(['Power at channel' dat.label(nchan)])
saveas(gcf,[plots_path 'logp/hyp' num2str(hypothesis) '_' dat.label{nchan} '.png'])