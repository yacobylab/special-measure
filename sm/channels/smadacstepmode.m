function smadacstepmode(ch, inst)
% smadacstepmode(ch, inst)
% set physical DecaDAC channel ch (starting at 0) to allow stepped
% operation after ramping.

global smdata;

if nargin < 2
    inst = sminstlookup('DecaDAC');
else
    inst = sminstlookup(inst);
end

query(smdata.inst(inst).data.inst, ...
    sprintf('B%1d;C%1d;S0;L0;U65535;G0;', floor(ch/4), mod(ch, 4)));
