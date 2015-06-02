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

physicalvals = cell2mat(smget(smdata.inst(ic(1)).data.channels)); % get physical channel values
logicalvals = T*physicalvals'; %logical channel values
    
switch ic(3); % OPERATION TO PERFORM
    case 1 % SET
        logicalvals(ic(2)) = val; % update the value of the channel being changed
        newphysicalvals = T\logicalvals;
        
        %Calculate change in physical channel values
        deltaphysicalvals = newphysicalvals - physicalvals';
        %Calculate the maximum change in physical channel value and the
        %corresponding index
        [maxval, maxindex]=max(abs(deltaphysicalvals));
        %Set the ramp rate according to actual required change in physical
        %channel value:
        %First set all to the desired rate, then slow down all other ramp 
        %rates so that all physical channels take the same time to ramp.
        speed=rate*ones(1,length(deltaphysicalvals));
        for i=1:length(deltaphysicalvals)
            speed(i)=abs(speed(i)*deltaphysicalvals(i)/deltaphysicalvals(maxindex));
            %Make sure not to ramp at zero rate.
            if speed(i) == 0;
                speed(i) = 0.0001;
            end
        end
        
        smset(smdata.inst(ic(1)).data.channels,newphysicalvals',speed);
        val = 0;      
            
    case 0 % GET
        val = logicalvals(ic(2)); % return the requested value        

          
    otherwise
        error('Operation not supported');
end

