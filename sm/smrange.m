function smrange(chans,rangeInds,rangeVal)
% function smrange(chans,rangeVal,rangeInds)

global smdata; 
chans = smchanlookup(chans); 


rangeramps = {'Min Val','Max Val','Ramprate','Divider'};
rangeShort = {'min','max','rate','div'};
if ischar(rangeInds) 
    rangeInds=find(strcmp(rangeShort,rangeInds));
    if isempty(rangeInds) 
        error('Rangeramp not found')
    end
end

if length(rangeVal)~=length(rangeInds) 
    warning('Incorrect number of ranges. Change rangeInds')
    return 
end
for i = 1:length(chans) 
    if ~smdata.quiet
        fprintf('Changing %s for %s to %3.3f \n',rangeramps{rangeInds},smdata.channels(chans(i)).name,rangeVal);
    end
    smdata.channels(chans(i)).rangeramp(rangeInds) = rangeVal; 
end

end