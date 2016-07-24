function chanList = findChans(chan,num,inst)
% chanList = findChans(chan,num)
% Find all channels in rack associated with instrument / channel. 
% If number given, just find channel with given number of that instrument. 
% If no chan given, 
global smdata
if ~isempty(chan) && isempty(num) 
    ic = inst; 
else
    ic = smchaninst(chan); 
end

chanList = [];
if ~isempty(num)
    for i = 1:length(smdata.channels)
        if all(smdata.channels(i).instchan == [ic(1) num]);
            chanList = [chanList, i];
        end
    end
else
    for i = 1:length(smdata.channels)
        if smdata.channels(i).instchan(1) == ic(1)
            chanList = [chanList, i];
        end
    end
end
if isempty(chanList) 
    fprintf('Channel not found \n'); 
end
end