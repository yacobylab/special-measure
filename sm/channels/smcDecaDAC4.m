function val = smcDecaDAC4(ic, val, rate)
% With ramp support and new trigger scheme. Odd channels are ramped.
% Improved error treatment compared to smcdecaDAC3.m
global smdata;

nbits = 16; nvals = 2^nbits -1; 
if smdata.inst(ic(1)).channels(ic(2), 1) == 'S' % script 
    switch ic(3)
        case 1
            query(smdata.inst(ic(1)).data.inst, 'X0;'); % clear buffer to avoid overflows
            if val > 0
                pause(.02); % seems to help avoiding early triggers.
                fprintf(smdata.inst(ic(1)).data.inst, '%s', sprintf('X%d;', val));
            end
            % suppress terminator which would stop the script
            smdata.inst(ic(1)).data.scriptaddr = val;       
        case 0
            val = smdata.inst(ic(1)).data.scriptaddr;
    end
    return;
end
rng = smdata.inst(ic(1)).data.rng(floor((ic(2)-1)/2)+1, :);
dacslot = floor((ic(2)-1)/8); 
dacchan = floor(mod(ic(2)-1, 8)/2); 
switch ic(3)
    case 1 % set
        val = round((val - rng(1))/ diff(rng) * nvals);
        val = max(min(val, nvals), 0);
        if mod(ic(2)-1, 2) % ramp channel
            trigmode = smdata.inst(ic(1)).data.trigmode; 
            rate2 = int32(abs(rate / diff(rng)) * 2^32 * 1e-6 * smdata.inst(ic(1)).data.update(floor((ic(2)+1)/2)));            
            curr = dacread(smdata.inst(ic(1)).data.inst, sprintf('B%1d;C%1d;d;', dacslot, dacchan), '%*7c%d'); % B selects slot, C channel      
            if curr < val
                if rate > 0 % Set to not update, then set rate and new value. Then set to update. 
                    dacwrite(smdata.inst(ic(1)).data.inst, sprintf('G8;U%05d;S%011d;G0;', val, rate2)); % G sets update mode. U upper value. S rate.
                else % Set correct trigger mode, then set rate and new value. 
                    dacwrite(smdata.inst(ic(1)).data.inst, sprintf('G%02d;U%05d;S%011d;', trigmode, val, rate2));
                end
            else
                if rate > 0
                    dacwrite(smdata.inst(ic(1)).data.inst, sprintf('G8;L%05d;S%011d;G0;', val, -rate2));
                else
                    dacwrite(smdata.inst(ic(1)).data.inst, sprintf('G%02d;L%05d;S%011d;', trigmode, val, -rate2));
                end
            end
            val = abs(val-curr) * (nvals+1) * 1e-6 * smdata.inst(ic(1)).data.update(floor((ic(2)+1)/2)) / double(rate2);            
        else
            dacwrite(smdata.inst(ic(1)).data.inst, sprintf('B%1d;C%1d;D%05d;', dacslot, dacchan, val));
            val = 0;
        end
    case 0      %read
        val = dacread(smdata.inst(ic(1)).data.inst, sprintf('B%1d;C%1d;d;', dacslot, dacchan), '%*7c%d');
        val = val*diff(rng)/nvals + rng(1);
        if length(val) > 1
            error(['Apparent DAC comm error. MATLAB sucks.','Consider closing and opening the instrument with smclose and smopen']);
        end
    case 3   % trigger
        dacwrite(smdata.inst(ic(1)).data.inst, sprintf('B%1d;C%1d;G0;', dacslot, dacchan));
    otherwise
        error('Operation not supported');
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