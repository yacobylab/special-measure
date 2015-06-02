function out = smsetscanconst(scan,constant,value)
% scan = smsetscansonts(scan,constantname,value)
% sets the value of 'constant' in scan, returns new scan

for i=1:length(scan.consts)
    if strcmp(constant,scan.consts(i).setchan)
        scan.consts(i).val=value;
        out=scan;
        return;
    end
end


error(['No constant found with name' constant])