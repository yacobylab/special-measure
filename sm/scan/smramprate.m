function [isgood,rng,rate] = smramprate(scan,opts)
% [isgood,rng,rate] = smramprate(scan,opts)
if ~exist('opts','var'), opts = ''; end
global smdata; 
setchans = scan.loops(1).setchan; 
if ischar(setchans), setchans = {setchans}; end

channels = smchanlookup(setchans);
diffPoint = diff(scan.loops(1).rng)/scan.loops(1).npoints;
rate = abs(diffPoint)./abs(scan.loops(1).ramptime); toofast = 0;
if isopt(opts,'save') && isfield(scan,'data') && isfield(scan.data,'rangeramp')     
    maxRate = scan.data.rangeramp; 
else
    maxRate = smdata.channels(channels(1)).rangeramp(3);
end
for i=1:length(channels)
    if rate > maxRate
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
        %fprintf('Ramping too fast and may get wrong data \n')
        isgood = 0;
    end
end

if ~isgood 
    rescale = rate / smdata.channels(channels(1)).rangeramp(3);
    diffPoint = diffPoint / rescale; 
    rng = scan.loops(1).rng(1)+[0, (scan.loops(1).npoints-1)*diffPoint];
else 
    rng = scan.loops(1).rng; 
end