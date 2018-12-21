function inst = sminstlookup(dev)
% function inst = sminstlookup(dev)
% Convert instrument name or device to index. 
% Can type in portion of name -- e.g. AWG for AWG5000 or ATS for ATS660. 

global smdata;

if isnumeric(dev)
    inst = dev;
    if size(inst, 2) > 1
        inst = inst';
    end
    return;
end
if ischar(dev), dev = cellstr(dev); end % Convert to cell

inst = [];
for i = 1:length(dev) 
    devInd = find(contains({smdata.inst.name},dev{i}));
    if isempty(devInd)
        devInd = find(contains({smdata.inst.device},dev{i}));
    end
    if(isempty(devInd))
        warning('Unable to find sm instr "%s"\n',dev{i});
    else
        inst = [inst; devInd];  
    end
end

if isempty(inst)
    fprintf('Invalid instrument\n');
    return;
end
end