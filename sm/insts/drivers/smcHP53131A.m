function [val, rate] = smcHP53131A(ic, val, rate, ctrl)
% [val, rate] = smc53131A(ic, val, rate, ctrl)
% very limited driver for universal counter.  Should be configured on
% instrument front panel for totalize function and with appropriate gate time and triggering in order to perform
% counting using CTS channel.  TRIG sets trigger level in volts. 
% 1: Counts using totalize function, 2: TRIG

global smdata;
        
cmds = {'READ:TOT:TIM', 'EVENT1:LEVEL '};

switch ic(2) % Channel
    case 1
        val = query(smdata.inst(ic(1)).data.inst, sprintf('%s?',cmds{ic(2)}), '%s\n', '%f');
    case 2 %set trigger
        fprintf(smdata.inst(ic(1)).data.inst, sprintf('%s %f', cmds{ic(2)}, val));
end
