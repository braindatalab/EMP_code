figure
hypothesis = '4';
imagesc(-log10(p_volt_global4)); axis xy
xlabel('Time windows')
ylabel('Channels')
colorbar
title(['Voltage (global FDR), hyp' hypothesis])
saveas(gcf,[plots_path 'logp_global_fdr/hyp' hypothesis '_volt.png'])
%% pow for 2
figure
imagesc(-log10(p_theta_global2)); axis xy
xlabel('Time windows')
ylabel('Channels')
colorbar
title('Theta power')
saveas(gcf,[plots_path 'logp_global_fdr/hyp2_theta.png'])
figure
imagesc(-log10(p_alpha_global2)); axis xy
xlabel('Time windows')
ylabel('Channels')
colorbar
title('Alpha power')
saveas(gcf,[plots_path 'logp_global_fdr/hyp2_alpha.png'])
%% pow for 3 and 4
hypothesis = '4';
pow = reshape(p_pow_global4, 63, [], 15);
figure
nchan = 56;
imagesc(-log10(squeeze(pow(nchan,:,:)))); axis xy
xlabel('Time windows')
ylabel('Channels')
colorbar
title(['Power at channel' dat.label(nchan)])
saveas(gcf,[plots_path 'logp_global_fdr/hyp' hypothesis '_' dat.label{nchan} '.png'])