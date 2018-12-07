function scan = smflip(scan,loop)
%function scan = smflip(scan,loop)
% flip the direction of the scan on loop 'loop'
% defaults to first loop. 
if ~exist('loop','var') || isempty(loop) 
    loop = 1; 
end
scan.loops(loop).rng = fliplr(scan.loops(loop).rng); 

end