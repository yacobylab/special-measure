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

mag = smdata.inst(ico(1)).data.inst;

%fclose(mag); fopen(mag);  % this seems to make things less crappy

maxrate = 0.12; % Tesla/min HARD CODED

chanStr=cellstr(smdata.inst(ico(1)).channels(ico(2),:));

% read current persistent field value
curr = getMagField(mag,'magnet'); %here, should be same as 'leads'
oldfieldval= curr;
persistentsetpoint = curr;

if ico(3)==1
    rateperminute = rate*60;
end

chan = ico(2);
if chan ~=1 && chan ~=2 && chan~=3
   error('channel not programmed into Mercury'); 
end

switch ico(3) % operation
    
    case 0 % read
        
        val = oldfieldval(ico(2));
        
    case 1 % Standard magnet go to setpoint and hold
        
        %figure out the new setpoint
        newsp = getMagField(mag,'setpoint');
        newsp(ico(2)) = val;
        
        %check that we are setting to a good value
        if ~isFieldSafe(newsp) 
            error('Unsafe field requested. Are you trying to kill me?');
        end
        
        % check that the path is ok
        if ~ispathsafe(oldfieldval,newsp)
            error('Path from current to final B goes outside of allowed range');
        end
        
        heateron = ~ismagpersist(mag);
        
        if ~heateron  %magnet persistent at field or persistent at 0
            
            % any way to delay trigger
            if abs(rateperminute) > maxrate;
                error('Magnet ramp rate of %f too high. Must be less than %f T/min',rateperminute,maxrate)
            end
            
            if rateperminute<0
                
                % set to hold
                holdthemagnet(mag);
                
            end
            
            if ~all(curr==newsp) %only go through trouble if we're not at the target field
                
                % switch on heater
                goNormal(mag); %has pauses and checks built in. takes the current in the leads up to the magnet and opens the switch
                
                % set field target and rate
                cmd = sprintf('SET:DEV:GRP%s:PSU:SIG:RFST:%f',chans(ico(2)),abs(rateperminute));
                magwrite(mag,cmd);
                checkmag(mag);
                cmd = sprintf('SET:DEV:GRP%s:PSU:SIG:FSET:%f',chans(ico(2)),val);
                magwrite(mag,cmd);
                checkmag(mag);
                
                if rateperminute > 0
                    
                    % go to target field
                    cmd = sprintf('SET:DEV:GRP%s:PSU:ACTN:RTOS',chans(ico(2)));
                    magwrite(mag,cmd);
                    checkmag(mag);
                    
                    val = abs(norm(oldfieldval-newsp)/abs(rate));
                    
                    waitforidle(mag);
                    
                    goPers(mag); % turn off switch heater
                    
                else
                    
                    val = abs(norm(oldfieldval-newsp)/abs(rate));
                    
                end
                
            end
            
        else % magnet not persistent
            
            % any way to delay trigger
            if abs(rateperminute) > maxrate;
                error('Magnet ramp rate of %f too high. Must be less than %f T/min',rateperminute,maxrate)
            end
                
            if rateperminute<0
                
                % set to hold
                holdthemagnet(mag); 
                
            end
            
            if ~all(curr==newsp) %only go through trouble if we're not at the target field
                
            % set field target and rate
                cmd = sprintf('SET:DEV:GRP%s:PSU:SIG:RFST:%f',chans(ico(2)),abs(rateperminute));
                magwrite(mag,cmd);
                checkmag(mag);
                cmd = sprintf('SET:DEV:GRP%s:PSU:SIG:FSET:%f',chans(ico(2)),val);
                magwrite(mag,cmd);
                checkmag(mag);
                
                val = abs(norm(oldfieldval-newsp)/abs(rate));
            
                if rateperminute > 0
                    
                    % go to target field
                    cmd = sprintf('SET:DEV:GRP%s:PSU:ACTN:RTOS',chans(ico(2)));
                    magwrite(mag,cmd);
                    checkmag(mag);
                    
                    val = abs(norm(oldfieldval-newsp)/abs(rate));
                    
                    waitforidle(mag);
                    
                end
                
            end
            
        end
             
    case 3
        
        % go to target field
        % This is really screwed up and should be fixed.
        cmd = sprintf('SET:DEV:GRP%s:PSU:ACTN:RTOS',chans(ico(2)));
        magwrite(mag,cmd);
        checkmag(mag);
        
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

function out = ismagpersist(mag)

state = nan(1,3);

magwrite(mag,'READ:DEV:GRPX:PSU:SIG:SWHT');
stateX = fscanf(mag,'%s');
stateX = sscanf(stateX,'STAT:DEV:GRPX:PSU:SIG:SWHT:%s');
if ~(strcmp(stateX,'ON'))&&~(strcmp(stateX,'OFF'))
    error('garbled communication: %s',stateX); 
end
state(1) = strcmp(stateX,'OFF');

magwrite(mag,'READ:DEV:GRPY:PSU:SIG:SWHT');
stateY = fscanf(mag,'%s');
stateY = sscanf(stateY,'STAT:DEV:GRPY:PSU:SIG:SWHT:%s');
if ~(strcmp(stateY,'ON'))&&~(strcmp(stateY,'OFF'))
    error('garbled communication: %s',stateY); 
end
state(2) = strcmp(stateY,'OFF');

magwrite(mag,'READ:DEV:GRPZ:PSU:SIG:SWHT');
stateZ = fscanf(mag,'%s');
stateZ = sscanf(stateZ,'STAT:DEV:GRPZ:PSU:SIG:SWHT:%s');
if ~(strcmp(stateZ,'ON'))&&~(strcmp(stateZ,'OFF'))
    error('garbled communication: %s',stateZ); 
end
state(3) = strcmp(stateZ,'OFF');
    
if sum(state) == 3
    out = 1;
elseif sum(state) == 0
    out = 0;
else
    error('Switch heaters not all the same. Consider manual intervention. Heater state: %s',state); 
end

end

function out = getMagField(mag, opts)

% read the current field value:
% returns [X Y Z]
% opts can be 'magnet' or 'leads' or 'setpoint'
% 'magnet' will be magnet field whether or not magnet is persistent

if strcmp(opts,'magnet')
    
    magwrite(mag,'READ:DEV:GRPX:PSU:SIG:PFLD');
    BX = fscanf(mag,'%s');
    BX = sscanf(BX,'STAT:DEV:GRPX:PSU:SIG:PFLD:%fT');
    magwrite(mag,'READ:DEV:GRPY:PSU:SIG:PFLD');
    BY = fscanf(mag,'%s');
    BY = sscanf(BY,'STAT:DEV:GRPY:PSU:SIG:PFLD:%fT');
    magwrite(mag,'READ:DEV:GRPZ:PSU:SIG:PFLD');
    BZ = fscanf(mag,'%s');
    BZ = sscanf(BZ,'STAT:DEV:GRPZ:PSU:SIG:PFLD:%fT');
    
    B = [BX BY BZ];
    
elseif strcmp(opts,'leads');
    
    magwrite(mag,'READ:DEV:GRPX:PSU:SIG:FLD');
    BX = fscanf(mag,'%s');
    BX = sscanf(BX,'STAT:DEV:GRPX:PSU:SIG:FLD:%fT');
    magwrite(mag,'READ:DEV:GRPY:PSU:SIG:FLD');
    BY = fscanf(mag,'%s');
    BY = sscanf(BY,'STAT:DEV:GRPY:PSU:SIG:FLD:%fT');
    magwrite(mag,'READ:DEV:GRPZ:PSU:SIG:FLD');
    BZ = fscanf(mag,'%s');
    BZ = sscanf(BZ,'STAT:DEV:GRPZ:PSU:SIG:FLD:%fT');
    
    B = [BX BY BZ];
    
elseif strcmp(opts,'setpoint');
    
    magwrite(mag,'READ:DEV:GRPX:PSU:SIG:FSET');
    BX = fscanf(mag,'%s');
    BX = sscanf(BX,'STAT:DEV:GRPX:PSU:SIG:FSET:%fT');
    magwrite(mag,'READ:DEV:GRPY:PSU:SIG:FSET');
    BY = fscanf(mag,'%s');
    BY = sscanf(BY,'STAT:DEV:GRPY:PSU:SIG:FSET:%fT');
    magwrite(mag,'READ:DEV:GRPZ:PSU:SIG:FSET');
    BZ = fscanf(mag,'%s');
    BZ = sscanf(BZ,'STAT:DEV:GRPZ:PSU:SIG:FSET:%fT');
    B = [BX BY BZ];
    
else
    
    error('Can only read magnet or lead fields.');
    
end

out = B;

end

function goNormal(mag)

state = ismagpersist(mag);

if state == 0
    error('Magnet appears to already be normal. State: %f',state);
end

magwrite(mag,'SET:DEV:GRPX:PSU:ACTN:RTOS');
checkmag(mag);
magwrite(mag,'SET:DEV:GRPY:PSU:ACTN:RTOS');
checkmag(mag);
magwrite(mag,'SET:DEV:GRPZ:PSU:ACTN:RTOS');
checkmag(mag);

waitforidle(mag);

magwrite(mag,'SET:DEV:GRPX:PSU:SIG:SWHT:ON');
checkmag(mag);
magwrite(mag,'SET:DEV:GRPY:PSU:SIG:SWHT:ON');
checkmag(mag);
magwrite(mag,'SET:DEV:GRPZ:PSU:SIG:SWHT:ON');
checkmag(mag);

waitforidle(mag);

end

function goPers(mag)

state = ismagpersist(mag);

if state == 1
    error('Magnet appears to already be persistent. State: %f',state);
end

magwrite(mag,'SET:DEV:GRPX:PSU:SIG:SWHT:OFF');
checkmag(mag);
magwrite(mag,'SET:DEV:GRPY:PSU:SIG:SWHT:OFF');
checkmag(mag);
magwrite(mag,'SET:DEV:GRPZ:PSU:SIG:SWHT:OFF');
checkmag(mag);

waitforidle(mag);

magwrite(mag,'SET:DEV:GRPX:PSU:ACTN:RTOZ');
checkmag(mag);
magwrite(mag,'SET:DEV:GRPY:PSU:ACTN:RTOZ');
checkmag(mag);
magwrite(mag,'SET:DEV:GRPZ:PSU:ACTN:RTOZ');
checkmag(mag);

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

function holdthemagnet(mag)

magwrite(mag,'SET:DEV:GRPX:PSU:ACTN:HOLD');
checkmag(mag);
magwrite(mag,'SET:DEV:GRPY:PSU:ACTN:HOLD');
checkmag(mag);
magwrite(mag,'SET:DEV:GRPZ:PSU:ACTN:HOLD');
checkmag(mag);

end

function magwrite(mag,msg)

fprintf(mag,'%s\r\n',msg);

end

function checkmag(mag) % checks that communications were valid

outp=fscanf(mag,'%s');
%fprintf('%s\n',outp);
if ~isempty(strfind(outp,'INVALID'))
    fprintf('%s\n',outp);
    error('Garbled magnet power communications: %s',outp);
end

end

function waitforidle(mag)

state = zeros(1,3);
while sum(state) ~= 3
    magwrite(mag,'READ:DEV:GRPX:PSU:ACTN');
    stateX = fscanf(mag,'%s');
    stateX = sscanf(stateX,'STAT:DEV:GRPX:PSU:ACTN:%s');
    if strcmp(stateX,'HOLD')
        state(1) = 1;
    end
    magwrite(mag,'READ:DEV:GRPY:PSU:ACTN');
    stateY = fscanf(mag,'%s');
    stateY = sscanf(stateY,'STAT:DEV:GRPY:PSU:ACTN:%s');
    if strcmp(stateY,'HOLD')
        state(2) = 1;
    end
    magwrite(mag,'READ:DEV:GRPZ:PSU:ACTN');
    stateZ = fscanf(mag,'%s');
    stateZ = sscanf(stateZ,'STAT:DEV:GRPZ:PSU:ACTN:%s');
    if strcmp(stateZ,'HOLD')
        state(3) = 1;
    end
    pause(5);
end

end








