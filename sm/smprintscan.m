function smprintscan(scan)
% smprintscan(scan)

global smdata;

if ~isfield(scan.loops, 'npoints')
    [scan.loops.npoints] = deal([]);
end

if ~isfield(scan.loops, 'ramptime')
     [scan.loops.ramptime] = deal([]);
end


if isfield(scan, 'trafofn')
  fprintf('Global transformations:\n-----------------------\n');
    for i = 1:length(scan.trafofn)
        fprintf('%s\n%', func2str(scan.trafofn{i}));
    end
  fprintf('\n');
end


for i = 1:length(scan.loops)

    ch = smchanlookup(scan.loops(i).setchan);
    
    if isempty(scan.loops(i).npoints)
        scan.loops(i).npoints = length(scan.loops(i).rng);
    elseif isempty(scan.loops(i).rng)
        scan.loops(i).rng = 1:scan.loops(i).npoints;
    end
    
    if isempty(scan.loops(i).ramptime)
        scan.loops(i).ramptime = nan(length(ch), 1);
    end

    fprintf('Loop %d\n-------\nx = %.3g to %.3g,   %d  points\n\n', ...
        i, scan.loops(i).rng([1, end]), scan.loops(i).npoints);

    fprintf('Channels set : ')
    fprintf('%-15s ', smdata.channels(ch).name);
    fprintf('\nRamptimes    : ')
    fprintf('%-4.2d s/point    ', scan.loops(i).ramptime);
    if isfield(scan.loops(i), 'trafofn')
            fprintf('\nTransform''s  : ')
            for j = 1:length(scan.loops(i).trafofn)
                if iscell(scan.loops(i).trafofn)
                    if isempty(scan.loops(i).trafofn{j})
                        fprintf('%-15s ', 'identity');
                    else
                        fprintf('%-15s ', func2str(scan.loops(i).trafofn{j}));
                    end
                else
                    if isempty(scan.loops(i).trafofn(j).fn)
                        fprintf('%-15s ', 'identity');
                    else
                        fprintf('%-15s ', func2str(scan.loops(i).trafofn(j).fn));
                    end
                end
            end
    end
    ch = smchanlookup(scan.loops(i).getchan);
    fprintf('\n\nChannels read: ')    
    fprintf('%-15s ', smdata.channels(ch).name);
    fprintf('\n\n');
end

