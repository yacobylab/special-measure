function openLabBrick 
% Initialize Vaunix lab bricks. Load library, grab device handles, open communications to devices. 
% Opens all LabBricks on rack. 
% Checks that serial numbers are correct. 
global smdata; 
try
    if ~libisloaded('vnx_fsynth')
        [success,warnings]=labBrickLoadLibrary; % warnings can be checked for debugging. 
        if ~success
            error('Unable to load vnx_fsynth');
        end
    end
    labBricks = inl('LabBrick');
    calllib('vnx_fsynth','fnLSG_SetTestMode',false);
    num=brickfn('GetNumDevices'); % this needs to be run first. For debugging, can check #. 
    [~,devIDs]=calllib('vnx_fsynth','fnLSG_GetDevInfo',uint32(zeros(1,length(labBricks))));
    
    for i = 1:length(labBricks)
        serialNum(i) = brickfn('GetSerialNumber',devIDs(i));      %#ok<AGROW>
    end
    for i = 1:length(labBricks)
        devIDCurr = devIDs(serialNum==smdata.inst(labBricks(i)).data.serial);
        smdata.inst(labBricks(i)).data.handle = devIDCurr;
        brickfn('InitDevice',devIDCurr);
    end
catch
    warning('Error initializing lab bricks');
end
end