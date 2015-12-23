function [isgood,rng] = smramprate(scan)
global smdata; 
setchans = scan.loops(1).setchan; 
if ischar(setchans) 
    setchans = {setchans}; 
end

channels = smchanlookup(setchans);
diffPoint = diff(scan.loops(1).rng)/scan.loops(1).npoints;
rate = abs(diffPoint)./abs(scan.loops(1).ramptime); toofast = 0;
for i=1:length(channels)
    if rate > smdata.channels(channels(i)).rangeramp(3)
        toofast = toofast + 1; 
    end        
end

selframp = scan.loops(1).ramptime < 0; 

buff = 0; 
if isfield('configfn',scan) && isempty(scan.configfn) 
    for i = 1:length(scan.configfn)
        buff = buff + ~isempty(strfind(func2str(scan.configfn(i).fn)), 'smabufconfig2');        
    end
end

isgood = 1; 
if toofast 
    if buff || selframp 
        fprintf('Ramping too fast and may get wrong data \n')
        isgood = 0;
    end
end

if ~isgood 
    rescale = rate / smdata.channels(channels(1)).rangeramp(3);
    diffPoint = diffPoint / rescale; 
    rng = scan.loops(1).rng(1)+[0, (scan.loops(1).npoints-1)*diffPoint];
else 
    rng = NaN; 
end