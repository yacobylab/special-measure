function val = smcN(ic, val, rate)

global smdata;

switch ic(3); % OPERATION TO PERFORM
    case 1 % SET
        smset(ic(1),val);    
        val = 0;
    case 0 % GET
        val = smget(ic(1)); % return the requested value        

          
    otherwise
        error('Operation not supported');
end

