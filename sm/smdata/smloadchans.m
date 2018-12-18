function smloadchans(file)
% Load all channels from file to smdata. Existing channels are overwritten.
% function smloadchans(file)

global smdata;

load(['smchan_', file], 'channels');
smdata.channels = channels;
end
   