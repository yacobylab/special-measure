function scan = smflip(scan,loop)
if ~exist('loop','var') || isempty(loop) 
    loop = 1; 
end
scan.loops(loop).rng = fliplr(scan.loops(loop).rng); 

end