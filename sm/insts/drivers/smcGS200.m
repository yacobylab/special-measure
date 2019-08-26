 function val = smcGS200(ico, val, rate)

 % Channels:
% 1: direct set
% 2: ramped set(readout same)

% Old Yoko driver was for the 7651. This new Yoko driver is for the GS200. 

global smdata;


switch ico(3)
    case 2 %(Case 2: Query remaining ramp time)     
        
        val(1) = query(smdata.inst(ico(1)).data.inst, 'SOURCE:LEV?', '%s\n', '%*4c%f'); 
        
        % ico(1) indicates the instrument
        % OD is Output Value Data Output
        % '%s is string of new characters, \n is new line' - format for
        %written data
        % '%*4c%f' is formatting for read data
        % val(1) is assigned the data read from the instrument. 
        
        %query(smdata.inst(ico(1)).data.inst, 'OP', '%s\n');
        %val(2) = fscanf(smdata.inst(ico(1)).data.inst, '%*5c%f');
        val(2) = query(smdata.inst(ico(1)).data.inst, 'PROG:SLOP?', '%s\n', '%*3c%f');
        % (used to be OP: Program Output) 
        % fscanf reads data from open text file from fileID
        % val(2) is the value that instrument was set to 
        
        while smdata.inst(ico(1)).data.inst.BytesAvailable > 0
            fscanf(smdata.inst(ico(1)).data.inst);
        end
        % If there is extra data, keep reading. I guess. 
        
        val = abs(diff(val)/rate); 


    case 1 %Set channel value to val. 
        %fprintf(smdata.inst(ico(1)).data.inst, 'SOUR:RANG 30E0');
        switch ico(2)
            case 1 % Direct Set
                %fprintf(smdata.inst(ico(1)).data.inst, 'SOUR:FUNC VOLT'); %Change to CURR if you need current
                %fprintf(smdata.inst(ico(1)).data.inst, 'SOUR:RANG 30E0'); %MAX sets range to 30V. 1E0, 10E0, or 30E0 are other options. 
                %fprintf(smdata.inst(ico(1)).data.inst, 'OUTP ON'); %Switches Output ON
                fprintf(smdata.inst(ico(1)).data.inst, 'SOUR:LEV %2.6f', val); 
                %Writes command 'val' to object smdata.inst(ico(1).data.inst, 
                %f is Fixed-point notation
            case 2 % Ramped Set

                currentRange = query(smdata.inst(ico(1)).data.inst, 'SOUR:RANG?', '%s\n'); 
                curr = str2num(query(smdata.inst(ico(1)).data.inst, 'SOUR:LEV?', '%s\n'));

                if rate == 0
                    if abs(curr - val) < abs(val)*1e-4
                        val = 0;
                        return
                    else
                        error('Cannot ramp at zero rate.');
                    end
                end
                
                rt = round(10 * min(abs((curr - val)/rate), 3600))/10;

                %cmd = sprintf('PI%.1f SW%.1f PRS S%.4e PRE M1', max(rt, .1), rt, val);
                fprintf(smdata.inst(ico(1)).data.inst, 'PROG:REP OFF');
                fprintf(smdata.inst(ico(1)).data.inst, sprintf('PROG:INT %4.2f', max(rt,.1)));
                fprintf(smdata.inst(ico(1)).data.inst, sprintf('PROG:SLOP %4.2f', max(rt,.1)));
                %fprintf(myYoko, sprintf('PROG:MEM "%2.6f,1.0,V"', startVoltage));
                fprintf(smdata.inst(ico(1)).data.inst, [sprintf('PROG:MEM "%2.6f,', curr) currentRange ',V"']);
                fprintf(smdata.inst(ico(1)).data.inst, [sprintf('PROG:MEM "%2.6f,', val) currentRange ',V"']);
                
                
                if rate > 0
                    % start ramp
                    fprintf(smdata.inst(ico(1)).data.inst, 'PROG:RUN');
                end
                val = max(rt, .1);
        end
        
    case 0 %Read channel Value (smget)
%         val = query(smdata.inst(ico(1)).data.inst,'SOURCE:LEV?', '%s\n', '%*4c%f');
        val = query(smdata.inst(ico(1)).data.inst,'SOURCE:LEV?');
        val = str2num(val);
        
    case 3 %Trigger previously programmed ramp) 
%         fprintf(smdata.inst(ico(1)).data.inst, 'RU2'); OLD
        fprintf(smdata.inst(ico(1)).data.inst, 'PROG:RUN');
%         RU2 is the function of executing the program from the beginning (the first
%         step) and corresponds to pressing the RUN key on the front panel.
%         
%         execution
          
    otherwise
        error('Operation not supported');
end

