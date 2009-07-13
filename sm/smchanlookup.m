function chanind = smchanlookup(channels);
% convert channel names to indices

global smdata;

if isnumeric(channels)
    chanind = channels;
    if size(chanind, 2) > 1
        chanind = chanind';
    end
    return;
end

if ischar(channels)
    channels = cellstr(channels);
end

chanind = zeros(length(channels), 1);

for i = 1:length(channels)
    chanind(i) = strmatch(channels{i}, strvcat(smdata.channels.name), 'exact');
end