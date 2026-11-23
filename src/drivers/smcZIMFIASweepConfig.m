function scan = smcZIMFIASweepConfig(scan)
%SMCZIMFIASWEEPCONFIG  Configure a scan struct for an MFIA buffered bias sweep.
%   SCAN = SMCZIMFIASWEEPCONFIG(SCAN) prepares a 2-loop smdata SCAN so the
%   inner loop runs as a hardware DC-bias sweep on the MFIA sweeper module
%   (see smcZIMFIA channel 7), and the returned [param0 param1] buffer is split
%   back into two channels.
%
%   It modifies SCAN (and smdata, for the sweep instrument found from
%   scan.loops(2).getchan) as follows:
%     - stores the sweep endpoints and point count in
%       smdata.inst(i).data.bstart/.bstop/.npts, plus .nsample and .omegas;
%     - clears scan.loops(1).trafofn;
%     - sets scan.loops(2).procfn so the concatenated [param0 param1] vector is
%       sliced (via subsref) into its first and second halves as two channels
%       of length npoints;
%     - duplicates scan.disp(1)/(2) into disp(3)/(4) on channel 2.
%
%   Input/Output:  SCAN - smdata scan struct, modified and returned.
%
%   See also SMCZIMFIA, SMCHANINST, SMRUN.

%todo: write a function to update smdata with bstart and bstop, referencing
%the scan. Save the function in Nichol Group/matlab/special meaure/channels


global smdata;

ico=smchaninst(scan.loops(2).getchan); % Get channel name
xypoints=scan.loops(1).npoints;

smdata.inst(ico(1)).data.bstart=scan.loops(1).rng(1);
smdata.inst(ico(1)).data.bstop=scan.loops(1).rng(2);
smdata.inst(ico(1)).data.npts=scan.loops(1).npoints;
smdata.inst(ico(1)).data.nsample=1;%10000;
smdata.inst(ico(1)).data.omegas=120; % unit in dB
%smdata.inst(ico(1)).data.Vtest=0.1; % unit in V %JMN: Let's use special
%measure for this.
scan.loops(1).trafofn=[];

% Try to figure out the bandwidth, tc
% smdata.inst(ico(1)).data.bw = 90;

% Get data back, sub-divide into two parts
scan.loops(2).procfn(1).fn(1).fn=[];
scan.loops(2).procfn(1).fn(1).args={};
scan.loops(2).procfn(1).fn(1).inchan=1;
scan.loops(2).procfn(1).fn(1).outchan=2;

scan.loops(2).procfn(1).fn(2).fn=@subsref;
s=struct(); s.type='()'; s.subs={(1:1:xypoints)};
scan.loops(2).procfn(1).fn(2).args={s};
scan.loops(2).procfn(1).dim=xypoints;

scan.loops(2).procfn(2).fn.fn=@subsref;
s=struct(); s.type='()'; s.subs={(xypoints+1:1:2*xypoints)};
scan.loops(2).procfn(2).fn.args={s};
scan.loops(2).procfn(2).dim=xypoints;

scan.disp(3)=scan.disp(1);
scan.disp(3).channel=2;
scan.disp(4)=scan.disp(2);
scan.disp(4).channel=2;

end

