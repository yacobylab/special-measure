function val = smaLabBrick(ic,arg)
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