function val = smaDecaDac(ic, opts,str)
% Check information about dac, including relays, serial number, firmware version, and generation. 
% function val = smaDecaDac(ic, opts,str)
global smdata
inst = smdata.inst(ic(1)).data.inst; 
switch opts 
    case 'relay'  
        for i = 1:5 
            val{i}=dacread(inst,sprintf('B%dm;',i-1));
        end
    case 'serial'
        val = dacread(inst,'A 1107296264;p;');  
    case 'firmware'
        val = dacread(inst,'A 1107296266;p;');
    case 'gen' 
        dacwrite(inst,str);        
end

function dacwrite(inst, str)
try
    query(inst, str);
catch
    fprintf('WARNING: error in DAC (%s) communication. Flushing buffer.\n',inst.Port);
    while inst.BytesAvailable > 0
        fprintf(fscanf(inst));
    end
end

function val = dacread(inst, str, format)
if nargin < 3
    format = '%s';
end

i = 1;
while i < 10
    try
        val = query(inst, str, '%s\n', format);
        i = 10;
    catch
        fprintf('WARNING: error in DAC (%s) communication. Flushing buffer and repeating.\n',inst.Port);
        while inst.BytesAvailable > 0
            fprintf(fscanf(inst))
        end

        i = i+1;
        if i == 10
            error('Failed 10 times reading from DAC')
        end
    end
end