function val = smaLabBrick(ic,arg)
% Control properties of Vaunix Lab Brick using C library provided by Vaunix. 
% function val = smaLabBrick(ic,arg)
% ic is instrument number. Fix me sminist lookup. 
% arg can be:
%   on  - turn the RF on
%  off  - turn the RF off
% save  - save the current lab-brick state as the power-on default.
% list  - get number of devices
% open: initialize device
% close: close device 
% query_Rf : check if RF on. 

global smdata; 
handle = smdata.inst(ic(1)).data.handle; 
switch arg 
    case 'on' 
        brickfn('SetRFOn',handle,true); 
    case 'off' 
        brickfn('SetRFOn',handle,false); 
    case 'open' 
        brickfn('InitDevice',handle); 
    case 'close' 
        brickfn('CloseDevice',handle); 
    case 'save'
        brickfn('SaveSettings',handle);
    case 'list'
        val = brickfn('GetNumDevices');
    case 'name'
    case 'queryRF'
        val = brickfn('GetRF_On',handle);
end
end