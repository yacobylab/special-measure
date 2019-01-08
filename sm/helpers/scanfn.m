function trafrng=scanfn(scan,loop,name)
% Print out information on functions in scans. For now just trafofns.
% function trafrng=scanfn(scan,loop)
global smdata
if ~exist('name','var') || isempty(name)    
    name = 'trafo'; 
end
if strfind(name,'trafo')
for j = 1:length(scan.loops)
    if length(scan.loops(j).rng)==2
        startVals(j) = scan.loops(j).rng(1);
        endVals(j) = scan.loops(j).rng(2);
    end
end
if isfield(scan.loops(loop),'trafofn') && ~isempty(scan.loops(loop).trafofn)
    for i = 2:length(scan.loops(loop).trafofn)
        startTraf(i)=scan.loops(loop).trafofn(i).fn(startVals,smdata.chanvals, scan.loops(loop).trafofn(i).args{:});
        endTraf(i)=scan.loops(loop).trafofn(i).fn(endVals,smdata.chanvals, scan.loops(loop).trafofn(i).args{:});
        fprintf('Trafofn for %s goes from %3.3f to %3.3f for %s from %3.3f to %3.3f \n', scan.loops(loop).setchan{i}, startTraf(i),endTraf(i), scan.loops(loop).setchan{1}, startVals(loop),endVals(loop));
    end
end
trafrng = [startTraf',endTraf'];
elseif strfind(name,'pre') || strfind(name,'post')
    xvals = scanRng(scan.loops(loop));     
    trafrng = '';
end
end