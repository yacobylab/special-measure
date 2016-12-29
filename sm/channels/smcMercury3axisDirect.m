function val = smcMercury3axisDirect(ico, val, rate)
% function val = smcMercury3axisDirect(ico, val, rate)
% Driver for 3 axis mercury power supply.
% This driver is written to directly communicate with the power
% supply, not the VRM software.
%
% Here are the relevant old comments from smcMercury3axisV2 which communicates
% with the VRM software:
% Warning! It is possible to remotely quench the magnet. The power supply
% does not know about the field limits of the magnet.
% It is therefore important to make sure the sub-function below isFieldSafe
% is properly populated
% channels are [Bx By Bz]
%
% Here are the old comments from the IPS supply: 
% ico: vector with instrument(index to smdata.inst), channel number for that instrument, operation
% operation: 0 - read, 1 - set , 2 - unused usually,  3 - trigger
% rate overrides default

%Might need in setup:
%channel 1: FIELD
%disp(ico)
%maginst = tcpip('140.247.189.116',7020,'NetworkRole','client')
global smdata;

chans = 'XYZ';
obj = smdata.inst(ico(1)).data.inst;
maxRate = 0.12; % Tesla/min HARD CODED
chanStr=cellstr(smdata.inst(ico(1)).channels(ico(2),:));

% read current persistent field value
currField = getMagField(obj,'magnet'); %here, should be same as 'leads'
oldFieldVal= currField;

if ico(3)==1 % If setting value 
    ratePerMinute = rate*60;
end

chan = ico(2);  %Only programmed for Bx, By, Bz 
if chan ~=1 && chan ~=2 && chan~=3
   error('channel not programmed into Mercury'); 
end

switch ico(3) % operation    
    case 0 % read        
        val = oldFieldVal(chan);        
    case 1 % Standard magnet go to setpoint and hold                
        newSetPoint = getMagField(obj,'setpoint'); %figure out the new setpoint
        newSetPoint(chan) = val;        
        if ~isFieldSafe(newSetPoint) 
            error('Unsafe field requested. Are you trying to kill me?');
        end  %check that we are setting to a good value
        if ~ispathsafe(oldFieldVal,newSetPoint)
            error('Path from current to final B goes outside of allowed range');
        end  % check that the path is ok
        if abs(ratePerMinute) > maxRate
            error('Magnet ramp rate of %f too high. Must be less than %f T/min',ratePerMinute,maxRate)
        end
        if ratePerMinute<0
            holdMagnet(obj);  % set to hold
        end        
        heaterOn = ~isMagPersist(obj);        
        if ~heaterOn,  goNormal(obj);   end %magnet persistent at field or persistent at 0. 
        if ~all(currField==newSetPoint) %only go through trouble if we're not at the target field
            cmd = sprintf('SET:DEV:GRP%s:PSU:SIG:RFST:%f',chans(ico(2)),abs(ratePerMinute)); % set rate
            magwrite(obj,cmd); checkmag(obj);
            cmd = sprintf('SET:DEV:GRP%s:PSU:SIG:FSET:%f',chans(ico(2)),val); % set field
            magwrite(obj,cmd); checkmag(obj);
            if ratePerMinute > 0
                cmd = sprintf('SET:DEV:GRP%s:PSU:ACTN:RTOS',chans(ico(2))); % start ramp
                magwrite(obj,cmd); checkmag(obj);
                val = abs(norm(oldFieldVal-newSetPoint)/abs(rate));
                waitforidle(obj);                
            else
                val = abs(norm(oldFieldVal-newSetPoint)/abs(rate));
            end
        end      
        if heaterOn,   goPers(obj);   end 
            
    case 3        
        % go to target field        
        cmd = sprintf('SET:DEV:GRP%s:PSU:ACTN:RTOS',chans(ico(2)));
        magwrite(obj,cmd); checkmag(obj);   
    case 5 
        % If running ramp, will want to go Normal before scan and go persistent at end.          
        waitforidle(obj); goNormal(obj);         
    case 6
        waitforidle(obj);  goPers(obj); 
    otherwise        
        error('Operation not supported by Mercury.');        
end
end

function bool = isFieldSafe(B)
% return 1 if inside 1T sphere, 2 if inside cyl, 3 if inside both, 0 if unsafe
bool=0;
if norm(B)<=1
    bool=1;
end
if (abs(B(3))<=6 && norm(B(1:2))<=.262)
    bool=bool+2;
end
end

function out = isMagPersist(obj) 
%Check if all switch heaters off
state = nan(1,3); chans = 'XYZ'; 
cmd = 'READ:DEV:GRP%s:PSU:SIG:SWHT';
cmdForm = 'STAT:DEV:GRP%s:PSU:SIG:SWHT';
for i = 1:3 
    cmdtmp = sprintf(cmd,chans(i)); 
    magwrite(obj,cmdtmp); % Check if switch heater on 
    statetmp{i} = fscanf(obj,'%s');
    statetmp{i} = sscanf(statetmp{i},[sprintf(cmdForm,chans(i)) ':%s']);
    if ~(strcmp(statetmp{i},'ON'))&&~(strcmp(statetmp{i},'OFF'))
        error('Garbled communication: %s',statetmp{i}); 
    end
    state(i) = strcmp(statetmp{i},'OFF');
end  
if sum(state) == 3
    out = 1;
elseif sum(state) == 0
    out = 0;
else
    error('Switch heaters not all the same. Consider manual intervention. Heater state: %s',state); 
end
end

function B = getMagField(mag, opts)
% read the current field value: % returns [X Y Z]
% opts can be 'magnet' or 'leads' or 'setpoint'
% 'magnet' will be magnet field whether or not magnet is persistent
chans = 'XYZ'; 
switch opts 
    case 'magnet' 
        cmd = 'READ:DEV:GRP%s:PSU:SIG:PFLD';
        cmdForm = 'STAT:DEV:GRP%s:PSU:SIG:PFLD'; 
    case 'leads' 
        cmd = 'READ:DEV:GRP%s:PSU:SIG:FLD'; 
        cmdForm = 'STAT:DEV:GRP%s:PSU:SIG:FLD'; 
    case 'setpoint'
        cmd = 'READ:DEV:GRP%s:PSU:SIG:FSET'; 
        cmdForm = 'STAT:DEV:GRP%s:PSU:SIG:FSET'; 
    otherwise
        error('Can only read magnet or lead fields.')
end
for i = 1:length(chans)
    magwrite(mag,sprintf(cmd,chans(i)));
    pause(0.125); 
    magfield = fscanf(mag,'%s');
    B(i) = sscanf(magfield,[sprintf(cmdForm,chans(i)) ':%fT']);
end    
end

function goNormal(mag)
% Has pauses and checks built in.
% takes the current in the leads up to the magnet and opens the switch                         
state = isMagPersist(mag);
if state == 0
    warning('Magnet appears to already be normal. State: %d',state);
    return
end
magwrite(mag,'SET:DEV:GRPX:PSU:ACTN:RTOS'); checkmag(mag);
magwrite(mag,'SET:DEV:GRPY:PSU:ACTN:RTOS'); checkmag(mag);
magwrite(mag,'SET:DEV:GRPZ:PSU:ACTN:RTOS'); checkmag(mag);
waitforidle(mag);

% Turn on all switch heaters 
magwrite(mag,'SET:DEV:GRPX:PSU:SIG:SWHT:ON'); checkmag(mag);
magwrite(mag,'SET:DEV:GRPY:PSU:SIG:SWHT:ON'); checkmag(mag);
magwrite(mag,'SET:DEV:GRPZ:PSU:SIG:SWHT:ON'); checkmag(mag);
waitforidle(mag);

end

function goPers(mag)
%Turn off all switch heaters 
state = isMagPersist(mag);
if state == 1
    error('Magnet appears to already be persistent. State: %f',state);
end

magwrite(mag,'SET:DEV:GRPX:PSU:SIG:SWHT:OFF'); checkmag(mag);
magwrite(mag,'SET:DEV:GRPY:PSU:SIG:SWHT:OFF'); checkmag(mag);
magwrite(mag,'SET:DEV:GRPZ:PSU:SIG:SWHT:OFF'); checkmag(mag);
waitforidle(mag);

magwrite(mag,'SET:DEV:GRPX:PSU:ACTN:RTOZ'); checkmag(mag);
magwrite(mag,'SET:DEV:GRPY:PSU:ACTN:RTOZ'); checkmag(mag);
magwrite(mag,'SET:DEV:GRPZ:PSU:ACTN:RTOZ'); checkmag(mag);
waitforidle(mag);

end

function out = ispathsafe(a,b)
% see if the path from a to b will quench magnet
% if they are both contained in the same allowed volume then is is safe
safea = isFieldSafe(a);
safeb = isFieldSafe(b);
if (safea==0) || (safeb==0)
    error('Magnet fields unsafe.');
end
out = bitand(uint8(safea),uint8(safeb))>0;
end

function holdMagnet(mag)
% Put magnet in hold mode 
magwrite(mag,'SET:DEV:GRPX:PSU:ACTN:HOLD'); checkmag(mag);
magwrite(mag,'SET:DEV:GRPY:PSU:ACTN:HOLD'); checkmag(mag);
magwrite(mag,'SET:DEV:GRPZ:PSU:ACTN:HOLD'); checkmag(mag);
end

function magwrite(mag,msg)
fprintf(mag,'%s\r\n',msg);
end

function checkmag(mag) 
% checks that communications were valid
outp=fscanf(mag,'%s');
if ~isempty(strfind(outp,'INVALID'))
    fprintf('%s\n',outp);
    error('Garbled magnet power communications: %s',outp);
end
end

function waitforidle(mag)
% Check if hold
chans = 'XYZ'; fin = zeros(1,3);
cmd = 'READ:DEV:GRP%s:PSU:ACTN';
cmdForm = 'STAT:DEV:GRP%s:PSU:ACTN';
while sum(fin) ~= 3
    for i = 1:3 
    cmdCurr =sprintf(cmd,chans(i));  
    magwrite(mag,cmdCurr);
    state{i} = fscanf(mag,'%s');
    state{i} = sscanf(state{i},[sprintf(cmdForm,chans(i)) ':%s']);
    if strcmp(state{i},'HOLD')
        fin(i) = 1;
    end
    end    
    pause(5);
end
end