function smrange(chans,rangeVal,rangeInds)
% function smrange(chans,rangeVal,rangeInds)

global smdata; 
chans = smchanlookup(chans); 

if length(rangeVal)~=length(rangeInds) 
    warning('Incorrect number of ranges. Change rangeInds')
    return 
end
rangeramps = {'Min Val','Max Val','Ramprate','Divider'};
    
for i = 1:length(chans) 
    if ~smdata.quiet
        fprintf('Changing %s for %s to %3.3f \n',rangeramps{rangeInds},smdata.channels(chans(i)).name,rangeVal);
    end
    smdata.channels(chans(i)).rangeramp(rangeInds) = rangeVal; 
end

end