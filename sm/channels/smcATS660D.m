function [val, rate] = smcATS660D(ico, val, rate, varargin)
% val = smcATS660C(ico, val, rate, varargin)
% ico(3) == 3 sets/gets  HW sample rate.  negative sets to external fast ac.
% ico(3) = 4 arm
% ico(3) = 5 configures. val = record length,
% 4th argument specifies number of readout operations per trigger (can be inf)
% ico(2) = 7; 7th chan is the new flag for number of pulses in group
    % this is used for groups w pulses of multiple lengths
global smdata;
nchans=2; chanInds=[1 2]; %Alazar refers to chans 1:4 as 1,2,4,8 
minSamps=128;  bufferPost = 16; % number of buffers to post 
nbits = 16; 
boardHandle = smdata.inst(ico(1)).data.handle; 
% Allow user to specify how to merge data. useful options are 
% @(x,y) mean(x,y) 
% @(x,y) std(diff(double(x),[],y),y)
if ~isfield(smdata.inst(ico(1)).data,'combine') || isempty(smdata.inst(ico(1)).data.combine)
  combine = @(x,y) mean(x,y);
else
  combine = smdata.inst(ico(1)).data.combine;
end

switch ico(3)
    case 0
        switch ico(2)
            case {1, 2}
                downsamp = smdata.inst(ico(1)).data.downsamp;
                nBuffers = smdata.inst(ico(1)).data.nBuffers;
                npoints = smdata.inst(ico(1)).datadim(ico(2), 1); 
                npointsBuf = ceil(smdata.inst(ico(1)).datadim(ico(2), 1)/max(1, nBuffers));               
                finPoints = mod(smdata.inst(ico(1)).datadim(ico(2), 1),max(1, nBuffers)); 
                if finPoints == 0  finPoints = npointsBuf;   end
                samplesPerBuffer = smdata.inst(ico(1)).data.samplesPerBuffer; 
                chanRng = smdata.inst(ico(1)).data.rng(ico(2));              
                
                s.type = '()';                               
                if isfield(smdata.inst(ico(1)).data, 'mask') && ~isempty(smdata.inst(ico(1)).data.mask)                    
                    if size(smdata.inst(ico(1)).data.mask,1) >= ico(2) % if mask has 2 rows, use 2nd for 2nd channel. 
                      s.subs = {smdata.inst(ico(1)).data.mask(ico(2),:), ':'};
                    else           
                      s.subs = {smdata.inst(ico(1)).data.mask(1,:), ':'};
                    end
                else
                    s.subs = {[], ':'};
                end
                
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
                    waittime = 2*ceil(3000*npointsBuf*downsamp/smdata.inst(ico(1)).data.samprate)+500;
                    %waittime = 1e4;  % 10 s. may need to change for really long scans. 
                    for i = 1:nBuffers % read # records/readout                        
                        bufferIndex = mod(i-1, bufferPost) + 1;                        
                        newInds = (i - 1)*npointsBuf+1:i*npointsBuf;
                        if i == nBuffers
                            newInds = newInds(1):npoints;
                        end
                        newDataInds = 1:length(newInds); 
                        pbuffer = smdata.inst(ico(1)).data.buffers{bufferIndex}; 
                        [~, ~,bufferOut]=calllib('ATSApi','AlazarWaitAsyncBufferComplete', boardHandle, pbuffer, 2*waittime); 
                        % Add error handling 
                        setdatatype(bufferOut, 'uint16Ptr',samplesPerBuffer)

                        if ~isempty(s.subs{1})
                            if length(s.subs{1}) == downsamp %old style: each pulse the same 
                                newDataAve = combine(subsref(reshape(bufferOut.value, downsamp, npointsBuf), s), 1); 
                            else                                
                                npls = length(s.subs{1})/downsamp;
                                newData=subsref(reshape(bufferOut.value,npls*downsamp,npointsBuf/npls),s);
                                newDataAve = reshape(combine(reshape(newData,size(newData,1)/npls,npls,npointsBuf/npls),1),1,npointsBuf);
                            end
                        else                                                         
                            newDataAve = combine(reshape(bufferOut.Value,downsamp,length(bufferOut.Value)/downsamp),1);                             
                        end
                        val(newInds) = chanRng * (newDataAve(newDataInds)./2^(nbits-1)-1);
                        if i < nBuffers - bufferPost + 1; 
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
        % rate passed by smabugconfi2 is 1/pulselength
        
        daqfn('AbortAsyncRead', boardHandle);
        smdata.inst(ico(1)).data.chan = chanInds(ico(2));
        if nargin < 2           
            return;
        end               

        % Set DAQ range 
        rngVals = [.2 .4 .8, 2, 5, 8, 16]; % first row gives the range of the channel in V, second its Alazar Ref. 
        rngRef =  [6, 7, 9, 11, 12, 14, 18];
        for ch = 1:nchans
            [~, rngInd] = min(abs(rngVals - smdata.inst(ico(1)).data.rng(ch)));
            daqfn('InputControl', boardHandle, chanInds(ch),...
                2, rngRef(rngInd), 2-logical(smdata.inst(ico(1)).data.highZ(ch)));
            smdata.inst(ico(1)).data.rng(ch) = rngVals(rngInd);
        end
        
        % Find downsamp value -- number of points averaged together. . 
        if smdata.inst(ico(1)).data.samprate > 0
            % downsamp is the number of points acquired by the alazar per
            % pulse. nomically (sampling rate)*(pulselength)
            downsamp = floor(smdata.inst(ico(1)).data.samprate/rate);                           
            samprate = smdata.inst(ico(1)).data.samprate; 
            if downsamp == 0
                error('Sample rate too large.');
            end
        else
            downsamp = 1;
        end           
        rate=setclock(ico,samprate)/downsamp; %Set the clock to the sampling rate.      
        
        
        % Select number of buffers
        % make sure #points per buffer is divisible by 16 and downsampling factor.        
        npoints = val; 
        sampInc = 16; % buffer size must be a multiple of this 
        maxBufferSize = 1024000; 
        buffFactor = lcm(sampInc,downsamp); % Buffer must me multiple of both sampInc and downsamp, so find lcm. 
        samplesPerBuffer = floor(maxBufferSize / buffFactor)*buffFactor; 
       
        N = downsamp * npoints; nBuffers = ceil(N / samplesPerBuffer); % N = total points        
        
        if nBuffers > 1 || nargin >= 4            
            if N < minSamps
                error('Record size must be larger than 128');
            end
            missedbuf = [];
            for j = 1:length(smdata.inst(ico(1)).data.buffers);
                try
                    daqfn('FreeBufferU16', boardHandle, smdata.inst(ico(1)).data.buffers{j});
                catch
                    missedbuf(end+1)=j; %#ok<AGROW>
                end
            end
            smdata.inst(ico(1)).data.buffers={}; %for future: cell(length(smdata.inst(ico(1)).data.rng),0);            
            for i=1:bufferPost
                pbuffer = calllib('ATSApi', 'AlazarAllocBufferU16', boardHandle, samplesPerBuffer);
                if pbuffer == 0
                    pbuffer = daqfn('AllocBufferU16', boardHandle, samplesPerBuffer);
                    fprintf('Failed to allocate buffer %i\n',i)
                    error('Error: AlazarAllocBufferU16 %u samples failed\n', samplesPerBuffer);
                end
                smdata.inst(ico(1)).data.buffers{i} =  pbuffer ;
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
