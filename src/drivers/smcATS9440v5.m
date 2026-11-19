function [val, rate] = smcATS9440v5(ico, val, rate, varargin)
% val = [val, rate] = smcATS9440_test(ico, val, rate, varargin)
% ico(3) = 0 get
% ico(3) = 1 set various parameters. val = clock rate or num_pls_in_grp 
% ico(3) = 3 sets/gets  HW sample rate.  negative sets to external fast ac.
% ico(3) = 4 arm
% ico(3) = 5 configures. val = record length,
% ico(3) = 6 sets the mask. val=mask
% 4th argument specifies number of readout operations per trigger (can be inf)

% Change log
% smcATS9440_test : good driver from Harvard
%
% smcATS9440v4: Corrently configures the card for
% non-buffered acquisition. This needed to be implemented on a switch to
% Win10 and/or using the Alazar card in a gpu slot. 
%
% smcATS9440v5: Continuous streaming happens all the time, and it is now
% configured for two qubits

tstart2=tic;
global smdata;
maxbuf=64;
extrabuf=16;%40;
extracap=4;
debug = false;

if debug
    fprintf('\nATS9440 normal driver call: ico=[%s]\n', num2str(ico));
    if nargin >= 2 && ico(3) ~= 6
        if isscalar(val)
            fprintf('  val=%.12g\n', val);
        else
            fprintf('  val class=%s, size=%s\n', ...
                class(val), mat2str(size(val)));
        end
    end
    if nargin >= 3
        fprintf('  rate=%.12g\n', rate);
    end
    fprintf('  optional argument count=%d\n', numel(varargin));
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

nChansToGet=2; %JMN this is only a place holder to indicate the number of channels we are reading. 


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
                    % see p. 26 of ATS-SDK manual regarding exrta 16 samples
                    while calllib('ATSApi', 'AlazarBusy', smdata.inst(ico(1)).data.handle); end
                    daqfn('Read',  smdata.inst(ico(1)).data.handle, ico(2), buf, 2, 1, 0, nsamp*downsamp);
                    if ~isempty(s.subs{1})
                        if length(s.subs{1})==downsamp %old style mask = 1 mask for whole group
                            val = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                (mean(subsref(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^(nbits-1)-1)';
                        else % new style mask; 1 mask/pulse
                            nreadout=sum(diff(s.subs{1}(1,:))>0);
                            %QHF: 2019/12/10 below if statement is added for varying pulse lengths
                            if isfield(smdata.inst(ico(1)).data,'num_pls_in_grp')...
                                    && ~isempty(smdata.inst(ico(1)).data.num_pls_in_grp)...
                                    && ~isnan(smdata.inst(ico(1)).data.num_pls_in_grp(1))
                                npls = smdata.inst(ico(1)).data.num_pls_in_grp(1);
                                nloop = nsamp/npls;
                                a=subsref(reshape(buf.value(1:nloop*length(s.subs{1})),length(s.subs{1}),nloop),s);
                            else
                                npls = length(s.subs{1})/downsamp;
                                a=subsref(reshape(buf.value(1:downsamp*nsamp),npls*downsamp,nsamp/npls),s);
                            end
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
                        fprintf('Getting buffers for channel %d\n',ico(2));
                    end
                    for i = 0:nrec-1 % read # records/readout
                        %fprintf('multiple buffers\n')
                        buf=smdata.inst(ico(1)).data.buffers{mod(i,end)+1};
                        if debug
                            bufferIndex = mod(i, ...
                                length(smdata.inst(ico(1)).data.buffers))+1;
                            fprintf([ ...
                                'ATS9440 wait: acquisition buffer %d/%d, ' ...
                                'host buffer index=%d, bufRead=%d\n'], ...
                                i+1, nrec, bufferIndex, ...
                                smdata.inst(ico(1)).data.bufRead(i+1));
                        end
                        if ~smdata.inst(ico(1)).data.bufRead(i+1)
                            try
                                daqfn('WaitAsyncBufferComplete', smdata.inst(ico(1)).data.handle,buf,smdata.inst(ico(1)).data.bufferTimeOut);
                                setdatatype(buf, 'uint16Ptr', 1, nsamp*downsamp*nChansToGet);
                                smdata.inst(ico(1)).data.bufRead(i+1)=1;
                                if debug
                                    fprintf([ ...
                                        'ATS9440 wait: PASS; daqfn accepted ' ...
                                        'ApiSuccess for host buffer %d\n'], ...
                                        bufferIndex);
                                    fprintf('buffer %d read in %.6f seconds \n', ...
                                        i+1, toc(tstart));
                                    tstart = tic;
                                end
                            catch err;
                                fprintf('\nOn buffer %d/%d, %d total\n',i+1,nrec,length(smdata.inst(ico(1)).data.buffers));
                                if debug
                                    fprintf('buffer %d/%d failed after %d seconds \n',i+1,nrec,toc(tstart));
                                end
                                rethrow(err);
                            end
                        end
                        
                        %Handle interleaving here.
                        bufLen=length(buf.value);
                        %data=buf.value((ico(2)-1).*bufLen/2+1:(ico(2)).*bufLen/2);
                        %I think it's interleaving point by point
                        data=buf.value(ico(2):2:bufLen-2+ico(2));
                        % Plot the selected raw channel for masked and unmasked
                        % scans. When a mask exists, repeat its complete-record
                        % block exactly as the acquisition path does below.
                        if debug
                            mask = s.subs{1};
                            dataBlockCount = floor(numel(data)/downsamp);
                            maxPlotRecords = max(1, floor(1e4/downsamp));
                            nPlotRecords = min(dataBlockCount, maxPlotRecords);
                            maskContainsWholeRecords = isvector(mask) && ...
                                ~isempty(mask) && ...
                                mod(numel(mask), downsamp) == 0;

                            if nPlotRecords > 0
                                nPlotSamples = nPlotRecords*downsamp;
                                figure(333); clf;
                                plot(double(data(1:nPlotSamples)), ...
                                    'DisplayName', 'Raw ADC');
                                xlabel('Samples in consecutive records');
                                ylabel('ADC code / scaled mask');

                                if maskContainsWholeRecords
                                    maskRepeatCount = ceil( ...
                                        nPlotSamples/numel(mask));
                                    plotMask = repmat(double(mask(:)), ...
                                        maskRepeatCount, 1);
                                    plotMask = plotMask(1:nPlotSamples);
                                    maskRecordCount = numel(mask)/downsamp;
                                    hold on;
                                    plot(3e4*plotMask, ...
                                        'DisplayName', 'Mask x 3e4');
                                    hold off;
                                    title(sprintf([ ...
                                        'Channel %d, buffer %d: %d/%d ' ...
                                        'blocks of %d samples; mask = %d blocks'], ...
                                        ico(2), i+1, nPlotRecords, ...
                                        dataBlockCount, downsamp, ...
                                        maskRecordCount));
                                else
                                    title(sprintf([ ...
                                        'Channel %d, buffer %d: first %d/%d ' ...
                                        'samples; unmasked acquisition'], ...
                                        ico(2), i+1, nPlotSamples, ...
                                        numel(data)));
                                end
                                legend('show');
                            end

                            if ~isempty(mask) && ~maskContainsWholeRecords
                                warning('smcATS9440v5:DebugMaskShape', ...
                                    ['Debug overlay requires a mask whose ' ...
                                     'length is a multiple of the ' ...
                                     '%d-sample record; found %d samples.'], ...
                                    downsamp, numel(mask));
                            end

                            pairedLength = 2*floor(bufLen/2);
                            channelA = buf.value(1:2:pairedLength-1);
                            channelB = buf.value(2:2:pairedLength);
                            channelACodes = double(channelA);
                            channelBCodes = double(channelB);
                            lowerBitsA = mean(bitand(channelA, uint16(3)) ~= 0);
                            lowerBitsB = mean(bitand(channelB, uint16(3)) ~= 0);
                            nearRailA = mean(channelA <= uint16(4) | ...
                                channelA >= uint16(65528));
                            nearRailB = mean(channelB <= uint16(4) | ...
                                channelB >= uint16(65528));
                            fprintf([ ...
                                'ATS9440 word audit: words=%d, paired=%d, ' ...
                                'selected channel=%d\n'], ...
                                bufLen, pairedLength, ico(2));
                            fprintf([ ...
                                '  A min/max/mean/std=[%.0f %.0f %.3g %.3g], ' ...
                                'lower-two-bit nonzero fraction=%.6g, ' ...
                                 'near-rail fraction=%.6g\n'], ...
                                min(channelACodes), max(channelACodes), ...
                                mean(channelACodes), std(channelACodes), ...
                                lowerBitsA, nearRailA);
                            fprintf([ ...
                                '  B min/max/mean/std=[%.0f %.0f %.3g %.3g], ' ...
                                'lower-two-bit nonzero fraction=%.6g, ' ...
                                 'near-rail fraction=%.6g\n'], ...
                                min(channelBCodes), max(channelBCodes), ...
                                mean(channelBCodes), std(channelBCodes), ...
                                lowerBitsB, nearRailB);

                            nChannelPlotSamples = min(1e4, ...
                                numel(channelACodes));
                            channelAVolts = ...
                                smdata.inst(ico(1)).data.rng(1)*( ...
                                channelACodes(1:nChannelPlotSamples)/ ...
                                2^(nbits-1)-1);
                            channelBVolts = ...
                                smdata.inst(ico(1)).data.rng(2)*( ...
                                channelBCodes(1:nChannelPlotSamples)/ ...
                                2^(nbits-1)-1);
                            figure(334); clf;
                            plot(channelAVolts, 'DisplayName', 'ATS channel A');
                            hold on;
                            plot(channelBVolts, 'DisplayName', 'ATS channel B');
                            hold off;
                            xlabel('Interleaved sample index per channel');
                            ylabel('Input voltage (V)');
                            title(sprintf([ ...
                                'Host buffer %d: first %d samples from ' ...
                                'both ATS channels'], ...
                                bufferIndex, nChannelPlotSamples));
                            legend('show');
                            drawnow;
                        end
                        
                        if ~isempty(s.subs{1})
                            % old style mask = 1 mask for whole group
                            %if mask size is same as downsample, return average of the time series
                            if length(s.subs{1})==downsamp
                                %                                 val((1+i*nsamp):(i*nsamp+nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                %                                     (combine(subsref(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^(nbits-1)-1)';
                                val((1+i*nsamp):(i*nsamp+nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                    (combine(subsref(reshape(data(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^(nbits-1)-1)';
                                
                                
                                %new style mask with 1 mask for each pulse
                            else
                                nreadout=sum(diff(s.subs{1}(1,:))>0);
                                %QHF: 2019/12/10 below if statement is added for varying pulse lengths
                                if isfield(smdata.inst(ico(1)).data,'num_pls_in_grp')...
                                        && ~isempty(smdata.inst(ico(1)).data.num_pls_in_grp)...
                                        && ~isnan(smdata.inst(ico(1)).data.num_pls_in_grp(1))
                                    npls = smdata.inst(ico(1)).data.num_pls_in_grp(1);
                                    nloop = nsamp/npls;
%                                     nloop = floor(nsamp/npls);
                                    a=subsref(reshape(data(1:nloop*length(s.subs{1})),length(s.subs{1}),nloop),s);
                                else
                                    npls = length(s.subs{1})/downsamp;
                                    a=subsref(reshape(data(1:downsamp*nsamp),npls*downsamp,nsamp/npls),s);
                                end
                                
                                %                                 val((1+i*nsamp):(i*nsamp+nsamp)) = smdata.inst(ico(1)).data.rng(ico(2))* ...
                                %                                     (reshape(combine(reshape(a,size(a,1)/npls,npls,nsamp/npls),1),1,nsamp)./2^15-1)';
                                val((1+i*nsamp):(i*nsamp+nsamp)) = smdata.inst(ico(1)).data.rng(ico(2))* ...
                                    (reshape(combine(reshape(a,size(a,1)/nreadout,nreadout,nsamp/npls),1),1,nsamp*nreadout/npls)./2^(nbits-1)-1)';
                            end
                        else
                            %                             val(i*nsamp+(1:nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                            %                                 (combine(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), 1)./2^(nbits-1)-1);
                            val(i*nsamp+(1:nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                (combine(reshape(data(1:downsamp*nsamp), downsamp, nsamp), 1)./2^(nbits-1)-1);
                            %bb=reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp);
                            %                             bb=combine(bb,1);
                            %bb=smdata.inst(ico(1)).data.rng(ico(2)).*bb./2^(nbits-1)-1;
                            %bb=mean(bb,1);
                        end
                        if debug
                            fprintf('processed buffer %d in %d seconds \n',i+1,toc(tstart));
                            tstart = tic;
                        end
                        %lets automatically post the buffer back to the
                        %board, its plenty fast
                        % if this gets slow, check to see if buffer is
                        % needed again
                        if ~smdata.inst(ico(1)).data.bufRead(i+1)
                            daqfn('PostAsyncBuffer',smdata.inst(ico(1)).data.handle, buf, smdata.inst(ico(1)).data.bytesPerBuffer);
                        end
                    end
                end
                daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);
                %pause(.1);
                %Possibly free the buffers here?
            case 5
                val = smdata.inst(ico(1)).data.samprate;
            case 7 %QHF: 2019/12/10 the num_pls_in_grp flag
                val = smdata.inst(ico(1)).data.num_pls_in_grp;
        end
    case 1
        switch ico(2)
            case 5
                setclock(ico, val);
            case 7 %QHF: 2019/12/10 the num_pls_in_grp flag
                smdata.inst(ico(1)).data.num_pls_in_grp=val;
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
            
            %JMN 2019_11_11 need to reconfigure the board for no continuous
            %streaming. Added code up to start capture.
            daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);
            samplesPerChannel = smdata.inst(ico(1)).datadim(ico(2), 1) * smdata.inst(ico(1)).data.downsamp;
            buffersPerAcquisition = 1;
            admaFlags = 1;
            %Hard code acquiring on two qubits. This will break something
            %in the future.
            channelMask=3; %sum(chan_inds(smdata.inst(ico(1)).data.chansToRead));
            daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, channelMask, 0, ...
                samplesPerChannel, 1, buffersPerAcquisition, admaFlags);
            
            daqfn('StartCapture', smdata.inst(ico(1)).data.handle);
            
        else %continuous streaming
            daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);
            nsamp = smdata.inst(ico(1)).datadim(ico(2), 1) * smdata.inst(ico(1)).data.downsamp/nrec(1); % number of points per record.
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
            %channelMask = chan_inds(ico(2)); % ico(2) is a scalar. to start capturing on more than one channel simultaneously will fail
            %admaFlags = 1+1024;
            
            %JMN 2019/11/12 set for interleaved acquisition on channels A
            %and B
            channelMask=3;
            admaFlags = 1+1024+4096;
            
            samplesPerChannel = nsamp;
            buffersPerAcquisition = nrec(min(2,end))+extracap;
            smdata.inst(ico(1)).data.bytesPerBuffer = nsamp*2*nChansToGet;%FIXME %two bytes/samp = 16 bits
            smdata.inst(ico(1)).data.bufferTimeOut = ...
                10*ceil(3000*nsamp*smdata.inst(ico(1)).data.downsamp/smdata.inst(ico(1)).data.samprate)+500; %timeout in ms

            if debug
                fprintf([ ...
                    'ATS9440 arm: channelMask=%d, admaFlags=%d, ' ...
                    'samplesPerChannel=%d, buffersPerAcquisition=%d\n'], ...
                    channelMask, admaFlags, samplesPerChannel, ...
                    buffersPerAcquisition);
                fprintf([ ...
                    '  allocated host buffers=%d, bytesPerBuffer=%d, ' ...
                    'timeout=%g ms\n'], ...
                    length(smdata.inst(ico(1)).data.buffers), ...
                    smdata.inst(ico(1)).data.bytesPerBuffer, ...
                    smdata.inst(ico(1)).data.bufferTimeOut);
            end
            
            daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, channelMask, 0, ...
                samplesPerChannel, 1, buffersPerAcquisition, admaFlags); % uses total # records
            if debug
                fprintf('ATS9440 BeforeAsyncRead: PASS (ApiSuccess)\n');
            end
            
            %JMN 2019_11_11
            smdata.inst(ico(1)).data.bufRead=zeros(1,length(smdata.inst(ico(1)).data.buffers));
            for i=1:length(smdata.inst(ico(1)).data.buffers) % Number of buffers to use in acquisiton;
                daqfn('PostAsyncBuffer', smdata.inst(ico(1)).data.handle,...
                    smdata.inst(ico(1)).data.buffers{i}, smdata.inst(ico(1)).data.bytesPerBuffer);
            end
            if debug
                fprintf('ATS9440 PostAsyncBuffer: PASS for %d host buffers\n', ...
                    length(smdata.inst(ico(1)).data.buffers));
            end
              
            %mikey got rid of next line 4/23/2014
            %daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, ico(2), 0, ...
            %   samplesPerChannel, 1, buffersPerAcquisition, admaFlags);% uses total # records
           
            daqfn('StartCapture', smdata.inst(ico(1)).data.handle);
            if debug
                fprintf('ATS9440 StartCapture: PASS (ApiSuccess)\n');
            end
            
            %mikey got rid of next line
            %             daqfn_ne('WaitAsyncBufferComplete', smdata.inst(ico(1)).data.handle, smdata.inst(ico(1)).data.buffers{1},1);
            %             pause(50e-3);
            
        end
        
    case 5
        % val passed by smabufconfig2 is npoints in the scan, usually npulses*nloop.
        % rate passed by smabugconfi2 is 1/pulselength
        % for future development: only add channel if no further arguments given
        if nargin < 2
            smdata.inst(ico(1)).data.chan = chan_inds(ico(2));
            return;
        end

        if debug
            fprintf([ ...
                'ATS9440 configure request: instrument=%d, channel=%d, ' ...
                'points=%.12g, rate=%.12g Hz\n'], ...
                ico(1), ico(2), val, rate);
        end
        
        smdata.inst(ico(1)).data.chan = chan_inds(ico(2));
        
        %JMN 2018/10/19 added 10 sec trigger timeout for handling of
        %complicated scans.
        trigTimeout=10;
        trigTimeoutTicks=trigTimeout/10e-6;
        daqfn('SetTriggerTimeOut',smdata.inst(ico(1)).data.handle,trigTimeoutTicks);
        if debug
            fprintf(['ATS9440 trigger timeout: %.6f s; a first-buffer ' ...
                'wait near this value indicates automatic triggering.\n'], ...
                trigTimeout);
        end
        
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
            %downsamp = floor(smdata.inst(ico(1)).data.samprate/rate); %FIXME
            downsamp = round(floor(smdata.inst(ico(1)).data.samprate/rate*1e6)/1e6); %JMN 2018_04_11 not sure why this is needed.
            
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
        %Could fit another 2^6 -- so 2^28 for 9440 (256 million), possibly.
        %2^20 gives ~1 Mbyte buffers.
        %QHF: 2019/07/31, the number of samples that fit into one buffer
        %varies depending on memory size of Alazar, which is stored in
        %smdata. Default is 2^22 if no memory is specified
        if isfield(smdata.inst(ico(1)).data,'memory') && ~isempty(smdata.inst(ico(1)).data.memory)
            memPow=ceil(log2(smdata.inst(ico(1)).data.memory)); %QHF: not 100% certain about ceil vs. floor
        else
            memPow=22;
        end
        nrec = max(1, 2^(ceil(log2(val*downsamp))-memPow)); %val*downsamp total points all records.
        
        if nrec <= 1
            missedbuf = [];
            for j = 1:length(smdata.inst(ico(1)).data.buffers)
                try
                    daqfn('FreeBufferU16', smdata.inst(ico(1)).data.handle, smdata.inst(ico(1)).data.buffers{j});
                catch
                    missedbuf(end+1)=j; %#ok<AGROW>
                end
            end
            if ~isempty(missedbuf)
                warning('problems freeing buffers %d, memory leaks likely...\n', num2str(missedbuf))
            end
            
            smdata.inst(ico(1)).data.buffers={}; %for future: cell(length(smdata.inst(ico(1)).data.rng),0);
        end
        if nrec >= 1 || nargin >= 4 %JMN changing from > to >= forces continuous streaming all the time.
            dsf = 2^max(0, log2(mintrig)-sum(factor(downsamp)==2)); % downsampling factor, check if downsamp divisible by mintrig.
            npt = ceil(val/(dsf * nrec))*dsf; % number of samples/record after downsampling. dsf used to ensure that is multiple of mintrig
            val = npt*nrec; % should be an int, but avoid rounding errors
            npt = npt*downsamp; %npt renormalized to be number of points gathered by Alazar per record.
            
            if npt < minsamps
                error('Record size must be larger than 128');
            end
            %maxbuf;%
            bufferCount = min(4*nrec+extrabuf,maxbuf);% Number of buffers to use in acquisiton
            if 4*nrec>256 %XC, JMN 2021_03_25 empirically, when 4*nrec>256, the scan wont run
                warning('Too many buffers required. The scan will probably fail')
            end
            samplesPerBuffer=val*downsamp/nrec(1)*nChansToGet;
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
                warning('problems freeing buffers %d, memory leaks likely...\n', num2str(missedbuf))
            end
            
            smdata.inst(ico(1)).data.buffers={}; %for future: cell(length(smdata.inst(ico(1)).data.rng),0);
            
            %JMN 2019/11/12
            smdata.inst(ico(1)).data.bufRead=zeros(1,bufferCount);
            
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

        if debug
            fprintf([ ...
                'ATS9440 configure result: returnedPoints=%d, ' ...
                'sampleRate=%.12g Hz, downsamp=%d, nrec=%s, npt=%d\n'], ...
                val, smdata.inst(ico(1)).data.samprate, downsamp, ...
                mat2str(nrec), npt);
            fprintf([ ...
                '  host buffers=%d, samplesPerBuffer=%d, ranges=%s V, ' ...
                'highZ=%s\n'], ...
                length(smdata.inst(ico(1)).data.buffers), ...
                samplesPerBuffer, ...
                mat2str(smdata.inst(ico(1)).data.rng), ...
                mat2str(smdata.inst(ico(1)).data.highZ));
        end
        
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
if smdata.inst(ico(1)).data.extclk == 0 %Not sure why this is zero. This opion is actually using the external 10 MHz reference.
    %sourceID=7, use the 10 MHz reference and decimation factor to get different sampling rates
    smdata.inst(ico(1)).data.samprate = max(min(val, 125e6), 0);
    rate = val/1e6;
    freqs=[125; 100];  %decvals=[1,2,5,10];   
    decvals=[1,2,5,10,15,20,25,50,75,100]; % AE add this to have lower sampling rate 8/24/2023
    freq_vals=bsxfun(@rdivide,freqs,decvals); 
    [~,ind]=min(abs(rate-freq_vals(:))); 
    freqind=rem(ind,2);
    clkrt=freqs(-rem(ind,2)+2); dec=decvals((ind-freqind)/2); 
    daqfn('SetCaptureClock', smdata.inst(ico(1)).data.handle, 7, clkrt*1e6, 0, dec);
    % daqfn('SetCaptureClock', smdata.inst(ico(1)).data.handle, 7, clkrt*1e6, 0, 2);
    smdata.inst(ico(1)).data.samprate=clkrt*1e6/dec;
    rate=clkrt*1e6/dec; 
else %not using the external 10 MHz reference.  
    %sourceID=1, use the internal clock to generate the different possible sampling rates.See the Alazar SDK docs to find the possible sampling rates.
    smdata.inst(ico(1)).data.samprate=val;
    intclkrts.hexval={'1','2','4','8','A','C','E','10','12','14','18','1A','1C','1E','22','24','25'};
    intclkrts.val=[1e3,2e3,5e3,1e4,2e4,5e4,1e5,2e5,5e5,1e6,2e6,5e6,10e6,20e6,50e6,100e6,125e6];
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
