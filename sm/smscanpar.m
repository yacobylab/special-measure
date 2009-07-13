function scan = smscanpar(scan, cntr, rng, npoints, loops)
% scan = smscanpar(scan, cntr, rng, npoints, loops)
% Set center, range and number of points for scan.loops(loops).
% loops defaults to 1:length(cntr).  Empty or omitted arguments are left unchanged.
% scan.configfn is executed at the end if present and not empty.

if nargin < 5
    loops = 1:length(cntr);
end

if ~isempty(cntr)
    for i = 1:length(loops)
        scan.loops(loops(i)).rng =  scan.loops(loops(i)).rng - mean(scan.loops(loops(i)).rng) + cntr(i);
    end
end

if nargin >=3 && ~isempty(rng)
    for i = 1:length(loops)
        scan.loops(loops(i)).rng =  mean(scan.loops(loops(i)).rng) + rng(i) * [-.5 .5];
    end
end

if nargin >=4 && ~isempty(npoints)
    for i = 1:length(loops)
        scan.loops(loops(i)).npoints =  npoints(i);
    end
end

if isfield(scan, 'configfn') && ~isempty(scan.configfn)
    scan = scan.configfn.fn(scan, scan.configfn.args{:});
end
