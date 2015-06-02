function scan = smarampYokoLeCroy(scan)

global smdata;


tds = sminstlookup('LeCroy'); % assumes there is only one
yokos = smchaninst(scan.loops(1).setchan); % assumes no other ramped device

% coding and byte order
fprintf(smdata.inst(tds).data.inst, 'CFMT DEF9,BYTE,BIN;CORD LO;');


sp = floor(50002/scan.loops(end).npoints);
scan.loops(end).npoints = ceil(50002/sp);
fprintf(smdata.inst(tds).data.inst, 'WFSU SP, %d', sp);


fprintf(smdata.inst(tds).data.inst, 'TDIV %f', ...
    scan.loops(end).npoints *abs(scan.loops(1).ramptime) /10);

tdiv = query(smdata.inst(tds).data.inst, 'TDIV?', '%s\n', '%*4c %f %*c');

%if tdiv < % check for modifications of tdiv.

scan.loops(1).ramptime = -tdiv * 10 / scan.loops(end).npoints;

smdata.inst(tds).datadim(1:4, 1) = scan.loops(1).npoints;

scan.loops(1).trigfn.fn = @smatrigYokoLeCroy;
scan.loops(1).trigfn.args = {tds, yokos(:, 1)};


    