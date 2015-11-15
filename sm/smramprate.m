function isgood = checkramprate(scan)
global smdata; 
setchans = scan.loops(1).setchan; 
if ischar(setchans) 
    setchans = {setchans}; 
end

channels = smchanlookup(setchans);
rate = max(abs(diff(scan.loops(1).rng)))./abs(scan.loops(1).ramptime)/scan.loops(1).npoints; toofast = 0;
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

end