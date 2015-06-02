function val = smcIPS12010(ico, val, rate)

global smdata;
IPSaddress = 1; %default for oxford
rateperminute = rate*60;

%ico: vector with instruemnt(index to smdata.inst), channel number for that instrument, operation
% operation: 0 - read, 1 - set , 2 - unused usually
% rate overrides default

%Might need in setup:
%channel 1: FIELD

switch ico(2) % channel

    case 1

        switch ico(3)

            case 1
                % any way to delay trigger
                if abs(rateperminute) > .5; %.5 T /MIN
                    error('Magnet ramp rate too high')
                end
                
                % put instrument in remote controlled mode
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['@' int2str(IPSaddress) 'C3']);
                fscanf(smdata.inst(ico(1)).data.inst);
                
                % set the rate
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['@' int2str(IPSaddress) 'T' num2str(rateperminute)]);
                fscanf(smdata.inst(ico(1)).data.inst);
                
                % read the current field value
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['@' int2str(IPSaddress) 'R7']);
                currstring = fscanf(smdata.inst(ico(1)).data.inst);
                curr=str2double(currstring(3:end));
                
                % set the field target
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['@' int2str(IPSaddress) 'J' num2str(val)]);
                fscanf(smdata.inst(ico(1)).data.inst);
                
                % go to target field
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['@' int2str(IPSaddress) 'A1']);
                fscanf(smdata.inst(ico(1)).data.inst);
                

                val = abs(val-curr)/rate;
            case 0
                % read the current field value
                fprintf(smdata.inst(ico(1)).data.inst, '%s\r', ['@' int2str(IPSaddress) 'R7']);
                val = fscanf(smdata.inst(ico(1)).data.inst);
                
            otherwise
                error('Operation not supported');
        end
end

function val = querycheck(inst, cmd, varargin)
% sometimes the query doesnt seem to terminate properly. This check should
% fix the problem.
val = [];
i = 1;
while isempty(val) && i < 10
    val = query(inst, cmd, varargin{:}); 
    if isempty(val)
        fscanf(inst);
    end
    i = i+1;
end
if i == 10
    error('Max retries exceeded for reading from AMI420.');
end
