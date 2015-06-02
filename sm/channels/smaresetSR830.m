function dummy = smaresetSR830(dummy, inst, pt)
% smaresetSR830dmm(dummy, inst)

global smdata;

fprintf(smdata.inst(inst).data.inst, 'REST');
smdata.inst(inst).data.currsamp = 0;
if nargin < 3
    pause(.1); %needed to give instrument time before next trigger.
    % anything much shorter leads to delays.
else
    pause(pt);
end