function val = smcSantecTSL775(ico, val, ~)
% 9/2026 FTL
% Santec TSL-775 tunable laser, GPIB, SCPI command set -- step-and-read driver.
% A Wavelength set blocks until the laser reports it has finished tuning,
% so in a stepped smrun loop the next getchan (e.g. a power meter) reads at
% the new wavelength. No hardware sweeps, triggers or sweep-log readout.
%
% Requires the SCPI command set (front panel: Other > Communication). In
% SCPI mode an unsuffixed length is read as METERS, so wavelength commands
% carry an explicit NM suffix.
%
% ico(2): 1 Wavelength  (nm)  get/set
%         2 Power       (dBm) get/set  setpoint, -5..13 dBm (auto power control)
%         3 PowerActual (dBm) get      internal power monitor
%         4 Output      (0/1) get/set  laser emission (:POW:STAT)
% ico(3): 0 = get, 1 = set

global smdata
tsl = smdata.inst(ico(1)).data.inst;

getcmds = {':WAV? NM', ':POW?', ':POW:ACT?', ':POW:STAT?'};
if ico(2) < 1 || ico(2) > numel(getcmds)
    error('SantecTSL775: unknown channel %d.', ico(2));
end

switch ico(3)
    case 0 % get
        val = parseNum(query(tsl, getcmds{ico(2)}));

    case 1 % set
        switch ico(2)
            case 1, cmd = sprintf(':WAV %.4fNM', val);
            case 2, cmd = sprintf(':POW %.2f', val);
            case 4, cmd = sprintf(':POW:STAT %d', val ~= 0);
            otherwise, error('SantecTSL775: channel %d is read-only.', ico(2));
        end
        fprintf(tsl, '*CLS'); % empty the error queue so checkError sees only this command
        fprintf(tsl, cmd);
        waitDone(tsl, 30);
        checkError(tsl, cmd);

    otherwise
        error('SantecTSL775: operation %d not supported.', ico(3));
end
end

function waitDone(tsl, tmax)
% The TSL-775's *OPC? answers immediately: 0 while an operation (wavelength
% change, output turn-on) is in progress, 1 once finished (manual 7.4.3).
t0 = tic;
while parseNum(query(tsl, '*OPC?')) ~= 1
    if toc(t0) > tmax
        error('SantecTSL775: operation still running after %g s.', tmax);
    end
    pause(0.02);
end
end

function checkError(tsl, cmd)
% A refused command (-200 Execution error, -222 Data out of range) is
% reported only in the error queue; the command itself gives no sign.
e = strtrim(query(tsl, ':SYST:ERR?'));
if ~contains(e, '+0,')
    error('SantecTSL775: "%s" was refused: %s', cmd, e);
end
end

function val = parseNum(s)
% SCPI replies look like '+1.55000000E+003', possibly with a unit suffix.
tok = regexp(strtrim(s), '^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?', 'match', 'once');
if isempty(tok)
    error('SantecTSL775: unexpected reply "%s".', strtrim(s));
end
val = str2double(tok);
end