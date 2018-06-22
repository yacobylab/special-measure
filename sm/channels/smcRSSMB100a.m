function val = smcRSSMB100a(ic, val, ~)
% Driver for  Rohde & Schwarz Signal generator 
% Channels:  1: freq, 2: power

global smdata;

cmds = {'FREQ:CW %.10fGHz', 'POW:LEV:IMM:AMPL %.8f'};
queries={'FREQ:CW?','POW:LEV?'};
scales = [1e9, 1];
switch ic(3)
    case 1
        fprintf(smdata.inst(ic(1)).data.inst, sprintf(cmds{ic(2)},val/scales(ic(2))));
    case 0
        val = query(smdata.inst(ic(1)).data.inst, queries{ic(2)}, '%s\n', '%f');
    otherwise
        error('Operation not supported');
end