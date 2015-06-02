function scan = smarampYokoSR830(scan)
% scan = smcrampYokoSR830(scan)
% Configures scan for syncronized acquisition with SR830 and Yokogawa
% - assumes scan.loops(end-1).getchan(lockins) to be SR830s and
%   scan.loops(end).setchan(yokos) to be Yokogawas
% - sets sample interval of lockins to value nearest
%   scan.loops(end).ramptime and corrects the latter.
% - programs lockins to record data.
% - sets scans.loops(end).trigfn.

global smdata;
 
    
% if nargin >=2 
%     lockins = scan.loops(end-1).getchan(lockins, :);
% else
%     lockins = scan.loops(end-1).getchan;
% end
% 
% if nargin >=3
%     yokos = scan.loops(end).setchan(yokos);
% else
%     yokos = scan.loops(end).setchan;
% end
% 
% yokos = smchanlookup(yokos);
% lockins = smchanlookup(lockins);

% should check that specified channels are the right instruments, maybe
% detect automatically. Needs inst ID, though.

lockin = sminstlookup('SR830'); % assumes there is only one
yokos = smchaninst(scan.loops(end).setchan); % assumes no other ramped device

% correct rate to lockin capability.
n = round(-log2(abs(scan.loops(end).ramptime))) + 4;
scan.loops(end).ramptime = -2^(4-n);

for inst = lockin
    fprintf(smdata.inst(inst).data.inst, 'REST; SEND 1; TSTR 0; SRAT %i', n);
    smdata.inst(inst).data.sampint = abs(scan.loops(end).ramptime);
    smdata.inst(inst).datadim(15:16, 1) = scan.loops(end).npoints;
end

%Set displayed channel(s)?

% lockins = vertcat(smdata.channels(lockins).instchan);
% yokos = vertcat(smdata.channels(yokos).instchan);

scan.loops(end).trigfn.fn = @smatrigYokoSR830;
scan.loops(end).trigfn.args = {lockin, yokos(:, 1)};
