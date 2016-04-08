function rehashChan(opts)
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