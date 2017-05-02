function [data,xt] = smrunloop(scan, filename)
% Rewritten version of smrun that enables non rectangular scans. 
global smdata; global smscan;
if ~isstruct(scan) %if no scan is sent to smrun, use smscan and assume first argument is filename
    filename=scan;
    scan=smscan;
end
if exist('filename','var') % check that filename doesn't already exist 
    filename = checkFile(filename);
    saveData = 1;
    scanStruct.filename = filename;
else
    scanStruct.filename = '';
    saveData = 0;
end
scanStruct.saveData = saveData;

% Set up self-ramping trigger for inner loop if none is provided.
% Assumes self ramping w/ no trigger if the ramptime is negative and either there's no trigfn or the trigfn has field autoset set to true.
if ~isempty(scan.loops(1).ramptime) && scan.loops(1).ramptime<0 && (~isfield(scan.loops(1),'trigfn') || isempty(scan.loops(1).trigfn) || (isfield(scan.loops(1).trigfn,'autoset') && scan.loops(1).trigfn.autoset))
    scan.loops(1).trigfn.fn=@smatrigfn;
    scan.loops(1).trigfn.args{1}=smchaninst(scan.loops(1).setchan);
end
if isfield(scan,'consts') && ~isempty(scan.consts) % Set consts to values. 
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
end
scan = scanFun(scan,'config'); % run configfn 
scandef = scan.loops;
%% Assign defaults
% If there is no npoints, trafofn, procfn, ramptime, or saveloop, empty or default values added to avoid errors. 
for i=1:length(scandef) %setchanranges mostly used in gui. Lets you set up multiple ranges for channels in single loop without using trafofns. 
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
if ~isfield(scandef, 'rng'),  [scandef.rng] = deal([]); end
if ~isfield(scan, 'trafofn'),      scan.trafofn = {};           end
if ~isfield(scan, 'saveloop')
    scan.saveloop = [2 1];
elseif length(scan.saveloop) == 1
    scan.saveloop(2) = 1;
end

nloops = length(scandef);
for i = 1:nloops % Set up rng/npoints if not given, replace setchan/getchan with numbers. 
    if isempty(scandef(i).npoints)   % If only have one of npoints, rng, can make up the rest.
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
scanDisp = scan; scanDisp.loops = scandef; 
[disp,figurenumber] = initDisp(scanDisp,dataloop,ndim,datadim,data);
scanStruct.fignum = figurenumber;
%% Run prescan fns., scan, postscan.
npoints = [scandef.npoints];
setVal0 = zeros(1, nloops);
count = ones(size(npoints)); % will cause all loops to be updated.

if isfield(scan,'configch') % gather the values of the scan's configch. 
    configvals = cell2mat(smget(scan.configch));
else
    configvals = cell2mat(smget(smdata.configch));
end
configch = {smdata.channels(smchanlookup(smdata.configch)).name}; % gather the values of smdata configch. 
configdata = cell(1, length(smdata.configfn));
for i = 1:length(smdata.configfn) % run smdata.configfn. 
    if iscell(smdata.configfn)
        configdata{i} = smdata.configfn{i}();
    else
        configdata{i} = smdata.configfn(i).fn(smdata.configfn(i).args);
    end
end
if saveData % save scan components and loginfo before starting. 
    save(filename, 'configvals', 'configdata', 'scan', 'configch');
    str = [configch; num2cell(configvals)];
    logentry(filename);
    logadd(sprintf('%s=%.3g, ', str{:}));
end

isdummy = false(1, nloops);
for i = 1:nloops % find loops that do nothing other than starting a ramp and have skipping enabled (waittime < 0) they also have no getchan, prefn, postfn, no saves or disps.
    isdummy(i) = isfield(scandef(i), 'waittime') && ~isempty(scandef(i).waittime) && scandef(i).waittime < 0 && all(scandef(i).ramptime < 0) && isempty(scandef(i).getchan) ...
        &&  (~isfield(scandef(i), 'prefn') || isempty(scandef(i).prefn)) && (~isfield(scandef(i), 'postfn') || isempty(scandef(i).postfn)) ...
        && ~any(scan.saveloop(1) == i) && ~any([disp.loop] == i);
end
scanStruct.dummy = isdummy; scanStruct.trafofn = scan.trafofn; scanStruct.disp=disp; scanStruct.ndim = ndim; 
scanStruct.saveloop = scan.saveloop; scanStruct.nsetchan = nsetchan; scanStruct.ngetchan = ngetchan;
[data,~]=smloop(scandef,data,nloops,count,setVal0,scanStruct); % This runs the actual scan 
scan = scanFun(scan,'cleanup'); % Run cleanup function before scan ends. 
set(figurenumber,'userdata',[]); % tag this figure as not being used by SM
if saveData
    save(filename, 'configvals', 'configdata', 'scan', 'configch', 'data')
end
end