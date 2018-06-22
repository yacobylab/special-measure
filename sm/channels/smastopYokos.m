function smastopYokos(yokos)
% Stop ramps on yokos with indices given (default all devices with name 'Yoko7651')
% smastopYokos(yokos)

global smdata;

if ~exist('yokos','var')    
    yokos = sminstlookup('Yoko7651');
end

for i = yokos'
    if strcmp(smdata.inst(i).device, 'Yoko7651')
        if bitand(query(smdata.inst(i).data.inst, 'OC', '%s\n', '%*5c%d'), 2)
            fprintf(smdata.inst(i).data.inst, 'RU0');
        end
    end
end