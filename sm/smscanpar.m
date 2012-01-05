function scan = smscanpar(scan, cntr, rng, npoints, loops)
% scan = smscanpar(scan, cntr, rng, npoints, loops)
% Set center, range and number of points for scan.loops(loops).
% loops defaults to 1:length(cntr).  Empty or omitted arguments are left unchanged.
% scan.configfn is executed at the end if present and not empty.
%
% if cntr is 'gca', copy the range of the current plot to the scan.

if nargin < 5
    loops = 1:length(cntr);
end

if ~isempty(cntr)
    if ischar(cntr) && strcmp(cntr,'gca')
        xrng=get(gca,'XLim');
        yrng=get(gca,'YLim');
        scan.loops(loops(1)).rng = xrng;
        scan.loops(loops(2)).rng = yrng;        
        fprintf('X range: [%g,%g]   Y range: [%g,%g]\n',xrng,yrng);
        return;
    end
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

for i=1:length(scan.consts)
    smset(scan.consts(i).setchan,scan.consts(i).val);
end
if isfield(scan, 'configfn') && ~isempty(scan.configfn)
    scan = scan.configfn.fn(scan, scan.configfn.args{:});
end
