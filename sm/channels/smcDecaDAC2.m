function val = smcDecaDAC2(ic, val, rate)
% With ramp support. Odd channels are ramped.

global smdata;

rng = smdata.inst(ic(1)).data.rng(floor((ic(2)-1)/2)+1, :);

switch ic(3)
    case 1

        val = round((val - rng(1))/ diff(rng) * 65535);
        val = max(min(val, 65535), 0);
                
        if mod(ic(2)-1, 2) % ramp
            rate2 = int32(abs(rate) / diff(rng) * 2^32 * 1e-3);
                
            try
                curr = query(smdata.inst(ic(1)).data.inst, ...
                    sprintf('B%1d;C%1d;d;', floor((ic(2)-1)/8), floor(mod(ic(2)-1, 8)/2)), '%s\n', '%*7c%d');

                if curr < val
                    if rate > 0
                        query(smdata.inst(ic(1)).data.inst, sprintf('S0;U%05d;S%+11d;', val, rate2));
                    else
                        query(smdata.inst(ic(1)).data.inst, sprintf('S0;U%05d;', val));                                                
                        smdata.inst(ic(1)).data.rate(floor((ic(2)+1)/2)) = rate2;                        
                    end
                else
                    if rate > 0
                        query(smdata.inst(ic(1)).data.inst, sprintf('S0;L%05d;S%+11d;', val, -rate2));                    
                    else
                        query(smdata.inst(ic(1)).data.inst, sprintf('S0;L%05d;',  val));
                        smdata.inst(ic(1)).data.rate(floor((ic(2)+1)/2)) = -rate2;
        
                    end
                end
            catch
                fprintf('WARNING: error in DAC communication. Flushing buffer.\n');
                smflush(ic(1));
            end
            val = abs(val-curr) * 65.536 / rate2; 
            
        else
            try
                query(smdata.inst(ic(1)).data.inst, ...
                    sprintf('B%1d;C%1d;D%05d;', floor((ic(2)-1)/8), floor(mod(ic(2)-1, 8)/2), val));
            catch
                fprintf('WARNING: error in DAC communication. Flushing buffer.\n');
                smflush(ic(1));
            end
            val = 0;
        end


    case 0
        try
            val = query(smdata.inst(ic(1)).data.inst, ...
                sprintf('B%1d;C%1d;d;', floor((ic(2)-1)/8), floor(mod(ic(2)-1, 8)/2)), '%s\n', '%*7c%d');
        catch
            fprintf('WARNING: error in DAC communication. Flushing buffer.\n');
            smflush(ic(1));
        end
        val = val*diff(rng)/65535 + rng(1);
        
    case 3        
        smquery(ic(1), sprintf('B%1d;C%1d;S%+11d;', floor((ic(2)-1)/8), floor(mod(ic(2)-1, 8)/2),...
            smdata.inst(ic(1)).data.rate(floor((ic(2)+1)/2))));

    otherwise
        error('Operation not supported');

end
        
