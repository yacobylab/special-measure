function val = smcMercury3axisDirect(ico, val, rate)
% Driver for 3 axis mercury power supply.
% function val = smcMercury3axisDirect(ico, val, rate)
% This driver is written to directly communicate with the power supply, not the VRM software.
% Warning! It is possible to remotely quench the magnet. The power supply does not know about the field limits of the magnet.
% It is therefore important to make sure the sub-function below isFieldSafe is properly populated
% channels are [Bx By Bz]
% ico: vector with instrument(index to smdata.inst), channel number for that instrument, operation
% operation: 0 - read, 1 - set , 2 - unused usually,  3 - trigger, 4 - 5 - go normal, 6 - go persistent
% maginst = tcpip('140.247.189.116',7020,'NetworkRole','client')
% Specify in driver if you want magnet to end in persistent mode or not.
% If not specified, leaves heaters on at end.
% For Mercury 3-axis magnet with persistent mode. 
% When changing field, driver first checks if magnet persistent
% There are 3 magnetic fields stored in the instrument: magnet, which is
% current magnetic field in magnet, leads, current magnetic field in leads,
% and setpoint, the field leads will ramp to when ramp started. 

global smdata;
chans = 'XYZ';
obj = smdata.inst(ico(1)).data.inst;
maxRate = 0.12; % Tesla/min HARD CODED
currField = getMagField(obj,'magnet'); % Read current persistent field value
oldFieldVal= currField;
if ico(3)==1, ratePerMinute = rate*60; end % Convert from /sec (sm units) to /min (Oxford units)
chan = ico(2);  %Only programmed for Bx, By, Bz
if chan ~=1 && chan ~=2 && chan~=3
    error('Channel not programmed into Mercury');
end
if ~isfield(smdata.inst(ico(1)).data,'endPers')
    endPers = false;
else
    endPers = smdata.inst(ico(1)).data.endPers;
end

switch ico(3) % operation
    case 0 % read
        val = oldFieldVal(chan);
    case 1 % set
        oldSetPoint = getMagField(obj,'setpoint'); % figure out the new setpoint
        if any(abs(oldSetPoint - currField)>5e-4)
            fprintf('Set point not equal to field. Setting them to be the same \n');
            for i = 1:3
                cmd = sprintf('SET:DEV:GRP%s:PSU:SIG:FSET:%f',chans(i),currField(i)); % set setpoint
                magwrite(obj,cmd);
            end
        end
        newSetPoint = currField; newSetPoint(chan) = val; % Values to set magnetic field to 
        if ~isFieldSafe(newSetPoint), error('Unsafe field requested. Are you trying to kill me?'); end
        if ~ispathsafe(oldFieldVal,newSetPoint), error('Path from current to final B goes outside of allowed range'); end
        if abs(ratePerMinute) > maxRate, error('Magnet ramp rate of %f too high. Must be less than %f T/min',ratePerMinute,maxRate); end
        if ratePerMinute < 0, holdMagnet(obj); end % Set to hold. This stabilizes magnet.
        heaterOn = ~isMagPersist(obj);
        if ~all(currField==newSetPoint) %only make changes if we're not at the target field
            if ratePerMinute > 0 && ~heaterOn,  goNormal(obj);   end % Ramp leads to current magnet value
            cmd = sprintf('SET:DEV:GRP%s:PSU:SIG:RFST:%f',chans(ico(2)),abs(ratePerMinute)); % Set rate
            magwrite(obj,cmd);
            cmd = sprintf('SET:DEV:GRP%s:PSU:SIG:FSET:%f',chans(ico(2)),val); % Set field
            magwrite(obj,cmd);
            if ratePerMinute > 0
                cmd = sprintf('SET:DEV:GRP%s:PSU:ACTN:RTOS',chans(ico(2))); % Start ramp
                magwrite(obj,cmd);
                val = 0;
                waitforidle(obj);
            else
                val = abs(norm(oldFieldVal-newSetPoint)/abs(rate)); % readout ramptime
            end
            if ratePerMinute > 0 && ~isMagPersist(obj) && endPers
                goPers(obj);
                if ~isMagPersist(obj), error('Magnet did not go persistent. Check magnet.'); end
            end
        end
    case 3 % go to target field
        cmd = sprintf('SET:DEV:GRP%s:PSU:ACTN:RTOS',chans(ico(2))); magwrite(obj,cmd);
    case 5 % If running ramp, will want to go Normal before scan and go persistent at end.
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
    statetmp{i}=magwrite(obj,cmdtmp); % Check if switch heater on
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
    magfield = magwrite(mag,sprintf(cmd,chans(i)));
    % pause(0.125);
    % changed 2018-06-13 for use with MX400 mercury power supply:
    % pause(0.3);
    
    B(i) = sscanf(magfield,[sprintf(cmdForm,chans(i)) ':%fT']);
end
end

function goNormal(obj)
% Takes the current in the leads up to that in the magnet and opens the switch
% Has pauses and checks built in.
chans = 'XYZ';                
state = isMagPersist(obj);
if state == 0
    warning('Magnet appears to already be normal. State: %d',state);
    return
end
for i = 1:length(chans) % Ramp the leads to setpoint.
    cmd = sprintf('SET:DEV:GRP%s:PSU:ACTN:RTOS',chans(ico(2))); magwrite(obj,cmd);
end
waitforidle(obj);

for i = 1:length(chans) % Turn on all switch heaters
    cmd = sprintf('SET:DEV:GRP%s:PSU:SIG:SWHT:ON',chans(ico(2))); magwrite(obj,cmd);
end
waitforidle(obj);
end

function goPers(mag)
%Turn off all switch heaters
state = isMagPersist(mag);
if state == 1
    error('Magnet appears to already be persistent. State: %f',state);
end

magwrite(mag,'SET:DEV:GRPX:PSU:SIG:SWHT:OFF');
magwrite(mag,'SET:DEV:GRPY:PSU:SIG:SWHT:OFF');
magwrite(mag,'SET:DEV:GRPZ:PSU:SIG:SWHT:OFF');
waitforidle(mag);

magwrite(mag,'SET:DEV:GRPX:PSU:ACTN:RTOZ');
magwrite(mag,'SET:DEV:GRPY:PSU:ACTN:RTOZ');
magwrite(mag,'SET:DEV:GRPZ:PSU:ACTN:RTOZ');
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
% In this mode there is a fine trim function running which ensures the output is held constantly and precisely at the set point.
magwrite(mag,'SET:DEV:GRPX:PSU:ACTN:HOLD');
magwrite(mag,'SET:DEV:GRPY:PSU:ACTN:HOLD');
magwrite(mag,'SET:DEV:GRPZ:PSU:ACTN:HOLD');
end

function outp=magwrite(mag,msg)
outp=query(mag,msg);
if contains(outp,'INVALID')
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
        state{i}=magwrite(mag,cmdCurr);
        state{i} = sscanf(state{i},[sprintf(cmdForm,chans(i)) ':%s']);
        if strcmp(state{i},'HOLD')
            fin(i) = 1;
        end
    end
    pause(5);
end
end