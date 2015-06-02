function data = smrun(scan, filename)
% data = smrun(scan, filename)
% data = smrun(filename) will assume scan = smscan
%
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
%        below. The last entry is for the fastest, innermost loop
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

%if no scan is sent to smrun, assume only field is filename
if ~isstruct(scan) 
    filename=scan;
    scan=smscan;
end

% set global constants for the scan, held in field scan.consts
if isfield(scan,'consts') && ~isempty(scan.consts)
    smset({scan.consts.setchan}, [scan.consts.val]);
end

if isfield(scan, 'configfn')
    for i = 1:length(scan.configfn)
        scan = scan.configfn(i).fn(scan, scan.configfn(i).args{:});
    end
end

scandef = scan.loops;

if ~isfield(scan, 'disp') || isempty(scan.disp)
    disp = struct('loop', {}, 'channel', {}, 'dim', {});
else
    disp = scan.disp;
end

nloops = length(scandef);
nsetchan = zeros(1, nloops);
ngetchan = zeros(1, nloops);

% If the scan sent to smrun has fields scan.loops(i).setchanranges, the
% trafofn and rng fields have to be adjusted to convention
% If there is more than one channel being ramped, the range for the loop
% will be setchanranges{1}, and the channel values will be determined by linear
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



if ~isfield(scandef, 'npoints')
    [scandef.npoints] = deal([]);
end

if ~isfield(scandef, 'trafofn')
    [scandef.trafofn] = deal({});
end

if ~isfield(scandef, 'procfn')
    [scandef.procfn] = deal([]);
end

if ~isfield(scandef, 'ramptime')
     [scandef.ramptime] = deal([]);
end

if ~isfield(scan, 'saveloop')
    scan.saveloop = [2 1];
elseif length(scan.saveloop) == 1
    scan.saveloop(2) = 1;
end

if ~isfield(scan, 'trafofn')
    scan.trafofn = {};
end

%if nargin < 2
%    filename = 'data';
%end

if nargin >= 2 && filename(2)~=':'
    if isempty(filename);
        filename = 'data';
    end
    
    if all(filename ~= '/')
        filename = sprintf('sm_%s.mat', filename);
    end
    
    str = '';
    while (exist(filename, 'file') || exist([filename, '.mat'], 'file')) && ~strcmp(str, 'yes')
        fprintf('File %s exists. Overwrite? (yes/no)', filename);
        while 1
            str = input('', 's');
            switch str
                case 'yes'
                    break;
                case 'no'
                    filename = sprintf('sm_%s.mat', input('Enter new name:', 's'));
                    break
            end
        end
    end
end


for i = 1:nloops
    if isempty(scandef(i).npoints)        
        scandef(i).npoints = length(scandef(i).rng);
    elseif isempty(scandef(i).rng)        
        scandef(i).rng = 1:scandef(i).npoints;
    else
        scandef(i).rng = linspace(scandef(i).rng(1), scandef(i).rng(end), ...
            scandef(i).npoints);
    end

    % default for ramp?
    
    scandef(i).setchan = smchanlookup(scandef(i).setchan);
    scandef(i).getchan = smchanlookup(scandef(i).getchan);
    nsetchan(i) = length(scandef(i).setchan);

    %procfn defaults
    if ~isempty(scandef(i).getchan) && isempty(scandef(i).procfn) % no processing at all, each channel saved
        [scandef(i).procfn(1:length(scandef(i).getchan)).fn] = deal([]);
    end
    
    % number of channels saved.
    ngetchan(i) = 0;%length(scandef(i).procfn); 
    
    for j = 1:length(scandef(i).procfn)
        % set ngetchan to largest outdata index or procfn index where outdata not given
        if isfield(scandef(i).procfn(j).fn, 'outdata')
            ngetchan(i) = max([ngetchan(i), scandef(i).procfn(j).fn.outdata]);
            
            % index lookup from data index to function index
            nod = length([scandef(i).procfn(j).fn.outdata]);
            ind = sum(ngetchan(1:i-1)); % data channel index

            odind(:, [scandef(i).procfn(j).fn.outdata]+ind) = [j * ones(1, nod); 1:nod];
        else
            odind(:, sum(ngetchan(1:i-1))+j) = [j ; 1];
            ngetchan(i) = max(ngetchan(i), j);
        end
        
        if isfield(scandef(i).procfn(j).fn, 'outdata') && ~isfield(scandef(i).procfn(j).fn, 'indata')
            [scandef(i).procfn(j).fn.indata] = deal(scandef(i).procfn(j).fn.outdata);
        end
            
        if ~isfield(scandef(i).procfn(j).fn, 'inchan')
            for k = 1:length(scandef(i).procfn(j).fn)
                scandef(i).procfn(j).fn(k).inchan = j;
            end
        end
       
        if ~isempty(scandef(i).procfn(j).fn) && ~isfield(scandef(i).procfn(j).fn, 'outchan')
            [scandef(i).procfn(j).fn.outchan] = deal(scandef(i).procfn(j).fn.inchan);
        end
    end
        
    if isempty(scandef(i).ramptime)
        scandef(i).ramptime = nan(nsetchan(i), 1);
    elseif length(scandef(i).ramptime) == 1 
        scandef(i).ramptime = repmat(scandef(i).ramptime, size(scandef(i).setchan));
    end

    %k = nloops-i+1; %use user convention: slowest loops first    
    if isempty(scandef(i).trafofn)
        scandef(i).trafofn = {};
       [scandef(i).trafofn{1:nsetchan(i)}] = deal(@(x, y) x(i));
    else
        for j = 1:nsetchan(i)
            if iscell(scandef(i).trafofn)
                if isempty(scandef(i).trafofn{j})
                    scandef(i).trafofn{j} = @(x, y) x(i);
                end
            elseif isempty(scandef(i).trafofn(j).fn)
                scandef(i).trafofn(j).fn = @(x, y) x(i);
                scandef(i).trafofn(j).args = {};
            end                
        end
    end
end

npoints = [scandef.npoints];
totpoints = prod(npoints);

datadim = zeros(sum(ngetchan), 5); % size of data read each time
%newdata = cell(1, max(ngetchan));
data = cell(1, sum(ngetchan));
ndim = zeros(1, sum(ngetchan)); % dimension of data read each time
dataloop = zeros(1, sum(ngetchan)); % loop in which each channel is read
disph = zeros(1, sum(ngetchan));
ramprate = cell(1, nloops);
tloop = zeros(1, nloops);
getch = vertcat(scandef.getchan);
% get data dimension and allocate data memory
for i = 1:nloops
    instchan = vertcat(smdata.channels(scandef(i).getchan).instchan);            
    for j = 1:ngetchan(i)
        ind = sum(ngetchan(1:i-1))+ j; % data channel index
        if  isfield(scandef(i).procfn(odind(1, ind)), 'dim') && ~isempty(scandef(i).procfn(odind(1, ind)).dim)
            %get dimension of proscessed data if procfn used
            dd = scandef(i).procfn(odind(1, ind)).dim(odind(2, ind), :);                                     
        else
            dd = smdata.inst(instchan(j, 1)).datadim(instchan(j, 2), :);
        end
        
        %ndim(ind) = sum(dd > 1); % used unitl 08/03/09. See software.txt        
        if all(dd <= 1)
            ndim(ind) = 0;
        else
            ndim(ind) = find(dd > 1, 1, 'last');
        end
        % # of non-singleton dimensions
        datadim(ind, 1:ndim(ind)) = dd(1:ndim(ind));
        if isfield(scandef(i).procfn(odind(1, ind)).fn, 'outdata')
            dim = datadim(ind, 1:ndim(ind));
            % no not expand dimension if outdata given.
        else
            dim = [npoints(end:-1:i), datadim(ind, 1:ndim(ind))];
        end
        if length(dim) == 1
            dim(2) = 1;
        end
        data{ind} = nan(dim);
        dataloop(ind) = i;
    end
end
   
switch length(disp)
    case 1
        sbpl = [1 1];         
    case 2
        sbpl = [1 2];
   
    case {3, 4}
        sbpl = [2 2];
        
    case {5, 6}
        sbpl = [2 3];
        
    otherwise
        sbpl = [3 3];
        disp(10:end) = [];
end


% determine the next available figure after 1000 for this measurement.  A
% figure is available unless its userdata field is the string 'SMactive'
if isfield(scan,'figure')
    figurenumber=scan.figure;
    if isnan(figurenumber)
        figurenumber = 1000;
        while ishandle(figurenumber) && strcmp(get(figurenumber,'userdata'),'SMactive')
            figurenumber=figurenumber+1;
        end
    end
else
    figurenumber=1000;
end
if ~ishandle(figurenumber);
    figure(figurenumber)
    set(figurenumber, 'pos', [10, 10, 800, 400]);
else
    figure(figurenumber);
    clf;
end


set(figurenumber,'userdata','SMactive'); % tag this figure as being used by SM
set(figurenumber, 'CurrentCharacter', char(0));

% default for disp loop
if ~isfield(disp, 'loop')
    for i = 1:length(disp)
        disp(i).loop = dataloop(disp(i).channel)-1;
    end
end

s.type = '()';
s2.type = '()';
for i = 1:length(disp)    
    subplot(sbpl(1), sbpl(2), i);
    dc = disp(i).channel; %index of channel to be displayed
    % modify if reducing data before plotting

    s.subs = num2cell(ones(1, nloops - dataloop(dc) + 1 + ndim(dc)));
    [s.subs{end-disp(i).dim+1:end}] = deal(':');
    %s.subs = [num2cell(ones(1, dataloop(scan.dispchan(i)) + ndim(scan.dispchan(i))-2)), ':', ':'];
    if dataloop(dc) - ndim(dc) < 1 
        x = 1:datadim(dc, ndim(dc));
        xlab = 'n';
    else
        x = scandef(dataloop(dc) - ndim(dc)).rng;        
        if ~isempty(scandef(dataloop(dc) - ndim(dc)).setchan)
            xlab = smdata.channels(scandef(dataloop(dc) - ndim(dc)).setchan(1)).name;
        else
            xlab = '';
        end
    end

    if disp(i).dim == 2        
        if dataloop(dc) - ndim(dc) < 0
            y = [1, datadim(dc, ndim(dc)-1)];
            ylab = 'n';
        else
            y = scandef(dataloop(dc) - ndim(dc) + 1).rng;
            if ~isempty(scandef(dataloop(dc) - ndim(dc) + 1).setchan)
                ylab = smdata.channels(scandef(dataloop(dc) - ndim(dc) + 1).setchan(1)).name;
            else
                ylab = '';
            end
        end
        z = zeros(length(y), length(x));
        z(:, :) = subsref(data{dc}, s);
        disph(i) = imagesc(x, y, z);
        %disph(i) = imagesc(x, y, permute(subsref(data{dc}, s), [ndim(dc)+(-1:0), 1:ndim(dc)-2]));
        
        set(gca, 'ydir', 'normal');
        colorbar;
        if dc <= length(getch)
            title(smdata.channels(getch(dc)).name);
        end
        xlabel(xlab);
        ylabel(ylab);
    else
        y = zeros(size(x));
        y(:) = subsref(data{dc}, s);
        disph(i) = plot(x, y);
        %permute(subsref(data{dc}, s), [ndim(dc), 1:ndim(dc)-1])
        xlim(sort(x([1, end])));
        xlabel(xlab);
        if dc <= length(getch)
            ylabel(smdata.channels(getch(dc)).name);
        end
    end
end  

x = zeros(1, nloops);
%filename = sprintf('sm_%02d%02d%02d_%02d%02d')


configvals = cell2mat(smget(smdata.configch));
configch = {smdata.channels(smchanlookup(smdata.configch)).name};

configdata = cell(1, length(smdata.configfn));
for i = 1:length(smdata.configfn)
    if iscell(smdata.configfn)
        configdata{i} = smdata.configfn{i}();
    else
        configdata{i} = smdata.configfn(i).fn(smdata.configfn(i).args);   
    end
end

if nargin >= 2
    save(filename, 'configvals', 'configdata', 'scan', 'configch');
    str = [configch; num2cell(configvals)];
    logentry(filename);
    logadd(sprintf('%s=%.3g, ', str{:}));
end

tic;

count = ones(size(npoints)); % will cause all loops to be updated.

loops = 1:nloops; % indices of loops to be updated. 1 = fastest loop
for i = 1:totpoints    
    % update a loop if all faster loops are at first val
    if i > 1;
        loops = 1:find(count > 1, 1);
    end       
    
    for j = loops
        x(j) = scandef(j).rng(count(j));
    end

    xt = x;  
    for k = 1:length(scan.trafofn)
        xt = trafocall(scan.trafofn(k), xt);
    end

    for j = fliplr(loops)
        
        val = trafocall(scandef(j).trafofn, xt, smdata.chanvals);
        
        autochan = scandef(j).ramptime < 0;
        scandef(j).ramptime(autochan) = min(scandef(j).ramptime(autochan));
        % this is a bit of a hack
        
        % alternative place to call prefn
        
        % set autochannels and program ramp only at first loop point
        if count(j) == 1 %
            if nsetchan(j) % stuff below pointless if no channels exist.
                smset(scandef(j).setchan, val(1:nsetchan(j)));
                % since only the entry for this loop is changed, this
                % procedure only makes sense if the loop is not mixed
                % with any faster loop by the global transformations.
                % Should not be a major limitation.
                x2 = x;
                x2(j) = scandef(j).rng(end);
                %x2 = fliplr(x2);
                for k = 1:length(scan.trafofn)
                    x2 = trafocall(scan.trafofn(k), x2);
                end

                val2 = trafocall(scandef(j).trafofn, x2, smdata.chanvals);

                % compute ramp rate for all steps.
                ramprate{j} = abs((val2(1:nsetchan(j))-val(1:nsetchan(j))))'...
                    ./(scandef(j).ramptime * (scandef(j).npoints-1));

                % program ramp
                if any(autochan)
                    smset(scandef(j).setchan(autochan), val2(autochan), ramprate{j}(autochan));
                end
            end
            tloop(j) = now;
        elseif ~all(autochan)
            smset(scandef(j).setchan(~autochan), val(~autochan), ...
                ramprate{j}(~autochan));            
        end
        
        % prolog functions
        if isfield(scandef, 'prefn')
            fncall(scandef(j).prefn, xt);
        end              

        pause((tloop(j) - now)*24*3600 + count(j) * max(abs(scandef(j).ramptime)));
        
        % if the field 'waittime' was in scan.loops(j), then wait that
        % amount of time now
        if isfield(scandef,'waittime')
            pause(scandef(j).waittime)
        end
        
        % trigger after waiting for first point.
        if count(j) == 1 && isfield(scandef, 'trigfn')
            fncall(scandef(j).trigfn);
        end

        if get(figurenumber, 'CurrentCharacter') == char(27)            
            if isfield(scan, 'cleanupfn')
                for k = 1:length(scan.cleanupfn)
                    scan = scan.cleanupfn(k).fn(scan, scan.cleanupfn(k).args{:});
                end
            end

            if nargin >= 2
                save(filename, 'configvals', 'configdata', 'scan', 'configch', 'data')
            end
            set(figurenumber, 'CurrentCharacter', char(0));
            set(figurenumber,'userdata',[]); % tag this figure as not being used by SM
            return;
        end

    end
    % read loops if all subsequent loops are at max count, outer loops last
    loops = 1:find(count < npoints, 1);
    if isempty(loops)
        loops = 1:nloops;
    end
    for j = loops
        % could save a function call/data copy here - not a lot of code               
        newdata = smget(scandef(j).getchan);
        
        ind = sum(ngetchan(1:j-1));
        for k = 1:length(scandef(j).procfn) 
            
            if isfield(scandef(j).procfn(k).fn, 'outdata')
                for fn = scandef(j).procfn(k).fn
                    if isempty(fn.outchan)
                        data{ind + fn.outdata} = fn.fn(newdata{fn.inchan}, data{ind + fn.indata}, fn.args{:});
                    else
                        [newdata{fn.outchan}, data{ind + fn.outdata}] = fn.fn(newdata{fn.inchan}, data{ind + fn.indata}, fn.args{:});
                    end
                end
            else
                for fn = scandef(j).procfn(k).fn
                    [newdata{fn.outchan}] = fn.fn(newdata{fn.inchan}, fn.args{:});
                end
                s.subs = [num2cell(count(end:-1:j)), repmat({':'}, 1, ndim(ind + k))];
                if isempty(fn)
                    data{ind + k} = subsasgn(data{ind + k}, s, newdata{k}); 
                else
                    data{ind + k} = subsasgn(data{ind + k}, s, newdata{fn.outchan(1)});
                end
                % added if and else case 08/04/09. See software.txt
            end
               
        end    
        
        % display data. 
        for k = find([disp.loop] == j)
            dc = disp(k).channel;

            % last dim: :
            % previous: count or ones. Total number of indices
            % 
            nind = ndim(dc)+ nloops+1-dataloop(dc)-disp(k).dim;
            s2.subs = [num2cell([count(end:-1:max(j, end-nind+1)), ones(1, max(0, nind+j-1-nloops))]),...
                repmat({':'},1, disp(k).dim)];    
            
            if disp(k).dim == 2
                dim = size(data{dc});
                z = zeros(dim(end-1:end));
                z(:, :) = subsref(data{dc}, s2);
                set(disph(k), 'cdata', z);
            else                
                set(disph(k), 'ydata', subsref(data{dc}, s2));
            end
            drawnow;

        end

        if j == scan.saveloop(1) && ~mod(count(j), scan.saveloop(2)) && nargin >= 2
            save(filename, '-append', 'data');
        end
               
        if isfield(scandef, 'postfn')
            fncall(scandef(j).postfn, xt);
        end

        if isfield(scandef, 'datafn')
            fncall(scandef(j).datafn, xt, data);
        end

        if get(figurenumber, 'CurrentCharacter') == char(27)
            if isfield(scan, 'cleanupfn')
                for k = 1:length(scan.cleanupfn)
                    scan = scan.cleanupfn(k).fn(scan, scan.cleanupfn(k).args{:});
                end
            end

            if nargin >= 2
                save(filename, 'configvals', 'configdata', 'scan', 'configch', 'data')
            end
            set(figurenumber, 'CurrentCharacter', char(0));
            set(figurenumber,'userdata',[]); % tag this figure as not being used by SM
            return;
        end
    
        %fprintf('Start %.3f  Set %.3f  Read: %.3f  Proc: %.3f\n', [t(1), diff(t)]);
    end
    %update counters
    count(loops(1:end-1)) = 1;
    count(loops(end)) =  count(loops(end)) + 1;

end

if isfield(scan, 'cleanupfn')
    for k = 1:length(scan.cleanupfn)
        scan = scan.cleanupfn(k).fn(scan, scan.cleanupfn(k).args{:});
    end
end
set(figurenumber,'userdata',[]); % tag this figure as not being used by SM

if nargin >= 2
    save(filename, 'configvals', 'configdata', 'scan', 'configch', 'data')
end
end

function fncall(fns, varargin)   
if iscell(fns)
    for i = 1:length(fns)
        fns{i}(varargin{:});
    end
else
    for i = 1:length(fns)
        fns(i).fn(varargin{:}, fns(i).args{:});
    end
end
end

function v = trafocall(fn, varargin)   
v = zeros(1, length(fn));
if iscell(fn)
    for i = 1:length(fn)
        v(i) = fn{i}(varargin{:});
    end
else
    for i = 1:length(fn)
        v(i) = fn(i).fn(varargin{:}, fn(i).args{:});
    end
end
end
