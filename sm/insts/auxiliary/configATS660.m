function configATS660
% Initialize Alazar 660 2 channel DAQ. Load library, grab handle, set trigger timing, bandwidth, and range of DAQ. 
global smdata
%% Load DLL and board handle 
if libisloaded('ATSApi')
  unloadlibrary('ATSApi');
end

if ~alazarLoadLibrary
   error('Unable to load library');
end
inst = sminstlookup('ATS660'); 
boardh = calllib('ATSApi', 'AlazarGetBoardBySystemID', 1, 1);
smdata.inst(inst).data.handle = boardh;

%% Configure standard parameters
daqfn('SetExternalTrigger', boardh,2, 1); %AC/DC (1/2), 5V/1V (0/1)
daqfn('SetTriggerOperation', boardh, 0, 0, 2, 2, 140, 1, 3, 1, 1);
% Have varied level : 146 -> 140 -> 160 -> 140 
% TriggerOp, TriggerEng1, Source1, Slp1, Lvl1, TriggerEng2, Source2, Slp2, Level2
% J low to high ,engine J, trigin, negative, 
% source: 0=chan a, 1=chan b, 2=external, 3=off
% slope: 1 = rising, 2=falling.
% operation: J, K, J | K, J & K, J ^ K, J & !K !J & K = 0:6
% Engine1: J/K = 0/1, Sourve1: CH1, CH2, EXT, NONE = 0:3, Slope: +/-=1/2,
% level (0:255 = -1 V:1 V
% same for engine 2

daqfn('ConfigureAuxIO',boardh,14,0);
daqfn('SetTriggerDelay', boardh, 0);
daqfn('SetTriggerTimeOut', boardh, uint32(0)); 

daqfn('SetBWLimit', boardh, 1, 1);   % approx. 20 Mhz.
daqfn('SetBWLimit', boardh, 2, 1);

% Set DAQ range
nchans = 2; 
rngVals = [.2 .4 .8, 2, 5, 8, 16]; % range of the channel in V
rngRef =  [6, 7, 9, 11, 12, 14, 18]; % Alazar Ref for each V.
for ch = 1:nchans
    [~, rngInd] = min(abs(rngVals - smdata.inst(inst).data.rng(ch)));
    daqfn('InputControl', boardh, ch,2, rngRef(rngInd), 2-logical(smdata.inst(inst).data.highZ(ch)));
    smdata.inst(inst).data.rng(ch) = rngVals(rngInd);
end
end