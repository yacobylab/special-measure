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
bufferPost = uint32(10); % number of buffers to post 
boardHandle = smdata.inst(ico(1)).data.handle; 
switch ico(3)    
    case 0
        switch ico(2)
            case {1, 2}
                if ~isfield(smdata.inst(ico(1)).data,'combine') || isempty(smdata.inst(ico(1)).data.combine)
                    combine = @(x) nanmean(x,1);
                else
                    combine = smdata.inst(ico(1)).data.combine;
                end
                waitData = smdata.inst(ico(1)).data.waitData;
                downsamp = smdata.inst(ico(1)).data.downsamp; 
                nBuffers = smdata.inst(ico(1)).data.nBuffers;
                npoints = smdata.inst(ico(1)).datadim(ico(2), 1); 
                samplesPerBuffer = smdata.inst(ico(1)).data.samplesPerBuffer; 
                npointsBuf = smdata.inst(ico(1)).data.npointsBuf; % smdata points per buffer                           
                chanRng = smdata.inst(ico(1)).data.rng(ico(2));              
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
                if nBuffers == 0
%                    buf = libpointer('uint16Ptr', zeros(npointsBuf*downsamp+16, 1, 'uint16')); % see p. 26 of ATS-SDK manual regarfding exrta 16 samples
                    buf = calllib('ATSApi', 'AlazarAllocBufferU16', boardHandle, npointsBuf*downsamp+16);
                    while calllib('ATSApi', 'AlazarBusy', boardHandle); end
                    daqfn('Read',  boardHandle, ico(2), buf, 2, 1, 0, npointsBuf*downsamp);
                    setdatatype(buf, 'uint16Ptr',npointsBuf*downsamp+16)                        
                    if ~isempty(s.subs{1})
                        if length(s.subs{1})==downsamp %old style mask
                            newDataAve = combine(subsref(reshape(buf.value, downsamp, npointsBuf), s), 1)';
                        else % new style mask;
                            npls = length(s.subs{1})/downsamp;
                            newData=subsref(reshape(buf.value(1:downsamp*npointsBuf),npls*downsamp,npointsBuf/npls),s);                            
                            newDataAve = reshape(combine(reshape(newData,size(newData,1)/npls,npls,npointsBuf/npls)),1,npointsBuf)';
                        end
                    else
                        newDataAve = combine(reshape(buf.Value(1:downsamp*npointsBuf),downsamp,npointsBuf))';                                                      
                    end
                    daqfn('FreeBufferU16', boardHandle, buf);
                    val = chanRng * (newDataAve/2^(nbits-1)-1); 
                else
                    val = zeros(npoints, 1);
                    waittime = 5*(1000*samplesPerBuffer/smdata.inst(ico(1)).data.samprate)+50; % how long to wait for data to come in before timing out
                    for i = 1:nBuffers % read # records/readout
                        bufferIndex = mod(i-1, bufferPost) + 1; % since we recycle buffers, need to consider which buffer currently using                        
                        pbuffer = smdata.inst(ico(1)).data.buffers{bufferIndex};
                        try
                            daqfn('WaitAsyncBufferComplete', boardHandle, pbuffer, waittime);  % Add error handling
                            setdatatype(pbuffer, 'uint16Ptr',samplesPerBuffer)
                            if ~isempty(s.subs{1})
                                if length(s.subs{1}) == downsamp %old style: each pulse the same
                                    newDataAve = combine(subsref(reshape(pbuffer.value, downsamp, npointsBuf), s), 1);
                                else
                                    npls = length(s.subs{1})/downsamp;
                                    newData=subsref(reshape(pbuffer.value,npls*downsamp,npointsBuf/npls),s);
                                    newDataAve{i} = reshape(combine(reshape(newData,size(newData,1)/npls,npls,npointsBuf/npls)),1,npointsBuf);
                                end
                            else
                                newDataAve{i} = combine(reshape(pbuffer.Value,downsamp,length(pbuffer.Value)/downsamp));
                            end
                            if ~waitData
                                newInds = (i - 1)*npointsBuf+1:i*npointsBuf; % new sm points coming in.
                                val(newInds) = chanRng * (newDataAve{i}(1:length(newInds))/2^(nbits-1)-1); % is this even necessary anymore?
                            end
                        catch
                            newInds = (i - 1)*npointsBuf+1:i*npointsBuf; % new sm points coming in.
                            val(newInds)=nan(length(newInds),1); 
                            fprintf('Timeout DAQ \n'); 
                        end
                        %if i < nBuffers - bufferPost + 1                            
                            daqfn('PostAsyncBuffer',boardHandle, pbuffer,samplesPerBuffer*2);
                        %end
                    end
                    if waitData 
                        val = chanRng*(mean(cell2mat(newDataAve),2)/2^(nbits-1)-1);
                    else
                        val(npoints+1:length(val)) =[];
                    end
                    daqfn('AbortAsyncRead', boardHandle);
                end
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
            for i=1:min(smdata.inst(ico(1)).data.nBuffers,bufferPost) % Number of buffers to use in acquisiton;
                daqfn('PostAsyncBuffer', boardHandle, smdata.inst(ico(1)).data.buffers{i}, samplesPerBuffer*2);
            end
            daqfn('StartCapture', boardHandle);         
        end
    case 5
        % val passed by smabufconfig2 is npoints in the scan, usually npulses*nloop. 
        % rate passed by smabufconfi2 is 1/pulselength        
        if ~exist('val','var'),   return;     end               
        nchans=2; chanInds=[1 2]; %Alazar refers to chans 1:4 as 1,2,4,8 
        smdata.inst(ico(1)).data.chan = chanInds(ico(2));
        if smdata.inst(ico(1)).data.samprate > 0  % Find downsamp value -- number of points averaged together.
            samprate = smdata.inst(ico(1)).data.samprate; 
            if ~isempty(varargin) && strcmp(varargin{2},'pls')
                downsampBuff = floor(samprate/rate)*varargin{1};
            else
                downsampBuff = floor(samprate/rate); % downsamp is the number of points acquired by the alazar per pulse. nominally (sampling rate)*(pulselength)                         
            end
            downsamp = floor(samprate/rate);
            if downsamp == 0
                error('Pulse/ramp rate too large.');
            end
        else
            downsamp = 1;
        end   
        if ~(samprate==smdata.inst(ico(1)).data.samprate)
            samprate = setclock(ico,samprate);
        end
        rate=samprate/downsamp; %Set the clock to the sampling rates. Set rate to the new ramprate (returned to smabufconfig2)      
                
        % Select number of buffers. Make sure # points per buffer is divisible by 16 and downsampling factor.        
        npoints = val; 
        sampInc = 16; % buffer size must be a multiple of this 
        maxBufferSize = 1024000/2; 
        if downsampBuff > maxBufferSize 
            error('Need to increase number of points / reduce ramptime. Too many points per buffer'); 
        end
        buffFactor = lcm(sampInc,downsampBuff); % Buffer must be multiple of both sampInc and downsamp, so find lcm. 
        samplesPerBuffer = floor(maxBufferSize / buffFactor)*buffFactor; 
        if samplesPerBuffer > val*downsamp
            buffFactor = lcm(sampInc,val*downsamp); % Buffer must be multiple of both sampInc and downsamp, so find lcm. 
            samplesPerBuffer = floor(val*downsamp / buffFactor)*buffFactor;            
        end
        if samplesPerBuffer == 0 % If maxBufferSize < buffFactor, need to redo. 
            downsampBuff = round(downsampBuff/sampInc)*sampInc;
            buffFactor = lcm(sampInc,downsampBuff); % Buffer must be multiple of both sampInc and downsamp, so find lcm. 
            samplesPerBuffer = floor(maxBufferSize / buffFactor)*buffFactor; 
            downsamp = downsampBuff;
            rate=samprate/downsampBuff;
        end
        N = downsamp * npoints; nBuffers = ceil(N / samplesPerBuffer); % N = total points        
        npointsBuf = round(samplesPerBuffer/downsamp);
        
        minSamps=128;
        if nBuffers > 1
             daqfn('AbortAsyncRead', boardHandle);                               
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
            daqfn('SetRecordSize', boardHandle,0,samplesPerBuffer);
        end
        
        if ~isempty(varargin) && strcmp(varargin{2},'mean')
            smdata.inst(ico(1)).datadim(1:nchans) = varargin{1};
            smdata.inst(ico(1)).data.npointsBuf = round(samplesPerBuffer/varargin{1});
            smdata.inst(ico(1)).data.waitData = 1; 
        else
            smdata.inst(ico(1)).datadim(1:nchans) = npoints;
            smdata.inst(ico(1)).data.npointsBuf = npointsBuf; 
            smdata.inst(ico(1)).data.waitData = 0; 
        end
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
    daqfn('SetCaptureClock', boardHandle, 2, 64, 0, 0);
    rate=val;
elseif smdata.inst(ico(1)).data.extclk == 2 %internal clock   
    smdata.inst(ico(1)).data.samprate=val;
    intclkrts.hexval={'1','2','4','8','A','C','E','10','12','14','18','1A','1C','1E','22','24','25'};
    intclkrts.val=[1e3,2e3,5e3,1e4,2e4,5e4,1e5,2e5,5e5,1e6,2e6,5e6,10e6,20e6,50e6,100e6,125e6]; 
    [~,ind]=min(abs(val-intclkrts.val)); 
    clkrt=hex2dec(intclkrts.hexval(ind));    
    daqfn('SetCaptureClock', boardHandle, 1 , clkrt, 0, 0); %changed from 2,65     
    rate=intclkrts.val(ind);
    smdata.inst(ico(1)).data.samprate=rate; 
end
end