function [trl, event] = ft_trialfun_emp(cfg)

% modified trial function from example1

% FT_TRIALFUN_EXAMPLE1 is an example trial function. It searches for events
% of type "trigger" and specifically for a trigger with value 7, followed
% by a trigger with value 64.
%
% You can use this as a template for your own conditial trial definitions.
%
% Use this function by calling
%   [cfg] = ft_definetrial(cfg)
% where the configuration structure should contain
%   cfg.dataset           = string with the filename
%   cfg.trialfun          = 'ft_trialfun_example1'
%   cfg.trialdef.prestim  = number, in seconds
%   cfg.trialdef.poststim = number, in seconds

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% search for "trigger" events
value  = [event(strcmp('trigger', {event.type})).value]';
sample = [event(strcmp('trigger', {event.type})).sample]';

% determine the number of samples before and after the trigger
prestim  = -round(cfg.trialdef.prestim  * hdr.Fs);
poststim =  round(cfg.trialdef.poststim * hdr.Fs);

trl = [];

for j = 1:length(value)
  trlbegin = sample(j) + prestim;
  trlend   = sample(j) + poststim;
  offset   = prestim;
  % adding event value as last column
  newtrl   = [trlbegin trlend offset value(j)];
  trl      = [trl; newtrl];
end