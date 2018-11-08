function scan = smaAgilNAconfigSingle(scan,freqRng,npoints,opts)
% Configfn for Agilent/Keysight Network Analyzer scan w/ less points than
% instrument limit. 
% scan = smanaconfigSingle(scan,freqRng,npoints,opts) 
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
    scan.loops(1).prefn.fn = @smaAgilNAtrig;
    scan.loops(1).prefn.args{1} = inst;
end
end