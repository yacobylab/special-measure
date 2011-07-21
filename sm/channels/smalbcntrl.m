function val = smcLabBrick(inst, opt)
% function val = smcLabBrick(inst, opt)
% inst is the inst number of name of the lab brick (fix me use sminstlookup)
% Control function for LabBricks from Vaunix.
% opt can contain any of:
%   on  - turn the RF on
%  off  - turn the RF off
% save  - save the current lab-brick state as the power-on default.
% list  - list serials of attached bricks

global smdata;

inst=sminstlookup(inst);

if ~isempty(strmatch(opt,'list'))
  smcLabBrick([inst 12 1], 1, inf);
end

if ~isempty(strmatch(opt,'on'))
  smcLabBrick([inst 3 1], 1, inf);
end

if ~isempty(strmatch(opt,'off'))   
  smcLabBrick([inst 3 1], 0, inf);
end

if ~isempty(strmatch(opt,'save'))
  smcLabBrick([inst 10 1], 0, inf);  
end
    
end

function varargout = lbfn(fn, varargin)
[varargout{1:nargout}] = calllib('labbrick', ['lb_', fn], varargin{:});
end