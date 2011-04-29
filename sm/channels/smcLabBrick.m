function val = smcLabBrick(ic, val, rate)
% 1: freq, 2: power, 3: rf on/off
% 11: close

global smdata;

% Open the library if needed.
if ~libisloaded('labbrick')
  loadlibrary('z:\qDots\labbrick\labbrick','z:\qDots\labbrick\labbrick.h','alias','labbrick');
  smdata.inst(ic(1)).data.devhandle=[];
  lbfn('SetTestMode',0);  
end

% Open the device if needed.
if ~isfield(smdata.inst(ic(1)).data,'devhandle') || isempty(smdata.inst(ic(1)).data.devhandle)
   nd=lbfn('GetNumDevices');
   if nd == 0
       error('No labbrick attached');
   end
   devids=libpointer('uint32Ptr',zeros(nd+1,1));
   lbfn('GetDevInfo',devids);
   if isfield(smdata.inst(ic(1)).data,'serial') && ~isempty(smdata.inst(ic(1)).data.serial)       
      for i=1:nd
         if lbfn('GetSerialNumber',devids(i)) == smdata.inst(ic(1)).data.serial
             mydev=i;
             break;
         end
      end
      error('No device found matching serial number %d\n',smdata.inst(ic(1)).data.serial);
   else
       mydev = 1;
       if nd > 1
           fprintf('Warning: More than one labbrick present and no serial number given\n');
           fprintf('Choosing first\n');
       end
   end
   smdata.inst(ic(1)).data.devhandle=devids.value(mydev);
   lbfn('InitDevice',smdata.inst(ic(1)).data.devhandle);       
end

fscale=1e5;  % Frequency is set in 100khz increments.
funcs = {'Frequency','PowerLevel','RFOn'};
scales= [ 1e5, 0.25, 1];
switch ic(2)
    case {1,2,3}
       if ic(3)       
           lbfn(['Set' funcs{ic(2)}],smdata.inst(ic(1)).data.devhandle,val/scales(ic(2)));           
       else
           val=lbfn(['Get' funcs{ic(2)}],smdata.inst(ic(1)).data.devhandle)*scales(ic(2));
           % Work around a bug in the DLL
           if (ic(2) == 2)
               val=10-val;
           end
       end       
    case 11
       lbfn('CloseDevice',smdata.inst(ic(1)).data.devhandle);
       smdata.inst(ic(1)).data.devhandle=[];            
    otherwise
        error('Unknown channel');
end
end


function varargout = lbfn(fn, varargin)
[varargout{1:nargout}] = calllib('labbrick', ['lb_', fn], varargin{:});
end