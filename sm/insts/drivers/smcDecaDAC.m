function val = smcDecaDAC(ic, val, rate)
% Driver for Jim MacArthur's DecaDAC. With ramp support and new trigger scheme. Odd channels are ramped.
% function val = smcDecaDAC(ic, val, rate)
% returns ramptime. 
% Requires setting trigmode, rng, update in smdata.inst
% Setting a voltage with a negative ramprate means trigger must be provided to start ramp. 
global smdata;

if ~isfield(smdata.inst(ic(1)).data,'nbits')
    nbits = 16; 
else
    nbits = smdata.inst(ic(1)).data.nbits;
end
if ~isfield(smdata.inst(ic(1)).data,'nChansPerSlot')
    nChansPerSlot = 4; 
else
    nChansPerSlot = smdata.inst(ic(1)).data.nChansPerSlot;
end
nvals = 2^nbits -1;
updateTimeUnit = 1e-6;  % units of update time are us. 
rng = smdata.inst(ic(1)).data.rng(floor((ic(2)-1)/2)+1, :);
dacSlot = floor((ic(2)-1)/(2*nChansPerSlot)); 
dacChan = floor(mod(ic(2)-1, 2*nChansPerSlot)/2); 
smChan = floor((ic(2)+1)/2);
inst = smdata.inst(ic(1)).data.inst;
switch ic(3)
    case 1 % set
        bitVal = round((val - rng(1))/ diff(rng) * nvals); % Find bit corresponding to voltage
        bitVal = max(min(bitVal, nvals), 0); % Check that within range. 
        if mod(ic(2)-1, 2) % ramp channel
            trigmode = smdata.inst(ic(1)).data.trigmode; 
            bitRate = int32(abs(rate / diff(rng)) * 2^32 * updateTimeUnit * smdata.inst(ic(1)).data.update(smChan)); % DAC updates every "update" us (configured in smadacinit). This finds # bits to change/unit.
            curr = dacread(inst, sprintf('B%1d;C%1d;d;', dacSlot, dacChan), '%*7c%d'); % B selects slot, C channel. Current DAC value
            if curr < bitVal % If increasing voltage
                if rate > 0 %Configure and start ramp: set to not update, then set rate and new value. Then set to update. 
                    dacwrite(inst, sprintf('G8;U%05d;S%011d;G0;', bitVal, bitRate)); % G sets update mode. U upper value. S rate.
                else % Configure ramp, then await trigger. Set correct trigger mode, then set rate and new value. 
                    dacwrite(inst, sprintf('G%02d;U%05d;S%011d;', trigmode, bitVal, bitRate));
                end
            else % decreasing voltage
                if rate > 0 %Configure and start ramp: set to not update, then set rate and new value. Then set to update. 
                    dacwrite(inst, sprintf('G8;L%05d;S%011d;G0;', bitVal, -bitRate));
                else % Configure ramp, then await trigger. Set correct trigger mode, then set rate and new value. 
                    dacwrite(inst, sprintf('G%02d;L%05d;S%011d;', trigmode, bitVal, -bitRate));
                end
            end
            val = abs(bitVal-curr) * (nvals+1) * 1e-6 * smdata.inst(ic(1)).data.update(floor((ic(2)+1)/2)) / double(bitRate); % Remaining ramp time
        else % Step channel
            dacwrite(inst, sprintf('B%1d;C%1d;D%05d;', dacSlot, dacChan, val));
            val = 0;
        end
    case 0  %read 
        bitVal = dacread(inst, sprintf('B%1d;C%1d;d;', dacSlot, dacChan), '%*7c%d');
        val = bitVal*diff(rng)/nvals + rng(1); % Convert bit # to voltage
        if length(val) > 1
            error(['Apparent DAC comm error. MATLAB sucks.','Consider closing and opening the instrument with smclose and smopen']);
        end
    case 3   % software trigger
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
if ~exist('format','var')
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