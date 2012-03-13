clear scanLock;

scanLock.loops(1).setchan = 'Vgate1';
scanLock.loops(1).getchan = 'Vlockin';
scanLock.loops(1).rng = rng1;
scanLock.loops(1).npoints = npts(1);
scanLock.loops(1).ramptime = .01;

scanLock.loops(2).setchan = 'Vgate2';
scanLock.loops(2).npoints = npts(2);

scanLock.disp(1).loop = 1;
scanLock.disp(1).channel = 1;
scanLock.disp(1).dim = 1;

scanLock.disp(2).loop = 1;
scanLock.disp(2).channel = 1;
scanLock.disp(2).dim = 2;
