function val = smcMercury3axisV2(ico, val, rate)
%function val = smcMercury3axis(ico, val, rate)
% Driver for new 3 axis mercury power supply from oxford
% Warning! It is possible to remotely quench the magnet. The power supply
% does not know about the field limits of the magnet.
% It is therefore important to make sure the sub-function below isFieldSafe
% is properly populated
% channels are [Bx By Bz R Theta Phi]
% Note that Phi is the angle away from the z axis, and Theta is that
% azimuthal angle from the x axis
% here are the old comments from the IPS supply: 
%ico: vector with instruemnt(index to smdata.inst), channel number for that instrument, operation
% operation: 0 - read, 1 - set , 2 - unused usually,  3 - trigger
% rate overrides default

%Might need in setup:
%channel 1: FIELD

global smdata;
mag = smdata.inst(ico(1)).data.inst;

fclose(mag); fopen(mag); % this seems to make things less crappy

maxrate = .2; %.05 Tesla/min HARD CODED!!!!!

chanStr=cellstr(smdata.inst(ico(1)).channels(ico(2),:));

%If Bx,By, or Bz, set coordinate system to cartesian
if strcmp(chanStr,'BX')||strcmp(chanStr,'BY')||strcmp(chanStr,'BZ')
    magwrite(mag,'SET:SYS:VRM:COO:CART');
    coord='cart';
end

%If R, Theta, or Phi, set coordinate system to spherical
if strcmp(chanStr,'R')||strcmp(chanStr,'THETA')||strcmp(chanStr,'PHI')
    magwrite(mag,'SET:SYS:VRM:COO:SPH');
    coord='sph';
end

checkmag(mag);

% read current persistent field value
curr = getMagField(mag,'magnet',coord); %here, should be same as 'leads'
oldfieldval= curr;
persistentsetpoint = curr;

if ico(3)==1
    rateperminute = rate*60;
end

chan = ico(2);
if chan ~=1 && chan ~=2 && chan~=3 && chan~=4 && chan~=5 && chan~=6
   error('channel not programmed into Mercury'); 
end

switch ico(3) %operation
    case 0 %read
        val = oldfieldval(ico(2)-3*strcmp(coord,'sph'));%get the coordinate system right
        
    case 1 % standard magnet go to setpoint and holding there
        
        %figure out the new setpoint
        newsp = getMagField(mag,'setpoint',coord);
        newsp(ico(2)-3*strcmp(coord,'sph')) = val; %get the coordinate system right
        
        if ~isFieldSafe(newsp,coord) %check that we are setting to a good value
            error('Unsafe field requensted. Are you trying to kill me?');
        end
        
        % check that the path is ok
        if ~ispathsafe(oldfieldval,newsp,coord)
            error('Path from current to final B goes outside of allowed range');
        end
        
        heateron = ~ismagpersist(mag);
        if ~heateron %magnet persistent at field or persistent at 0
            % any way to delay trigger
            if abs(rateperminute) > maxrate;
                error('Magnet ramp rate of %f too high. Must be less than %f T/min',rateperminute,maxrate)
            end
            
            if rateperminute<0
                % set to hold
                holdthemagnet(mag);
            end
            
            magwrite(mag,'SET:SYS:VRM:POC:ON'); %make it persistent on completion
            checkmag(mag);
            
            if ~all(curr==newsp) %only go through trouble if we're not at the target field
                
                % switch on heater
                goNormal(mag); %has pauses and checks built in. takes the current in the leads up to the magnet and opens the switch
                
                % set the field target
                %this command sets the mode to "rate," sets the
                %rate and sets the setpoint
                cmd = sprintf('SET:SYS:VRM:RVST:MODE:RATE:RATE:%f:VSET:[%f %f %f]',[rateperminute, newsp(:)']);
                magwrite(mag,cmd);
                checkmag(mag);
                
                
                if rateperminute > 0
                    % go to target field
                    magwrite(mag,'SET:SYS:VRM:ACTN:RTOS');
                    fscanf(mag,'%s');
                    
                    waittime=calcWait(oldfieldval,newsp,rate,coord);
                    %waittime = abs(norm(oldfieldval-newsp))/abs(rate);
                    
                    pause(waittime);
                    waitforidle(mag);
                    
                    %goPers(mag);  % turn off switch heater. 7/15/14 Not needed,
                    %because it's already persistent on completion.
                    
                    %waitforidle(mag);
                else
                    val = calcWait(oldfieldval,newsp,rate,coord);
                end
            end
            
        else % magnet not persistent
            
            magwrite(mag,'SET:SYS:VRM:POC:OFF'); %turn off persistent on completion
            checkmag(mag);
            
            % any way to delay trigger
            if abs(rateperminute) > maxrate
                error('Magnet ramp rate too high')
            end
            
            
            if rateperminute<0
                % set to hold
                holdthemagnet(mag);    
            end
            
            % read the current field value
            curr = getMagField(mag,'leads',coord); %here it shouldnt matter if we pass 'magnet'
            
            % set the mode to "RATE", set rate, set field target
            cmd = sprintf('SET:SYS:VRM:RVST:MODE:RATE:RATE:%f:VSET:[%f %f %f]',[rateperminute, newsp(:)']);
            fprintf('%s\n',cmd)
            magwrite(mag,cmd);
            checkmag(mag);
            
            val = calcWait(oldfieldval,newsp,rate,coord);
            
            if rateperminute>0
                
                % go to target field
                magwrite(mag,'SET:SYS:VRM:ACTN:RTOS');
                checkmag(mag);
                waitforidle(mag);
            end
        end
        
    case 3 % trigger
        % go to target field FIXME
        magwrite(mag,'SET:SYS:VRM:ACTN:RTOS'); % new code
        checkmag(mag);
        
    otherwise
        error('operation not supported by mercury');
end
end


function waittime=calcWait(old,new,rate,coord)
switch coord
    case 'cart'       
    case 'sph'
        old=magsph2cart(old); 
        new=magsph2cart(new);
end
        waittime=abs(norm(old-new))/abs(rate);
end

function bool=isFieldSafe(B,coord)
% return 1 if inside 1T sphere, 2 if inside cyl, 0 if unsafe
bool=0;
switch coord
    case 'cart'
    case 'sph'
        B=magsph2cart(B);
end

if norm(B)<=1
    bool=1;
end
if (abs(B(3))<=6 && norm(B(1:2))<=.262)
    bool=bool+2;
end

end

function out =ismagpersist(mag)
  magwrite(mag,'READ:SYS:VRM:SWHT');
  state = fscanf(mag,'%s'); 
  sh=sscanf(state,'STAT:SYS:VRM:SWHT:%s');
  
  if isempty(sh)
      error('garbled communication: %s',state); 
  end
  
  offs = strfind(sh,'OFF');
  ons = strfind(sh,'ON');
  
  if length(offs)==3 && isempty(ons)
      out = 1;
  elseif length(ons)==3 && isempty(offs)
      out = 0;
  else
     error('switch heaters not all the same. consider manual intervention. Heater state: %s',state); 
  end
  
end

function out = getMagField(mag, opts,coord)
% read the current field value:
% returns [X Y Z] or [R Theta Phi];
% opts can be 'magnet' or 'leads' or 'setpoint'
% 'magnet' will be magnet field whether or not magnet is persistent
if strcmp(opts,'magnet')
    magwrite(mag,'READ:SYS:VRM:VECT');
    Btemp=fscanf(mag,'%s');
    switch coord
        case 'cart'
            B= sscanf(Btemp,'STAT:SYS:VRM:VECT:[%fT%fT%fT]');
        case 'sph'
            B= sscanf(Btemp,'STAT:SYS:VRM:VECT:[%fT%frad%frad]');
    end

elseif strcmp(opts,'leads')
    magwrite(mag,'READ:SYS:VRM:OVEC');
    Btemp=fscanf(mag,'%s');
    switch coord
        case 'cart'
            B= sscanf(Btemp,'STAT:SYS:VRM:OVEC:[%fT%fT%fT]');
        case 'sph'
            B= sscanf(Btemp,'STAT:SYS:VRM:OVEC:[%fT%frad%frad]');
    end

elseif strcmp(opts,'setpoint')
    magwrite(mag,'READ:SYS:VRM:VSET');
    Btemp=fscanf(mag,'%s');
    switch coord
        case 'cart'
            B= sscanf(Btemp,'STAT:SYS:VRM:VSET:[%fT%fT%fT]');
        case 'sph'
            B= sscanf(Btemp,'STAT:SYS:VRM:VSET:[%fT%frad%frad]');
    end
else
    error('can only read magnet or lead fields');
end

if length(B)==3
    out = B;
else
   error('garbled comunications from mercury: %s', Btemp);
end
end


function goNormal(mag)
magwrite(mag,'SET:SYS:VRM:ACTN:NPERS'); 
checkmag(mag);
while ismagpersist(mag)
   pause(5); 
end
waitforidle(mag);
end

function goPers(mag)
magwrite(mag,'SET:SYS:VRM:ACTN:PERS');
checkmag(mag);
while ~ismagpersist(mag)
   pause(5); 
end
waitforidle(mag);
end


function out = ispathsafe(a,b,coord)
% see if the path from a to b will quench magnet
% if they are both contained in the same allowed volume then is is safe

fa = isFieldSafe(a,coord);
fb = isFieldSafe(b,coord);

if fb==0 || fb ==0
   error('magnet fields unsafe'); 
end
out = bitand(uint8(fa),uint8(fb))>0;
end

function holdthemagnet(mag)
  magwrite(mag,'SET:SYS:VRM:HOLD');
  checkmag(mag);
end

function magwrite(mag,msg)
fprintf(mag,'%s\r\n',msg);
end

function checkmag(mag) % checks that communications were valid
  outp=fscanf(mag,'%s');
  %fprintf('%s\n',outp);
  if isempty(strfind(outp,'VALID')) && isempty(strfind(outp,'BUSY'))
     fprintf('%s\n',outp);
      error('garbled magnet power communications: %s',outp); 
  end
end

function waitforidle(mag)
  magwrite(mag,'READ:SYS:VRM:ACTN');
  a=fscanf(mag,'%s');
  a=sscanf(a,'STAT:SYS:VRM:ACTN:%s');
  while ~strcmp(a,'IDLE')
     pause(1);
     magwrite(mag,'READ:SYS:VRM:ACTN');
     tmp=fscanf(mag,'%s');
     a=sscanf(tmp,'STAT:SYS:VRM:ACTN:%s');
  end
  
end

function cartVec=magsph2cart(sphVec)
%Converts a spherical vector to a cartesian vector in the magnet coordinate
%system
% R,Theta,Phi, theta is azimuth, phi is angle away from z axis.
    cartVec(1)=sphVec(1)*sin(sphVec(3))*cos(sphVec(2));
    cartVec(2)=sphVec(1)*sin(sphVec(3))*sin(sphVec(2));
    cartVec(3)=sphVec(1)*cos(sphVec(3));
end

