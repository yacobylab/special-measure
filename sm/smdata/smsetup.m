% This file is an example for how to create a special measure configuration from scratch.

cd ../instruments/ % assumes starting from config directory where this file lives.

% load empty 
global smdata;
load smdata_empty;

smloadinst('test') % dummy instrument without hardware attached

% add channels
smaddchannel('test', 'CH1', 'dummy');
smaddchannel('test', 'CH2', 'count');

if 0 % only useful if SR830 connected to computer
    ind = smloadinst('SR830', [], 'ni', 0, 23); % SR830 on NI GPIB card 0, address 23.
    smopen(ind); %open GPIB communication

    %smloadinst is not fully developed. Have a look at the code if this simple
    %load does not work. If you don't find a sminst_* file for your instrument,
    %you have to configure the instrument manually and possibly write a driver. 
    
    smaddchannel('SR830', 'X', 'Vlockin');
    smaddchannel('SR830', 'OUT1', 'Vgate1');
    smaddchannel('SR830', 'OUT2', 'Vgate2');
        
end



% save configuration for future use
cd mydatadir;
save mysmdata smdata  


% useful commands for inspecting configuration (not required)
smprintinst
smprintinst(1)
smprintchannels

