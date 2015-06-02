function smatrigfn(inst, inst2, op)
% smatrigfn(inst, inst2, op)
% inst is a n x 2 matrix containing an instrument and channel index
% for a channel to be triggered in each row.
% If inst2 is specified, inst is ignorded.  (WHY? WTF Hendrik!)
% If op is not specified, it defaults to 3 (trigger)

global smdata;

if nargin < 3
    op = 3;
end
if nargin > 1
    inst = inst2;
end

for i = 1:size(inst, 1)
    smdata.inst(inst(i, 1)).cntrlfn([inst(i, :), op]);
end

