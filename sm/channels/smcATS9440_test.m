function [val, rate] = smcATS9440_test(ico, val, rate, varargin)
% val = [val, rate] = smcATS9440_test(ico, val, rate, varargin)
% ico(3) == 3 sets/gets  HW sample rate.  negative sets to external fast ac.
% ico(3) = 4 arm
% ico(3) = 5 configures. val = record length,
% 4th argument specifies number of readout operations per trigger (can be inf)


tstart2=tic;
global smdata;
maxbuf=64;
extrabuf=16;%40;
extracap=4;
debug = false;

if debug 
    disp(ico);
end
% Allow user to specify how to merge data. useful options are 
% @(x,y) mean(x,y) 
% @(x,y) std(diff(double(x),[],y),y)
if ~isfield(smdata.inst(ico(1)).data,'combine') || isempty(smdata.inst(ico(1)).data.combine)
  combine = @(x,y) mean(x,y);
else
  combine = smdata.inst(ico(1)).data.combine;
end
chan_inds=[1 2 4 8]; %Alazar refers to chans 1:4 as 1,2,4,8 
nbits=16; % ATS9440 is 14 bits but data stored as 16
nchans=4; %length of chan_inds 
mintrig=32; minsamps=256; 
switch ico(3)
    case 0
        switch ico(2)
            case {1, 2, 3, 4} % read channels 1:4
                downsamp = smdata.inst(ico(1)).data.downsamp;
                nrec = smdata.inst(ico(1)).data.nrec(1);
                nsamp = smdata.inst(ico(1)).datadim(ico(2), 1)/max(1, nrec);
                s.type = '()';
%                 if isfield(smdata.inst(ico(1)).data, 'mask') && ~isempty(smdata.inst(ico(1)).data.mask)                    
%                     if size(smdata.inst(ico(1)).data.mask,1) >= ico(2)
%                       s.subs = {smdata.inst(ico(1)).data.mask(ico(2),:), ':'};
%                     else           
%                       s.subs = {smdata.inst(ico(1)).data.mask(1,:), ':'};
%                     end
%                 else
%                     s.subs = {[], ':'};
%                 end
                if isfield(smdata.inst(ico(1)).data, 'mask') && ~isempty(smdata.inst(ico(1)).data.mask)                    
                    if size(smdata.inst(ico(1)).data.mask,1) >= ico(2)
                      s.subs = {smdata.inst(ico(1)).data.mask(ico(2),:), ':'};
                    else           
                      s.subs = {smdata.inst(ico(1)).data.mask(1,:), ':'};
                    end
                else
                    s.subs = {[], ':'};
                end
                
                if nrec(1) == 0 %no continuous streaming
                    buf = libpointer('uint16Ptr', zeros(nsamp*downsamp+32, 1, 'uint16'));
                    % see p. 26 of ATS-SDK manual regarfding exrta 16 samples
                    while calllib('ATSApi', 'AlazarBusy', smdata.inst(ico(1)).data.handle); end
                    daqfn('Read',  smdata.inst(ico(1)).data.handle, ico(2), buf, 2, 1, 0, nsamp*downsamp);
                    if ~isempty(s.subs{1})
                        if length(s.subs{1})==downsamp %old style mask = 1 mask for whole group
                           val = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                             (mean(subsref(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^(nbits-1)-1)';
                        else % new style mask; 1 mask/pulse
                            nreadout=sum(diff(s.subs{1}(1,:))>0);
                            npls = length(s.subs{1})/downsamp; 
                            a=subsref(reshape(buf.value(1:downsamp*nsamp),npls*downsamp,nsamp/npls),s);
%                             val = smdata.inst(ico(1)).data.rng(ico(2))* ...
%                                 (reshape(combine(reshape(a,size(a,1)/npls,npls,nsamp/npls),1),1,nsamp)./2^(nbits-1)-1)';
                            val = smdata.inst(ico(1)).data.rng(ico(2))* ...
                                (reshape(combine(reshape(a,size(a,1)/nreadout,nreadout,nsamp/npls),1),1,nsamp*nreadout/npls)./2^(nbits-1)-1)';
                        end
%                         val = smdata.inst(ico(1)).data.rng(ico(2)) * ...
%                             (mean(subsref(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^(nbits-1)-1)';
                    else
                        val = smdata.inst(ico(1)).data.rng(ico(2)) * (combine(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), 1)./2^(nbits-1)-1)';
                    end
                else %continuous streaming
                    val = zeros(nsamp*nrec, 1);
                    if debug
                        tstart = tic;
                    end
                    for i = 0:nrec-1 % read # records/readout
                        %fprintf('multiple buffers\n') 
                        buf=smdata.inst(ico(1)).data.buffers{mod(i,end)+1};    
                        try               
                          daqfn('WaitAsyncBufferComplete', smdata.inst(ico(1)).data.handle,buf,smdata.inst(ico(1)).data.bufferTimeOut);
                          setdatatype(buf, 'uint16Ptr', 1, nsamp*downsamp); 
                          if debug
                            fprintf('buffer %d read in %d seconds \n',i+1,toc(tstart));
                            tstart = tic;
                          end
                        catch err;
                           fprintf('\nOn buffer %d/%d, %d total\n',i+1,nrec,length(smdata.inst(ico(1)).data.buffers));   
                           if debug
                           	fprintf('buffer %d/%d failed after %d seconds \n',i+1,nrec,toc(tstart));
                           end
                           rethrow(err);
                        end
                        
                        
                        if ~isempty(s.subs{1})
                            % old style mask = 1 mask for whole group
                            if length(s.subs{1})==downsamp
                                val((1+i*nsamp):(i*nsamp+nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                    (combine(subsref(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^(nbits-1)-1)';
                                
                            %new style mask with 1 mask for each pulse
                            else
                                nreadout=sum(diff(s.subs{1}(1,:))>0);
                                npls = length(s.subs{1})/downsamp;
                                a=subsref(reshape(buf.value(1:downsamp*nsamp),npls*downsamp,nsamp/npls),s);
%                                 val((1+i*nsamp):(i*nsamp+nsamp)) = smdata.inst(ico(1)).data.rng(ico(2))* ...
%                                     (reshape(combine(reshape(a,size(a,1)/npls,npls,nsamp/npls),1),1,nsamp)./2^15-1)';
                                val((1+i*nsamp):(i*nsamp+nsamp)) = smdata.inst(ico(1)).data.rng(ico(2))* ...
                                    (reshape(combine(reshape(a,size(a,1)/nreadout,nreadout,nsamp/npls),1),1,nsamp*nreadout/npls)./2^(nbits-1)-1)';
                            end
                        else
                            val(i*nsamp+(1:nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                (combine(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), 1)./2^(nbits-1)-1);
                        end
                        if debug
                            fprintf('processed buffer %d in %d seconds \n',i+1,toc(tstart));
                            tstart = tic;
                        end
                        %lets automatically post the buffer back to the
                        %board, its plenty fast
                        % if this gets slow, check to see if buffer is
                        % needed again
                        daqfn('PostAsyncBuffer',smdata.inst(ico(1)).data.handle, buf, smdata.inst(ico(1)).data.bytesPerBuffer);
                    end                      
                end
                daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);           
                %pause(.1);
                % possibly free the buffers here?
            case 5
                val = smdata.inst(ico(1)).data.samprate;        
        end
    case 1
        switch ico(2)
            case 5
                setclock(ico, val);                                 
        end

    case 3
        daqfn('ForceTrigger', smdata.inst(ico(1)).data.handle);

    case 4 %arm!
        % if only filling one buffer, just start capture
        % if filling multiple buffers:
        %   abort the read, call BeforeAsyncRead
        %   post the buffers to the card
        %   call start capture
        nrec = smdata.inst(ico(1)).data.nrec;
        
        if debug fprintf('Case 4. nrec=%d\n',nrec); end
        
        if nrec(1) == 0 %no continuous streaming
            daqfn('StartCapture', smdata.inst(ico(1)).data.handle);
        else %continuous streaming             
            daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);
            nsamp = smdata.inst(ico(1)).datadim(ico(2), 1) * smdata.inst(ico(1)).data.downsamp/nrec(1); %# of points per record. 
            %Flags for last argument of BeforeAsyncRead 
            % 0 (0x0) = ADMA_TRADITIONAL_MODE
            % 256 (0x100) = ADMA_CONTINUOUS_MODE
            % 32 (0x20) = ADMA_ALLOC_BUFFERS
            % 1024 = 0x400 = ADMA_TRIGGERED_STREAMING 
            % ADMA_EXTERNAL_STARTCAPTURE (1) - call AlazarStartCapture to begin the acquisition
            % ADMA_TRIGGERED_STREAMING (1024) - acquire a single gapless record spanning multiple buffers
            %   after a trigger event.
            % ADMA_INTERLEAVE_SAMPLES (4096) - interleave samples for highest throughput
            %retCode = calllib('ATSApi', 'AlazarBeforeAsyncRead', boardHandle, channelMask, 0, samplesPerChannel, 1, buffersPerAcquisition, admaFlags);
            channelMask = chan_inds(ico(2)); % ico(2) is a scalar. to start capturing on more than one channel simultaneously will fail
            admaFlags = 1+1024;
            samplesPerChannel = nsamp;
            buffersPerAcquisition = nrec(min(2,end))+extracap;
            smdata.inst(ico(1)).data.bytesPerBuffer = nsamp*2;%FIXME %two bytes/samp = 16 bits
            smdata.inst(ico(1)).data.bufferTimeOut = ...
                10*ceil(3000*nsamp*smdata.inst(ico(1)).data.downsamp/smdata.inst(ico(1)).data.samprate)+500; %timeout in ms

            daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, channelMask, 0, ...
                samplesPerChannel, 1, buffersPerAcquisition, admaFlags); % uses total # records      
            for i=1:length(smdata.inst(ico(1)).data.buffers) % Number of buffers to use in acquisiton;
                daqfn('PostAsyncBuffer', smdata.inst(ico(1)).data.handle,...
                    smdata.inst(ico(1)).data.buffers{i}, smdata.inst(ico(1)).data.bytesPerBuffer); 
            end
            %mikey got rid of next line 4/23/2014
            %daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, ico(2), 0, ...
            %   samplesPerChannel, 1, buffersPerAcquisition, admaFlags);% uses total # records
            
            daqfn('StartCapture', smdata.inst(ico(1)).data.handle);
            %mikey got rid of next line
            %daqfn_ne('WaitAsyncBufferComplete', smdata.inst(ico(1)).data.handle, smdata.inst(ico(1)).data.buffers{1},1);
            %pause(50e-3);
        end
        
    case 5
        % val passed by smabufconfig2 is npoints in the scan, usually npulses*nloop. 
        % rate passed by smabugconfi2 is 1/pulselength
        % for future development: only add channel if no further arguments given        
        if nargin < 2
            smdata.inst(ico(1)).data.chan = chan_inds(ico(2));
            return;
        end
        
       smdata.inst(ico(1)).data.chan = chan_inds(ico(2));
        
       daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);
       % next line moved to inside if statement below. only needed if
       % acquiring a single record (nrec = 0 or nrec = 1)
%       daqfn('SetRecordCount', smdata.inst(ico(1)).data.handle, 1) 

        rngtab = [.2 .4 .8, 2, 5, 8, 16 % first row gives the range of the channel in V, second its Alazar Ref. 
            6, 7, 9,11,12,14, 18];
        for ch = 1:nchans
            [~, rng] = min(abs(rngtab(1, :) - smdata.inst(ico(1)).data.rng(ch)));
            daqfn('InputControl', smdata.inst(ico(1)).data.handle, chan_inds(ch),...
                2, rngtab(2, rng), 2-logical(smdata.inst(ico(1)).data.highZ(ch)));
            smdata.inst(ico(1)).data.rng(ch) = rngtab(1, rng);
        end

        if smdata.inst(ico(1)).data.samprate >0
            % downsamp is the number of points acquired by the alazar per
            % pulse. nomically (sampling rate)*(pulselength)
            downsamp = floor(smdata.inst(ico(1)).data.samprate/rate);   
            
            % rate changes to be the sampling rate of the alazar card
            rate = smdata.inst(ico(1)).data.samprate; 
            if downsamp == 0
                error(sprintf('Sample rate too large.'));
            end
        else
            downsamp = 1;
        end

        %Set the clock to the sampling rate. rate is not used after this
        %line.
        rate=setclock(ico,rate)/downsamp; 
        
        %Decide how many buffers to use.
        % make sure #points per record is divisible by 32 (or 64?) and downsampling factor.        
        %2^23 is number of samples that fit in memory for 660. (8 million) 
        %Could fit another 2^6 -- so 2^28 for 9440 (512 million), possibly. 
        %2^20 gives ~1 Mbyte buffers.        
        nrec = max(1, 2^(ceil(log2(val*downsamp))-22)); %val*downsamp total points all records. 
        if nrec > 1 || nargin >= 4
            dsf = 2^max(0, log2(mintrig)-sum(factor(downsamp)==2)); % downsampling factor, check if downsamp divisible by mintrig. 
            npt = ceil(val/(dsf * nrec))*dsf; %# samples/record after downsampling. dsf used to ensure that is multiple of mintrig
            val = npt*nrec; % should be an int, but avoid rounding errors
            npt = npt*downsamp; %npt renormalized to be number of points gathered by Alazar per record.
            
            if npt < minsamps
                error('Record size must be larger than 128');
            end
            %maxbuf;%
            bufferCount = min(4*nrec+extrabuf,maxbuf);% Number of buffers to use in acquisiton
            samplesPerBuffer=val*downsamp/nrec(1);
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
                %note, the buffer is the first return argument, not the
                %return code
                pbuffer = calllib('ATSApi', 'AlazarAllocBufferU16', smdata.inst(ico(1)).data.handle, samplesPerBuffer);
                if pbuffer == 0
                pbuffer = daqfn('AllocBufferU16', smdata.inst(ico(1)).data.handle, samplesPerBuffer);

                    fprintf('failed to alloc buffer %i\n',i)
                    error('Error: AlazarAllocBufferU16 %u samples failed\n', samplesPerBuffer);
                end
                smdata.inst(ico(1)).data.buffers{i} =  pbuffer ;
                %smdata.inst(ico(1)).data.buffers{i}=libpointer('uint16Ptr', zeros(samplesPerBuffer, 1, 'uint16')); %initialize buffers to all zeros
            end
        else
            nrec = 0;
            npt = max(ceil(val*downsamp/mintrig)*mintrig, minsamps);
            daqfn('SetRecordCount', smdata.inst(ico(1)).data.handle, 1) 
            %daqfn('SetRecordSize', smdata.inst(ico(1)).data.handle, 0, npt);
        end

        daqfn('SetRecordSize', smdata.inst(ico(1)).data.handle, 0, npt);
        %%not needed
        %cache nice stuff in smdata:
        smdata.inst(ico(1)).datadim(1:nchans) = val;
        smdata.inst(ico(1)).data.downsamp = downsamp;
        smdata.inst(ico(1)).data.nrec = nrec;
        
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

if debug
    toc(tstart2);
end
end
function rate=setclock(ico, val)
global smdata;
if smdata.inst(ico(1)).data.extclk == 0 %fix all this... 
    smdata.inst(ico(1)).data.samprate = max(min(val, 125e6), 0);
    rate = val/1e6;
    freqs=[125; 100];  decvals=[1,2,5,10];   
    freq_vals=bsxfun(@rdivide,freqs,decvals); 
    [~,ind]=min(abs(rate-freq_vals(:))); 
    freqind=rem(ind,2);
    clkrt=freqs(-rem(ind,2)+2); dec=decvals((ind-freqind)/2); 
    daqfn('SetCaptureClock', smdata.inst(ico(1)).data.handle, 7, clkrt*1e6, 0, dec);
    % daqfn('SetCaptureClock', smdata.inst(ico(1)).data.handle, 7, clkrt*1e6, 0, 2);
    smdata.inst(ico(1)).data.samprate=clkrt*1e6/dec;
    rate=clkrt*1e6/dec;
else
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

% function varargout = daqfn_ne(fn, varargin)
% 
% % (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.
% 
% %fprintf('Calling %s\n',fn);
% [varargout{1:nargout}] = calllib('ATSApi', ['Alazar', fn], varargin{:});
% 
% end
