function val = smc5071c(ic, val, ~) 
% Driver for Agilent E5071C Network Analyzer
% val = smc5071c(ic, val, ~) 

global smdata; 

switch ic(3) % operation 
    case 1 % set
        switch ic(2)
            case 1 %start freq
                fprintf(smdata.inst(ic(1)).data.inst, sprintf(':SENS1:FREQ:STAR %f', val));                
            case 2 %stop freq
                fprintf(smdata.inst(ic(1)).data.inst, sprintf(':SENS1:FREQ:STOP %f', val));            
            case 3 %power
                fprintf(smdata.inst(ic(1)).data.inst, sprintf(':SOUR1:POW %f', val));            
            case 4 %bandwidth
                fprintf(smdata.inst(ic(1)).data.inst, sprintf(':SENS1:BAND %f', val));                
            case 5 %npoints
                fprintf(smdata.inst(ic(1)).data.inst, sprintf(':SENS1:SWE:POIN %f', val));
                smdata.inst(ic(1)).datadim(6:10) = val*ones(5,1);                             
            case {6,7,8,9,10}
                error('Cant write this channel')
        end        
    case 0 %read 
        switch ic(2)            
            case 1 %start freq
                fprintf(smdata.inst(ic(1)).data.inst, ':SENS1:FREQ:STAR?');
                val = fscanf(smdata.inst(ic(1)).data.inst);                
            case 2 %stop freq
                fprintf(smdata.inst(ic(1)).data.inst, ':SENS1:FREQ:STOP?');
                val = str2double(fscanf(smdata.inst(ic(1)).data.inst));                                            
            case 3 %power
                fprintf(smdata.inst(ic(1)).data.inst, ':SOUR1:POW?');
                val = str2double(fscanf(smdata.inst(ic(1)).data.inst));            
            case 4 %bandwidth
                fprintf(smdata.inst(ic(1)).data.inst, ':SENS1:BAND?');
                val = str2double(fscanf(smdata.inst(ic(1)).data.inst));                                
            case 5 %npoints
                fprintf(smdata.inst(ic(1)).data.inst, ':SENS1:SWE:POIN?');
                val = str2double(fscanf(smdata.inst(ic(1)).data.inst));
                smdata.inst(6).datadim(6:10) = val*ones(5,1);      
            case 6 %Frequency vector
                %npoints = smdata.inst(6).datadim(6); 
                fprintf(smdata.inst(ic(1)).data.inst, ':SENS1:FREQ:DATA?\n');
                val = fscanf(smdata.inst(ic(1)).data.inst, '%e,');               
            case 7 % S21 MLOG               
                fprintf(smdata.inst(ic(1)).data.inst, ':CALC1:TRAC1:FORM MLOG');
                fprintf(smdata.inst(ic(1)).data.inst, ':CALC1:PAR1:DEF S21');
                fprintf(smdata.inst(ic(1)).data.inst, sprintf(':CALC1:DATA:FDAT?'));
                npoints = smdata.inst(ic(1)).datadim(7);                 
                datatmp = fscanf(smdata.inst(ic(1)).data.inst, '%e,',[2 npoints]);
                val=datatmp(1,:);                                 
            case 8 %S21 PHS
                fprintf(smdata.inst(ic(1)).data.inst, ':CALC1:TRAC1:FORM PHAS');
                fprintf(smdata.inst(ic(1)).data.inst, ':CALC1:PAR1:DEF S21');
                fprintf(smdata.inst(ic(1)).data.inst, sprintf(':CALC1:DATA:FDAT?'));
                npoints = smdata.inst(ic(1)).datadim(8);     
                datatmp = fscanf(smdata.inst(ic(1)).data.inst, '%e,',[2 npoints]);
                val=datatmp(1,:);                    
            case 9 %S11 MLG
                fprintf(smdata.inst(ic(1)).data.inst, ':CALC1:TRAC1:FORM mLOG');
                fprintf(smdata.inst(ic(1)).data.inst, ':CALC1:PAR1:DEF S11');
                fprintf(smdata.inst(ic(1)).data.inst, sprintf(':CALC1:DATA:FDAT?'));
                npoints = smdata.inst(ic(1)).datadim(9);     
                datatmp = fscanf(smdata.inst(ic(1)).data.inst, '%e,',[2 npoints]);
                val=datatmp(1,:);                    
            case 10 %S11 PHASE 
                fprintf(smdata.inst(ic(1)).data.inst, ':CALC1:TRAC1:FORM PHAS');
                fprintf(smdata.inst(ic(1)).data.inst, ':CALC1:PAR1:DEF S11');
                fprintf(smdata.inst(ic(1)).data.inst, sprintf(':CALC1:DATA:FDAT?'));
                npoints = smdata.inst(ic(1)).datadim(10);     
                datatmp = fscanf(smdata.inst(ic(1)).data.inst, '%e,',[2 npoints]);
                val=datatmp(1,:);   
        end                
end
end