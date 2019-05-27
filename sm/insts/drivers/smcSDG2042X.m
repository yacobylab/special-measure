function [val, rate] = smcSDG2042X(ic, val, rate, ctrl)
% [val, rate] = smcSDG2042X(ic, val, rate, ctrl)
% limited driver for Siglent waveform generator.  sets waveform
% parameters in volts.

global smdata;
        
cmds = {'C1:BSWV AMP,', 'C1:BSWV OFST,', 'C1:BSWV HLEV,','C2:BSWV AMP,', 'C2:BSWV OFST,', 'C2:BSWV HLEV,'};

if ic(3)
    fprintf(smdata.inst(ic(1)).data.inst, sprintf('%s %f', cmds{ic(2)}, val));
else
    val = 1;
    rate = 1;
end