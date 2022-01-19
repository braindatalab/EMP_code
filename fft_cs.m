%% try fft w default fc
dat = data_seg;
nchan = size(dat.label,2);
ntri = size(dat.trial{1,1},1); 
nsam = size(dat.trial{1,1},2);
data = cat(3,dat.trial{1,:});
conn = data2spwctrgc(data, 100, 20, 0, 0, [], {'CS'});
CS_sensor = conn.CS;
psd_sensor = abs(cs2psd(CS_sensor));
plot(psd_sensor);