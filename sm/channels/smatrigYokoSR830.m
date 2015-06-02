function smatrigYokoSR830(lockins, yokos)

global smdata;

for i = lockins
    fprintf(smdata.inst(i).data.inst, 'REST');
end
pause(.1); %Reset command seems to take some time, this seems OK, did not 
% try to push for less.
for i = yokos
    fprintf(smdata.inst(i).data.inst, 'RU2');
end
for i = lockins
    fprintf(smdata.inst(i).data.inst, 'STRT');
end