function scan = smaAgilNAconfig(scan,opts)
% Configfn to make scan for Agilent/Keysight network analyzer with more
% points per line than instrument allows. 
% scan = smanaconfig(scan,opts);
% Network Analyzer can only take 1600 points per sweep, so if you want more than that, first loop runs multiple sweeps.
% To sweep another physical parameter, an outer loop must be used.
% This can be used for < 1600 points per loop, but smanaconfigSingle
% preferred. 
% Scan must have inner loop with npoints = total points per line, rng =
% min/max frequencies.  
% We will probably change this in future as it makes it annoying to reload
% scan. If you do that, original scan saved in scan.data. 
% Outline of function:
% - Figure out the correct number of points per line.
% - Set it in the instrument and datadim.
% - Create the prefn.
% - possible opts: int, to use continuous internal trigger.
% Assumes that network analyzer instrument called 'E5071c'

if ~exist('opts','var'), opts = ''; end
scan.data.scan = scan; % Save this with the scan so that it is easy to recreate when loading data.
naLimPoints = 1600;
npoints = scan.loops(1).npoints;
% Let's change this now to have args of Freqs, then points
if npoints > naLimPoints
    ncount = ceil(npoints / cell2mat(smget('NApoints')) ); % Number of lines it takes to get 1 dataset, due to limitations of NA
    NApoints = round(scan.loops(1).npoints / ncount); % Find number of points so that each line has equal number (may change total points slightly)
    totpoints = NApoints * ncount;
    smset('NApoints',NApoints); % This also changes datadim in inst
else
    ncount = 1;
    NApoints = npoints;
    totpoints = NApoints;
    smset('NApoints',npoints); % This also changes datadim in inst
end
%The prefn run before each line will reset the start and stop frequencies of the NA, so it uses the start and stop frequency for each line as arguments.
if ncount > 1
    measWidth = (scan.loops(1).rng(2)-scan.loops(1).rng(1))/(totpoints -1);
    startVals = scan.loops(1).rng(1) + measWidth * (NApoints-1)*(0:(ncount-1));
    stopVals = [startVals(2:end)-measWidth scan.loops(1).rng(2)];
else
    startVals = scan.loops(1).rng(1);
    stopVals = scan.loops(1).rng(2);
end
if length(scan.loops)>1 % if there is an outer loop, set up plotting so that it will plot as meaningful full frequency range. 
    if isempty(scan.loops(2).getchan)
        scan.loops(2).getchan = 'count';
    end
    scan.loops(2).datafn.fn = plotAgilNA;
    scan.loops(2).datafn.args = {scan.loops(1).rng};
end

inst = sminstlookup('E5071c');
% Create the prefn
scan.loops(1).prefn.fn = @smaAgilNAprefn;
scan.loops(1).prefn.args{1}=startVals;
scan.loops(1).prefn.args{2}=stopVals;
scan.loops(1).prefn.args{3} = inst;
scan.loops(1).prefn.args{4} = opts;

% Rewrite the first loop of the scan to run the multiple NA sweeps. 
if ncount > 1
    scan.loops(1).rng = [1 ncount];
    scan.loops(1).npoints = ncount;
    scan.loops(1).setchan = 'count';
end

if ischar(scan.loops(1).getchan) % Make the getchan a cell. Things work better that way. 
    scan.loops(1).getchan = {scan.loops(1).getchan};
end
end