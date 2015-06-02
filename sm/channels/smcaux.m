function val = smcaux(ico, val, rate)
% auxiliary functions not related to instruments
% channels: 
% 1: date/time as returned by now.

%global smdata;

switch ico(2) 
    case 1 % time
        switch ico(3)      
            case 0
                val = now;

            otherwise
                error('Operation not supported');
        end
end
