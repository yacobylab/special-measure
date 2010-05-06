function smrestore(file, channels)
% smrestore(file, channels) 
% restore channel values from a datafile.
% channels can be strings or indices and specifies which values to set, default is all.

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

smset(configch, configvals);