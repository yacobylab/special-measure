% This file is an example for how to reload a previously loaded configuration

global smdata;

cd mydatadir;
load mysmdata;

smopen; % open instruments (GPIB, serial, ...) for communication.
% can optionally specify which.

sminitdisp; % optionally initialise window displaying current values.
