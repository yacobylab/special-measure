function scan = smarampconfig(scan, cntrl, ovsmpl)
% scan = smarampconfig(scan, cntrl)
% configure buffered acquisition for fastest loop using smabufconfig + triggering
% cntrl is passed on to smabufconfig

ic = smchaninst(scan.loops(2).getchan);

if nargin < 2 
    cntrl = '';
end
%if nargin >= 2 &&~ isempty(order)
%    ic = ic(order, :);
%end

%if ~isfield(scan.loops, 'procfn') || isempty(scan.loops(2).procfn)
if nargin >=3 && ovsmpl ~= 1
    %if ovsmpl == 0 % smart default        
        %ovsmpl = ;
    %end
    lenrate = smabufconfig(ic(:, 1)', scan.loops(1).npoints*ovsmpl, ...
        ovsmpl/abs(scan.loops(1).ramptime), cntrl);
    scan.loops(1).npoints = ceil(lenrate(1)/ovsmpl);
    scan.loops(1).ramptime = -ovsmpl/lenrate(2); 
    pf.dim = scan.loops(1).npoints;
    pf.fn.fn = @decimate;
    pf.fn.args = {ovsmpl};
    if isempty(scan.loops(2).procfn)
      scan.loops(2).procfn=pf;
    end
    scan.loops(2).procfn(1:length(scan.loops(2).getchan)) = pf;    
else
    lenrate = smabufconfig(ic(:, 1)', scan.loops(1).npoints, 1/abs(scan.loops(1).ramptime), cntrl);
    scan.loops(1).npoints = lenrate(1);
    scan.loops(1).ramptime = -1/lenrate(2);
    if isfield(scan.loops, 'procfn')
        scan.loops = rmfield(scan.loops, 'procfn');
    end
end

% possible trigger modes:
%  - software (generic trigfn)
%  - AWG - pulse or marker level control
%  - instrument specific

if strfind(cntrl, 'YokoTDS')
    scan.loops(1).trigfn.fn = @smatrigYokoTDS;
    yokos = smchaninst(scan.loops(1).setchan);
    scan.loops(1).trigfn.args = {sminstlookup('TDS5104'), yokos(:, 1)};
elseif strfind(cntrl, 'AWG')
    scan.loops(1).trigfn.fn = @smatrigAWG;
    scan.loops(1).trigfn.args = {sminstlookup('AWG5000')};
    %scan.loops(1).trigfn.fn = @smset;
    %scan.loops(1).trigfn.args = {'PulseLine', 1};
else
    scan.loops(1).trigfn.fn = @smatrigfn;
    scan.loops(1).trigfn.args = {smchaninst([smchanlookup(scan.loops(1).setchan);...
        smchanlookup(scan.loops(2).getchan)])};
end
% could determine behavior form flags, or pass trigfns as arguments.

%scan.loops(1).trigfn.fn = @smtrigger; % see software.txt, 10/29/08
%scan.loops(1).trigfn.args = {insts};
