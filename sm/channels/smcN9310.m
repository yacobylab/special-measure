function val = smcN9310(ic, val, rate)
% 1: freq, 2: power
% this is identical in principle to the HP1000A, but seems to require a 
% somewhat more strict interpretation of the SCPI instruction set.


global smdata;

cmds = {':FREQ:CW %.10f MHz; *LCL;', ':AMPL:CW %f dBm'};
queries={':FREQ:CW?',':AMPL:CW?'};
scales = [1e6, 1];
switch ic(3)
    case 1
        fprintf(smdata.inst(ic(1)).data.inst, sprintf(cmds{ic(2)},val/scales(ic(2))));
    case 0
        val = query(smdata.inst(ic(1)).data.inst, queries{ic(2)}, '%s\n', '%f');
    otherwise
        error('Operation not supported');
end

