function val = smcN5183A(ic, val, rate)
% 1: freq, 2: power
% the scales variable will make it so that we can think in Hz and dBm
% this is identical in principle to the HP1000A, but seems to require a 
% somewhat more strict interpretation of the SCPI instruction set.


global smdata;

%cmds = {':FREQ:CW %.10f MHz; *LCL;', ':AMPL:CW %f dBm'};
cmds = {':FREQ:CW %.10f MHz', 'SOUR:POW:LEV:IMM:AMPL %.6f',':FM:DEV %.10f MHz'};
queries={':FREQ:CW?',':SOUR:POW:LEV:IMM:AMPL?',':FM:DEV?'};
scales = [1e6, 1, 1e6];
switch ic(3)
    case 1
        fprintf(smdata.inst(ic(1)).data.inst, sprintf(cmds{ic(2)},val/scales(ic(2))));
    case 0
        val = query(smdata.inst(ic(1)).data.inst, queries{ic(2)}, '%s\n', '%f');
    otherwise
        error('Operation not supported');
end