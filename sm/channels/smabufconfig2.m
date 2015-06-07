function scan = smabufconfig2(scan, cntrl, getchanInd, config, loop)
% scan = smabufconfig2(scan, cntrl, getrng, setrng, loop)
% Configure buffered acquisition for fastest loop using drivers. 
% Supersedes smarampconfig/smabufconfig if driver provides this
% functionality.
%
% cntrl: trig : use smatrigfn for triggering
%         arm : use smatrigfn to arm insts in loops(2).prefn(1)
%         fast: change behavior to not use rate and time of first loop.
%               Instead, setrng = [npts, rate, nrec(optional)], loop = loop to be used (default = 1)     
%         end
% getrng: indices to loops(2).getchan to be programmed (and armed/triggered).
% For fast, config is just an array of numbers, otherwise it is indeices of setchans to trigger.   
% Possible extensions (not implemented): 
% - configure decimation (see smarampconfig for code)

global smdata;


if nargin < 2 
    cntrl = '';
end

% Set loops. 
if strfind(cntrl, 'fast')
    if nargin < 5
        loop = 1;
    end
else
    if nargin < 5 
        loop = 2; 
    end
    if loop == 1 
        error('Need to use fast control if you want readout in first loop')
    end

    setic = smchaninst(scan.loops(loop-1).setchan);
    if nargin >= 4
        setic = setic(config, :);
    end

end

% Only select getchans with index getchanInd. 
getic = smchaninst(scan.loops(loop).getchan);
if nargin >= 3 && getchanInd ~= 0 
   getic = getic(getchanInd, :);
end

if strfind(cntrl, 'fast')
    for i = 1:size(getic, 1)
        args = num2cell(config);
        [config(1), config(2)] = smdata.inst(getic(i, 1)).cntrlfn([getic(i, :), 5], args{:});
    end
else
    for i = 1:size(getic, 1)
        [scan.loops(loop-1).npoints, rate] = smdata.inst(getic(i, 1)).cntrlfn([getic(i, :), 5], scan.loops(loop-1).npoints, ...
            1/abs(scan.loops(loop-1).ramptime));
        scan.loops(loop-1).ramptime = sign(scan.loops(loop-1).ramptime)/abs(rate);
    end
    
    if strfind(cntrl, 'trig')
        scan.loops(loop-1).trigfn.fn = @smatrigfn;
        scan.loops(loop-1).trigfn.args = {[setic; getic]};
    end
end

if strfind(cntrl, 'arm')
    if strfind(cntrl,'end') % bad hack, need to fix this
      scan.loops(loop).prefn(end).fn = @smatrigfn;
      scan.loops(loop).prefn(end).args = {getic, 4};  
    else
      scan.loops(loop).prefn(1).fn = @smatrigfn;
      scan.loops(loop).prefn(1).args = {getic, 4};
    end
end
