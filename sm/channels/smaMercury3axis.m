function out = smaMercury3axis(opts,chan)
% function val = smcMercury3axisDirect(ico, val, rate)
% Here are the old comments from the IPS supply: 
% ico: vector with instrument(index to smdata.inst), channel number for that instrument, operation
% operation: 0 - read, 1 - set , 2 - unused usually,  3 - trigger
% rate overrides default
% grab the channel. I think we'll look up the instrument. 
%  
global smdata;
inst = sminstlookup('VectorMagnet'); 
chans = 'XYZ';
obj = smdata.inst(inst).data.inst; 
maxRate = 0.12; % Tesla/min HARD CODED. 2 mT / s 

if isopt(opts, 'magnet')
    out.currField = getMagField(obj,'magnet');
end
if isopt(opts,'leads') 
    out.leadField = getMagField(obj,'leads'); 
end
if isopt(opts,'setpoint') 
    out.setpoint = getMagField(obj,'setpoint'); 
end
if isopt(opts,'queryHeater')
    val = ~isMagPersist(obj); 
    out.heater = val; 
end
if isopt(opts,'heaterOn');
    goNormal(obj); 
end
if isopt(opts,'heaterOff')
    goPers(obj); 
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