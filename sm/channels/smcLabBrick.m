function val = smcLabBrick(ic, val, rate)
%function val = smcLabBrick(ic, val, rate)
% Control function for LabBricks from Vaunix.
% KNOWN BUG
%    The loadlibrary path below needs to get updated to the location of this file /labbrick.
%    it's currently hardwired to a path on our machine, and I'm disinclined to fix it until
%    we're not measuring.
% 1: freq, 2: power, 3: rf on/off
% 4: save settings
% 11: close
% 12: print a list of serial numbers
% example: instrument 20 is a lab brick:
%  smcLabBrick([20 3 1],1) will turn on power


global smdata;

% Open the library if needed.
if ~libisloaded('labbrick')
  loadlibrary('z:\qDots\labbrick\labbrick','z:\qDots\labbrick\labbrick.h','alias','labbrick');
  smdata.inst(ic(1)).data.devhandle=[];
  lbfn('SetTestMode',0);  
end

if ic(2) == 12
   nd=lbfn('GetNumDevices');
   devids=libpointer('uint32Ptr',zeros(nd+1,1));
   lbfn('GetDevInfo',devids);
   for i=1:nd
     fprintf('%d: %d\n',i,lbfn('GetSerialNumber',devids.value(i)));
   end
   return;
end
    
    
% Open the device if needed.
if ~isfield(smdata.inst(ic(1)).data,'devhandle') || isempty(smdata.inst(ic(1)).data.devhandle)
   nd=lbfn('GetNumDevices');
   if nd == 0
       error('No labbrick attached');
   end
   devids=libpointer('uint32Ptr',zeros(nd+1,1));
   lbfn('GetDevInfo',devids);
   mydev=-1;
   if isfield(smdata.inst(ic(1)).data,'serial') && ~isempty(smdata.inst(ic(1)).data.serial)       
      for i=1:nd
         if lbfn('GetSerialNumber',devids.value(i)) == smdata.inst(ic(1)).data.serial
             mydev=i;             
             break;
         end
      end   
      if mydev == -1
        error('No device found matching serial number %d\n',smdata.inst(ic(1)).data.serial);
      end
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
    case 10
        lbfn('SaveSettings',smdata.inst(ic(1)).data.devhandle);
    otherwise
        error('Unknown channel');
end
end


function varargout = lbfn(fn, varargin)
[varargout{1:nargout}] = calllib('labbrick', ['lb_', fn], varargin{:});
end