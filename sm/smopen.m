function smopen(inst)
% smopen(inst)
% Opens smdata.inst(i).data.inst for all i in inst, if defined.
% Default is to try to open all instruments.

global smdata;
if nargin < 1
    inst = 1:length(smdata.inst);
end

inst = sminstlookup(inst);

for i = inst
    if isfield(smdata.inst(i), 'data') && isfield(smdata.inst(i).data, 'inst') 
        if strmatch('closed',smdata.inst(i).data.inst.Status)
            fopen(smdata.inst(i).data.inst);
        end
    end
end
    
    