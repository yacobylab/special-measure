function dummy = smaresetSR830(dummy, inst, pauseTime)
% Stops data storage and resets buffer data (for buffered readout). 
% smaresetSR830dmm(dummy, inst, pt)

global smdata;

fprintf(smdata.inst(inst).data.inst, 'REST');
smdata.inst(inst).data.currsamp = 0;
if ~exist('pauseTime','var')
    pause(.1); %needed to give instrument time before next trigger.
    % anything much shorter leads to delays.
else
    pause(pauseTime);
end