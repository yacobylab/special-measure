function [val, rate] = smcdmm(ico, val, rate)
% driver for Agilent DMMs with support for buffered readout. 
% Some instrument and mode dependent parameters hardcoded!
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

            case 4 % arm instrument
                fprintf(smdata.inst(ico(1)).data.inst, 'INIT'); 
                
            case 5 % configure instrument                    
                % minumum time per sample for dmm - heuristic and mode dependent
                %samptime = .04225; %34401A 20 ms integration time
                %samptime = .035; % %34401A 16.7 ms integration time
                samptime = .4025; %34401A 200 ms
                 
                if 1/rate < samptime
                    trigdel = 0;
                    rate = 1/samptime;
                else
                    trigdel = 1/rate - samptime;
                end

                if val > 512 % 50000 for newer model
                    error('More than allowed number of samples requested. Correct and try again!\n');
                end
                fprintf(smdata.inst(ico(1)).data.inst, 'TRIG:SOUR BUS');
                %fprintf(smdata.inst(ind).data.inst, 'VOLT:NPLC 1'); %integrate 1 power line cycle
                fprintf(smdata.inst(ico(1)).data.inst, 'SAMP:COUN %d', val);
                fprintf(smdata.inst(ico(1)).data.inst, 'TRIG:DEL %f', trigdel);
                smdata.inst(ico(1)).datadim(2, 1) = val;
                                
            otherwise
                error('Operation not supported');
        end
end
