function val = smalintrafo(x, xcoeff, xref, fixch, fixcoeff, fixref, const)

global smdata;
val = (x-xref) * xcoeff + (smdata.chanvals(fixch) - fixref) * fixcoeff + const;