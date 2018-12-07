function val = smcNI7841Rlockin(ic, val, rate)
% Driver for FPGA lockin running on NI7841R board.  Required auxiliary
% files are located in folder fpga_lockin, and Labview must be installed
% for driver to work.  Available channels:
% 1) X [get]
% 2) Y [get]
% 3) R [get]
% 4) THETA [get]
% 5) TAU [set,get]
% 6) VREF [set,get]
% 7) FREQ [set,get]
% 8) PHASE [set,get]
%
% smdata.inst(#).name='FPGAlockin';
% smdata.inst(#).device='Lockin NUM';
% smdata.inst(#).cntrlfn=@smcNI7841Rlockin;
% smdata.inst(#).channels=strvcat('X','Y','R','TAU','VREF','FREQ','PHASE');
% smdata.inst(#).type=zeros(7,1);
% smdata.inst(#).datadim=zeros(7,0);
% smdata.inst(#).data.lockin_number=NUM;


% cmds = {'X',... %[get]
%         'Y',... %[get]
%         'R',... %[get]
%         'THETA',... %[get]
%         'TAU',... % [set, get]
%         'VREF',... % [set, get]
%         'PHASE'}% [set, get]


global smdata;

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


lockin_number = smdata.inst(ic(1)).data.lockin_number;


switch ic(2) % Channel
    case 1 % X [get]
        switch ic(3) % action
            case 1 % set
                error('set not supported for this channel');
            case 0 % get
                control_sigamp = 33106 - lockin_number*4;
                sigamp = double(lia_readU16(control_sigamp));
                control_c = 33072 - lockin_number*4;
                val = double(lia_readI32(control_c))*(2^(-15))*20/sigamp;
            otherwise
                error('Operation not supported');
        end
    case 2 % 2) Y [get]
        switch ic(3) % action
            case 1 % set
                error('set not supported for this channel');
            case 0 % get
                control_sigamp = 33106 - lockin_number*4;
                sigamp = double(lia_readU16(control_sigamp));
                control_c = 33056 - lockin_number*4;
                val = double(lia_readI32(control_c))*(2^(-15))*20/sigamp;
            otherwise
                error('Operation not supported');
        end
    case 3 % 3) R [get]
        switch ic(3) % action
            case 1 % set
                error('set not supported for this channel');
            case 0 % get
                control_sigamp = 33106 - lockin_number*4;
                sigamp = double(lia_readU16(control_sigamp));
                control_x = 33072 - lockin_number*4;
                x = double(lia_readI32(control_x))*(2^(-15))*20/sigamp;
                control_y = 33056 - lockin_number*4;
                y = double(lia_readI32(control_y))*(2^(-15))*20/sigamp;
                val = sqrt(x^2 + y^2);
            otherwise
                error('Operation not supported');
        end
    case 4 % 4) THETA [get]
        switch ic(3) % action
            case 1 % set
                error('set not supported for this channel');
            case 0 % get
                control_sigamp = 33106 - lockin_number*4;
                sigamp = double(lia_readU16(control_sigamp));
                control_x = 33072 - lockin_number*4;
                x = double(lia_readI32(control_x))*(2^(-15))*20/sigamp;
                control_y = 33056 - lockin_number*4;
                y = double(lia_readI32(control_y))*(2^(-15))*20/sigamp;
                val = atand(y/x);
            otherwise
                error('Operation not supported');
        end
    case 5 % 5) TAU [set, get]
    case 6 % 6) VREF [set, get]
    case 7 % 7) PHASE [set,get] (phase of input signal)

end