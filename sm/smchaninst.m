function ic = smchaninst(chan)
% ic = smchaninst(chan)
% get instrument and instrument channel index for channel chan.
% use smprintchannels to display information.

global smdata;

chan = smchanlookup(chan);
ic = vertcat(smdata.channels(chan).instchan);
