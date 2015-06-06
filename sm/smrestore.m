function smrestore(file, channels, ramprate)
% function smrestore(file, channels, ramprate) 
% restore channel values from a datafile.
% channels can be strings or indices and specifies which values to set, default is all.
% ramprate is optional ramptime that will be applied to all channels.

load(file, 'configvals', 'configch');

configch = smchanlookup(configch);
if nargin >= 2
    channels = smchanlookup(channels);
    if ~all(ismember(channels, configch))
        fprintf('WARNING: some channel values not found.\n');
    end
    mask = ismember(configch, channels);    
    configch = configch(mask);
    configvals = configvals(mask);
end


if exist('ramprate','var')
    smset(configch, configvals,ramprate);
else
    smset(configch, configvals);
end
