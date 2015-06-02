function val = smcAWG520(ico, val, rate)
% 1: freq (FG mode), 2: clock (AWG mode), 3,4: CH1,2 amplitude (not sure if working in FG mode),  
% 5: jump to line (requires active sequence)
% 6:13: MARKER 1-4 Low/High

global smdata;

cmds = {'AWGC:FG:FREQ', ':FREQ', 'SOUR1:VOLT', 'SOUR2:VOLT', 'AWGC:EVEN:SOFT', ...
    'SOUR1:MARK1:VOLT:LOW', 'SOUR1:MARK1:VOLT:HIGH', 'SOUR1:MARK2:VOLT:LOW', 'SOUR1:MARK2:VOLT:HIGH', ... 
    'SOUR2:MARK1:VOLT:LOW', 'SOUR2:MARK1:VOLT:HIGH', 'SOUR2:MARK2:VOLT:LOW', 'SOUR2:MARK2:VOLT:HIGH', ...
    'AWGC:FG1:PULS:DCYC', 'AWGC:FG2:PULS:DCYC'};
%cmds = {'AWGC:FG:FREQ', ':FREQ', 'SOUR1:VOLT', 'SOUR2:VOLT', 'SEQ:JUMP'};

switch ico(2)
    case 5;
        switch ico(3) 
            case 1
                fprintf(smdata.inst(ico(1)).data.inst, sprintf('%s %f', cmds{ico(2)}, val));
                smdata.inst(ico(1)).data.line = val;
            case 0
                val = smdata.inst(ico(1)).data.line;
            otherwise
                error('Operation not supported');
        end
        
    otherwise
        switch ico(3) 
            case 1
                fprintf(smdata.inst(ico(1)).data.inst, sprintf('%s %f', cmds{ico(2)}, val));
            case 0
                val = query(smdata.inst(ico(1)).data.inst, sprintf('%s?', cmds{ico(2)}), '%s\n', '%f');
            otherwise
                error('Operation not supported');
        end
end
