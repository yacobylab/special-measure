function val = smcDecaDAC(ic, val, rate)
% 1-12 = channel 0 - 11

global smdata;

switch ic(3)
    case 1
        val = round((val - smdata.inst(ic(1)).data.rng(ic(2), 1))...
            / diff(smdata.inst(ic(1)).data.rng(ic(2), :)) * 65535);
        val = max(min(val, 65535), 0);
        try
            query(smdata.inst(ic(1)).data.inst, ...
                sprintf('B%1d;C%1d;D%05d;', floor((ic(2)-1)/4), mod(ic(2)-1, 4), val));
        catch
            fprintf('WARNING: error in DAC communication. Flushing buffer.\n');
            smflush(ic(1));
        end
        val = 0;

    case 0
        try
            val = query(smdata.inst(ic(1)).data.inst, ...
                sprintf('B%1d;C%1d;d;', floor((ic(2)-1)/4), mod(ic(2)-1, 4)), '%s\n', '%*7c%d');
        catch
            fprintf('WARNING: error in DAC communication. Flushing buffer.\n');
            smflush(ic(1));
        end

        
        val = val*diff(smdata.inst(ic(1)).data.rng(ic(2), :))/65535 ...
            + smdata.inst(ic(1)).data.rng(ic(2), 1);

    otherwise
        error('Operation not supported');

end
        
