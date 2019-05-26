function pos = smaddchannel(inst, channel, name, rangeramp, pos)
% function pos = smaddchannel(inst, channel, name, rangeramp, pos)
% 
% Add channel from instrument 'inst' with name 'name' to position 'pos' in
% channel list. If pos not given, channel added to the end. 
% channel is the number or name of channel in smdata.inst.channels
% rangeramp defaults to [-Inf, Inf, Inf, 1];
% The first two elements are the range limits,
% the last two elements the ramp rate (1/2) and the divider (see Wiki).

global smdata;

if nargin < 4 || isempty(rangeramp)
    rangeramp = [-Inf, Inf];
end

if length(rangeramp) < 3
    rangeramp(3) = Inf;
end

if length(rangeramp) < 4
    rangeramp(4) = 1;
end

inst = sminstlookup(inst);

if ~isnumeric(channel)    
    sizeChans = size(smdata.inst(inst).channels); 
    % Hack because we should change this to cell arrays... 
    channel = find(startsWith(mat2cell(smdata.inst(inst).channels,ones(1,sizeChans(1)),sizeChans(2)),channel));     
    if length(channel)>1, channel = channel(1); end
end

if isempty(channel)
    fprintf('Invalid channel.\n');
    return;
end

if ~exist('pos','var')
    if isfield(smdata, 'channels')
        pos = length(smdata.channels)+1;
    else
        pos = 1;
    end
end
smdata.channels(pos).name = name;
smdata.channels(pos).instchan = [inst, channel];
smdata.channels(pos).rangeramp = rangeramp;
end