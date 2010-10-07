function scan = smabufconfig2(scan, cntrl, getrng, setrng)
% scan = smabufconfig2(scan, cntrl, irng)
% Configure buffered acquisition for fastest loop using drivers. 
% Supersedes smarampconfig/smabufconfig if driver provides this
% functionality.
%
% cntrl: trig : use smatrigfn for triggering
%         arm : use smatrigfn to arm insts in loops(2).prefn(1)
% irng: indices to loops(2).getchan to be programmed (and armed/triggered).
%   
% Possible extensions (not implemented): 
% - configure decimation (see smarampconfig for code)

global smdata;


if nargin < 2 
    cntrl = '';
end

getic = smchaninst(scan.loops(2).getchan);
if nargin >= 3
   getic = getic(getrng, :);
end

setic = smchaninst(scan.loops(1).setchan);
if nargin >= 4
   setic = setic(setrng, :);
end

for i = 1:size(getic, 1)
    [scan.loops(1).npoints, rate] = smdata.inst(getic(i, 1)).cntrlfn([getic(i, :), 5], scan.loops(1).npoints, ...
        -1/scan.loops(1).ramptime);
    scan.loops(1).ramptime = -1/rate;
end

if strfind(cntrl, 'trig')
    scan.loops(1).trigfn.fn = @smatrigfn;
    scan.loops(1).trigfn.args = {[setic; getic]};
end

if strfind(cntrl, 'arm')
    scan.loops(2).prefn.fn = @smatrigfn;
    scan.loops(2).prefn.args = {getic, 4};
end
