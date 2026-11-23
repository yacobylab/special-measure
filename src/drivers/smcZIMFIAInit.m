function [] = smcZIMFIAInit(device_id,inst)
%SMCZIMFIAINIT  Initialise the Zurich Instruments MFIA and store its session.
%   SMCZIMFIAINIT(DEVICE_ID, INST) opens a LabOne API session (ziDAQ) to the
%   MFIA named DEVICE_ID and stores the returned device handle in
%   smdata.inst(INST).data.inst for use by smcZIMFIA.
%
%   It first checks that the ziDAQ MEX file and utility functions are on the
%   MATLAB path (printing guidance and returning early if not), then creates
%   the API session at API level 6 and verifies the Data Server version.
%
%   Inputs:
%     DEVICE_ID - MFIA device id string (e.g. 'dev1234').
%     INST      - instrument index into smdata.inst to populate.
%
%   See also SMCZIMFIA, ZICREATEAPISESSION.

global smdata;

clear ziDAQ;

% Check the ziDAQ MEX (DLL) and Utility functions can be found in Matlab's path.
if ~(exist('ziDAQ') == 3) && ~(exist('ziCreateAPISession', 'file') == 2)
    fprintf('Failed to either find the ziDAQ mex file or ziDevices() utility.\n')
    fprintf('Please configure your path using the ziDAQ function ziAddPath().\n')
    fprintf('This can be found in the API subfolder of your LabOne installation.\n');
    fprintf('On Windows this is typically:\n');
    fprintf('C:\\Program Files\\Zurich Instruments\\LabOne\\API\\MATLAB2012\\\n');
    return
end

apilevel = 6;
% Create an API session; connect to the correct Data Server for the device.
[device, props] = ziCreateAPISession(device_id, apilevel);
ziApiServerVersionCheck();

smdata.inst(inst).data.inst=device; %not sure if this is the correct places for this. 
end
        
