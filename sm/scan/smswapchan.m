function smswapchan(chan1,chan2) 

global smdata 
smdata.channels(chl(chan1)).name = 'tmp'; 
smdata.channels(chl(chan2)).name = chan1; 
smdata.channels(chl('tmp')).name = chan2; 
end