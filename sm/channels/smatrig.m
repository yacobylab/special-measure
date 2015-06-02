function smatrig(inst)

global smdata;

for i = inst
    trigger(smdata.inst(i).data.inst);
end
