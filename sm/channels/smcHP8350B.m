function val = smcHP8350B(ic, val, rate)
% 1: freq, 2: power
% units are Hz and dBm

global smdata;

cmds = {'CW', 'PL'};
units = {'HZ', 'DM'};

switch ic(3)
    case 1
        fprintf(smdata.inst(ic(1)).data.inst, sprintf('%s %f %s', cmds{ic(2)}, val, units{ic(2)}));
    case 0
        val = query(smdata.inst(ic(1)).data.inst, sprintf('OP %s', cmds{ic(2)}), '%s\n', '%f');
    otherwise
        error('Operation not supported');
end

