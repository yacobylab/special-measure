function smastopYokos(yokos)
% smastopYokos(yokos)
% stop ramps on yokos with indices given (default all)
global smdata;

if nargin < 1
    %yokos = strmatch('Yoko7651', strvcat(smdata.inst.device), 'exact');
    yokos = sminstlookup('Yoko7651');
end

for i = yokos'
    if strcmp(smdata.inst(i).device, 'Yoko7651')
        if bitand(query(smdata.inst(i).data.inst, 'OC', '%s\n', '%*5c%d'), 2);
            fprintf(smdata.inst(i).data.inst, 'RU0');
        end
    end
end

