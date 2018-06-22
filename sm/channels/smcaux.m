function val = smcaux(ico, val, ~)
% Auxiliary functions not related to physical instruments (e.g. time)
% function val = smcaux(ico, val, ~)
% channels: 
% 1: date/time as returned by now.

switch ico(2) 
    case 1 % time
        switch ico(3)      
            case 0
                val = now;
            otherwise
                warning('Operation not supported');
        end
end
