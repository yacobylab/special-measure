function val = smcCS410V(ico, val, rate)
% Driver for CS4-10V (GPIB version)
%
% Rate is not allowed to exceed specifications given for micrcoscope
% magnet in each range.  Switching ranges mid-sweep may cause the rate to
% change to the previously stored value for that range.
%
% For positive fields, lower limit is set to zero, and upper limit is set
% to desired setpoint.  For negative fields, the upper limit is set to zero
% and the lower limit is set to the desired setpoint.  For zero field,
% upper limit is set to 1 T and lower limit is set to 0.
%
% More details to be added later.

global smdata;

%ico: vector with instruemnt(index to smdata.inst), channel number for that instrument, operation
% operation: 0 - read, 1 - set , 2 - unused usually
% rate overrides default

%Might need in setup:
%channel 1: FIELD
%channel 2: RAMP (goes to setpoint in one sweep)

% Select units in T
fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'Units T');
fscanf(smdata.inst(ico(1)).data.inst);

if ico(3)==1
    % Read current magnetic field
    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'IOUT?');
    resp = fscanf(smdata.inst(ico(1)).data.inst);
    [splitresp] = regexp(resp, ' ', 'split');
    currentfield = str2double(splitresp(1));

    % Determine and set current magnetic field range
    currentrange = 0;
    if abs(currentfield) > 6.232
        currentrange = 1;
    end
    if abs(currentfield) > 9.9712
        currentrange = 2;
    end

    % Make sure that magnet ramp rate is low enough
    if (rate > 8.3e-3) && (currentrange == 0);
        rate = 8.3e-3;
    elseif (rate > 5.5e-3) && (currentrange == 1);
        rate = 5.5e-3;
    elseif (rate > 2.8e-3) && (currentrange == 2);
        rate = 2.8e-3;
        
% Do we need to account for negative rates?  Probably not.
% % %     elseif (rate < -8.3e-3) && (currentrange == 0);
% % %         rate = -8.3e-3;
% % %     elseif (rate < -5.5e-3) && (currentrange == 1);
% % %         rate = -5.5e-3;
% % %     elseif (rate < -2.8e-3) && (currentrange == 2);
% % %         rate = -2.8e-3;

    end
end


switch ico(2) %channel

    case 1
        switch ico(3) %Operation

            case 1 % SET
                % Put instrument in remote controlled mode
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'RL1');
                fscanf(smdata.inst(ico(1)).data.inst);
                
                % Set the rate
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['RATE' num2str(currentrange) num2str(rate)]);
                fscanf(smdata.inst(ico(1)).data.inst);
                
                % Set the field target and go to it
                % Positive fields
                if val > 0;
                    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'LLIM 0');
                    fscanf(smdata.inst(ico(1)).data.inst);
                    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['ULIM' num2str(val)]);
                    fscanf(smdata.inst(ico(1)).data.inst);
                    
                    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'SWEEP UP');
                    fscanf(smdata.inst(ico(1)).data.inst);
                
                % Negative fields
                elseif val < 0;
                    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'ULIM 0');
                    fscanf(smdata.inst(ico(1)).data.inst);
                    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['LLIM' num2str(val)]);
                    fscanf(smdata.inst(ico(1)).data.inst);
                    
                    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'SWEEP DOWN');
                    fscanf(smdata.inst(ico(1)).data.inst);
                    
                % B = 0
                elseif val = 0;
                    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'ULIM 1');
                    fscanf(smdata.inst(ico(1)).data.inst);
                    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'LLIM 0');
                    fscanf(smdata.inst(ico(1)).data.inst);
                    
                    fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'SWEEP DOWN');
                    fscanf(smdata.inst(ico(1)).data.inst);
   
                end
                    
                val = abs(val-currentfield)/abs(rate);
                
            case 0 % GET
                % Read current magnetic field
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'IOUT?');
                resp = fscanf(smdata.inst(ico(1)).data.inst);
                [splitresp] = regexp(resp, ' ', 'split');
                currentfield = str2double(splitresp(1));
                
            otherwise
                error('Operation not supported');
        end
        
    case 2
        error('Channel not supported');
        
end

