function smatrigYokoTDS(tds, yokos)

global smdata;

for i = yokos
    fprintf(smdata.inst(i).data.inst, 'RU2');
end
fprintf(smdata.inst(tds).data.inst, 'TRIG FORCE');
