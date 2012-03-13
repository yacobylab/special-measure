% make a scan of the dummy device
clear scan;

scan.loops(1).setchan = 'dummy';
scan.loops(1).getchan = 'dummy';
scan.loops(1).rng = [0, 2];
scan.loops(1).npoints = 50;
scan.loops(1).ramptime = .01;

scan.loops(2).setchan = 'count';
scan.loops(2).npoints = 10;

scan.disp(1).loop = 1;
scan.disp(1).channel = 1;
scan.disp(1).dim = 1;

scan.disp(2).loop = 1;
scan.disp(2).channel = 1;
scan.disp(2).dim = 2;


% optional: inspect the scan
smprintscan(scan);

%% scan of Lockin input vs two control voltages
% It is useful to only define parameters in the front end file and to call
% a script to so the work.

npts = [50, 20];
rng1 = [0, 1];
rng2 = [0, 2.5];

confLockin;
