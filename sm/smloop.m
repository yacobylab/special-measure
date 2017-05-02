function [data,flag]=smloop(scandef,data,n,count,setVal0,scanStruct)
% we may need to keep count to get indice
disp = scanStruct.disp; ndim = scanStruct.ndim;
dummy = scanStruct.dummy(n); filename = scanStruct.filename; 
nsetchan = scanStruct.nsetchan; ngetchan = scanStruct.ngetchan;
trafofn=scanStruct.trafofn; saveloop = scanStruct.saveloop;
figurenumber = scanStruct.fignum; saveData = scanStruct.saveData; 
loop = scandef(n); 
global smdata

autochan = loop.ramptime < 0; %channels that ramp themself selves
loop.ramptime(autochan) = min(loop.ramptime(autochan));
for i = 1:loop.npoints
    count(n) = i;
    setVal0(n) = loop.rng(i);
    setValL = setVal0;
    for k = 1:length(trafofn)
        setValL = trafocall(trafofn(k), setValL);
    end
    setVal = trafocall(loop.trafofn, setValL, smdata.chanvals);    
    if i == 1
        smset(loop.setchan, setVal(1:nsetchan(n))); % figure out numbering.
        if isfield(loop,'settle') && ~isempty(loop.settle) && loop.settle ~= 0
            pause(loop.settle)
        end
        setValEndL = setVal0;
        setValEndL(n) = loop.rng(end);
        for k = 1:length(trafofn)
            setValEndL = trafocall(trafofn(k), setValEnd);
        end
        setValEnd = trafocall(loop.trafofn, setValEndL, smdata.chanvals);
        ramprate = abs((setValEnd(1:nsetchan(n))-setVal(1:nsetchan(n))))'./(loop.ramptime * (loop.npoints-1)); % compute ramp rate for all steps.
        t1stPt = now;
        if any(autochan) % program ramp
            smset(loop.setchan(autochan), setValEnd(autochan), ramprate(autochan));
        end
    end
    scanFun(loop,'prefn', setVal);
    
    if isfield(loop,'waittime') && ~isempty(loop.waittime) && loop.waittime ~= 0
        pause(loop.waittime)
    end
    if i==1 && isfield(loop, 'trigfn') && ~isempty(loop.trigfn) % trigger after waiting for first point.
        fncall(loop.trigfn);
    end
    if dummy
        if ~isfield(loop,'stream') || isempty(loop.stream) || ~loop.stream
            tDiff=loop.npoints * max(abs(loop.ramptime)) - (now -t1stPt)*24*3600;    %wait for correct ramptime: time needed to wait - time passed since first point
            if tDiff>0, pause(tDiff); end % Pause always waits 10ms            
        end
        return
    end    
    tDiff=i * max(abs(loop.ramptime)) - (now -t1stPt)*24*3600;    %wait for correct ramptime: time needed to wait - time passed since first point
    if tDiff>0, pause(tDiff); end % Pause always waits 10ms
    smset(loop.setchan(~autochan), setVal(~autochan), ramprate(~autochan));
    if n > 1
        [data,flag]=smloop(scandef,data,n-1,count,setVal0,scanStruct);
    end
    newdata = smget(loop.getchan);
    dataindPrev = sum(ngetchan(1:n-1)); %fix me
    data = allocData(loop.procfn,data,newdata,count(end:-1:n),dataindPrev,ndim);                % yeah, so will need to figure out how to allocate data here.  %figure out how to deal with count.
    plotData(disp,data,n,count,length(scandef)); %FIX ME 
    scanFun(loop,'postfn',setVal);
    if n == saveloop(1) && ~mod(count(n), saveloop(2)) && saveData
        save(filename, '-append', 'data');
    end
    if isfield(loop, 'datafn')
        scanFn(loop.datafn, setVal, data);
    end    
    if isfield(loop,'testfn') && ~isempty(loop.testfn)
        if (~isfield(loop.testfn,'mod') && ~mod(count(n),loop.testfn.mod)) || isempty(loop.testfn.mod)
            testgood = testcall(loop.testfn,xt, data);
        else
            testgood =1;
        end
    else
        testgood =1;
    end
    figChar = get(figurenumber,'CurrentCharacter');
    if (~isempty(figChar) && figChar == char(27)) || testgood == 0
        flag = 'quit';
        return; % make this really return...
    end
    if figChar == ' '
        set(figurenumber, 'CurrentCharacter', char(0));
        fprintf('Measurement paused. Type ''return'' to continue.\n')
        evalin('base', 'keyboard');
    end    
end
flag = 'happy'; 
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
else good = 0; 
end
end