function val = smcATS660(ico, val, rate)

global smdata;
switch ico(3)    
    case 0
        while calllib('ATSApi', 'AlazarBusy', smdata.inst(ico(1)).data.handle); end
        %pause(.0)
        nsamp = smdata.inst(ico(1)).datadim(ico(2), 1);
        downsamp = smdata.inst(ico(1)).data.downsamp;
        buf = uint16(zeros(nsamp*downsamp+16, 1));
        [board, buf] = daqfn('Read',  smdata.inst(ico(1)).data.handle, ico(2), buf, 2, 1, 0, nsamp*downsamp);
       
        val = smdata.inst(ico(1)).data.rng(ico(2)) * (mean(reshape(buf(1:end-16), downsamp, nsamp), 1)./2^15-1)';

    case 3
        daqfn('StartCapture', smdata.inst(ico(1)).data.handle);
        daqfn('ForceTrigger', smdata.inst(ico(1)).data.handle);

    otherwise
        error('Operation not supported.');
end