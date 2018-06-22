function scan = smanaconfigS(scan,freqRng,npoints,opts)
% scan = smanaconfigS(scan,freqRng,npoints,opts) 
% Used for a scan with <= 1600 points. Goes with smanatrig
% possible opts: trig
naLimPoints = 1600; 
if npoints > naLimPoints
    fprintf('Use fewer points \n') 
    npoints = naLimPoints; 
end
smset('NApoints',npoints);
smset('NAstartFreq',freqRng(1)); 
smset('NAstopFreq',freqRng(2)); 
inst = sminstlookup('E5071c'); 

if exist('opts','var') && isopt(opts,'trig')
    scan.loops(1).prefn.fn = @smanatrig;
    scan.loops(1).prefn.args{1} = inst;
end
end