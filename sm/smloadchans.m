function smloadchans(file)
% function smloadchans(file)
% load all channels from file to smdata. Existing channels are overwritten.
global smdata;
load(['smchan_', file], 'channels');
smdata.channels = channels;

   