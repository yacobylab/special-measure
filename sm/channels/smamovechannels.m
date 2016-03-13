function smamovechannels(oldchan,newchan) 
% Put oldchan in newchan position.  
global smdata; 
dummychan = smdata.channels; 
newchanlist = smdata.channels; 

if newchan > oldchan 
    newchanlist(newchan) = dummychan(oldchan); 
    newchanlist(oldchan:newchan-1)=dummychan(oldchan+1:newchan);
else
    newchanlist(newchan) = dummychan(oldchan);         
    newchanlist(newchan+1:oldchan) = dummychan(newchan:oldchan-1);    
end
smdata.channels = newchanlist; 

end