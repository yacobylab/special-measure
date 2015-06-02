function val = smcIPS12010GPIB(ico, val, rate)
% Driver for IPS12010 (GPIB version)
% settings for GPIB:
% usually board index is 0, address is 25
% can change Timeout to 1
% 6/27/2012: modified to automatically reset GPIB comm parameters with each
%           invocation.  Much safer.
%           
% 1/18/2010: modified to close and open magnet if behavior is sluggish
%           currently uses tic/toc instead of cputime because of bad
%           behavior of cputime on MX400 computer.
% 4/9/2010: added ramp support (set ramprate < 0, and use
%   scan.loops(1).trigfn.fn=@smatrigfn.  using GUI, setting
%   smscan.loops(1).trigfn.autoset=1 is enough.

tic



global smdata;

if ico(3)==1
    rateperminute = rate*60;
end

%ico: vector with instruemnt(index to smdata.inst), channel number for that instrument, operation
% operation: 0 - read, 1 - set , 2 - unused usually,  3 - trigger
% rate overrides default

%Might need in setup:
%channel 1: FIELD

mag = smdata.inst(ico(1)).data.inst;

%tm=now;
% The next three lines take < 1 microsecond to run.  Why not be kind?
set(mag,'EOIMode','off');
set(mag,'EOSCharCode','CR');
set(mag,'EOSMode','read');
%fprintf('Safety took %f seconds',now-tm);

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
                    
                    if rateperminute<0
                        % set to hold
                        fprintf(mag, '%s\r', 'A0'); fscanf(mag);
                    end
                    
                    % set the rate
                    fprintf(mag, '%s\r', ['T' num2str(abs(rateperminute))]); fscanf(mag);
                    
                    
                    % read current persistent field value
                    curr = NaN;
                    while isnan(curr)
                        fprintf(mag, '%s\r', 'R18');
                        curr = fscanf(mag, '%*c%f');
                    end
                    persistentsetpoint = curr;
                    
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
                        
                        if rateperminute > 0
                            % go to target field
                            fprintf(smdata.inst(ico(1)).data.inst, '%s\r', 'A1');
                            fscanf(smdata.inst(ico(1)).data.inst);

                            waittime = abs(val-curr)/abs(rate);

                            pause(waittime+5);

                            fprintf(mag, '%s\r', 'H0'); fscanf(mag);  % turn off switch heater
                            pause(10);
                            fprintf(mag, '%s\r', 'A2'); fscanf(mag);  % set leads to zero
                             val = 0;  
                        else
                            val = abs(val-curr)/abs(rate);
                        end
                    end
                        
                                  
                    
                else % magnet not persistent


                    % any way to delay trigger
                    if abs(rateperminute) > .5; %.5 T /MIN
                        error('Magnet ramp rate too high')
                    end

                    % put instrument in remote controlled mode
                    fprintf(mag, '%s\r', 'C3');
                    fscanf(mag);
                    
                    if rateperminute<0
                        % set to hold
                         fprintf(mag, '%s\r', 'A0'); fscanf(mag);
                    end

                    % set the rate
                    fprintf(mag, '%s\r', ['T' num2str(abs(rateperminute))]);
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
                    
                    val = abs(val-curr)/abs(rate);
                    
                    if rateperminute>0
        
                        % go to target field
                        fprintf(mag, '%s\r', 'A1');
                        fscanf(mag);
                      
                        elapsedtime=toc;
                        if elapsedtime>2
                            fclose(mag);
                            fopen(mag);
                        end
                    end
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
                 

                 elapsedtime=toc;
                if elapsedtime>2
                    fclose(mag);
                    fopen(mag);
                end
                
            case 3 % trigger
                % go to target field
                fprintf(mag, '%s\r', 'A1'); fscanf(mag);
                
            otherwise
                error('Operation not supported');
        end
        
    otherwise
        error('Channel not programmed');

end

