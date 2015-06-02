function val = smcRSSMB100a(ic, val, rate)
% 1: freq, 2: power
% this is identical in principle to the HP1000A, but seems to require a 
% somewhat more strict interpretation of the SCPI instruction set.


global smdata;

%fprintf(inst,'SOUR:POW:LEV:IMM:AMPL %.8f',power);
%output = eval(query(inst,'SOUR:FREQ:CW?'))/1e9; in GHz
%fprintf(inst,'SOUR:FREQ:CW %.10fGHz',freq);
%output = eval(query(inst,'SOUR:POW:LEV?'));
cmds = {'SOUR:FREQ:CW %.10fGHz', 'SOUR:POW:LEV:IMM:AMPL %.8f'};
queries={'SOUR:FREQ:CW?','SOUR:POW:LEV?'};
scales = [1e9, 1];
switch ic(3)
    case 1
        fprintf(smdata.inst(ic(1)).data.inst, sprintf(cmds{ic(2)},val/scales(ic(2))));
    case 0
        val = query(smdata.inst(ic(1)).data.inst, queries{ic(2)}, '%s\n', '%f');
    otherwise
        error('Operation not supported');
end
