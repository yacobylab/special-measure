function niceprint(scan)
global smdata;
if isprop(scan,'scan') && ~isfield(scan,'loops')
    scan = scan.scan; 
end
if isfield(scan.loops,'settle') && ~isempty(scan.loops(1).settle)
    Loop1Time= (scan.loops(1).npoints*abs(scan.loops(1).ramptime)+scan.loops(1).settle)*scan.loops(2).npoints;
    fprintf('Settle time %2.2f s \n',scan.loops(1).settle)
else
    Loop1Time = (scan.loops(1).npoints*abs(scan.loops(1).ramptime))*scan.loops(2).npoints;
end
if ~iscell(scan.loops(1).setchan)
    scan.loops(1).setchan={scan.loops(1).setchan};
end
if ~iscell(scan.loops(2).setchan)
    scan.loops(2).setchan={scan.loops(2).setchan};
end
ramprate1 = smdata.channels(chl(scan.loops(1).setchan{1})).rangeramp(3);
resetTime = abs(diff(scan.loops(1).rng))/ramprate1*scan.loops(2).npoints;
ramprate2 = smdata.channels(chl(scan.loops(2).setchan{1})).rangeramp(3);
Loop2Time = abs(diff(scan.loops(2).rng))/ramprate2;
scanTime = (resetTime + Loop2Time + Loop1Time)/60;
fprintf('Scan time = %3.3g minutes \n',scanTime)
pointSpacingX = diff(scan.loops(1).rng)/scan.loops(1).npoints;
pointSpacingY = diff(scan.loops(2).rng)/scan.loops(2).npoints;
ramprate = abs(pointSpacingX/scan.loops(1).ramptime);
fprintf('Spacing: X = %3.3f mV Y = %3.3f mV. Ramprate: %3.0f mV/s \n',...
    pointSpacingX*1e3, pointSpacingY*1e3, ramprate*1e3);
smprint(scan);
end