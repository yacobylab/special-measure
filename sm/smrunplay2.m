function [data,xt] = smrunplay2(scan, filename)
% function data = smrun(scan, filename)
% data = smrun(filename) will assume scan = smscan
% scan: struct with the following fields:
%   disp: struct array with display information with  fields:  
%     channel: (index to saved channels)
%     dim: plot dimension (1 or 2)
%     loop: in what loop to display. defaults to one slower than 
%           acquisition. (somewhat rough)
% saveloop: loop in which to save data (default: second fastest)
% trafofn: list of global transformations.
% configfn: function struct with elements fn and args.
%            confignfn.fn(scan, configfn.args{:}) is called before all
%            other operations.
% cleanupfn; same, called before exiting.
% figure: number of figure to be plotted on. Uses next available figure
%         starting at 1000 if Nan. 
% loops: struct array with one element for each dimension, fields given
%        below. The first entry is for the fastest, innermost loop
%   fields of loops:
%   rng, 
%   npoints (empty means take rng as a vector, otherwise rng defines limits)
%   ramptime: min ramp time from point to point for each setchannel, 
%           currently converted to ramp rate assuming the same ramp rate 
%           at each point. If negative, the channel is only initialized at
%           the first point of the loop, and ramptime replaced by the 
%           slowest negative ramp time.
%           At the moment, this determines both the sample and the ramp
%           rate, i.e. the readout occurs as soon as a ramp finishes.
%           Ramptime can be a vector with an entry for each setchannel or
%           a single number for all channels. 
%   setchan
%   trafofn (cell array of function handles. Default: independent variable of this loop)
%   getchan
%   prefn (struct array with fields fn, args. Default empty)
%   postfn (default empty, currently a cell array of function handles)
%   datafn
%   procfn: struct array with fields fn and dim, one element for each
%           getchannel. dim replaces datadim, fn is a struct array with
%           fields fn and args. 
%           Optional fields: inchan, outchan, indata, outdata.
%           inchan, outchan refer to temporary storage space
%           indata, outdata refer to data space.
%           indata defaults to outdata if latter is given.
%           inchan, outdata default to index of procfn, i.e. the nth function uses the nth channel of its loop.
%           These fields can be used to implemnt complex processing by mixing and 
%           routing data between channels. Basically, any procfn can access any data read and any
%           previously recorded data. Further documentation will be provided when needed...
%   trigfn: executed only after programming ramps for autochannels.

global smdata;
global smscan;

if ~isstruct(scan) %if no scan is sent to smrun, assume only field is filename
    filename=scan;
    scan=smscan;
end
if exist('filename','var') 
    filename = checkFile(filename); 
    saveData = 1; 
else 
    saveData = 0; 
end
 % Set up self-ramping trigger for inner loop if none is provided.  
 % Assumes self ramping w/ no trigger if the ramptime is negative and either there's no trigfn or the trigfn has field autoset set to true. 
if ~isempty(scan.loops(1).ramptime) && scan.loops(1).ramptime<0 && (~isfield(scan.loops(1),'trigfn') || ...
   isempty(scan.loops(1).trigfn) || (isfield(scan.loops(1).trigfn,'autoset') && scan.loops(1).trigfn.autoset))
    scan.loops(1).trigfn.fn=@smatrigfn;
    scan.loops(1).trigfn.args{1}=smchaninst(scan.loops(1).setchan);
end
if isfield(scan,'consts') && ~isempty(scan.consts)
    if ~isfield(scan.consts,'set')
        for i=1:length(scan.consts)
            scan.consts(i).set =1;
        end
    end
    setchans = {};
    setvals = [];
    for i=1:length(scan.consts)
        if scan.consts(i).set
            setchans{end+1}=scan.consts(i).setchan;
            setvals(end+1)=scan.consts(i).val;
        end
    end
    smset(setchans, setvals);
end% set global constants for the scan, held in field scan.consts 
scan = scanfn(scan,'configfn');
scandef = scan.loops;

% If the scan sent to smrun has fields scan.loops(i).setchanranges, the trafofn and rng fields have to be adjusted to convention
% If there is more than one channel being ramped, the range for the loop will be setchanranges{1}, and the channel values will be determined by linear
% mapping of this range onto the desired range for each channel.
for i=1:length(scandef)
    if isfield(scandef(i),'setchanranges')
        scandef(i).rng=scandef(i).setchanranges{1};
        for j=1:length(scandef(i).setchanranges)
            setchanranges = scandef(i).setchanranges{j};
            A = (setchanranges(2)-setchanranges(1))/(scandef(i).rng(end)-scandef(i).rng(1));
            B = (setchanranges(1)*scandef(i).rng(end)-setchanranges(2)*scandef(i).rng(1))/(scandef(i).rng(end)-scandef(i).rng(1));
            scandef(i).trafofn{j}=@(x, y) A*x(i)+B;
        end
    end
end
scandef = initTrafofn(scandef); 
if ~isfield(scandef, 'npoints'),   [scandef.npoints] = deal([]); end
if ~isfield(scandef, 'trafofn'),   [scandef.trafofn] = deal({}); end
if ~isfield(scandef, 'procfn'),    [scandef.procfn] = deal([]);  end
if ~isfield(scandef, 'ramptime'),  [scandef.ramptime] = deal([]); end
if ~isfield(scan, 'trafofn'),      scan.trafofn = {};           end
if ~isfield(scan, 'saveloop')
    scan.saveloop = [2 1];
elseif length(scan.saveloop) == 1
    scan.saveloop(2) = 1;
end

nloops = length(scandef);
for i = 1:nloops    
    if isempty(scandef(i).npoints)        % If only have one of npoints, rng, can make up the rest. 
        scandef(i).npoints = length(scandef(i).rng);
    elseif isempty(scandef(i).rng)        
        scandef(i).rng = 1:scandef(i).npoints;
    else
        scandef(i).rng = linspace(scandef(i).rng(1), scandef(i).rng(end), scandef(i).npoints);
    end
    scandef(i).setchan = smchanlookup(scandef(i).setchan);
    scandef(i).getchan = smchanlookup(scandef(i).getchan);
    nsetchan(i) = length(scandef(i).setchan);                
    if isempty(scandef(i).ramptime)
        scandef(i).ramptime = nan(nsetchan(i), 1);
    elseif length(scandef(i).ramptime) == 1 
        scandef(i).ramptime = repmat(scandef(i).ramptime, size(scandef(i).setchan));
    end
end

[scandef,data,datadim,ndim,dataloop,ngetchan] = initProc(scandef);
simploop=scan.loops; 
scan.loops = scandef; 
[disp,figurenumber] = initDisp(scan,dataloop,ndim,datadim,data);
scan.loops = simploop; 
npoints = [scandef.npoints];
totpoints = prod(npoints);
ramprate = cell(1, nloops);
t1stPt = zeros(1, nloops);
setVal0 = zeros(1, nloops);
count = ones(size(npoints)); % will cause all loops to be updated.

if isfield(scan,'configch')
    configvals = cell2mat(smget(scan.configch));
else
    configvals = cell2mat(smget(smdata.configch));
end
configch = {smdata.channels(smchanlookup(smdata.configch)).name};
configdata = cell(1, length(smdata.configfn));
for i = 1:length(smdata.configfn)
    if iscell(smdata.configfn)
        configdata{i} = smdata.configfn{i}();
    else
        configdata{i} = smdata.configfn(i).fn(smdata.configfn(i).args);   
    end
end

if saveData
    save(filename, 'configvals', 'configdata', 'scan', 'configch');
    str = [configch; num2cell(configvals)];
    logentry(filename);
    logadd(sprintf('%s=%.3g, ', str{:}));
end

% find loops that do nothing other than starting a ramp and have skipping enabled (waittime < 0) they also hve no getchan, prefn, postfn, no saves or disps. 
isdummy = false(1, nloops);
for i = 1:nloops
    isdummy(i) = isfield(scandef(i), 'waittime') && ~isempty(scandef(i).waittime) && scandef(i).waittime < 0 ...
        && all(scandef(i).ramptime < 0) && isempty(scandef(i).getchan) ...
        &&  (~isfield(scandef(i), 'prefn') || isempty(scandef(i).prefn)) ...
        && (~isfield(scandef(i), 'postfn') || isempty(scandef(i).postfn)) ...
        && ~any(scan.saveloop(1) == i) && ~any([disp.loop] == i);
end

for i = 1:totpoints % Whenever inner loop reset to 1, update next outer loop. Start with outer loops and work inward.     
    if i > 1 % setLoops is the list of loops to update on this ind. 
        outerUpdatingLoop = find(count > 1,1); % indices of loops to be updated. 1 = fastest loop
        setLoops = 1:outerUpdatingLoop;       
    else
        setLoops = 1:nloops; % At start, set all loops
    end    
    for j = setLoops %x is the set of values to set in this ind.
        setVal0(j) = scandef(j).rng(count(j));
    end    
    setValL = setVal0;  
    for k = 1:length(scan.trafofn)
        setValL = trafocall(scan.trafofn(k), setValL);
    end
    
    activeLoops = setLoops(~isdummy(setLoops) | count(setLoops)==1);              % exclude dummy loops with nonzero count
    for j = fliplr(activeLoops)    % Go from outerloops in. 
        firstPtLoop = count(j)==1;
        setVal = trafocall(scandef(j).trafofn, setValL, smdata.chanvals);        
        autochan = scandef(j).ramptime < 0; %channels that ramp themself selves 
        scandef(j).ramptime(autochan) = min(scandef(j).ramptime(autochan));                
        if firstPtLoop % set autochannels and program ramp only at first loop point
            if nsetchan(j) 
                smset(scandef(j).setchan, setVal(1:nsetchan(j)));
                setValEndL = setVal0;
                setValEndL(j) = scandef(j).rng(end);
                for k = 1:length(scan.trafofn)
                    setValEndL = trafocall(scan.trafofn(k), setValEnd);
                end
                setValEnd = trafocall(scandef(j).trafofn, setValEndL, smdata.chanvals);                
                ramprate{j} = abs((setValEnd(1:nsetchan(j))-setVal(1:nsetchan(j))))'./(scandef(j).ramptime * (scandef(j).npoints-1)); % compute ramp rate for all steps.
                if any(autochan) % program ramp
                    smset(scandef(j).setchan(autochan), setValEnd(autochan), ramprate{j}(autochan));
                end
            end
            t1stPt(j) = now;
        elseif ~all(autochan)
            smset(scandef(j).setchan(~autochan), setVal(~autochan), ramprate{j}(~autochan));            
        end               
        scanfn(scandef(j),'prefn',setVal);                
        tDiff=count(j) * max(abs(scandef(j).ramptime)) - (now -t1stPt(j))*24*3600;    %wait for correct ramptime: time needed to wait - time passed since first point    
        if tDiff>0, pause(tDiff); end % Pause always waits 10ms                
        if isfield(scandef,'waittime') && ~isempty(scandef(j).waittime) && scandef(j).waittime ~= 0
            pause(scandef(j).waittime)
        end  % if the field 'waittime' was in scan.loops(j), then wait that amount of time now
        if firstPtLoop && isfield(scandef, 'trigfn') && ~isempty(scandef(j).trigfn) % trigger after waiting for first point.
            fncall(scandef(j).trigfn);
        end
    end
    
    %Read loops from inner to outer.
    %Only read the outerloops if inner loops are at their max. i.e. read at the end of the loop. 
    readLoops = 1:find(count < npoints, 1);
    if isempty(readLoops)
        readLoops = 1:nloops;
    end
    for j = readLoops(~isdummy(readLoops))
        newdata = smget(scandef(j).getchan);
        dataindPrev = sum(ngetchan(1:j-1)); %fix me
        data = allocData(scandef(j).procfn,data,newdata,count(end:-1:j),dataindPrev,ndim);                
        plotData(disp,data,j,count,nloops); 
        scanfn(scandef(j),'postfn',setVal);        
        if j == scan.saveloop(1) && ~mod(count(j), scan.saveloop(2)) && saveData
            save(filename, '-append', 'data');
        end               
        if isfield(scandef, 'datafn')
            fncall(scandef(j).datafn, setVal, data);
        end
    end    
    count(readLoops(1:end-1)) = 1;
    count(readLoops(end)) =  count(readLoops(end)) + 1;

    if isfield(scandef,'testfn') && ~isempty(scandef(j).testfn)
            if ~isfield(scandef(j).testfn,'mod') || isempty(scandef(j).testfn.mod) || ~mod(count(j),scandef(j).testfn.mod)
                testgood = testcall(scandef(j).testfn,xt, data);
            else 
                testgood =1; 
            end
    else
        testgood =1; 
    end
    figChar = get(figurenumber,'CurrentCharacter'); 
    if (~isempty(figChar) && figChar == char(27)) || testgood == 0
        scan = scanfn(scan,'cleanupfn');      
        if saveData
            save(filename, 'configvals', 'configdata', 'scan', 'configch', 'data')
        end        
        set(figurenumber,'userdata',[]); % tag this figure as not being used by SM
        return;
    end        
    if figChar == ' '
        set(figurenumber, 'CurrentCharacter', char(0));
        fprintf('Measurement paused. Type ''return'' to continue.\n')
        evalin('base', 'keyboard');                
    end
end

scan = scanfn(scan,'cleanupfn');       %#ok<*NASGU>
set(figurenumber,'userdata',[]); % tag this figure as not being used by SM
if saveData
    save(filename, 'configvals', 'configdata', 'scan', 'configch', 'data')
end
end

function fncall(fns, varargin)   
if iscell(fns)
    for i = 1:length(fns)
        if ischar(fns{i})
          fns{i} = str2func(fns{i});
        end
        fns{i}(varargin{:});
    end
else
    for i = 1:length(fns)
        if ischar(fns(i).fn)
          fns(i).fn = str2func(fns(i).fn);
        end
        if ~isfield(fns,'args') || ~iscell(fns(i).args)
            if ~isfield(fns,'args') || isempty(fns(i).args)
                fns(i).args={};
            else
                error('Arguments to functions must be a cell array');
            end
        end
        fns(i).fn(varargin{:}, fns(i).args{:});        
    end
end
end

function v = trafocall(fn, x,chanvals)   
v = zeros(1, length(fn));
if iscell(fn)
    for i = 1:length(fn)
        if ischar(fn{i})
          fn{i} = str2func(fn{i});
        end
        v(i) = fn{i}(x,chanvals);
    end
else
    for i = 1:length(fn)
        if ischar(fn(i).fn)
          fn(i).fn = str2func(fn(i).fn);
        end
        if ~isfield(fn,'args') || ~iscell(fn(i).args)
            if ~isfield(fn,'args') || isempty(fn(i).args)
                fn(i).args={};
            else
                error('Arguments to functions must be a cell array');
            end
        end        
        
        v(i) = fn(i).fn(x,chanvals, fn(i).args{:});
    end
end
end

function good = testcall(fn,xt,data)
v = zeros(1, length(fn));
if iscell(fn)
    for i = 1:length(fn)
        if ischar(fn{i})
          fn{i} = str2func(fn{i});
        end
        v(i) = fn{i}(xt,data);
    end
else
    for i = 1:length(fn)
        if ischar(fn(i).fn)
          fn(i).fn = str2func(fn(i).fn);
        end
        v(i) = fn(i).fn(xt,data, fn(i).args{:});
    end
end
if all(v) == 1
    good =1; 
else, good = 0; 
end
end

function scan = scanfn(scan,funcName,arg) 
switch funcName
    case 'config'
        if isfield(scan, 'configfn')
            for i = 1:length(scan.configfn)
                if ~isfield(scan.configfn,'args') || isempty(scan.configfn(i).args)
                    scan.configfn(i).args = {}; 
                end
                scan = scan.configfn(i).fn(scan, scan.configfn(i).args{:});
            end
        end
    case 'cleanup'
        if isfield(scan, 'cleanupfn')
            for i = 1:length(scan.cleanupfn)
                if ~isfield(scan.cleanupfn,'args') || isempty(scan.cleanupfn(i).args)
                    scan.cleanupfn(i).args = {}; 
                end
                scan = scan.cleanupfn(i).fn(scan, scan.cleanupfn(i).args{:});
            end
        end
    case 'prefn'
        if isfield(scan,'prefn') 
            fncall(scan.prefn,arg)
        end
    case 'postfn' 
        if isfield(scan,'postfn') 
            fncall(scan.prefn,arg)
        end
end
end