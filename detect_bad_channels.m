function [interpdata, badchans] = detect_bad_channels(outdir, chantype, data, chanlayout)
varchans = zeros(length(chantype),1);
for i=1:1:length(chantype)
    varchans(i) = var(data.trial{1,1}(chantype(i),:));
end
outliers = isoutlier(varchans); %three scaled median absolute deviations
if any(outliers)
    bad_channels_fig = figure('visible','off');
    %subplot(1,2,1)
    hold on
    plot(1:length(chantype),varchans,'o')
    plot(find(outliers),varchans(outliers),'or')
    xlabel('Channels')
    ylabel('Variance')
    title('Variance of channels')
    badchans = chantype(outliers);
    %prepare neighbors for the chosen chantype for interpolation
    cfg = [];
    cfg.layout = chanlayout;
    cfg.method = 'triangulation';
    neighbours = ft_prepare_neighbours(cfg, data);
    cfg = [];
    cfg.method = 'weighted';
    % FT bug - badchannel needs to have a name since it's compared to
    % data.label and not just an index
    badchan_cell = data.label(badchans);
    cfg.badchannel = badchan_cell;
    cfg.neighbours = neighbours;
    [interpdata] = ft_channelrepair(cfg, data);
    saveas(bad_channels_fig,[outdir '/bad_channels.jpg'])
else
    interpdata = data;
    badchans = [];
end
clearvars varchans nbad