function val = smcDecaDAC(ic, val, rate)
% With ramp support and new trigger scheme. Odd channels are ramped.
% returns ramptime. 
global smdata;

nbits = 16; nvals = 2^nbits -1; 
updateTime = 1e-6;  % units of update time. 
rng = smdata.inst(ic(1)).data.rng(floor((ic(2)-1)/2)+1, :);
dacSlot = floor((ic(2)-1)/8); 
dacChan = floor(mod(ic(2)-1, 8)/2); 
smChan = floor((ic(2)+1)/2);
inst = smdata.inst(ic(1)).data.inst;
switch ic(3)
    case 1 % set
        bitVal = round((val - rng(1))/ diff(rng) * nvals);
        bitVal = max(min(bitVal, nvals), 0);
        if mod(ic(2)-1, 2) % ramp channel
            trigmode = smdata.inst(ic(1)).data.trigmode; 
            bitRate = int32(abs(rate / diff(rng)) * 2^32 * updateTime * smdata.inst(ic(1)).data.update(smChan));            
            curr = dacread(inst, sprintf('B%1d;C%1d;d;', dacSlot, dacChan), '%*7c%d'); % B selects slot, C channel      
            if curr < bitVal
                if rate > 0 % Set to not update, then set rate and new value. Then set to update. 
                    dacwrite(inst, sprintf('G8;U%05d;S%011d;G0;', bitVal, bitRate)); % G sets update mode. U upper value. S rate.
                else % Set correct trigger mode, then set rate and new value. 
                    dacwrite(inst, sprintf('G%02d;U%05d;S%011d;', trigmode, bitVal, bitRate));
                end
            else
                if rate > 0
                    dacwrite(inst, sprintf('G8;L%05d;S%011d;G0;', bitVal, -bitRate));
                else
                    dacwrite(inst, sprintf('G%02d;L%05d;S%011d;', trigmode, bitVal, -bitRate));
                end
            end
            val = abs(bitVal-curr) * (nvals+1) * 1e-6 * smdata.inst(ic(1)).data.update(floor((ic(2)+1)/2)) / double(bitRate);            
        else
            dacwrite(inst, sprintf('B%1d;C%1d;D%05d;', dacSlot, dacChan, val));
            val = 0;
        end
    case 0  %read
        bitVal = dacread(inst, sprintf('B%1d;C%1d;d;', dacSlot, dacChan), '%*7c%d');
        val = bitVal*diff(rng)/nvals + rng(1);
        if length(val) > 1
            error(['Apparent DAC comm error. MATLAB sucks.','Consider closing and opening the instrument with smclose and smopen']);
        end
    case 3   % trigger
        dacwrite(inst, sprintf('B%1d;C%1d;G0;', dacSlot, dacChan));
    otherwise
        error('Operation not supported');
end
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
end