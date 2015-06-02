function val = smcHP1000A(ic, val, rate)
% 1: freq, 2: power

global smdata;

cmds = {':FREQ', ':POW'};

switch ic(3)
    case 1
        fprintf(smdata.inst(ic(1)).data.inst, sprintf('%s %f', cmds{ic(2)}, val));
    case 0
        val = query(smdata.inst(ic(1)).data.inst, sprintf('%s?', cmds{ic(2)}), '%s\n', '%f');
    otherwise
        error('Operation not supported');     
end


