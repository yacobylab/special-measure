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
% Check if any have empty devices or names. 
emptyDevice = find(cellfun(@isempty,{smdata.inst.device}));
for i =1:length(emptyDevice)
    smdata.inst(emptyDevice(i)).device = 'default'; 
end
emptyName = find(cellfun(@isempty,{smdata.inst.name}));
for i = 1:length(emptyName) 
    smdata.inst(emptyName(i)).name = smdata.inst(emptyName(i)).device;
end
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