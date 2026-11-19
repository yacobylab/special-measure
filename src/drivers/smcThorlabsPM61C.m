function [val, rate] = smcThorlabsPM61C(ico, val, rate)
% 6/2026 FTL
% Driver for Thorlabs PM61C Optical Power Meter — old VISA API (visa/fprintf/query)
% ico(1): instrument index in smdata
% ico(2): channel / parameter to control
    %   1  - Power measurement (W or dBm depending on unit setting)
    %   2  - Power unit        (get/set: 0=Watts, 1=dBm)
    %   3  - Wavelength (nm)   (get/set)
    %   4  - Averaging count   (get/set: 1..5000, sets meas rate = 1000/N Hz)
    %   5  - Bandwidth         (get/set: 0=full ~100kHz, 1=limited ~3Hz)
    %   6  - Power range (W)   (get/set)
    %   7  - Auto-range        (get/set: 0=off, 1=on)
    %   8  - Scope power (W)   (10000-point raw Scope Mode array)
    %   9  - Scope time (s)    (relative timestamps for the same capture)
% ico(3): 0=get, 1=set, 3=trigger, 4=arm/reset, 5=configure

global smdata
pm = smdata.inst(ico(1)).data.inst;

switch ico(2)
    % --- 1: Power measurement ---
    case 1
        switch ico(3)
            case 0 % get
                val = str2double(query(pm, 'MEAS?'));
            otherwise
                error('PM61C: Power is read-only.');
        end

    % --- 2: Power unit ---
    case 2
        switch ico(3)
            case 0 % get: returns 0 (W) or 1 (dBm)
                val = double(strcmpi(strtrim(query(pm, 'SENS:POW:UNIT?')), 'DBM'));
            case 1 % set: 0=W, 1=dBm
                if val == 1
                    fprintf(pm, 'SENS:POW:UNIT DBM');
                else
                    fprintf(pm, 'SENS:POW:UNIT W');
                end
            otherwise
                error('PM61C: Operation not supported for Unit.');
        end

    % --- 3: Wavelength (nm) ---
    case 3
        switch ico(3)
            case 0 % get
                val = str2double(query(pm, 'SENS1:CORR:WAV?'));
            case 1 % set
                fprintf(pm, sprintf('SENS1:CORR:WAV %d', round(val)));
            otherwise
                error('PM61C: Operation not supported for Wavelength.');
        end

    % --- 4: Averaging count ---
    case 4
        switch ico(3)
            case 0 % get
                val = str2double(query(pm, 'SENS1:AVER?'));
            case 1 % set: integer count, 1..5000
                % Text presets are deliberately not accepted: smset does
                % arithmetic on vals before the driver is called, so a char
                % array silently arrives here as its character codes.
                if ~isnumeric(val)
                    error(['PM61C: Averaging must be numeric (1 through ' ...
                        '5000); text presets are not supported by smset.']);
                end
                val = round(val);
                if ~isscalar(val) || ~isfinite(val) || val < 1 || val > 5000
                    error('PM61C: Averaging must be an integer from 1 through 5000.');
                end
                fprintf(pm, sprintf('SENS1:AVER %d', val));
            otherwise
                error('PM61C: Operation not supported for Averaging.');
        end

    % --- 5: Bandwidth filter ---
    case 5
        switch ico(3)
            case 0 % get: returns 0 or 1
                val = str2double(query(pm, 'INP1:FILT?'));
            case 1 % set: 0=full, 1=limited
                fprintf(pm, sprintf('INP1:FILT %d', val ~= 0));
            otherwise
                error('PM61C: Operation not supported for Bandwidth.');
        end

    % --- 6: Power range (W) ---
    case 6
        switch ico(3)
            case 0 % get current range upper limit (W)
                val = str2double(query(pm, 'SENS:POW:RANG?'));
            case 1 % set manual range
                if ~isscalar(val) || ~isfinite(val) || val <= 0
                    error('PM61C: Range must be a positive scalar in W.');
                end
                fprintf(pm, sprintf('SENS:POW:RANG %g', val));
            otherwise
                error('PM61C: Operation not supported for Range.');
        end

    % --- 7: Auto-range ---
    case 7
        switch ico(3)
            case 0 % get: returns 0 or 1
                val = str2double(query(pm, 'SENS:POW:RANG:AUTO?'));
            case 1 % set: 0=off, 1=on
                fprintf(pm, sprintf('SENS:POW:RANG:AUTO %d', val ~= 0));
            otherwise
                error('PM61C: Operation not supported for AutoRange.');
        end

    % --- 8-9: Buffered Scope Mode readout ---
    case {8, 9}
        switch ico(3)
            case 0 % get the shared capture
                [scopePower, scopeTime] = readScopeCapture(ico(1));
                if ico(2) == 8
                    val = scopePower;
                else
                    val = scopeTime;
                end

            case 3 % trigger: software-triggered Scope Mode starts on INIT
                ensureScopeState(ico(1));
                fprintf(pm, 'INIT');
                smdata.inst(ico(1)).data.scopeGeneration = ...
                    smdata.inst(ico(1)).data.scopeGeneration + 1;
                smdata.inst(ico(1)).data.scopeTriggered = true;
                invalidateScopeCache(ico(1));

            case 4 % arm/reset for a new outer-loop point
                ensureScopeState(ico(1));
                fprintf(pm, 'ABOR');
                smdata.inst(ico(1)).data.scopeTriggered = false;
                invalidateScopeCache(ico(1));

            case 5 % configure, called by smabufconfig2 from the scan
                if nargin < 3 || ~isscalar(rate) || ~isfinite(rate) || rate <= 0
                    error('PM61C: Scope configuration requires a positive rate.');
                end
                if ~isscalar(val) || ~isfinite(val) || val < 1
                    error('PM61C: Scope configuration requires a positive point count.');
                end

                requestedDuration = val / rate;
                scopeAverage = max(1, ceil(10 * requestedDuration));
                if scopeAverage > double(intmax('uint32'))
                    error('PM61C: Requested capture duration is too long.');
                end
                val = 10000;
                rate = 100000 / scopeAverage;
                configureScope(ico(1), scopeAverage, rate);

            otherwise
                error('PM61C: Operation not supported for Scope channel.');
        end

    otherwise
        error('PM61C: Unknown channel ico(2) = %d.', ico(2));
end
end

function configureScope(instIndex, scopeAverage, scopeRate)
global smdata
pm = smdata.inst(instIndex).data.inst;

fprintf(pm, 'ABOR');
drainErrors(pm);

if str2double(query(pm, 'SENS:POW:RANG:AUTO?')) ~= 0
    error(['PM61C: Scope Mode requires manual range. Set Range_PM and ' ...
        'AutoRange_PM=0 in scan.consts before the configfn runs.']);
end

fprintf(pm, 'SENS1:FREQ:MODE CW');
fprintf(pm, 'INP1:FILT 0');
fprintf(pm, 'SENS:POW:UNIT W');
fprintf(pm, 'CONF:ARR:CHA');
fprintf(pm, sprintf('CONF:ARR %d', scopeAverage));
checkError(pm, 'Scope Mode configuration');

ensureScopeState(instIndex);
smdata.inst(instIndex).datadim(8:9, 1) = 10000;
smdata.inst(instIndex).data.scopePoints = 10000;
smdata.inst(instIndex).data.scopeAverage = scopeAverage;
smdata.inst(instIndex).data.scopeRate = scopeRate;
smdata.inst(instIndex).data.scopeDuration = 10000 / scopeRate;
smdata.inst(instIndex).data.scopeTriggered = false;
invalidateScopeCache(instIndex);
end

function [power, time] = readScopeCapture(instIndex)
global smdata
ensureScopeState(instIndex);
state = smdata.inst(instIndex).data;
pm = state.inst;

if ~state.scopeTriggered
    error('PM61C: Scope acquisition has not been triggered.');
end
if state.scopeCacheGeneration == state.scopeGeneration
    power = state.scopePower;
    time = state.scopeTime;
    return
end

timeout = max(5, state.scopeDuration + 5);
t0 = tic;
while str2double(query(pm, 'FETC:STAT?')) == 0
    if toc(t0) > timeout
        error(['PM61C: Scope buffer not ready after %.3g s; expected ' ...
            'capture duration %.3g s.'], timeout, state.scopeDuration);
    end
    pause(min(0.02, max(0.002, state.scopeDuration / 1000)));
end

npts = state.scopePoints;
rawTime = zeros(1, npts, 'uint32');
power = zeros(1, npts);
offset = 0;
while offset < npts
    requested = min(100, npts - offset);
    [timeBlock, powerBlock] = fetchScopeBlock(pm, offset, requested);
    count = numel(timeBlock);
    idx = offset + (1:count);
    rawTime(idx) = timeBlock;
    power(idx) = powerBlock;
    offset = offset + count;
end

ticks = double(rawTime);
time = [0, cumsum(mod(diff(ticks), 2^32))] * 1e-6;
smdata.inst(instIndex).data.scopePower = power;
smdata.inst(instIndex).data.scopeTime = time;
smdata.inst(instIndex).data.scopeRawTime = rawTime;
smdata.inst(instIndex).data.scopeCacheGeneration = state.scopeGeneration;
end

function [time, power] = fetchScopeBlock(pm, offset, requested)
while pm.BytesAvailable > 0
    fread(pm, min(pm.BytesAvailable, 4096), 'uint8');
end
fprintf(pm, sprintf('FETC:ARR? %d,%d', offset, requested));

[countBytes, nread] = fread(pm, 4, 'uint8');
if nread ~= 4
    error('PM61C: Incomplete binary count at offset %d.', offset);
end
count = double(typecast(uint8(countBytes(:))', 'uint32'));
if count < 1 || count > requested
    error('PM61C: Invalid block count %d at offset %d.', count, offset);
end

[payload, nread] = fread(pm, 8 * count, 'uint8');
if nread ~= 8 * count
    error('PM61C: Incomplete binary payload at offset %d.', offset);
end
records = reshape(uint8(payload), 8, count);
time = typecast(reshape(records(1:4, :), 1, []), 'uint32');
power = double(typecast(reshape(records(5:8, :), 1, []), 'single'));
end

function ensureScopeState(instIndex)
global smdata
defaults = {'scopePoints', 10000; 'scopeAverage', 1; ...
    'scopeRate', 100000; 'scopeDuration', 0.1; ...
    'scopeGeneration', 0; 'scopeCacheGeneration', -1; ...
    'scopeTriggered', false; 'scopePower', []; 'scopeTime', []; ...
    'scopeRawTime', uint32([])};
for k = 1:size(defaults, 1)
    if ~isfield(smdata.inst(instIndex).data, defaults{k, 1})
        smdata.inst(instIndex).data.(defaults{k, 1}) = defaults{k, 2};
    end
end
end

function invalidateScopeCache(instIndex)
global smdata
smdata.inst(instIndex).data.scopeCacheGeneration = -1;
smdata.inst(instIndex).data.scopePower = [];
smdata.inst(instIndex).data.scopeTime = [];
smdata.inst(instIndex).data.scopeRawTime = uint32([]);
end

function drainErrors(pm)
for k = 1:20
    response = strtrim(query(pm, 'SYST:ERR?'));
    if ~isempty(regexp(response, '^\+?0(?:,| )', 'once')) %#ok<RGXP1>
        return
    end
end
end

function checkError(pm, action)
response = strtrim(query(pm, 'SYST:ERR?'));
if isempty(regexp(response, '^\+?0(?:,| )', 'once')) %#ok<RGXP1>
    error('PM61C: %s failed: %s', action, response);
end
end
