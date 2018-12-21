function smaLabBrickHID(insts, opt)
% Control properties of Vaunix Lab Brick using HID drivers, doesn't work as well on current Matlab/Windows
% function val = smaLabBrick(insts, opt)
% inst is the inst number of name of the lab brick (fix me use sminstlookup)
% Control function for LabBricks from Vaunix.
% inst can be a cell array of insts.
% opt can contain any of:
%   on  - turn the RF on
%  off  - turn the RF off
% save  - save the current lab-brick state as the power-on default.
% list  - list serials of attached bricks

if ~iscell(insts) && ~isnumeric(insts)
  insts={insts};
end

for i=1:length(insts)
    inst=sminstlookup(insts(i));    
    if contains(opt,'list')
        smcLabBrick([inst 12 1], 1, inf);
    end    
    if contains(opt,'on')
        smcLabBrick([inst 3 1], 1, inf);
    end    
    if contains(opt,'off')
        smcLabBrick([inst 3 1], 0, inf);
    end    
    if contains(opt,'save')
        smcLabBrick([inst 10 1], 0, inf);
    end    
end
end