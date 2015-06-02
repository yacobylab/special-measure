function smatrigYokoSR830dmm(yokos, lockins, dmms, nolocktrig)
% smatrigYokoSR830dmm(yokos, lockins, dmms, triglock)
% trigger routines for lockins, yokos and dmms.
% If nolocktrig given and nonzero,  lockin acquisition is only initiated 
% but not triggered, so that the DMM OUT can be used as a 
% trigger signal.

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

for i = yokos
    fprintf(smdata.inst(i).data.inst, 'RU2');
end
for i = dmms
    trigger(smdata.inst(i).data.inst);
end