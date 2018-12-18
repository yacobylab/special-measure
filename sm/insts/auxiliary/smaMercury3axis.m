function out = smaMercury3axis(opts,valIn)

global smdata;
inst = sminstlookup('VectorMagnet'); 
obj = smdata.inst(inst).data.inst; 

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
if isopt(opts,'heaterOn')
    goNormal(obj); 
end
if isopt(opts,'heaterOff')
    goPers(obj); 
end
if isopt(opts,'chgSet') 
    chans = 'XYZ';
    for i = 1:3 
        cmd = sprintf('SET:DEV:GRP%s:PSU:SIG:FSET:%f',chans(i),valIn(i)); % set field    
        magwrite(obj,cmd); checkmag(obj);
    end
end
end

function state = isMagPersist(obj) 
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
    magfield=magwrite(mag,sprintf(cmd,chans(i)));        
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
magwrite(mag,'SET:DEV:GRPX:PSU:ACTN:RTOS'); 
magwrite(mag,'SET:DEV:GRPY:PSU:ACTN:RTOS'); 
magwrite(mag,'SET:DEV:GRPZ:PSU:ACTN:RTOS'); 
waitforidle(mag);

% Turn on all switch heaters 
magwrite(mag,'SET:DEV:GRPX:PSU:SIG:SWHT:ON'); 
magwrite(mag,'SET:DEV:GRPY:PSU:SIG:SWHT:ON'); 
magwrite(mag,'SET:DEV:GRPZ:PSU:SIG:SWHT:ON'); 
waitforidle(mag);

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

function outp=magwrite(mag,msg)
outp=query(mag,msg);
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
    state{i}=magwrite(mag,cmdCurr);    
    state{i} = sscanf(state{i},[sprintf(cmdForm,chans(i)) ':%s']);
    if strcmp(state{i},'HOLD')
        fin(i) = 1;
    end
    end    
    pause(5);
end
end