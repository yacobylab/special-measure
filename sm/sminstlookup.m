function inst = sminstlookup(dev)
% inst = sminstlookup(dev)
% Convert instrument name dev to index. Dev can be either the device (must be unique) or
% name of the instrument.

global smdata;

if ~isnumeric(dev)
    inst = strmatch(dev, strvcat(smdata.inst.name), 'exact');
    if isempty(inst)
        inst = strmatch(dev, strvcat(smdata.inst.device), 'exact');
    end
else
    inst = dev;
end

if isempty(inst)
    fprintf('Invalid instrument\n');
    return;
end
