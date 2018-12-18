function val = smctemplate(ico, val, rate)

global smdata;

switch ico(2) % channel
    case 1
        switch ico(3)
            case 2 % estimate remaining ramp time
                %val =
      
            case 1
                if nargin >= 3 %ramp (optional)
                    %...
                else
                    fprintf(smdata.inst(ico(1)).data.inst, 'FREQ %f', val);
                end
                
            case 0
                val = query(smdata.inst(ico(1)).data.inst,  'FREQ?', '%s\n', '%f');

            otherwise
                error('Operation not supported');
        end
end
