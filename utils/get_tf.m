% function get_tf(data)
% % this function performs time-frequency analysis of the data using
% % zero-padding and Hanning windows 
% end
data = data_sub;
nchan = size(data_sub,1);
ntri = size(data_sub,3);
fs = 100;

%% compute tf
for c = 1:nchan
    fprintf('channel %d\n', c)
    for t = 1:ntri
        data_tri = squeeze(data(c,20:end,t));
        % zero-pad
        data_tri_pad = [zeros(159,1);data_tri'.*hanning(82);zeros(159,1)];
        l = size(data_tri_pad,1);
        freqs = fs*(0:(l/2))/l;
        tf_i = fft(data_tri_pad);
        plot(freqs,abs(tf_i(1:l/2+1)));
    end
end
%% compare with spectrogram
for c = 1:nchan
    fprintf('channel %d\n', c)
    for t = 1:ntri
        data_tri = squeeze(data(c,20:end,t));
        [p,f,~] = spectrogram(data_tri,20,10,20,100);
        p_all(c,t,:,:) = p;
    end
end
p_all_abs = abs(p_all);