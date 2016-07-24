function [scandef,data,datadim,ndim,dataloop,ngetchan] = initProc(scandef)
%function [scandef,data,datadim,ndim,dataloop] = initProc(scandef)
global smdata
nloops = length(scandef); 
ngetchan = zeros(nloops,1); 
for i =1:length(scandef)
    if ~isempty(scandef(i).getchan) && isempty(scandef(i).procfn) % no processing at all, each channel saved
        [scandef(i).procfn(1:length(scandef(i).getchan)).fn] = deal([]);
    end        
    
    for j = 1:length(scandef(i).procfn) % set indata to outdata if only outdata exists 
        if isfield(scandef(i).procfn(j).fn, 'outdata') && ~isfield(scandef(i).procfn(j).fn, 'indata')
            [scandef(i).procfn(j).fn.indata] = deal(scandef(i).procfn(j).fn.outdata);
        end
        if ~isfield(scandef(i).procfn(j).fn, 'inchan') %set inchan to current loop if not given
            for k = 1:length(scandef(i).procfn(j).fn)
                scandef(i).procfn(j).fn(k).inchan = j;
            end
        end               
        if ~isempty(scandef(i).procfn(j).fn) && ~isfield(scandef(i).procfn(j).fn, 'outchan')  % set outchan to inchan if not given.
            [scandef(i).procfn(j).fn.outchan] = deal(scandef(i).procfn(j).fn.inchan);
        end
        
        if ~isempty(scandef(i).procfn(j).fn) % set each procfn inchan to current if not given, outchan to inchan
            for k = 1:length(scandef(i).procfn(j).fn)
                if isempty(scandef(i).procfn(j).fn(k).inchan)
                    scandef(i).procfn(j).fn(k).inchan = j;
                end
                if isempty(scandef(i).procfn(j).fn(k).outchan)
                    scandef(i).procfn(j).fn(k).outchan = scandef(i).procfn(j).fn(k).inchan;
                end
            end
        end
        
        % set ngetchan to largest outdata index or procfn index where outdata not given
        if isfield(scandef(i).procfn(j).fn, 'outdata')  % Outdata will create a datachannel at the number outdata, even if larger than procfns/getchans.                 
            ngetchan(i) = max([ngetchan(i), scandef(i).procfn(j).fn.outdata]);                        
            dataindPrev = sum(ngetchan(1:i-1)); % data channel index for previous loops.             
            outdataInds = [scandef(i).procfn(j).fn.outdata]+dataindPrev; 
            nOutdata = length(outdataInds); % number of outdata chans in procfn                        
            procOutchanInd(outdataInds) = 1:nOutdata; %First gives which outdata chan index 
            procFnInd(outdataInds) = j * ones(1, nOutdata); % which procfn index.                                
        else
            dataInd = sum(ngetchan(1:i-1)) + j;
            procFnInd(dataInd) = j; 
            procOutchanInd(dataInd) = 1; 
            ngetchan(i) = max(ngetchan(i), j);
        end       
    end
end

datadim = zeros(sum(ngetchan), 5); % size of data read each time, can be up to 5d. 
data = cell(1, sum(ngetchan));
ndim = zeros(1, sum(ngetchan)); % dimension of data read each time
dataloop = zeros(1, sum(ngetchan)); % loop in which each channel is read
npoints = [scandef.npoints]; 
for i = 1:nloops
    instchan = vertcat(smdata.channels(chl(scandef(i).getchan)).instchan);            
    dataindPrev = sum(ngetchan(1:i-1));
    for j = 1:ngetchan(i)
        dataInd = dataindPrev + j; % data channel index
        dataloop(dataInd) = i;
        currProcFn = procFnInd(dataInd); 
        if  isfield(scandef(i).procfn(currProcFn), 'dim') && ~isempty(scandef(i).procfn(currProcFn).dim)            
            dataDimCurr = scandef(i).procfn(currProcFn).dim(procOutchanInd(dataInd), :); %get dimension of processed data if procfn used                                    
        else
            dataDimCurr = smdata.inst(instchan(j, 1)).datadim(instchan(j, 2), :);
        end
        
        if all(dataDimCurr <= 1)
            ndimCurr = 0; 
        else
            ndimCurr = find(dataDimCurr > 1, 1, 'last');
        end
        ndim(dataInd) = ndimCurr;
        
        dataDimCurr = dataDimCurr(1:ndimCurr); % number of non-singleton dimensions
        datadim(dataInd, 1:ndimCurr) = dataDimCurr;
        
        if isfield(scandef(i).procfn(currProcFn).fn, 'outdata') % i.e. do not expand dimension if outdata given.
            dataCellSize = dataDimCurr;            
        else %collect points of size dimnsions outer + current loops 
            dataCellSize = [npoints(end:-1:i), dataDimCurr];
        end
        if length(dataCellSize) == 1 %data given in rows, not columns. 
            dataCellSize(2) = 1;
        end
        data{dataInd} = nan(dataCellSize);               
    end
end
% output ndim, datadim,data,dataloop
end