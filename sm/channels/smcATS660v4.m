function [val, rate] = smcATS660v4(ico, val, rate, varargin)
% val = smcATS660v2(ico, val, rate, varargin)
% ico(3) == 3 sets/gets  HW sample rate.  negative sets to external fast ac.
% ico(3) = 4 arm
% ico(3) = 5 configures. val = record length,
% 4th argument specifies number of readout operations per trigger (can be inf)
global smdata;
maxbuf=256;
extrabuf=40;
extracap=4;
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
                    buf = libpointer('uint16Ptr', zeros(nsamp*downsamp+16, 1, 'uint16'));
                    % see p. 26 of ATS-SDK manual regarfding exrta 16 samples
                    while calllib('ATSApi', 'AlazarBusy', smdata.inst(ico(1)).data.handle); end
                    daqfn('Read',  smdata.inst(ico(1)).data.handle, ico(2), buf, 2, 1, 0, nsamp*downsamp);
                    if ~isempty(s.subs{1})
                        val = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                            (combine(subsref(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^15-1)';
                    else
                        val = smdata.inst(ico(1)).data.rng(ico(2)) * (combine(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), 1)./2^15-1)';
                    end
                else
                    val = zeros(nsamp*nrec, 1);
                    
                    for i = 0:nrec-1 % read # records/readout                        
                        buf=smdata.inst(ico(1)).data.buffers{mod(i,end)+1};    
                        try                          
                          daqfn('WaitAsyncBufferComplete', smdata.inst(ico(1)).data.handle, ...
                                buf, ...                                                
                               2*ceil(3000*nsamp*downsamp/smdata.inst(ico(1)).data.samprate)+500);
                        catch err;
                           fprintf('\nOn buffer %d/%d, %d total\n',i+1,nrec,length(smdata.inst(ico(1)).data.buffers));   
                           rethrow(err);
                        end
                        if ~isempty(s.subs{1})
                            val((1+i*nsamp):(i*nsamp+nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                (combine(subsref(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^15-1)';
                        else
                            val(i*nsamp+(1:nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                                (combine(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), 1)./2^15-1);
                        end
                        if (nrec-i) > length(smdata.inst(ico(1)).data.buffers)
                          daqfn('PostAsyncBuffer',smdata.inst(ico(1)).data.handle, buf, nsamp*downsamp*2);
                        end
                    end                      
                end
                daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);                
%                pause(.1);
            case 3
                val = smdata.inst(ico(1)).data.samprate;        
        end
    case 1
        switch ico(2)
            case 3
                setclock(ico, val);                                 
        end

    case 3
        daqfn('ForceTrigger', smdata.inst(ico(1)).data.handle);

    case 4
        nrec = smdata.inst(ico(1)).data.nrec;
        if nrec(1) == 0
            daqfn('StartCapture', smdata.inst(ico(1)).data.handle);
        else                      
            daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);
            nsamp = smdata.inst(ico(1)).datadim(ico(2), 1) * smdata.inst(ico(1)).data.downsamp/nrec(1);
            % 0 (0x0) = ADMA_TRADITIONAL_MODE
            % 256 (0x100) = ADMA_CONTINUOUS_MODE
            % 32 (0x20) = ADMA_ALLOC_BUFFERS
            % 1024 = 0x400 = ADMA_TRIGGERED_STREAMING            
            daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, ico(2), 0, ...
                nsamp, 1, nrec(min(2, end))+extracap, 1024);% uses total # records
            %            daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, ico(2), 0, ...
            %                nsamp, 1, 2147483647, 1024+1);% uses total # records
            for i=1:length(smdata.inst(ico(1)).data.buffers) % Number of buffers to use in acquisiton;
                daqfn('PostAsyncBuffer', smdata.inst(ico(1)).data.handle, smdata.inst(ico(1)).data.buffers{i}, nsamp*2);
            end
            daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, ico(2), 0, ...
                nsamp, 1, nrec(min(2, end))+extracap, 1024);% uses total # records
            
            daqfn('StartCapture', smdata.inst(ico(1)).data.handle);         
            daqfn_ne('WaitAsyncBufferComplete', smdata.inst(ico(1)).data.handle, smdata.inst(ico(1)).data.buffers{1},1);
            %pause(50e-3);
        end
        
    case 5
        % for future development: only add channel if no further arguments given        
        if nargin < 2
            smdata.inst(ico(1)).data.chan = ico(2);
            return;
        end
        
        smdata.inst(ico(1)).data.chan = ico(2);
        
        daqfn('AbortAsyncRead', smdata.inst(ico(1)).data.handle);
        daqfn('SetRecordCount', smdata.inst(ico(1)).data.handle, 1)

        rngtab = [.2 .4 .8, 2, 5, 8, 16
            6, 7, 9,11,12,14, 18];
        for ch = 1:2
            [m, rng] = min(abs(rngtab(1, :) - smdata.inst(ico(1)).data.rng(ch)));
            daqfn('InputControl', smdata.inst(ico(1)).data.handle, ch, 2, rngtab(2, rng), ...
                2-logical(smdata.inst(ico(1)).data.highZ(ch)));
            smdata.inst(ico(1)).data.rng(ch) = rngtab(1, rng);
        end

        if smdata.inst(ico(1)).data.samprate >0
            downsamp = floor(smdata.inst(ico(1)).data.samprate/rate);
            rate = smdata.inst(ico(1)).data.samprate;
            if downsamp == 0
                error(sprintf('Sample rate too large.'));
            end
        else
            downsamp = 1;
        end

        rate=setclock(ico,rate)/downsamp;
        
        % make sure #points per record is divisible by 16 and downsampling factor.
        %nrec = ceil(val*downsamp/2^23);
        %2^23 is number of samples that fit in memory.
        %2^20 gives ~1 Mbyte buffers.
        % (23 in eqn below).
        nrec = max(1, 2^(ceil(log2(val*downsamp))-22));        
        if nrec > 1 || nargin >= 4
            dsf = 2^max(0, 4-sum(factor(downsamp)==2)); % factors of 2 missing in dowsamp towards 16
            npt = ceil(val/(dsf * nrec))*dsf; %# samples/record after downsampling            
            val = npt*nrec; % should be an int, but avoid rounding errors
%            fprintf('Buffers have %d million points\n',val*downsamp/(1e6*nrec(1)));
            npt = npt*downsamp;
            
            if npt < 128
                error('Record size must be larger than 128');
            end            
            smdata.inst(ico(1)).data.buffers={};
            for i=1:min(nrec*2+extrabuf,maxbuf) % Number of buffers to use in acquisiton; 
              nsamp=val*downsamp/nrec(1);
              smdata.inst(ico(1)).data.buffers{i}=libpointer('uint16Ptr', zeros(nsamp+16, 1, 'uint16'));              
            end 
             
        else
            nrec = 0;
            npt = max(ceil(val*downsamp/16)*16, 128);
        end

        daqfn('SetRecordSize', smdata.inst(ico(1)).data.handle, 0, npt);
        smdata.inst(ico(1)).datadim(1:2) = val;

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
if smdata.inst(ico(1)).data.extclk == 0
    smdata.inst(ico(1)).data.samprate = max(min(val, 130e6), 0);
    rate = val/1e6;
    dec = floor(130/rate);
    rby=1;
    rate = max(min(130, round(rate * dec/rby)*rby))*1e6;
    daqfn('SetCaptureClock', smdata.inst(ico(1)).data.handle, 7, rate, 0, dec-1); % external
    smdata.inst(ico(1)).data.samprate=rate/dec;
    rate=rate/dec;
else
    smdata.inst(ico(1)).data.samprate=val;
    daqfn('SetCaptureClock', smdata.inst(ico(1)).data.handle, 2 , 64, 0, 0);
    rate=val;
end
end

function varargout = daqfn_ne(fn, varargin)

% (c) 2010 Hendrik Bluhm.  Please see LICENSE and COPYRIGHT information in plssetup.m.

%fprintf('Calling %s\n',fn);
[varargout{1:nargout}] = calllib('ATSApi', ['Alazar', fn], varargin{:});

end
