function val = smgetscanconst(scan,constant)
% returns the value of 'constant' from the constants defined in scan

for i=1:length(scan.consts)
    if strcmp(constant,scan.consts(i).setchan)
        val=scan.consts(i).val;
        return;
    end
end

error(['No constant found with name' constant])