function val = smcdmm(ico, val, rate)

global smdata;

switch ico(2) % channel
    case 1
        switch ico(3)
            case 0 %get
                val = query(smdata.inst(ico(1)).data.inst,  'READ?', '%s\n', '%f');

            otherwise
                error('Operation not supported');
        end
        
    case 2
        switch ico(3)
            case 0
                % this blocks until all values are available
                val = sscanf(query(smdata.inst(ico(1)).data.inst,  'FETCH?'), '%f,')';
            case 3 %trigger
                trigger(smdata.inst(ico(1)).data.inst);
            otherwise
                error('Operation not supported');
        end
end
