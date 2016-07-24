function [val, rate] = smcATS660C(ico, val, rate, varargin)
% val = smcATS660C(ico, val, rate, varargin)
% ico(3) == 3 sets/gets  HW sample rate.  negative sets to external fast ac.
% ico(3) = 4 arm
% ico(3) = 5 configures. val = record length,
% 4th argument specifies number of readout operations per trigger (can be inf)
% ico(2) = 7; 7th chan is the new flag for number of pulses in group
    % this is used for groups w pulses of multiple lengths
global smdata;
maxbuf=256;
extrabuf=4;%changed from 40 to 10. 4/22/14. This change allows for longer pulsegroups. 
extracap=4;

chanInds=[1 2]; %Alazar refers to chans 1:4 as 1,2,4,8 
nchans=2; 
mintrig=16; minsamps=128; 
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
                nrec = smdata.inst(ico(1)).data.nrec(1);
                npointsBuf = floor(smdata.inst(ico(1)).datadim(ico(2), 1)/max(1, nrec));
                alldata = []; remData =[];
                samplesPerBuffer = smdata.inst(ico(1)).data.samplesPerBuffer; 
                s.type = '()';
                if isfield(smdata.inst(ico(1)).data, 'mask') && ~isempty(smdata.inst(ico(1)).data.mask)                    
                    if size(smdata.inst(ico(1)).data.mask,1) >= ico(2)
                      s.subs = {smdata.inst(ico(1)).data.mask(ico(2),:), ':'};
                    else           
                      s.subs = {smdata.inst(ico(1)).data.mask(1,:), ':'};
                    end
                else
                    s.subs = {[], ':'};
                end
                
                if nrec(1) == 0
                    buf = libpointer('uint16Ptr', zeros(npointsBuf*downsamp+16, 1, 'uint16'));
                    % see p. 26 of ATS-SDK manual regarfding exrta 16 samples
                    while calllib('ATSApi', 'AlazarBusy', smdata.inst(ico(1)).data.handle); end
                    daqfn('Read',  smdata.inst(ico(1)).data.handle, ico(2), buf, 2, 1, 0, npointsBuf*downsamp);
                    if ~isempty(s.subs{1})
                        if length(s.subs{1})==downsamp %old style mask
                            val = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                (combine(subsref(reshape(buf.value(1:downsamp*npointsBuf), downsamp, npointsBuf), s), 1)./2^15-1)';
                        else % new style mask;
                            npls = length(s.subs{1})/downsamp;
                            a=subsref(reshape(buf.value(1:downsamp*npointsBuf),npls*downsamp,npointsBuf/npls),s);
                            val = smdata.inst(ico(1)).data.rng(ico(2))* ...
                                (reshape(combine(reshape(a,size(a,1)/npls,npls,npointsBuf/npls),1),1,npointsBuf)./2^15-1)';
                        end
                    else
                        val = smdata.inst(ico(1)).data.rng(ico(2)) * (combine(reshape(buf.value(1:downsamp*npointsBuf), downsamp, npointsBuf), 1)./2^15-1)';
                    end
                else
                    %val = zeros(smdata.inst(ico(1)).datadim(ico(2), 1), 1);
                    val = [];
                    for i = 0:nrec-1 % read # records/readout                        
                        buf=smdata.inst(ico(1)).data.buffers{mod(i,end)+1};    
                        waittime = 2*ceil(3000*npointsBuf*downsamp/smdata.inst(ico(1)).data.samprate)+500;
                        try                          
                          daqfn('WaitAsyncBufferComplete', smdata.inst(ico(1)).data.handle, buf, waittime); 
                        catch err;
                           fprintf('\nOn buffer %d/%d, %d total\n',i+1,nrec,length(smdata.inst(ico(1)).data.buffers));   
                           rethrow(err);
                        end
                        setdatatype(buf, 'uint16Ptr',smdata.inst(ico(1)).data.samplesPerBuffer)
                        if ~isempty(s.subs{1})
                            if length(s.subs{1})==downsamp
                                val((1+i*npointsBuf):(i*npointsBuf+npointsBuf)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                    (combine(subsref(reshape(buf.value(1:downsamp*npointsBuf), downsamp, npointsBuf), s), 1)./2^15-1)';
                            else
                                npls = length(s.subs{1})/downsamp;
                                a=subsref(reshape(buf.value(1:downsamp*npointsBuf),npls*downsamp,npointsBuf/npls),s);
                                val((1+i*npointsBuf):(i*npointsBuf+npointsBuf)) = smdata.inst(ico(1)).data.rng(ico(2))* ...
                                   (reshape(combine(reshape(a,size(a,1)/npls,npls,npointsBuf/npls),1),1,npointsBuf)./2^15-1)';
                            end
                        else                                                         
%                             alldata = [alldata; buf.value]; 
%                             newPoints = floor(length(alldata)/downsamp); 
                            %newdata = alldata(1:newPoints * downsamp); 
                            %alldata(1:newPoints * downsamp) = [];
%                             newdataAve = combine(reshape(alldata(1:newPoints * downsamp), downsamp, newPoints), 1)';
%                             alldata= alldata(newPoints*downsamp+1:end); 
                        dataSize=length(remData) + samplesPerBuffer; 
                        newPoints = floor(dataSize/downsamp); 
                        Nnew = newPoints * downsamp - length(remData); 
                        newdataAve = combine(reshape([remData; buf.value(1:Nnew)], downsamp, newPoints), 1)';                        
                            val(end+1:end+newPoints) = smdata.inst(ico(1)).data.rng(ico(2)) * (newdataAve./2^15-1); 
                            remData = buf.value(Nnew+1:end); 
                        end
                        if (nrec-i) > length(smdata.inst(ico(1)).data.buffers)
                          daqfn('PostAsyncBuffer',smdata.inst(ico(1)).data.handle, buf, npointsBuf*downsamp*2);
                        end
                    end                      
                end
                daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);                
%                pause(.1);
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
        daqfn('ForceTrigger', smdata.inst(ico(1)).data.handle);
    case 4
        nrec = smdata.inst(ico(1)).data.nrec;
        if nrec(1) == 0
            daqfn('StartCapture', smdata.inst(ico(1)).data.handle);
        else                      
            daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);
            nsamp = smdata.inst(ico(1)).data.samplesPerBuffer;
            % 0 (0x0) = ADMA_TRADITIONAL_MODE
            % 256 (0x100) = ADMA_CONTINUOUS_MODE
            % 32 (0x20) = ADMA_ALLOC_BUFFERS
            % 1024 = 0x400 = ADMA_TRIGGERED_STREAMING            
            daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, ico(2), 0, ...
                nsamp, 1, nrec(min(2, end))+extracap, 1024);% uses total # records            
            for i=1:length(smdata.inst(ico(1)).data.buffers) % Number of buffers to use in acquisiton;
                daqfn('PostAsyncBuffer', smdata.inst(ico(1)).data.handle, smdata.inst(ico(1)).data.buffers{i}, nsamp*2);
            end
            daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, ico(2), 0, ...
                nsamp, 1, nrec(min(2, end))+extracap, 1024);% uses total # records
            
            daqfn('StartCapture', smdata.inst(ico(1)).data.handle);         
            daqfn_ne('WaitAsyncBufferComplete', smdata.inst(ico(1)).data.handle, smdata.inst(ico(1)).data.buffers{1},1);
        end       
    case 5
        % val passed by smabufconfig2 is npoints in the scan, usually npulses*nloop. 
        % rate passed by smabugconfi2 is 1/pulselength        
        daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);
        smdata.inst(ico(1)).data.chan = chanInds(ico(2));
        if nargin < 2           
            return;
        end               
               
        rngVals = [.2 .4 .8, 2, 5, 8, 16]; % first row gives the range of the channel in V, second its Alazar Ref. 
        rngRef =  [6, 7, 9, 11, 12, 14, 18];
        for ch = 1:nchans
            [~, rngInd] = min(abs(rngVals - smdata.inst(ico(1)).data.rng(ch)));
            daqfn('InputControl', smdata.inst(ico(1)).data.handle, chanInds(ch),...
                2, rngRef(rngInd), 2-logical(smdata.inst(ico(1)).data.highZ(ch)));
            smdata.inst(ico(1)).data.rng(ch) = rngVals(rngInd);
        end

        if smdata.inst(ico(1)).data.samprate >0
            % downsamp is the number of points acquired by the alazar per
            % pulse. nomically (sampling rate)*(pulselength)
            downsamp = floor(smdata.inst(ico(1)).data.samprate/rate);                           
            samprate = smdata.inst(ico(1)).data.samprate; 
            if downsamp == 0
                error(sprintf('Sample rate too large.'));
            end
        else
            downsamp = 1;
        end           
        rate=setclock(ico,samprate)/downsamp; %Set the clock to the sampling rate.      
        
        %Decide how many buffers to use.
        % make sure #points per record is divisible by 32 (or 64?) and downsampling factor.        
        %2^23 is number of samples that fit in memory for 660. (8 million)         
        %2^20 gives ~1 Mbyte buffers.        
        npoints = val; sampInc = 16; % sample increment
        maxbufsize = 2^19; 
        N = downsamp * npoints; nrec = ceil(N / maxbufsize); % N = total points
        if nrec > 1 || nargin >= 4
            N = round(N/nrec/sampInc)*nrec*sampInc; %N needs to be divisibl by nrec, sampInc           
            npoints = floor(N/downsamp);
            %npoints = floor(npoints/nrec)*nrec;
            val = npoints; 
            
            if N < minsamps
                error('Record size must be larger than 128');
            end
            bufferCount = min(nrec+extrabuf,maxbuf);% Number of buffers to use in acquisiton
            samplesPerBuffer= N / nrec; 
            %new scheme: alazar allocates buffer memory for you
            % free the buffers, then reallocate
            missedbuf = [];
            for j = 1:length(smdata.inst(ico(1)).data.buffers)
                try
                    daqfn('FreeBufferU16', smdata.inst(ico(1)).data.handle, smdata.inst(ico(1)).data.buffers{j}); 
                catch
                    missedbuf(end+1)=j; %#ok<AGROW>
                end
            end
            if ~isempty(missedbuf)
               warning('problems freeing buffers %i, memory leaks likely...\n', missedbuf) 
            end            
            smdata.inst(ico(1)).data.buffers={}; %for future: cell(length(smdata.inst(ico(1)).data.rng),0);            
            for i=1:bufferCount
                pbuffer = calllib('ATSApi', 'AlazarAllocBufferU16', smdata.inst(ico(1)).data.handle, samplesPerBuffer);
                if pbuffer == 0
                pbuffer = daqfn('AllocBufferU16', smdata.inst(ico(1)).data.handle, samplesPerBuffer);

                    fprintf('failed to alloc buffer %i\n',i)
                    error('Error: AlazarAllocBufferU16 %u samples failed\n', samplesPerBuffer);
                end
                smdata.inst(ico(1)).data.buffers{i} =  pbuffer ;
            end
        else
            nrec = 0;
            npt = max(ceil(val*downsamp/mintrig)*mintrig, minsamps);
            samplesPerBuffer = npt * downsamp; 
            daqfn('SetRecordCount', smdata.inst(ico(1)).data.handle, 1) 
        end
        daqfn('SetRecordSize', smdata.inst(ico(1)).data.handle, 0, samplesPerBuffer);

        %cache nice stuff in smdata:
        smdata.inst(ico(1)).datadim(1:nchans) = val;
        smdata.inst(ico(1)).data.downsamp = downsamp;
        smdata.inst(ico(1)).data.nrec = nrec;
        smdata.inst(ico(1)).data.samplesPerBuffer = samplesPerBuffer; 
        if nargin >= 4
            if ~isfinite(varargin{1})
                smdata.inst(ico(1)).data.nrec(2) = hex2dec('7fffffff'); %infinite
            else
                smdata.inst(ico(1)).data.nrec(2) = nrec*varargin{1}; % total #records
            end
        end

        % set other parameters (highZ, rng, ...). Samplerate would need to be set further up.
    case 6
        smdata.inst(ico(1)).data.mask = val;
        
    otherwise
        error('Operation not supported.');
end

end
function rate=setclock(ico, val)
global smdata;
if smdata.inst(ico(1)).data.extclk == 0 % Use 10 MHz PLL 
    smdata.inst(ico(1)).data.samprate = max(min(val, 130e6), 0);
    rate = val/1e6;
    dec = floor(130/rate);    
    rate = max(min(130, round(rate * dec)),110)*1e6;
    daqfn('SetCaptureClock', smdata.inst(ico(1)).data.handle, 7, rate, 0, dec-1); % external
    smdata.inst(ico(1)).data.samprate=rate/dec;
    rate=rate/dec;
elseif smdata.inst(ico(1)).data.extclk == 1 % Fast external clock
    smdata.inst(ico(1)).data.samprate=val;
    daqfn('SetCaptureClock', smdata.inst(ico(1)).data.handle, 2 , 64, 0, 0);
    rate=val;
elseif smdata.inst(ico(1)).data.extclk == 2 %internal clock
   
    smdata.inst(ico(1)).data.samprate=val;
    intclkrts.hexval={'8','A','C','E','10','12','14','18','1A','1C','1E'};
    intclkrts.val=[1e4,2e4,5e4,1e5,2e5,5e5,1e6,2e6,5e6,10e6,20e6]; 
    [~,ind]=min(abs(val-intclkrts.val)); 
    clkrt=hex2dec(intclkrts.hexval(ind));
    
    daqfn('SetCaptureClock', smdata.inst(ico(1)).data.handle, 1 , clkrt, 0, 0); %changed from 2,65 
    
    rate=intclkrts.val(ind);
    smdata.inst(ico(1)).data.samprate=rate; 
end
end

function varargout = daqfn_ne(fn, varargin)

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

%fprintf('Calling %s\n',fn);
[varargout{1:nargout}] = calllib('ATSApi', ['Alazar', fn], varargin{:});

end
