function val = smcN5183A(ic, val, ~)
% Driver for Agilent N5183A RF signal generator 
% function val = smcN5183A(ic, val, ~)
% Channels: 1: freq (Hz), 2: power (dB) 3: FM 

global smdata;

%CW  Frequency , power, FM
cmds = {':FREQ:CW %.10f MHz', ':POW:LEV:IMM:AMPL %.6f',':FM:DEV %.10f MHz'};
queries={':FREQ:CW?',':POW:LEV:IMM:AMPL?',':FM:DEV?'};
scales = [1e6, 1, 1e6];
switch ic(3)
    case 1
        fprintf(smdata.inst(ic(1)).data.inst, sprintf(cmds{ic(2)},val/scales(ic(2))));
    case 0
        val = query(smdata.inst(ic(1)).data.inst, queries{ic(2)}, '%s\n', '%f');
    otherwise
        error('Operation not supported');
end