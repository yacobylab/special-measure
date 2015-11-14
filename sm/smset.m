function smset(channels, vals, ramprate)
% function smset(channels, vals, ramprate)
%
% Set channels to vals.
% Channels can be a cell or char array with channel names, or a vector
% with channel numbers.
% vals is a vector with one element for each channel.
% ramprate is used instead of instrument default if given, finite,     
% and smaller than default. A negative ramprate prevents
% waiting for ramping to finish for self ramping channels (smdata.inst type = 1).
% (This feature is mainly used by smrun).
% After checking that vals and ramprates given are within bounds of
% rangeramp, divides channels into stepchans, setchans, rampchans. 
% setchans have infinite ramprate and are just to set to final value. 
% stepchans are stepped every 10 ms to final value, waiting correct time
% for ramprate. 
% rampchans have ramping done by the driver. If a negative ramprate is
% given, note that 

global smdata;

if isempty(channels) 
    return
end

if ~isnumeric(channels)
    channels = smchanlookup(channels);
end

nchan = length(channels);

if size(vals, 2) > 1 %use vertical list of channels. 
    vals = vals';
end
% could make some variables persistent and add recycling flag argument.

if length(vals) == 1 %if many channels and one value given, all get same value. 
    vals = vals * ones(nchan, 1);
end


rangeramp = vertcat(smdata.channels(channels).rangeramp);
instchan = vertcat(smdata.channels(channels).instchan);

% if ramprate given: 
if exist('ramprate','var') && ~isempty(ramprate)
    if size(ramprate, 2) > 1
        ramprate = ramprate';
    end

    if length(ramprate) == 1 % if many channels and one ramprate given, all get same ramprate. 
        ramprate = ramprate * ones(nchan, 1);
    end

    % check that finite ramprates are smaller than the max given by
    % rangeramp.  
    mask = isfinite(ramprate);
    if any(mask)
        autoramp = sign(ramprate); 
        rangeramp(mask,3) = min(abs(ramprate(mask)), rangeramp(mask, 3));       
        rangeramp(mask,3) = autoramp .* rangeramp(mask,3); % Keep sign for autoramp. 
    end
end
ramprate = rangeramp(:,3); 

% Check that the vals are within rangeramp limits. 
vals = max(min(vals, rangeramp(:, 2)), rangeramp(:, 1));

valsScaled = vals .* rangeramp(:, 4); % scale vals by multiplier 
ramprate = ramprate .* rangeramp(:, 4); % scale ramprate by multiplier


currVals = zeros(nchan, 1);
chantype = zeros(nchan, 1);
ramptime = zeros(nchan, 1);

% Check which channels can be ramped - chantype = 1 is ramping. 
for k = 1:nchan
    chantype(k) = smdata.inst(instchan(k, 1)).type(instchan(k, 2));
end

rampchan = find(chantype == 1);
stepchan = find(chantype == 0);

if any(ramprate(stepchan) < 0)
    error('Negative ramp rate for step channel.');
end
    
setchan = find(~isfinite(ramprate));

% get current val for step channels
for k = stepchan'
    currVals(k)= smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 0]);
end

% start ramps
for k = rampchan' 
    ramptime(k) = smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 1], valsScaled(k), ramprate(k));
end

for k = setchan'    
    smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 1], valsScaled(k));
end

tramp = now;

if ishandle(999)
    smdispchan(channels([rampchan; setchan]), vals([rampchan; setchan]));
end

dt = .01;
% step channels - the ramprate is maintained by smset, not through control
% function. 
if ~isempty(stepchan)
    dirStep = (2 * (valsScaled(stepchan) > currVals(stepchan)) - 1); % direction of step. (final value > init, dirStep = 1)
    sizeStep = dt * ramprate(stepchan) .* dirStep; 
    nstep = floor((valsScaled(stepchan)-currVals(stepchan))./sizeStep);
    for i = 1:max(nstep)
        tstep = now;
        currVals = currVals + sizeStep;        
        for k = stepchan(i <= nstep)'; % chans that haven't reach final value
            smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 1], currVals(k));
        end
        
        % update the display every 10 steps. 
        if ishandle(1001) && ~mod(i, 10)
            smdispchan(channels(stepchan(i <= nstep)), currVals(stepchan(i <= nstep))...
                ./rangeramp(stepchan(i <= nstep), 4));
        end

        % wait until dt is reached to maintain ramprate. 
        while (now - tstep) * 24 * 3600 < dt ;end
        
        if ishandle(1000) 
            c = get(1000, 'CurrentCharacter');
            if c == char(27)
                return;
            end
        end
    end
end

%After the last step, set channels to exact final value. 
for k = stepchan'    
    smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 1], valsScaled(k));
end

if ishandle(999)
    smdispchan(channels(stepchan), vals(stepchan));
end
smdata.chanvals(channels) = vals;


% rampchans let the driver do the ramping, but don't return until correct
% time has passed. 
rampchan = rampchan(ramprate(rampchan) > 0); % For rampchans with ramprate < 0, the driver will ramp. 
ramptime = ramptime(rampchan);
if ~isempty(rampchan)
    pause(max(ramptime) + 24*3600*(tramp - now)); 
    return; 
    % Next lines appear to use different method, querying the remainder of
    % ramping time through driver. However, not currently used. 
    %[ramptime, ind] = sort(ramptime, 'descend'); 
    %for k = rampchan(ind)'       
    %   t = Inf;
    %    while t > 0
    %        t = smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 2], [], rangeramp(k, 3));
    %        pause(0.8 * t);
    %    end
    %end
end

end

