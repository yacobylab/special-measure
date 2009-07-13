function scan = smdiagpar(scan, angle, cntr, loops)
% smdiagpar(scan, angle, cntr, loops)
% configure scan rotation by angle, followed by shift to cntr.
% loops specifies to which loops to apply the operation. Default is the
% two innermost loops. 
% Other global transformation functions are removed, and the range of the two 
% loops affected is shifted to be symmetric around 0.
% An exception is angle = 0, which removes all transformation functions
% and sets the scan range to be centered around cntr.
% Keep in mind thatin order to rotate the scan, both x and y channels must
% be set in the innermost loop.

if nargin < 4
    loops =[];
end

nloops = length(scan.loops);

switch length(loops)
    case 0
        loops = 1:2;
    case 1
        loops = loops + [0, 1];
    case 2
        
    otherwise
        fprintf('n-D rotations not implemented\n');
        return;
end

% difficult for repeated calls - would have to get center back from trafo
%if nargin < loops
%    cntr = mean(vertcat(scan.loops(loops).rng), 2)';
%end

if angle ~= 0
    M = eye(nloops);
    M(loops, loops) = [cos(angle), -sin(angle); sin(angle), cos(angle)];
    b = zeros(1, nloops);
    b(loops) = cntr;

    scan.trafofn{1} = @(x) x*M' + b;
    for i = loops
        scan.loops(i).rng = scan.loops(i).rng - mean(scan.loops(i).rng);
    end
else
    scan.trafofn = {};
    for i = 1:length(loops)
        scan.loops(loops(i)).rng = scan.loops(loops(i)).rng - mean(scan.loops(loops(i)).rng) + cntr(i);
    end
end