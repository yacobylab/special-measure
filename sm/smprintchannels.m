function smprintchannels(ch)
% smprintchannels(ch)
%
% Print information about channels ch (Default all).

global smdata;

if nargin < 1
    ch = 1:length(smdata.channels);
elseif ischar(ch)||iscell(ch)
    ch = smchanlookup(ch);
end

fmt = '%2d   %-10s  %-10s  %-10s  %-10s\n';
fprintf(['CH', fmt(4:end)], 'Name', 'Device', 'Dev. Name', 'Dev. Ch.');
fprintf([repmat('-', 1, 60), '\n']);
for i = ch;
    ic = smdata.channels(i).instchan;
    if ic(1) > length(smdata.inst) 
        fprintf('%2d %-10s BORKED: refers to an instrument that doesn''t exist\n', ...
            i, smdata.channels(i).name);
    elseif ic(2) > size(smdata.inst(ic(1)).channels,1)
                fprintf('%2d %-10s %-10s BORKED: refers to a channel that doesn''t exist\n', ...
            i, smdata.channels(i).name,smdata.inst(ic(1)).device);
    else
        fprintf(fmt, i, ...
        smdata.channels(i).name, smdata.inst(ic(1)).device, smdata.inst(ic(1)).name, ...
        smdata.inst(ic(1)).channels(ic(2), :));    
    end
end