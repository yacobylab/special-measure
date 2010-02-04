function val = smcIPS12010GPIB(ico, val, rate)
% Driver for IPS12010 (GPIB version)
% settings for GPIB:
% usually board index is 0, address is 25
% can change Timeout to 1
% make sure to change the following
%               EOIMode = 'off'
%               EOSCharCode = 'CR'
%               EOSMode = 'read'



global smdata;
IPSaddress = 25; % for He4 station

if ico(3)==1
    rateperminute = rate*60;
end

%ico: vector with instruemnt(index to smdata.inst), channel number for that instrument, operation
% operation: 0 - read, 1 - set , 2 - unused usually
% rate overrides default

%Might need in setup:
%channel 1: FIELD
mag = smdata.inst(ico(1)).data.inst;

switch ico(2) % channel

    case 1 % [standard] Magnet going to set point, then holding at set point

        switch ico(3)

            case 1 % set 
                
                
                fprintf(mag, '%s\r', 'X');
                state = fscanf(mag);
                
                if state(9)== '2' || state(9)=='0'  %magnet persistent at field or persistent at 0
                    % any way to delay trigger
                    if abs(rateperminute) > .5; %.5 T /MIN
                        error('Magnet ramp rate too high')
                    end
                    
                    % put instrument in remote controlled mode
                    fprintf(mag, '%s\r', 'C3');    fscanf(mag);
                    
                    % set the rate
                    fprintf(mag, '%s\r', ['T' num2str(rateperminute)]); fscanf(mag);
                    
                    
                    % read current persistent field value
                    curr = NaN;
                    while isnan(curr)
                        fprintf(mag, '%s\r', 'R18');
                        curr = fscanf(mag, '%*c%f');
                    end
                    persistentsetpoint = curr;
                    val;
                    
                    if curr ~= val %only go through trouble if we're not at the target field
                        % get out of persistent mode [code from magpersistoff]
                        
                            % turn off switch heater to be safe
                            fprintf(mag, '%s\r', 'H0'); fscanf(mag);  
                            pause(3);

                            % make the persistent field value the setpoint
                            fprintf(mag, '%s\r', ['J' num2str(persistentsetpoint)]); fscanf(mag);

                            % go to setpoint
                            fprintf(mag, '%s\r', 'A1'); fscanf(mag);

                            % get the current field value
                            fprintf(mag, '%s\r', ['R7']);
                            currstring = fscanf(mag);
                            currentfield = str2double(currstring(2:end));

                            % wait until persistent field value is reached
                            pause(10)
                            while currentfield ~= persistentsetpoint
                                fprintf(mag, '%s\r', ['R7']); currstring = fscanf(mag);
                                currentfield = str2double(currstring(2:end));
                                pause(10);
                            end

                            % switch on heater
                            fprintf(mag, '%s\r', 'H1'); fscanf(mag);  
                        
                        pause(10);
                        % set the field target
                        fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['J' num2str(val)]);
                        fscanf(smdata.inst(ico(1)).data.inst);
                    
                        % go to target field
                        fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'A1');
                        fscanf(smdata.inst(ico(1)).data.inst);
                    
                        waittime = abs(val-curr)/abs(rate);
                    
                        pause(waittime+5);
                        
                        fprintf(mag, '%s\r', 'H0'); fscanf(mag);  % turn off switch heater
                        pause(10);
                        fprintf(mag, '%s\r', 'A2'); fscanf(mag);  % set leads to zero
                    end
                        
                    val = 0;                   
                    
                else % magnet not persistent


                    % any way to delay trigger
                    if abs(rateperminute) > .5; %.5 T /MIN
                        error('Magnet ramp rate too high')
                    end

                    % put instrument in remote controlled mode
                    fprintf(mag, '%s\r', 'C3');
                    fscanf(mag);
                    
                    

                    % set the rate
                    fprintf(mag, '%s\r', ['T' num2str(rateperminute)]);
                    fscanf(mag);


                    % read the current field value
                    curr = NaN;
                    while isnan(curr)
                        fprintf(mag, '%s\r', 'R7');
                        curr = fscanf(mag, '%*c%f');
                    end

                    % set the field target
                    fprintf(mag, '%s\r', ['J' num2str(val)]);
                    fscanf(mag);

                    % go to target field
                    fprintf(mag, '%s\r', 'A1');
                    fscanf(mag);


                    val = abs(val-curr)/abs(rate);
                    
                end
                
            case 0 % read the current field value
                 fprintf(mag, '%s\r', 'X');
                 state = fscanf(mag);
                 val = NaN;
                 while isnan(val)
                    if state(9) == '2'
                        fprintf(mag, '%s\r', 'R18');
                    else
                        fprintf(mag, '%s\r', 'R7');
                    end
                    val = fscanf(mag, '%*c%f');
                 end
                
            otherwise
                error('Operation not supported');
        end
        
    case 2
        switch ico(3)
            case 1                
                % set the rate
                fprintf(mag, '%s\r', ['T' num2str(rateperminute)]);
                fscanf(mag);

                % read the current field value
                fprintf(mag, '%s\r', 'R7');
                currstring = fscanf(mag);
                curr=str2double(currstring(2:end));
                
                % set the field target
                fprintf(mag, '%s\r', ['J' num2str(val)]);
                fscanf(mag);
                                
                val = abs(val-curr)/abs(rate);

            case 0
                % read the current field value
                fprintf(mag, '%s\r', 'R8');
                val = fscanf(mag, '%*c%f');
                
            otherwise
                error('Operation not supported');
        end

end

