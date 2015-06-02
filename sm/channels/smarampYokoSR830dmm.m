function scan = smarampYokoSR830dmm2(scan, cntrl, ndmmsamples)
% scan = smcrampYokoSR830dmm2(scan, cntrl, ndmmsamples)
% Configures scan for syncronized acquisition with SR830, Yokogawa, and
% dmm, capable of handling multiple instruments [NOT YET IMPLEMENTED!]
% cntrl: dmm lock, lock dmm, lock, dmm 
%        specifies readout instruments to be syncronized, first one determines
%        time base. depending on cntrl, this routine does the following:
%
% dmm: programs dmm to sample at a rate corresponding to
%      scan.loops(1).ramptime if possible, or the maximum supported
%      rate. scan.loops(1).ramptime is changed to the actual sampling
%      interval.
% dmm lock: as dmm, plus the lockin is set to hardware triggered sampling, 
%     so that it can be triggerd by the DMM's "VM complete' output
% lock: sets sample interval of lockins to value nearest
%     scan.loops(1).ramptime and corrects the latter. 
% lock dmm: as lock, plus the dmm is set to sample at the same rate if 
% possible, or at the highest possible rate and to take fewer points.
% If ginven and compatible with the instrument limitations, ndmmsamples points
% are taken at each point.
% 
% The lockin and/or dmm are programmed to record data upon triggering with
% scans.loops(1).trigfn, which is set appropriately.
% This utility makes the following assumptions
% - scan.loops(1).setchan(yokos) are the Yokogawas to be triggered
% - all SR830 and HP34401A in the system are to be programmed and triggered.


global smdata;
 
% should check that specified channels are the right instruments, maybe
% detect automatically. Needs inst ID, though.

if strfind(cntrl, 'lock')
    lockin = sminstlookup('SR830'); % assumes there is only one
else
    lockin = [];
end
if strfind(cntrl, 'dmm')
    dmm = sminstlookup('HP34401A');
else 
    dmm = [];
end
    
yokos = smchaninst(scan.loops(1).setchan); % assumes no other ramped device

if strfind(cntrl, 'lock') == 1
    % corect rate to lockin capability if lockin used and not slaved to dmm
    n = round(-log2(abs(scan.loops(1).ramptime))) + 4;
    scan.loops(1).ramptime = -2^(4-n);
else
    n = 14;
end

for inst = lockin
    fprintf(smdata.inst(inst).data.inst, 'REST; SEND 1; TSTR 0; SRAT %i', n);
    smdata.inst(inst).data.sampint = abs(scan.loops(1).ramptime);
    smdata.inst(inst).datadim(15:16, 1) = scan.loops(1).npoints;
end


samptime = .035; % minumum time per sample for dmm - heuristic
trigdel = max(abs(scan.loops(1).ramptime) - samptime, 0);
if strfind(cntrl, 'dmm') == 1
    % dmm determines time base, keep # points, adapt ramptime
    ndmmsamples = scan.loops(1).npoints;
    scan.loops(1).ramptime = -max(abs(scan.loops(1).ramptime), samptime);        
else %dmm either not used or lockin determining samplerate.
    if nargin < 3
        ndmmsamples = scan.loops(1).npoints;
    end
    ndmmsamples = min(ndmmsamples, floor(scan.loops(1).npoints ...
        * abs(scan.loops(1).ramptime)/samptime));
    trigdel = max(abs(scan.loops(1).ramptime)*scan.loops(1).npoints/ndmmsamples - samptime, 0);
end

for inst = dmm
    if ndmmsamples > 512
        fprintf('More than 512 samples not supported by DMM. Correct and try again!\n');
    end
    fprintf(smdata.inst(inst).data.inst, 'TRIG:SOUR BUS');
    fprintf(smdata.inst(inst).data.inst, 'SAMP:COUN %d', ndmmsamples);
    fprintf(smdata.inst(inst).data.inst, 'TRIG:DEL %f', trigdel);
    smdata.inst(inst).datadim(2, 1) = ndmmsamples;
end

scan.loops(1).trigfn.fn = @smatrigYokoSR830dmm;
if strfind(cntrl, 'dmm lock')
    scan.loops(1).trigfn.args = {yokos(:, 1:min(1, end))', lockin, dmm, 1};
else
    scan.loops(1).trigfn.args = {yokos(:, 1:min(1, end))', lockin, dmm};
end