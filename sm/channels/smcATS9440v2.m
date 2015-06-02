function [val, rate] = smcATS9440v2(ico, val, rate, varargin)
% val = smcATS660v2(ico, val, rate, varargin)
% ico(3) == 3 sets/gets  HW sample rate.  negative sets to external fast ac.
% ico(3) = 4 arm
% ico(3) = 5 configures. val = record length,
% 4th argument specifies number of readout operations per trigger (can be inf)
global smdata;
maxbuf=256;
extrabuf=0;
extracap=0;
% Allow user to specify how to merge data. useful options are 
% @(x,y) mean(x,y) 
% @(x,y) std(diff(double(x),[],y),y)
if ~isfield(smdata.inst(ico(1)).data,'combine') || isempty(smdata.inst(ico(1)).data.combine)
  combine = @(x,y) mean(x,y);
else
  combine = smdata.inst(ico(1)).data.combine;
end
  
chan_inds=[1 2 4 8]; %Alazar refers to chans 1:4 as 1,2,4,8 
nbits=16; 
nchans=2; 
mintrig=32; minsamps=256; 
switch ico(3)
    case 0
        switch ico(2)
            case {1, 2, 3, 4}

                downsamp = smdata.inst(ico(1)).data.downsamp;
                nrec = smdata.inst(ico(1)).data.nrec(1);
                nsamp = smdata.inst(ico(1)).datadim(ico(2), 1)/max(1, nrec);

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
                    buf = libpointer('uint16Ptr', zeros(nsamp*downsamp+32, 1, 'uint16'));
                    % see p. 26 of ATS-SDK manual regarfding exrta 16 samples
                    while calllib('ATSApi', 'AlazarBusy', smdata.inst(ico(1)).data.handle); end
                    daqfn('Read',  smdata.inst(ico(1)).data.handle, ico(2), buf, 2, 1, 0, nsamp*downsamp);
                    if ~isempty(s.subs{1})
                        val = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                            (combine(subsref(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^(nbits-1)-1)';
                    else
                        val = smdata.inst(ico(1)).data.rng(ico(2)) * (combine(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), 1)./2^(nbits-1)-1)';
                    end
                else
                    val = zeros(nsamp*nrec, 1);
                              % pause(12); fprintf('Done with pause \n'); daqcheck(smdata.inst(11).data.handle); 
                    for i = 0:nrec-1 % read # records/readout                        
                        buf=smdata.inst(ico(1)).data.buffers{mod(i,end)+1};    
                        try               
                          daqfn('WaitAsyncBufferComplete', smdata.inst(ico(1)).data.handle, ...
                                buf, ...                                                
                               10*ceil(3000*nsamp*downsamp/smdata.inst(ico(1)).data.samprate)+500);
                        catch err;
                           fprintf('\nOn buffer %d/%d, %d total\n',i+1,nrec,length(smdata.inst(ico(1)).data.buffers));   
                           rethrow(err);
                        end
                        if ~isempty(s.subs{1})
                            val((1+i*nsamp):(i*nsamp+nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                (combine(subsref(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^(nbits-1)-1)';
                        else
                            val(i*nsamp+(1:nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                (combine(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), 1)./2^(nbits-1)-1);
                        end
                        if (nrec-i) > length(smdata.inst(ico(1)).data.buffers)
                          daqfn('PostAsyncBuffer',smdata.inst(ico(1)).data.handle, buf, nsamp*downsamp*2);
                        end
                    end                      
                end
                daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);                
%                pause(.1);
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

    case 4
        nrec = smdata.inst(ico(1)).data.nrec;
        nsamp = smdata.inst(ico(1)).datadim(ico(2), 1) * smdata.inst(ico(1)).data.downsamp/nrec; %# of points per record.
        daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, ico(2), 0, nsamp, 1, nrec, 1025); % uses total # records
        for i=1:length(smdata.inst(ico(1)).data.buffers) % Number of buffers to use in acquisiton;
            daqfn('PostAsyncBuffer', smdata.inst(ico(1)).data.handle, smdata.inst(ico(1)).data.buffers{i}, nsamp*2); %last arg is length of buffer in bytes.
        end        
        daqfn('StartCapture', smdata.inst(ico(1)).data.handle);

        
    case 5
        % val passed by smabufconfig2 is npoints. 
        % for future development: only add channel if no further arguments given        
        if nargin < 2
            smdata.inst(ico(1)).data.chan = chan_inds(ico(2));
            return;
        end
        
        smdata.inst(ico(1)).data.chan = chan_inds(ico(2));
   
          
       rngtab = [.2 .4 .8, 2, 5, 8, 16 % first row gives the range of the channel in V, second its Alazar Ref. 
            6, 7, 9,11,12,14, 18];
        for ch = 1:nchans
            [~, rng] = min(abs(rngtab(1, :) - smdata.inst(ico(1)).data.rng(ch)));
            daqfn('InputControl', smdata.inst(ico(1)).data.handle, chan_inds(ch), 2, rngtab(2, rng), ...
                2-logical(smdata.inst(ico(1)).data.highZ(ch)));
            smdata.inst(ico(1)).data.rng(ch) = rngtab(1, rng);
        end

        if smdata.inst(ico(1)).data.samprate >0
            downsamp = floor(smdata.inst(ico(1)).data.samprate/rate); % # of alazar samples gathered per sample gathered by smget. downsamp samples will be averaged together in case 0.  
            rate = smdata.inst(ico(1)).data.samprate; %rate changes to be current samprate of the Alazar
            if downsamp == 0
                error(sprintf('Sample rate too large.'));
            end
        else
            downsamp = 1;
        end

        samplesPerChannel=2^19; 
        channelCount=1; 
        % Calculate the size of each buffer in bytes
        bytesPerSample = 2;
        samplesPerBuffer = samplesPerChannel * channelCount;        
        bytesPerBuffer = uint32(bytesPerSample) * samplesPerBuffer;
        acquisitionLength_sec=val*downsamp/1e7; 
        SamplesPerSec=1e7; 
        % Find the number of buffers in the acquisition
        if acquisitionLength_sec > 0 
            samplesPerAcquisition = uint32(floor((SamplesPerSec * acquisitionLength_sec + 0.5)));
            buffersPerAcquisition = uint32(floor((samplesPerAcquisition + samplesPerChannel - 1) / samplesPerChannel));
        else
            buffersPerAcquisition = hex2dec('7FFFFFFF');  % acquire until aborted
        end

        % TODO: Select the number of DMA buffers to allocate.
        % The number of DMA buffers must be greater than 2 to allow a board to DMA into
        % one buffer while, at the same time, your application processes another buffer.
        bufferCount = uint32(32);

        % Create an array of DMA buffers 
        for j = 1 : bufferCount
            buffers(1, j) = { libpointer('uint16Ptr', 1:samplesPerBuffer) };
        end

     
        rate=setclock(ico,rate)/downsamp; %Set the clock to samprate. rate is not used again. 
        
        % make sure #points per record is divisible by 32 (or 64?) and downsampling factor.        
        %2^23 is number of samples that fit in memory for 660. (8 million) 
        %Could fit another 2^6 -- so 2^28 for 9440 (512 million), possibly. 
        %2^20 gives ~1 Mbyte buffers.        
        nrec = max(1, 2^(ceil(log2(val*downsamp))-19)); %val*downsamp total points all records. 
        if nrec > 1 || nargin >= 4
            dsf = 2^max(0, log2(mintrig)-sum(factor(downsamp)==2)); % downsampling factor, check if downsamp divisible by mintrig. 
            npt = ceil(val/(dsf * nrec))*dsf; %# samples/record after downsampling. dsf used to ensure that is multiple of mintrig
            val = npt*nrec; % should be an int, but avoid rounding errors
            npt = npt*downsamp; %npt renormalized to be number of points gathered by Alazar per record.
            
            if npt < minsamps
                error('Record size must be larger than 128');
            end
            smdata.inst(ico(1)).data.buffers={};
            for i=1:min(nrec,maxbuf) % Number of buffers to use in acquisiton;
                nsamp=val*downsamp/nrec(1); %is this not the same as npt?
                smdata.inst(ico(1)).data.buffers{i}=libpointer('uint16Ptr', zeros(nsamp+mintrig, 1, 'uint16'));
            end
        else
            nrec = 0;
            npt = max(ceil(val*downsamp/mintrig)*mintrig, minsamps);
        end

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
    % daqfn('SetCaptureClock', smdata.inst(ico(1)).data.handle, 7, 100e6, 0, 2);
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

function varargout = daqfn_ne(fn, varargin)

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

%fprintf('Calling %s\n',fn);
[varargout{1:nargout}] = calllib('ATSApi', ['Alazar', fn], varargin{:});

end
