function smadacinit(inst)
%dacinit(inst)
% activate dac outputs and set value to 0.
% also sets update rate if smdata.inst(inst).data.update exists.
% inst defaults to DecaDAC.

global smdata;

if nargin < 1
    inst = sminstlookup('DecaDAC');
else
    inst = sminstlookup(inst);
end

for i = 0:size(smdata.inst(inst).channels, 1)/8-1
    query(smdata.inst(inst).data.inst, sprintf('B%d;M2;', i));
    if isfield(smdata.inst(inst).data, 'update')
       for j = 0:3
           query(smdata.inst(inst).data.inst, sprintf('C%d;T%d;', j, smdata.inst(inst).data.update(4*i+j+1)));
       end
    end
end

for i = 1:size(smdata.inst(inst).channels, 1)/2
    smcDecaDAC4([inst, i, 1], 0);
end