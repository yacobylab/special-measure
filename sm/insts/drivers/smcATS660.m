function [val, rate] = smcATS660(ico, val, rate, varargin)
% Driver for Alazar 660 2 Channel DAQ, supports streaming
% val = smcATS660(ico, val, rate, varargin)
% ico(3) args can be:
% 3: sets/gets  HW sample rate.  negative sets to external fast ac.
% 4: arm before acquisition
% 5: configures, with val = record length, rate
% channels:
% 1,2: DAQ channels
% 3 : clock
% 7 : new flag for number of pulses in group, used for groups with pulses of multiple lengths
%
% This driver requires that smdata inst be set up with data: see github
% wiki for more info.
% For pulsed data, relies on smabufconfig2 for configuring.
% Works with masks, so that only data from readout period is saved.
% Averages multiple data points together before storing; set in
% inst.data.downsamp (usually set by program running scan, not manually)
%
% This is used in two main contexts: charge type scans and pulsed data.
% For charge type scans, configuring means setting up averaging,
% creating buffers. As data comes in, it is averaged together.
% For pulsing, need to do that, and set buffers to contain integer number
% of pulsegroups, and when data coming in to use mask to take in readout
% data.
% Charge scans do not use a mask. Two types of masks for pulsed data. If all pulses have
% same length (standard), mask is length of one pulse. If pulses have varying length, mask
% has length of all pulses. For now, use limited to cases where all pulses fit in one buffer .
% For typical use, this is at least 10 ms of data, so should be sufficient.

global smdata;

bufferPost = uint32(13); % number of buffers to post. # your system can handle will vary.
boardHandle = smdata.inst(ico(1)).data.handle;
switch ico(3)
    case 0
        switch ico(2)
            case {1, 2} % DAQ channels
                instData = smdata.inst(ico(1)).data;
                nchans = instData.nchans;
                if nchans > 1 && ico(2) > 1
                    val = smdata.inst(ico(1)).data.data{ico(2)-1};
                    smdata.inst(ico(1)).data.data{ico(2)-1}=[];
                    return
                end
                
                nBuffers = smdata.inst(ico(1)).data.nBuffers;
                npoints = smdata.inst(ico(1)).datadim(ico(2), 1);
                samplesPerBuffer = instData.samplesPerBuffer;
                
                if nBuffers == 1 % Single buffer, no async readout / streaming.
                    pbuffer = calllib('ATSApi', 'AlazarAllocBufferU16', boardHandle, instData.nPointsPerBuffer*instData.downsamp+16);
                    while calllib('ATSApi', 'AlazarBusy', boardHandle); end % Wait for data to come in.
                    daqfn('Read',  boardHandle, ico(2), pbuffer, 2, 1, 0, instData.nPointsPerBuffer*instData.downsamp);
                    newDataAve = procData(pbuffer,samplesPerBuffer,nchans,instData);
                    daqfn('FreeBufferU16', boardHandle, pbuffer);
                    val = newDataAve{1}(1:npoints); 
                    for i = 2:nchans
                        data{i}=newDataAve{i}(1:npoints);
                    end
                else
                    waittime = 10*(1000*samplesPerBuffer/instData.samprate)+5000; % how long to wait for data to come in before timing out
                    newDataAve = cell(nchans,nBuffers);
                    for i = 1:nBuffers % read # records/readout
                        bufferIndex = mod(i-1, bufferPost) + 1; % since we recycle buffers, need to consider which buffer currently using
                        pbuffer = smdata.inst(ico(1)).data.buffers{bufferIndex}; % current buffer.
                        daqfn('WaitAsyncBufferComplete', boardHandle, pbuffer, waittime);  % Add error handling. Runs until all data has come in.
                        newDataAve(:,i) = procData(pbuffer,samplesPerBuffer,nchans,instData);
                        if ~instData.waitData
                            daqfn('PostAsyncBuffer',boardHandle, pbuffer,samplesPerBuffer*2);
                        end
                    end
                    if instData.waitData % If data comes in too fast to process on the run, average at the end. Does not work with masks at this time.
                        nbits = 16;
                        val=mean(reshape(cell2mat(newDataAve),npoints,samplesPerBuffer*nBuffers/npoints),2);
                        val = instData.rng(ico(2))*(val/2^(nbits-1)-1);
                    else
                        val = cell2mat(newDataAve(1,:)');
                        val(npoints+1:end)=[];
                    end
                    daqfn('AbortAsyncRead', boardHandle);
                    
                end                
                if nchans > 1 % Store data from second channel
                    for i = 2:size(newDataAve,1)
                        outData = cell2mat(newDataAve(i,:)');
                        outData(npoints+1:end)=[];
                        smdata.inst(ico(1)).data.data{i-1}=outData;
                    end
                end
            case 3
                val = smdata.inst(ico(1)).data.samprate;
            case 7
                val = smdata.inst(ico(1)).data.numPls;
        end
case 1
    switch ico(2)
        case 3
            setclock(ico, val);
        case 7
            smdata.inst(ico(1)).data.numPls = val;
    end
    case 3 % software trigger
        daqfn('ForceTrigger', boardHandle);
    case 4 % Arm
        nBuffers = smdata.inst(ico(1)).data.nBuffers;
        if nBuffers>1 %For async readout. Abort ongoing async readout, config,post buffers,
            chan = smdata.inst(ico(1)).data.chan;
            daqfn('AbortAsyncRead', boardHandle);
            samplesPerBuffer = smdata.inst(ico(1)).data.samplesPerBuffer;
            daqfn('BeforeAsyncRead',  boardHandle, chan, 0, samplesPerBuffer, 1, nBuffers, 1024);% uses total # records
            for i=1:min(nBuffers,bufferPost) % Number of buffers to use in acquisiton;
                daqfn('PostAsyncBuffer', boardHandle, smdata.inst(ico(1)).data.buffers{i}, samplesPerBuffer*2);
            end
        end
        daqfn('StartCapture', boardHandle); % start readout (awaiting trigger)
    case 5
        %% Configure readout. Find best buffer size, number of buffers, then allocate. Save info in inst.data.
        % val passed by smabufconfig2 is npoints in the scan, usually npulses*nloop for pulsed data.
        % rate passed by smabufconfi2 is 1/pulselength
        % If pulsed data, also pass the number of pulses so that each buffer contains integer number of pulsegroups, making masking easier.
        smdata.inst(ico(1)).data.data={};
        if ~exist('val','var'),   return;     end        
        if ~isempty(varargin), config = struct(varargin{:}); end
        %% Set samprate, configure for multiple channels. 
        numDAQchans=2; chanInds = [1,2];
        if  ~isempty(varargin) && isfield(config,'chans')
            % Grabbing data from multiple channels
            smdata.inst(ico(1)).data.chan = sum(chanInds(config.chans));
            nchans = length(config.chans);            
            val = val * nchans; 
            chanList = [1,2]; 
        else
            % Grabbing data from only one channel, use typical SM method. 
            smdata.inst(ico(1)).data.chan = chanInds(ico(2));
            nchans = 1;
            chanList = ico(2); 
        end
        
        % Check that instrument can be set to samprate in inst.data
        currRate = cell2mat(smget('samprate'));
        if currRate ~= smdata.inst(ico(1)).data.samprate
            clockrate = setclock(ico,smdata.inst(ico(1)).data.samprate);
            if clockrate~=smdata.inst(ico(1)).data.samprate % ummmm
                smdata.inst(ico(1)).data.samprate=clockrate;
            end
        end
        samprate = smdata.inst(ico(1)).data.samprate;
        %% Configure correct number and size of buffers. 
        % Find downsamp value -- number of points averaged together. Uses samprate, # data
        % points input / time, divided by 'rate,' number of data points output / time
        % Fix me: Do we really do this samprate == 0 thing? 
        if samprate > 0
            downsamp = floor(samprate/rate);
            if ~isempty(varargin) && isfield(config,'pls')
                % Multiply points / pulse by # of pulses so that pulsegroup fits in buffer.
                minPointsPerBuffer = downsamp*config.pls; 
                smdata.inst(ico(1)).data.numPls = config.pls;
            else                
                smdata.inst(ico(1)).data.numPls = 1;
                minPointsPerBuffer = downsamp;
            end            
            if downsamp == 0 %
                error('Pulse or ramp rate too large. Increase samprate or decrease rate.');
            end
        else
            downsamp = 1;
        end
        rate=samprate/downsamp; % Set rate to the new ramprate (returned to smabufconfig2)
        
        % Select number of buffers. Make sure # points per buffer is divisible by sampInc
        % Tries to also make divisible by downsampling factor, but if both aren't possible adds extra points
        % Try to get closest to maxBufferSize .
        npoints = val;
        sampInc = 16; % buffer size must be a multiple of this. Depends on model, check model.
        maxBufferSize = 1024000; % Depnds on model, check manual
        if minPointsPerBuffer > maxBufferSize
            error('Too many points per buffer. Need to reduce ramptime or number of pulses.');
        end
        totPoints = npoints*downsamp;
        
        if totPoints < maxBufferSize % Only need a single buffer
            samplesPerBuffer = ceil(totPoints/sampInc)*sampInc;
        else
            % Buffer wants to be be multiple of both sampInc and downsampBuff, so find lcm.
            minPointsPerBuffer2 = lcm(sampInc,minPointsPerBuffer);
            % If buffFactor > maxBufferSize, this is 0. Otherwise, gives number
            % of repeats we can fit in buffer.
            nRepeats = floor(maxBufferSize / minPointsPerBuffer2);
            samplesPerBuffer = nRepeats*minPointsPerBuffer2;
        end
           
        % Case where buffers are too big due to sampInc. For non pulse
        % cases, change the ramprate to be multiple of sampInc. 
        if samplesPerBuffer == 0
            if ~isempty(varargin) && isfield(config,'pls')
                error('Cannot change ramprate for pulses, must change pulsegroup'); 
            end
            % Make the points per buffer divisible by sampInc.
            minPointsPerBuffer2 = round(minPointsPerBuffer/sampInc)*sampInc;
            if minPointsPerBuffer ==0, minPointsPerBuffer = 1; end % does this ever happen?            
            samplesPerBuffer = floor(maxBufferSize / minPointsPerBuffer2)*minPointsPerBuffer2;
            downsamp = minPointsPerBuffer;
            rate=samprate/minPointsPerBuffer;
            totPoints = downsamp * npoints;
        end
        
        nBuffers = ceil(totPoints / samplesPerBuffer);
        %samplesPerBuffer = ceil(totPoints/nBuffers/sampInc)*sampInc;
        nPointsPerBuffer = round(samplesPerBuffer/downsamp);
        %% Allocate buffers
        minSamps=128; % Depends on model, check manual
        if nBuffers > 1 % Configure Async read: abort current readout, free buffers, allocate new buffers.
            daqfn('AbortAsyncRead', boardHandle);
            if totPoints < minSamps
                error('Record size must be larger than 128');
            end
            missedbuf = [];
            for j = 1:length(smdata.inst(ico(1)).data.buffers) % Free buffers
                try
                    daqfn('FreeBufferU16', boardHandle, smdata.inst(ico(1)).data.buffers{j});
                catch
                    missedbuf(end+1)=j; 
                end
            end
            smdata.inst(ico(1)).data.buffers={}; %for future: cell(length(smdata.inst(ico(1)).data.rng),0);
            for i=1:bufferPost % Allocate buffers
                pbuffer = calllib('ATSApi', 'AlazarAllocBufferU16', boardHandle, samplesPerBuffer); % Use callib as this does not return a status byte.
                if pbuffer == 0
                    fprintf('Failed to allocate buffer %i\n',i)
                    error('Error: AlazarAllocBufferU16 %u samples failed\n', samplesPerBuffer);
                end
                smdata.inst(ico(1)).data.buffers{i} = pbuffer ;
            end
        else % Only one buffer, no async readout needed.
            daqfn('SetRecordCount', boardHandle, 1)
            daqfn('SetRecordSize', boardHandle,0,samplesPerBuffer);
        end
        %% Save info to inst, set up special functions. 
        % If the same pulse is run repeatedly and want to average many
        % together, use mean. Need to pass the number of samples/pulse as
        % varargin{1}.
        % For this, set higher samprate, so data comes in so quickly can't
        % process until end.
        if ~isempty(varargin) && isfield(config,'mean')
            smdata.inst(ico(1)).datadim(chanList) = config.mean;
            smdata.inst(ico(1)).data.nPointsPerBuffer = round(samplesPerBuffer/config.mean);
            smdata.inst(ico(1)).data.waitData = 1;
        else
            smdata.inst(ico(1)).datadim(chanList) = npoints/nchans;
            smdata.inst(ico(1)).data.nPointsPerBuffer = nPointsPerBuffer;
            smdata.inst(ico(1)).data.waitData = 0;
        end
        smdata.inst(ico(1)).data.downsamp = downsamp;
        smdata.inst(ico(1)).data.nchans = nchans; 
        smdata.inst(ico(1)).data.nBuffers = nBuffers;
        smdata.inst(ico(1)).data.samplesPerBuffer = samplesPerBuffer;
    case 6 % Set mask.
        smdata.inst(ico(1)).data.mask = val;
    otherwise
        error('Operation not supported.');
end
end

function rate=setclock(ico, val)
% 3 clocks can be used, set in inst.data.extclk: 0: PLL, 1: external clock,
% 2: internal clock.
% Frequencies that can be set using PLL varies by DAQ model.
global smdata;
boardHandle = smdata.inst(ico(1)).data.handle;
if smdata.inst(ico(1)).data.extclk == 0 % Use 10 MHz PLL
    smdata.inst(ico(1)).data.samprate = max(min(val, 130e6), 0); % Set within range
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

function newDataAve = procData(pbuffer,samplesPerBuffer,nchans,instData)
% Take buffer of incoming data and average, rescale. 
nbits = 16;
numPls = instData.numPls;
chanRng = instData.rng(1); %FIXME
downsamp = instData.downsamp; 
nPointsPerBuffer = instData.nPointsPerBuffer; 

% Configure data processing, default is mean.
if ~isfield(instData,'combine') || isempty(instData.combine)
    combine = @(x) nanmean(x,1);
else
    combine = instData.combine;
end

% Create mask
if isfield(instData, 'mask') && ~isempty(instData.mask) % Set mask
    if nchans > 1 % if mask has 2 rows, use 2nd for 2nd channel.
        s(1).subs = {instData.mask(1,:), ':'}; s(1).type = '()';
        s(2).subs = {instData.mask(2,:), ':'}; s(2).type = '()';
    else
        s.subs = {instData.mask(1,:), ':'};
        s.type = '()';
    end
else
    s.subs = {[], ':'}; % without a mask, grab all the data.
end

% Allocate data, assuming readout configured to have first channel then
% second channel (not interleaved). 
setdatatype(pbuffer, 'uint16Ptr',samplesPerBuffer)
if nchans ==2
    data(:,1) = pbuffer.value(1:end/2);
    data(:,2) = pbuffer.value(end/2+1:end);
else
    data = pbuffer.value;
end
if ~instData.waitData
    for i = 1:nchans
        if ~isempty(s(i).subs{1})
            if length(s(i).subs{1})==downsamp % Apply mask (s), reshape data into downsamp x npoints matrix, average across rows.
                newDataAve{i} = combine(subsref(reshape(data(:,i), downsamp, nPointsPerBuffer), s(i)), 1)'; %#ok<*AGROW>
            else % Varying pulse lengths.
                
                % Take useful data, reshape into full pulse lines, apply mask.
                % Assumes readout time constant across pulses.
                newData{i}=subsref(reshape(data(:,i),length(s(i).subs{1}),size(data,1)/length(s(i).subs{1})),s(i));
                % newData has size npls*nPointsPerReadout x nRepeats
                % Now all pulses have same length data, so separate and average.
                newDataAve{i} = reshape(combine(reshape(newData{i},size(newData{i},1)/numPls,numPls,nPointsPerBuffer/numPls/nchans)),1,nPointsPerBuffer/nchans)';
                %newDataAve{i} = squeeze(combine(reshape(newData{i},size(newData{i},1)/numPls,numPls,nPointsPerBuffer/numPls/nchans)));
            end
        else
            newDataAve{i} = combine(reshape(data(:,i),downsamp,nPointsPerBuffer));
        end
        newDataAve{i} = chanRng * (newDataAve{i}/2^(nbits-1)-1);
    end
else
    newDataAve{1} = data;
end
end