function val = smcLinearCombination(ic, val, rate)
% allows a linear combination of two channels to be controlled in a
% consistent manner.
%
% smdata.inst(ic(1)).data.channelsin contains channels being combined
% smdata.inst(ic(1)).data.tmat contains transformation matrix that
% determines how the output channels are constructed from the input
% channels


global smdata;

T = smdata.inst(ic(1)).data.tmat;

physicalvals = cell2mat(smget(smdata.inst(ic(1)).data.channelsin)); % get physical channel values
logicalvals = T*physicalvals'; %logical channel values
    
switch ic(3); % OPERATION TO PERFORM
    case 1 % SET
        logicalvals(ic(2)) = val; % update the value of the channel being changed
        newphysicalvals = T\logicalvals;
        smset(smdata.inst(ic(1)).data.channelsin,newphysicalvals',rate*ones(1,length(newphysicalvals)));
        val = 0;      
            
    case 0 % GET
        val = logicalvals(ic(2)); % return the requested value        

          
    otherwise
        error('Operation not supported');
end

