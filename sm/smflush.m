function smflush(inst)
% smflush(inst)
% Read data from smdata.inst(i).data.inst for all i in inst, if defined,
% until BytesAvailable is 0.
% Default is for all instruments.

global smdata;
if nargin < 1
    inst = 1:length(smdata.inst);
end

inst = sminstlookup(inst);

for i = inst
    if isfield(smdata.inst(i), 'data') && isfield(smdata.inst(i).data, 'inst')
        while smdata.inst(i).data.inst.BytesAvailable > 0
            fprintf(fscanf(smdata.inst(i).data.inst));
        end
    end
end
    
    