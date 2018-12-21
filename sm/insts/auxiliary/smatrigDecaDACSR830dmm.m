function smatrigDecaDACSR830dmm(dac, lockins, dmms, nolocktrig)
% smatrigDecaDACSR830dmm(dac, lockins, dmms, nolocktrig)
% trigger routines for lockins, DecaDacs and dmms.
% If nolocktrig given and nonzero,  lockin acquisition is only initiated 
% but not triggered, so that the DMM OUT can be used as a 
% trigger signal.  dac is an n x 2 matrix with the instrument and channel
% of each dac channel that needs to be triggered

global smdata;

if nargin < 3
    dmms = [];
end

for i = lockins
    fprintf(smdata.inst(i).data.inst, 'REST;STRT');
    smdata.inst(i).data.currsamp = 0;
end

for i = dmms
    fprintf(smdata.inst(i).data.inst, 'INIT');
end

pause(0.08); 
% needed for reset and INIT commands to complete.
% <=50 ms make lockin loose data.

if nargin < 4 || ~nolocktrig
    dmms = [dmms, lockins];
end

for i = size(dac,1)
    dacwrite(smdata.inst(dac(i,1)).data.inst, sprintf('B%1d;C%1d;G0;', floor((dac(i,2)-1)/8), floor(mod(dac(i,2)-1, 8)/2)));
end
for i = dmms
    trigger(smdata.inst(i).data.inst);
end

function dacwrite(inst, str)
try
    query(inst, str);
catch
    fprintf('WARNING: error in DAC communication. Flushing buffer.\n');
    while inst.BytesAvailable > 0
        fprintf(fscanf(inst));
    end
end