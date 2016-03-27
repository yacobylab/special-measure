function smamovechannels(oldchan,newchan) 
% Put oldchan in newchan position.  
global smdata; 
dummychan = smdata.channels; 
newchanlist = smdata.channels; 
if length(oldchan)==1
    if newchan > oldchan
        newchanlist(newchan) = dummychan(oldchan);
        newchanlist(oldchan:newchan-1)=dummychan(oldchan+1:newchan);
    else
        newchanlist(newchan) = dummychan(oldchan);
        newchanlist(newchan+1:oldchan) = dummychan(newchan:oldchan-1);
    end
    smdata.channels = newchanlist;
else
    if length(newchan)==1
        nchans = length(oldchan); 
        if newchan > oldchan(1)
            newchanlist(newchan:newchan+nchans-1) = dummychan(oldchan);
            newchanlist(oldchan(1):newchan-1)=dummychan(oldchan(end)+1:newchan+nchans-1);
        else
            newchanlist(newchan:newchan+nchans-1) = dummychan(oldchan);
            newchanlist(newchan+nchans:oldchan(end)) = dummychan(newchan:oldchan(1)-1);
        end
        smdata.channels = newchanlist;
    end
end

end