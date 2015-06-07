function inst = sminstlookup(dev)
% function inst = sminstlookup(dev)
% Convert instrument name dev to index. Dev can be either the device (must be unique) or
% name of the instrument.

global smdata;

if isnumeric(dev)
    inst = dev;
    if size(inst, 2) > 1
        inst = inst';
    end
    return;
end

if ischar(dev)
    dev = cellstr(dev); 
end

inst = [];
for i = 1:length(dev) 
    m = find(strcmp(dev{i}, cellstr(char(smdata.inst.name))));    
    if isempty(m)
        m = find(strcmp(dev{i}, cellstr(char(smdata.inst.device))));        
    end
    if(isempty(m))
        error(sprintf('Unable to find sm instr "%s"\n',dev{i}));
    else
        inst = [inst; m'];  
    end
end

if isempty(inst)
    fprintf('Invalid instrument\n');
    return;
end
