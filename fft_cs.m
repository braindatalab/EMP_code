%% try fft w default fc
dat = data_seg;
nchan = size(dat.label,2);
ntri = size(dat.trial{1,1},1); 
nsam = size(dat.trial{1,1},2);
data = cat(3,dat.trial{1,:});
conn = data2spwctrgc(data, 100, 0, 0, 0, [], {'CS'});
CS_sensor = conn.CS;
psd_sensor = abs(cs2psd(CS_sensor));
psd_sensor = psd_sensor(:,1:70);
freqs = linspace(0,50,101);
figure
subplot(1,2,1)
plot(freqs,psd_sensor); grid on;
title('Linear y-axis')
subplot(1,2,2)
semilogy(freqs,psd_sensor); grid on;
title('Log y-axis')
sgtitle('data2spwctrgc FFT');
xlim([0 50])