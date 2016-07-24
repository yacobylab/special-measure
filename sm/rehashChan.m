function rehashChan(opts)
% function rehashChan(opts)
% Connect channels to instruments using strings instead of numbers, so that
% if smdata reordered, no problems occur. 
% inst name stored in smdata.channels(i).inst. 
% to initialize and save inst names, call with 'init'
% to redo all the isntchans after moving / deleting insts, call with
% 'rehash'
global smdata

if ~exist('opts','var') || isempty(opts) || isopt(opts,'rehash')
    for i = 1:length(smdata.channels)
        inst = sminstlookup(smdata.channels(i).inst);
        smdata.channels(i).instchan(1) = inst;
    end
elseif isopt(opts,'init')
    for i = 1:length(smdata.channels)
        inst = smdata.channels(i).instchan(1);
        smdata.channels(i).inst = smdata.inst(inst).name;
    end
else
    error('This is not a valid option \n');
end

end