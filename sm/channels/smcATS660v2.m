function [val, rate] = smcATS660v2(ico, val, rate, varargin)
% val = smcATS660v2(ico, val, rate, varargin)
% ico(3) == 3 sets/gets  HW sample rate.
% ico(3) = 4 arm
% ico(3) = 5 configures. val = record length,
% ico(3) = 6 sets mask.
% 4th argument specifies number of readout operations per trigger (can be inf)
global smdata;

    
   
switch ico(3)    
    case 0
        switch ico(2)
            case {1, 2}

                downsamp = smdata.inst(ico(1)).data.downsamp;
                nrec = smdata.inst(ico(1)).data.nrec(1);
                nsamp = smdata.inst(ico(1)).datadim(ico(2), 1)/max(1, nrec);

                s.type = '()';
                if isfield(smdata.inst(ico(1)).data, 'mask') && ~isempty(smdata.inst(ico(1)).data.mask)
                    if size(smdata.inst(ico(1)).data.mask,1) > ico(2)
                      s.subs = {smdata.inst(ico(1)).data.mask(ico(2),:), ':'};
                    else
                      s.subs = {smdata.inst(ico(1)).data.mask, ':'};
                    end
                else
                    s.subs = {':', ':'};
                end
                buf = libpointer('uint16Ptr', zeros(nsamp*downsamp+16, 1, 'uint16'));
                if nrec(1) == 0
                    while calllib('ATSApi', 'AlazarBusy', smdata.inst(ico(1)).data.handle); end

                    daqfn('Read',  smdata.inst(ico(1)).data.handle, ico(2), buf, 2, 1, 0, nsamp*downsamp);
                    %val = smdata.inst(ico(1)).data.rng(ico(2)) * (mean(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), 1)./2^15-1)';
                    val = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                        (mean(subsref(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^15-1)';
                else
                    val = zeros(nsamp*nrec, 1);
                    for i = 0:nrec-1 % read # records/readout
                        daqfn('WaitNextAsyncBufferComplete', smdata.inst(ico(1)).data.handle, buf, 2*nsamp*downsamp+32, ...
                            ceil(3000*nsamp*downsamp/smdata.inst(ico(1)).data.samprate));
                        %val(i*nsamp+(1:nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                        %    (mean(reshape(buf.value(1:end-16), downsamp, nsamp), 1)./2^15-1);
                        val(i*nsamp+(1:nsamp)) = smdata.inst(ico(1)).data.rng(ico(2)) * ...
                            (mean(subsref(reshape(buf.value(1:downsamp*nsamp), downsamp, nsamp), s), 1)./2^15-1)';
                    end
                end
                
            case 3
                val = smdata.inst(ico(1)).data.samprate;        
        end
    case 1
        switch ico(2)
            case 3
                smdata.inst(ico(1)).data.samprate = max(min(val, 130e6), 0);
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
            daqfn('BeforeAsyncRead',  smdata.inst(ico(1)).data.handle, ico(2), 0, ...
                nsamp, 1, nrec(min(2, end))+1, 256+1024+32);% uses total # recors
        end
        
    case 5

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
                error('Sample rate too large.')
            end
        else
            downsamp = 1;
        end

        rate = rate/1e6;
        dec = floor(130/rate);
        rate = max(min(130, round(rate * dec)))*1e6;
        daqfn('SetCaptureClock', smdata.inst(ico(1)).data.handle, 7, rate, 0, dec-1); % external
        rate = rate/(dec * downsamp);

        % make sure #points per record is divisible by 16 and downsampling factor.
        %nrec = ceil(val*downsamp/2^23);
        nrec = max(1, 2^(ceil(log2(val*downsamp))-23));
        if nrec > 1 || nargin >= 4
            dsf = 2^max(0, 4-sum(factor(downsamp)==2)); % factors of 2 missing in dowsamp towards 16
            npt = ceil(val/(dsf * nrec))*dsf; %# samples/record after downsampling
            val = npt*nrec; % should be an int, but avoid rounding errors
            npt = npt*downsamp;
            
            if npt < 128
                error('Record size must be larger than 128');
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