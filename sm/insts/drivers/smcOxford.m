function val = smcOxford(ico,rate)
% Currently assumes there is only one IGH connected to the system. Seems
% reasonable. 
% Channels: MC
chanList = {'M/C'}; 
switch chanList{ico(2)}
    case 'M/C'
        switch ico(3) 
            case 0 
                val = getIGH('M/C'); 
            case 1
                error('Cannot set this channel');             
        end        
end

end