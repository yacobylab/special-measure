function smaAgilNAprefn(xt, startFreq, stopFreq,inst,opts)
% Used as prefn with network analyzer when getting more points than NA
% allows.
% smaAgilNAprefn(xt, startFreq, stopFreq,inst,opts)
% Changes the start and stop frequency before each data set
% collected. 
% By default, option 'trig' used to cause a software trigger to be sent. 
% With no option, internal trigger used. Will need to check that there is a wait for new data -- may need to add
% *OPC. Check this. 

smset('NAstartFreq', startFreq(xt(1)));
smset('NAstopFreq', stopFreq(xt(1)));
smaAgilNAtrig(xt,inst,{opts}); 

end