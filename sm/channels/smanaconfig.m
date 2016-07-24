function scan = smanaconfig(scan,opts)
% scan = smanaconfig(scan); 
% This takes in a human readable scan : with the rng and npoints
% corresponding to start and stop frequencies and number of points, and
% changes into sm-readable scan. 
% NA can only take 1600 points per sweep, so if you want more than that,
% first loop runs multiple sweeps. Outer loop must be used to sweep another
% physical parameter. 
% Consts are set before configfn are run, so can either put NApoitns in
% const, or just set before scan. 
% Figure out the correct number of points per line. 
% Set it in the instrument and datadim. 
% Create the prefn. 
% Set up the procfn (not using)
% possible opts: int, to use continuous internal trigger. 
global smdata 
naLimPoints = 1600; 
npoints = scan.loops(1).npoints;
if npoints > naLimPoints;
    ncount = ceil(npoints / cell2mat(smget('NApoints')) ); %Number of lines it takes to get 1 dataset, due to limitations of NA
    NApoints = round(scan.loops(1).npoints / ncount); %Try to get as close to correct number as possible.
    totpoints = NApoints * ncount;
    smset('NApoints',NApoints);
else
    ncount = 1; 
    NApoints = npoints;  
    totpoints = NApoints; 
    smset('NApoints',npoints);
end
%The prefn will take two arguments: The start values and stop values, and
%set those.  
if ncount > 1
    measWidth = (scan.loops(1).rng(2)-scan.loops(1).rng(1))/(totpoints -1); 
    startVals = scan.loops(1).rng(1) + measWidth * (NApoints-1)*(0:(ncount-1)); 
    stopVals = [startVals(2:end)-measWidth scan.loops(1).rng(2)]; 
else
     startVals = scan.loops(1).rng(1); 
     stopVals = scan.loops(1).rng(2); 
end
if length(scan.loops)>1 
    if isempty(scan.loops(2).getchan) 
        scan.loops(2).getchan = 'count'; 
    end
    scan.loops(2).datafn.fn = plot_na_data; 
    scan.loops(2).datafn.args = {scan.loops(1).rng};
end

inst = sminstlookup('E5071c');
scan.loops(1).prefn.fn = @smanatrig; 
scan.loops(1).prefn.args{1}=startVals; 
scan.loops(1).prefn.args{2}=stopVals; 
scan.loops(1).prefn.args{3} = inst; 
scan.loops(1).prefn.args{4} = opts; 
%Now, rewrite the first loop of the scan to run the multiple NA sweeps. 
if ncount > 1
    scan.loops(1).rng = [1 ncount];
    scan.loops(1).npoints = ncount;
    scan.loops(1).setchan = 'count';
else
    
end

%probably a waste of time to use. 
% Now, set up the procfn. %Need to have NA sweep in the first loop
%Currently assuming all getchans are buffered. 
if ischar(scan.loops(1).getchan)
    scan.loops(1).getchan = {scan.loops(1).getchan};
end


% for i = 1:length(scan.loops)
%     ngetchans(i) = length(scan.loops(i).getchan); %#ok<*AGROW>
% end
%totgetchans = sum(ngetchans);
% if ncount == 1 && length(scan.loops) == 2
%     scan.loops(1).npoints = scan.loops(2).npoints;
%     scan.loops(1).rng = scan.loops(2).rng;
%     scan.loops(1).setchan = scan.loops(2).setchan;
%     scan.loops(2) = [];
% end

if 0 %ncount > 1 % Not working yet. 
    procfn(1).fn.fn = [];
    for i = 1:length(ngetchans)
        procfn(i+totgetchans).dim = 1; %just needs to not be empty
        procfn(i+totgetchans).fn.fn = @proc_reshape;
        procfn(i+totgetchans).fn.args = {};
        procfn(i+totgetchans).fn.indata = i+ngetchans;
        procfn(i+totgetchans).fn.outdata = i+ngetchans;
        procfn(i+totgetchans).fn.inchan = 1;
        procfn(i+totgetchans).fn.outchan = 1;
    end
    
    scan.loops(1).procfn = procfn;
end


end