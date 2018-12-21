function smadacstepmode(ch, inst)
% Set DecaDAC channel mode to allow stepped operation after ramping.
% smadacstepmode(ch, inst)
% Sets physical channel ch, counting up from 0. 

global smdata;

if ~exist('inst','var')
    inst = sminstlookup('DecaDAC');
else
    inst = sminstlookup(inst);
end

query(smdata.inst(inst).data.inst, sprintf('B%1d;C%1d;S0;L0;U65535;G0;', floor(ch/4), mod(ch, 4)));
end