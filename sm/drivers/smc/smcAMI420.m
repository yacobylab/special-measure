function val = smcAMI420(ico, val, rate)

global smdata;


%Might need in setup:
%SYST:REM
%SYST:LOC
%FIELD:UNITS 1
%CONF:RAMP:RATE:UNITS 1; % not default, for compatibility with sm.

switch ico(2) % channel

    case 1

        switch ico(3)
            case 2 % estimate remaining ramp time
                curr = querycheck(smdata.inst(ico(1)).data.inst,  'FIELD:MAG?', '%s\n', '%f');
                val = querycheck(smdata.inst(ico(1)).data.inst,  'FIELD:PROG?', '%s\n', '%f');
                rate = querycheck(smdata.inst(ico(1)).data.inst, 'RAMP:RATE:FIELD?', '%s\n', '%f')/60;
                val = abs(val-curr)/rate;
                if val < .1
                    val = 0;
                end
            case 1
                % any way to delay trigger
                if abs(rate) > 1/60; % 1 T /MIN
                    error('Magnet ramp rate too high')
                end

                fprintf(smdata.inst(ico(1)).data.inst, 'CONF:RAMP:RATE:FIELD %f', rate*60);

                curr = querycheck(smdata.inst(ico(1)).data.inst,  'FIELD:MAG?', '%s\n', '%f');
                fprintf(smdata.inst(ico(1)).data.inst, 'CONF:FIELD:PROG %f', val);

                val = abs(val-curr)/rate;
            case 0
                val = querycheck(smdata.inst(ico(1)).data.inst,  'FIELD:MAG?', '%s\n', '%f');

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
