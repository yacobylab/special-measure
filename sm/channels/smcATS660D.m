function [val, rate] = smcATS660D(ico, val, rate, varargin)
% val = smcATS660C(ico, val, rate, varargin)
% ico(3) == 3 sets/gets  HW sample rate.  negative sets to external fast ac.
% ico(3) = 4 arm
% ico(3) = 5 configures. val = record length,
% 4th argument specifies number of readout operations per trigger (can be inf)
% ico(2) = 7; 7th chan is the new flag for number of pulses in group
    % this is used for groups w pulses of multiple lengths
global smdata;
nbits = 16; 
bufferPost = 16; % number of buffers to post 
boardHandle = smdata.inst(ico(1)).data.handle; 
if ~isfield(smdata.inst(ico(1)).data,'combine') || isempty(smdata.inst(ico(1)).data.combine)
    combine = @(x,y) mean(x,1);
else
    combine = smdata.inst(ico(1)).data.combine;
    % Allow user to specify how to merge data. useful options are
    % @(x,y) mean(x,y)
    % @(x,y) std(diff(double(x),[],y),y)
end
% I think we always use more than one buffer now? %Fix me. 
switch ico(3)
    case 0
        switch ico(2)
            case {1, 2}
                downsamp = smdata.inst(ico(1)).data.downsamp; nBuffers = smdata.inst(ico(1)).data.nBuffers;
                npoints = smdata.inst(ico(1)).datadim(ico(2), 1); samplesPerBuffer = smdata.inst(ico(1)).data.samplesPerBuffer; 
                npointsBuf = ceil(smdata.inst(ico(1)).datadim(ico(2), 1)/max(1, nBuffers)); % smdata points per buffer                           
                s.type = '()';                               
                if isfield(smdata.inst(ico(1)).data, 'mask') && ~isempty(smdata.inst(ico(1)).data.mask)                    
                    if size(smdata.inst(ico(1)).data.mask,1) >= ico(2) % if mask has 2 rows, use 2nd for 2nd channel. 
                      s.subs = {smdata.inst(ico(1)).data.mask(ico(2),:), ':'};
                    else           
                      s.subs = {smdata.inst(ico(1)).data.mask(1,:), ':'};
                    end
                else
                    s.subs = {[], ':'}; % without a mask, grab all the data. 
                end                
                chanRng = smdata.inst(ico(1)).data.rng(ico(2));              
                if nBuffers == 0
                    buf = libpointer('uint16Ptr', zeros(npointsBuf*downsamp+16, 1, 'uint16')); % see p. 26 of ATS-SDK manual regarfding exrta 16 samples
                    while calllib('ATSApi', 'AlazarBusy', boardHandle); end
                    daqfn('Read',  boardHandle, ico(2), buf, 2, 1, 0, npointsBuf*downsamp);
                    if ~isempty(s.subs{1})
                        if length(s.subs{1})==downsamp %old style mask
                            newDataAve = combine(subsref(reshape(buf.value, downsamp, npointsBuf), s), 1)';
                        else % new style mask;
                            npls = length(s.subs{1})/downsamp;
                            newData=subsref(reshape(buf.value(1:downsamp*npointsBuf),npls*downsamp,npointsBuf/npls),s);
                            newDataAve = reshape(combine(reshape(newData,size(newData,1)/npls,npls,npointsBuf/npls),1),1,npointsBuf)';
                        end
                    else
                        newDataAve = combine(reshape(buf.Value(1:downsamp*npointsBuf),downsamp,npointsBuf),1);                                                      
                    end
                    val = chanRng * (newDataAve./2^15-1); 
                else
                    val = zeros(smdata.inst(ico(1)).datadim(ico(2), 1), 1);
                    waittime = 2*ceil(3000*npointsBuf*downsamp/smdata.inst(ico(1)).data.samprate)+500; % how long to wait for data to come in before timing out
                    %waittime = 1e4;  % 10 s. may need to change for really long scans.
                    for i = 1:nBuffers % read # records/readout
                        bufferIndex = mod(i-1, bufferPost) + 1; % since we recycle buffers, need to consider which buffer currently using
                        newInds = (i - 1)*npointsBuf+1:i*npointsBuf; % new sm points coming in. 
                        newInds (newInds>npoints) = [];
                        pbuffer = smdata.inst(ico(1)).data.buffers{bufferIndex};
                        %[~, ~,bufferOut]=
                        daqfn('WaitAsyncBufferComplete', boardHandle, pbuffer, 2*waittime);  % Add error handling
                        setdatatype(pbuffer, 'uint16Ptr',samplesPerBuffer)                        
                        if ~isempty(s.subs{1})
                            if length(s.subs{1}) == downsamp %old style: each pulse the same
                                newDataAve = combine(subsref(reshape(pbuffer.value, downsamp, npointsBuf), s), 1);
                            else
                                npls = length(s.subs{1})/downsamp;
                                newData=subsref(reshape(pbuffer.value,npls*downsamp,npointsBuf/npls),s);
                                newDataAve = reshape(combine(reshape(newData,size(newData,1)/npls,npls,npointsBuf/npls),1),1,npointsBuf);
                            end
                        else
                            newDataAve = combine(reshape(pbuffer.Value,downsamp,length(pbuffer.Value)/downsamp));
                        end
                        val(newInds) = chanRng * (newDataAve(1:length(newInds))./2^(nbits-1)-1); % is this even necessary anymore?
                        if i < nBuffers - bufferPost + 1
                            daqfn('PostAsyncBuffer',boardHandle, pbuffer, npointsBuf*downsamp*2);
                        end
                    end
                end
                daqfn('AbortAsyncRead', boardHandle);                
            case 3
                val = smdata.inst(ico(1)).data.samprate;                
            case 7
                val = smdata.inst(ico(1)).data.num_pls_in_grp;
        end        
    case 1
        switch ico(2)
            case 3
                setclock(ico, val);
            case 7
                smdata.inst(ico(1)).data.num_pls_in_grp = val;
        end        
    case 3
        daqfn('ForceTrigger', boardHandle);   
    case 4
        nBuffers = smdata.inst(ico(1)).data.nBuffers;        
        if nBuffers(1) == 0
            daqfn('StartCapture', boardHandle);
        else                      
            daqfn('AbortAsyncRead', boardHandle);
            samplesPerBuffer = smdata.inst(ico(1)).data.samplesPerBuffer;         
            daqfn('BeforeAsyncRead',  boardHandle, ico(2), 0, samplesPerBuffer, 1, nBuffers, 1024);% uses total # records   
            for i=1:bufferPost % Number of buffers to use in acquisiton;
                daqfn('PostAsyncBuffer', boardHandle, smdata.inst(ico(1)).data.buffers{i}, samplesPerBuffer*2);
            end
            daqfn('StartCapture', boardHandle);         
        end        
    case 5
        % val passed by smabufconfig2 is npoints in the scan, usually npulses*nloop. 
        % rate passed by smabufconfi2 is 1/pulselength        
        nchans=2; chanInds=[1 2]; %Alazar refers to chans 1:4 as 1,2,4,8 
        minSamps=128;
        daqfn('AbortAsyncRead', boardHandle);
        smdata.inst(ico(1)).data.chan = chanInds(ico(2));
        if ~exist('val','var'),     return;       end               

        % Set DAQ range 
        rngVals = [.2 .4 .8, 2, 5, 8, 16]; % range of the channel in V
        rngRef =  [6, 7, 9, 11, 12, 14, 18]; % Alazar Ref for each V. 
        for ch = 1:nchans
            [~, rngInd] = min(abs(rngVals - smdata.inst(ico(1)).data.rng(ch)));
            daqfn('InputControl', boardHandle, chanInds(ch),2, rngRef(rngInd), 2-logical(smdata.inst(ico(1)).data.highZ(ch)));
            smdata.inst(ico(1)).data.rng(ch) = rngVals(rngInd);
        end
                
        if smdata.inst(ico(1)).data.samprate > 0  % Find downsamp value -- number of points averaged together.
            samprate = smdata.inst(ico(1)).data.samprate; 
            downsamp = floor(samprate/rate);  % downsamp is the number of points acquired by the alazar per pulse. nominally (sampling rate)*(pulselength)                         
            if downsamp == 0
                error('Pulse/ramp rate too large.');
            end
        else
            downsamp = 1;
        end           
        rate=setclock(ico,samprate)/downsamp; %Set the clock to the sampling rates. Set rate to the new ramprate (returned to smabufconfig2)      
                
        % Select number of buffers. Make sure # points per buffer is divisible by 16 and downsampling factor.        
        npoints = val; 
        sampInc = 16; % buffer size must be a multiple of this 
        maxBufferSize = 1024000; 
        buffFactor = lcm(sampInc,downsamp); % Buffer must be multiple of both sampInc and downsamp, so find lcm. 
        samplesPerBuffer = floor(maxBufferSize / buffFactor)*buffFactor; 
        N = downsamp * npoints; nBuffers = ceil(N / samplesPerBuffer); % N = total points        
        
        if nBuffers > 1 || nargin >= 4            
            if N < minSamps
                error('Record size must be larger than 128');
            end
            missedbuf = [];
            for j = 1:length(smdata.inst(ico(1)).data.buffers) % Free buffers
                try
                    daqfn('FreeBufferU16', boardHandle, smdata.inst(ico(1)).data.buffers{j});
                catch
                    missedbuf(end+1)=j; %#ok<AGROW>
                end
            end
            smdata.inst(ico(1)).data.buffers={}; %for future: cell(length(smdata.inst(ico(1)).data.rng),0);            
            for i=1:bufferPost
                %pbuffer = daqfn('AllocBufferU16', boardHandle, samplesPerBuffer);
                pbuffer = calllib('ATSApi', 'AlazarAllocBufferU16', boardHandle, samplesPerBuffer); % Use callib as this does not return a status byte. 
                if pbuffer == 0                    
                    fprintf('Failed to allocate buffer %i\n',i)
                    error('Error: AlazarAllocBufferU16 %u samples failed\n', samplesPerBuffer);
                end
                smdata.inst(ico(1)).data.buffers{i} = pbuffer ;
            end
        else
            nBuffers = 0;            
            daqfn('SetRecordCount', boardHandle, 1) 
        end
        daqfn('SetRecordSize', boardHandle, 0, samplesPerBuffer);

        %cache nice stuff in smdata:
        smdata.inst(ico(1)).datadim(1:nchans) = npoints;
        smdata.inst(ico(1)).data.downsamp = downsamp;
        smdata.inst(ico(1)).data.nBuffers = nBuffers;
        smdata.inst(ico(1)).data.samplesPerBuffer = samplesPerBuffer;            
    case 6
        smdata.inst(ico(1)).data.mask = val;        
    otherwise
        error('Operation not supported.');
end
end

function rate=setclock(ico, val)
global smdata;
boardHandle = smdata.inst(ico(1)).data.handle;
if smdata.inst(ico(1)).data.extclk == 0 % Use 10 MHz PLL 
    smdata.inst(ico(1)).data.samprate = max(min(val, 130e6), 0);
    rate = val/1e6;
    dec = floor(130/rate);    
    rate = max(min(130, round(rate * dec)),110)*1e6;
    daqfn('SetCaptureClock', boardHandle, 7, rate, 0, dec-1); % external
    smdata.inst(ico(1)).data.samprate=rate/dec;
    rate=rate/dec;
elseif smdata.inst(ico(1)).data.extclk == 1 % Fast external clock
    smdata.inst(ico(1)).data.samprate=val;
    daqfn('SetCaptureClock', boardHandle, 2 , 64, 0, 0);
    rate=val;
elseif smdata.inst(ico(1)).data.extclk == 2 %internal clock   
    smdata.inst(ico(1)).data.samprate=val;
    intclkrts.hexval={'8','A','C','E','10','12','14','18','1A','1C','1E'};
    intclkrts.val=[1e4,2e4,5e4,1e5,2e5,5e5,1e6,2e6,5e6,10e6,20e6]; 
    [~,ind]=min(abs(val-intclkrts.val)); 
    clkrt=hex2dec(intclkrts.hexval(ind));    
    daqfn('SetCaptureClock', boardHandle, 1 , clkrt, 0, 0); %changed from 2,65     
    rate=intclkrts.val(ind);
    smdata.inst(ico(1)).data.samprate=rate; 
end
end