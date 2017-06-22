function val = smcLabBrick2(ico, val,~)
global smdata;
handle = smdata.inst(ico(1)).data.handle;
switch ico(3)
    case 0
        switch ico(2)
            case 1
                % freq specified in 100kHZ increments.
                freq = brickfn('GetFrequency',handle);
                val = freq * 1e5;
            case 2
                % power encoded in 0.25 dB increments, with 0 = 0.
                pow = brickfn('GetPowerLevelAbs',handle);
                val = pow/4;
        end
    case 1
        switch ico(2)
            case 1
                % freq specified in 100kHZ increments.
                val = round(val / 1e5);
                brickfn('SetFrequency',handle,val);
            case 2
                % power encoded in 0.25 dB increments, with 0 = 0.
                val = round(val*4);
                brickfn('SetPowerLevel',handle,val);
        end
end
end