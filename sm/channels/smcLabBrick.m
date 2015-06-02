function val = smcLabBrick(ic, val, rate)
%function val = smcLabBrick(ic, val, rate)
% Control function for LabBricks from Vaunix.
% Only minimal functionality is supported.
% 1: freq, 2: power, 3: rf on/off
% 10: save settings
% 12: print a list of serial numbers (nb ; now only prints first serial.
% example: instrument 20 is a lab brick:
%  smcLabBrick([20 3 1],1) will turn on power
persistent holdoff; % Used to guarantee small pause between open and close
if ~exist('holdoff','var')
    holdoff=0;
end

global smdata;

% Open the library if needed.
if ~libisloaded('hidapi')
  p=strrep(which('smcLabBrick'),'smcLabBrick.m','labbrick') ;    
  addpath(p);
  if ~lbLoadLibrary
      error('Unable to load hidapi');
  end
  rmpath(p);
  smdata.inst(ic(1)).data.devhandle=[];
end

lb_manufacturer = sscanf('0x041f','%x'); % This is a dumb-ass way to do hex-to-dec conversion.
lb_product      = sscanf('0x1209','%x'); % Fixme; this only works with LSG-451

if ic(2) == 12 % Print serial of first device connected
   printFirstSerial(lb_manufacturer, lb_product);
   return;
end    
    
% Open the device if needed.
h=libpointer();
try
  if now-holdoff < 0.01
      %'holdoff'
      pause(0.001);
  end
  h=calllib('hidapi','hid_open',lb_manufacturer,lb_product,libpointer('uint16Ptr',[uint16(smdata.inst(ic(1)).data.serial) 0]));  
  if h.isNull
      error('Unable to open labbrick serial %s\n',smdata.inst(ic(1)).data.serial);
  end
  
  % Supported command info
  cmds(1).scale=1e5;
  cmds(1).size=4;
  cmds(1).name='Frequency';
  cmds(1).cmd=[4 132];
  cmds(1).offset=0;
  
  cmds(2).scale=-0.25;
  cmds(2).offset=-10;
  cmds(2).size=1;
  cmds(2).name='Power (dB)';
  cmds(2).cmd=[13 141];
  
  cmds(3).scale=1;
  cmds(3).offset=0;
  cmds(3).size=1;
  cmds(3).name='RF On';
  cmds(3).cmd=[10 138];  
  
  if ic(2) == 10 % Save settings
      cmd=uint8(zeros(1,9));
      cmd(2:6)=[140 3 66 85 49];
      cmd=libpointer('uint8Ptr',cmd);
      bytes = calllib('hidapi','hid_write',h,cmd,length(cmd.value));
      if bytes < 0; error('hidapi:hiderror','Error saving settings on labbrick\n'); end;
      clear cmd;      
  elseif ic(3) == 1 % Set
      if ic(2) > length(cmds)
          error('Unknown channel %d\n', ic(2));
      end
      cmd=uint8(zeros(1,9));
      cmd(2)=cmds(ic(2)).cmd(ic(3)+1);
      cmd(3)=cmds(ic(2)).size;
      cmd = libpointer('uint8Ptr',cmd);
      p = cmd+3;      
      switch cmds(ic(2)).size
          case 4 % 32 bit int
              setdatatype(p,'uint32Ptr',1);
              p.value = round((cmds(ic(2)).offset + val) / cmds(ic(2)).scale);               
          case 1 % 8 bit int
              p.value(1) = round((cmds(ic(2)).offset + val) / cmds(ic(2)).scale); 
          otherwise
              error('Unsupported size');
      end      
      bytes = calllib('hidapi','hid_write',h,cmd,length(cmd.value));
      if bytes < 0; error('hidapi:hiderror','Error sending command get %s\n',cmds(ic(2)).name); end;
      clear p;
      clear cmd;
  else    % get
      if ic(2) > length(cmds)
          error('Unknown channel %d\n', ic(2));
      end  
      cmd=uint8([0 cmds(ic(2)).cmd(ic(3)+1) 0 0 0 0 0 0 0]);
      bytes = calllib('hidapi','hid_write',h,cmd,length(cmd));
      if bytes < 0; error('hidapi:hiderror','Error sending command get %s\n',cmds(ic(2)).name); end;
      for i=1:256  % May not be first response
        data = libpointer('uint8Ptr',zeros(1,8));
        bytes = calllib('hidapi','hid_read',h,data,8);
        if data.value(1) == cmd(2)
           break;
        end
      end  
      assert(data.val(2) == cmds(ic(2)).size);  % Check payload size.
      % Parse the payload
      switch data.val(2) 
          case 4  % 32 bit int.
              p=data+2;
              setdatatype(p,'uint32Ptr',1);
              val = double(p.value) * cmds(ic(2)).scale + cmds(ic(2)).offset;
              clear p;              
          case 1
              val = double(data.val(3)) * cmds(ic(2)).scale - cmds(ic(2)).offset;              
      end
      clear data;
  end
  
  calllib('hidapi','hid_close',h);  h=libpointer();
  holdoff=now;
catch err
  if strcmp(err.identifier,'hidapi:hiderror')
      showHidError(h);
  end
  if ~h.isNull
     calllib('hidapi','hid_close',h);
     holdoff=now;
  end
  rethrow(err);
end
return;
end


function showHidError(h)
  if h.isNull
      fprintf('HIDERROR: Device is NULL\n');
  else
      str=calllib('hidapi','hid_error',h);
      for i=1:256
          setdatatype(str,'uint16Ptr',i);
          if(str.value(end) == 0)            
            setdatatype(str,'uint16Ptr',i-1);              
            str=char(str.value);
            break;
          end
      end
      fprintf('HIDERROR: %s\n',str);
      clear str;    
  end
end

function printFirstSerial(lb_manufacturer, lb_product)
  h=calllib('hidapi','hid_open',lb_manufacturer,lb_product,libpointer());
   if h.isNull
       error('No labbricks connected');
   end
   
   name=libpointer('uint16Ptr',zeros(1,128));
   calllib('hidapi','hid_get_manufacturer_string',h,name,length(get(name,'Value')));
   nmv=get(name,'Value');
   nmv=char(nmv(1:find(nmv == 0,1,'first')));
   calllib('hidapi','hid_get_product_string',h,name,length(get(name,'Value')));
   pnmv=get(name,'Value');
   pnmv=char(pnmv(1:find(pnmv == 0,1,'first')));
   calllib('hidapi','hid_get_serial_number_string',h,name,length(get(name,'Value')));
   snmv=get(name,'Value');
   snmv=char(snmv(1:find(snmv == 0,1,'first')));
   fprintf('First attached device is a %s from %s, serial "%s"\n',pnmv,nmv,snmv);
   calllib('hidapi','hid_close',h);
end