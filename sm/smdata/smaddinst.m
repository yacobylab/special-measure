function pos=smaddinst(inst,pos)
% Add instrument at some position (default is to add one on to end)
%function smaddinst(inst,pos)
% If data, channels, datadim or type not given, add default values. 

global smdata;

if ~isfield(inst,'data') 
    inst.data = [];
end
if ~isfield(inst,'name') 
    inst.name = inst.device; 
end
if ~isfield(inst,'channels') 
    warning('No channels defined, adding a dummy channel'); 
    inst.channels = 'dummy';     
end
smNChans = size(inst.channels,1);
if ~isfield(inst,'datadim')     
    inst.datadim = zeros(smNChans,1);
end
if ~isfield(inst,'type')     
    inst.type = zeros(smNChans,1);
end

if ~exist('pos','var')
    if isfield(smdata, 'inst')
        pos = length(smdata.inst)+1;
    else
        pos = 1;
    end
end
smdata.inst(pos) = inst; 
end