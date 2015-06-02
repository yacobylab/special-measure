function smclose(inst)
% smclose(inst)
% Closes smdata.inst(i).data.inst for all i in inst, if defined.
% Default is to try to close all instruments.

global smdata;
if nargin < 1
    inst = 1:length(smdata.inst);
end

inst = sminstlookup(inst);

for i = inst
    if isfield(smdata.inst(i), 'data') && isfield(smdata.inst(i).data, 'inst')
        fclose(smdata.inst(i).data.inst);
    end
end
    
    