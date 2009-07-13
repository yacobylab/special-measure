function smatrigfn(inst)
% smatrigfn(inst)
% inst is a n x 2 matrix containing an instrument and channel index
% for a channel to be triggered in each row.

global smdata;

for i = 1:size(inst, 1)
    smdata.inst(inst(i, 1)).cntrlfn([inst(i, :), 3]);
end

