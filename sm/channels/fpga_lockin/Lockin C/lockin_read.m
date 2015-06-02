function value = lockin_read(lockin,control)

if exist('lia_writeU16') ~= 3
    mex lia_writeU16.c
end
if exist('lia_writeU32') ~= 3
    mex lia_writeU32.c
end
if exist('lia_writeI32') ~= 3
    mex lia_writeI32.c
end
if exist('lia_readU16') ~= 3
    mex lia_readU16.c
end
if exist('lia_readU32') ~= 3
    mex lia_readU32.c
end
if exist('lia_readI32') ~= 3
    mex lia_readI32.c
end

switch upper(control)
    % Host indicators
    case {'TIME CONSTANT','TIME CONSTANT [S]','TAU'}
        control_c = 33088 - lockin*4;
        value = -(200000/(2*pi))*log(double(lia_readI32(control_c))/2147483647);
    case {'FILTER ROLLOFF'}
    case {'AMPLITUDE','AMPLITUDE [V]','VREF'}
        control_c = 33106 - lockin*4;
        value = double(lia_readU16(control_c))*(10/32768);
    case {'GLOBAL PHASE','GLOBAL PHASE [DEG]'}
        control_c = 33120 - lockin*4;
        value = 360*double(lia_readU32(control_c))/(2^32);
    case {'FREQUENCY','FREQUENCY [HZ]','FREQ'}
        looprate = 40000000/double(lia_readU32(33136));
        if lockin>1
            control_c = 33136 - lockin*4;
        else
            control_c = 33036;
        end
        value = looprate*double(lia_readU32(control_c));
    case {'UPDATE FREQ','UPDATE FREQ [HZ]'}
        value = 40000000/double(lia_readU32(33136));
    case {'X','X [V]'}
        control_sigamp = 33106 - lockin*4;
        sigamp = double(lia_readU16(control_sigamp));
        control_c = 33072 - lockin*4;
        value = double(lia_readI32(control_c))*(2^(-15))*20/sigamp;
    case {'Y','Y [V]'}
        control_sigamp = 33106 - lockin*4;
        sigamp = double(lia_readU16(control_sigamp));
        control_c = 33056 - lockin*4;
        value = double(lia_readI32(control_c))*(2^(-15))*20/sigamp;
    case {'R','R [V]'}
        control_sigamp = 33106 - lockin*4;
        sigamp = double(lia_readU16(control_sigamp));
        control_x = 33072 - lockin*4;
        x = double(lia_readI32(control_x))*(2^(-15))*20/sigamp;
        control_y = 33056 - lockin*4;
        y = double(lia_readI32(control_y))*(2^(-15))*20/sigamp;
        value = sqrt(x^2 + y^2);
    case {'THETA','THETA [V]'}
        control_sigamp = 33106 - lockin*4;
        sigamp = double(lia_readU16(control_sigamp));
        control_x = 33072 - lockin*4;
        x = double(lia_readI32(control_x))*(2^(-15))*20/sigamp;
        control_y = 33056 - lockin*4;
        y = double(lia_readI32(control_y))*(2^(-15))*20/sigamp;
        value = atand(y/x);
    case {'DATA RATE','DATA RATE [HZ]'}
        error('Assumed to be 200 kHz.  Check FPGA/get in Labview.');
    
    % FPGA indicators
    case {'UPDATE RATE','UPDATE RATE (TICKS)'}
        control_c = 33136;
        value = lia_readU32(control_c);
    case {'ACCUMULATOR INCREMENT'}
        if lockin>1
            control_c = 33136 - lockin*4;
        else
            control_c = 33036;
        end
        value = lia_readU32(control_c);
    case {'PHASE SHIFT'}
        control_c = 33120 - lockin*4;
        value = lia_readU32(control_c);
    case {'SIGNAL AMPLITUDE'}
        control_c = 33106 - lockin*4;
        value = lia_readU16(control_c);
    case{'BETA'}
        control_c = 33088 - lockin*4;
        value = lia_readI32(control_c);
    case{'X_FPGA'}
        control_c = 33072 - lockin*4;
        value = lia_readI32(control_c);
    case{'Y_FPGA'}
        control_c = 33056 - lockin*4;
        value = lia_readI32(control_c);
    otherwise
        error('Must provide existing control.');
end