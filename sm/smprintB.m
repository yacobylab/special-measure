function smprintB(scan)
% function smprintscan(scan)

global smdata;

if ~isfield(scan.loops, 'npoints')
    [scan.loops.npoints] = deal([]);
end

if ~isfield(scan.loops, 'ramptime')
     [scan.loops.ramptime] = deal([]);
end

if isfield(scan,'consts') 
    fprintf('Consts: \n')
    for i = 1 :length(scan.consts) 
        fprintf('    %g: %s = %g \n', i, scan.consts(i).setchan,scan.consts(i).val);
    end
end

if isfield(scan,'configfn')&&~isempty(scan.configfn) 
    fprintf('Configfns: \n') 
    for i = 1:length(scan.configfn) 
        fprintf('    %g: fn: %s, args: ',i,func2str(scan.configfn(i).fn)) 
        for j = 1:length(scan.configfn(i).args)
            fprintf('%g ',scan.configfn(i).args{j}); 
        end
        fprintf('\n')
    end
end

if isfield(scan,'cleanupfn')&&~isempty(scan.cleanupfn) 
    fprintf('cleanupfn: \n') 
    for i = 1:length(scan.cleanupfn) 
        fprintf('    %g: fn: %s, args: ',i,func2str(scan.cleanupfn(i).fn)) 
        for j = 1:length(scan.cleanupfn(i).args)
            fprintf('%g ',scan.cleanupfn(i).args{j}); 
        end
        fprintf('\n')
    end
end


if isfield(scan,'disp')&&~isempty(scan.disp) 
    fprintf('Display: \n' )
    for i= 1:length(scan.disp) 
        fprintf('    %g : %gD plot of channel %g, updated loop %g',i, scan.disp(i).dim, scan.disp(i).channel,scan.disp(i).loop); 
        fprintf('\n')
    end
end

if isfield(scan,'saveloop')&&~isempty(scan.saveloop)
    fprintf('Saves every %g points in loop %g \n', scan.saveloop(2),scan.saveloop(1)); 
end

if isfield(scan, 'trafofn')&&~isempty(scan.trafofn)
  fprintf('Global transformations:\n-----------------------\n');
    for i = 1:length(scan.trafofn)
        fprintf('%s\n%', func2str(scan.trafofn{i}));
    end
  fprintf('\n');
end

fprintf('\n'); 
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
    if isfield(scan.loops(i), 'trafofn')&&~isempty(scan.loops(i).trafofn)
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
      
    fprintf('\n');
    scanfn(scan,'trafo',i)
    if isfield(scan.loops(i),'prefn')&&~isempty(scan.loops(i).prefn)
        fprintf('prefn: \n')
        for k = 1:length(scan.loops(i).prefn)
            fprintf('    %g: fn: %s, args: ',k,func2str(scan.loops(i).prefn(k).fn))
            for j = 1:length(scan.loops(i).prefn(k).args)
                fprintf('%g ',scan.loops(i).prefn(k).args{j});
            end
            fprintf('\n')
        end
    end
    
    if isfield(scan.loops(i),'postfn')&&~isempty(scan.loops(i).postfn)
        fprintf('postfn: \n')
        for k = 1:length(scan.loops(i).postfn)
            fprintf('    %g: fn: %s, args: ',k,func2str(scan.loops(i).postfn(k).fn))
            for j = 1:length(scan.loops(i).postfn(k).args)
                fprintf('%g ',scan.loops(i).postfn(k).args{j});
            end
            fprintf('\n')
        end
    end
    
    if isfield(scan.loops(i),'trigfn')&&~isempty(scan.loops(i).trigfn)
        fprintf('trigfn: \n')
        for k = 1:length(scan.loops(i).trigfn)
            fprintf('    %g: fn: %s, args: ',k,func2str(scan.loops(i).trigfn(k).fn))
            for j = 1:length(scan.loops(i).trigfn(k).args)
                fprintf('%g ',scan.loops(i).trigfn(k).args{j});
            end
            fprintf('\n')
        end
    end
    
end
ch = smchanlookup(scan.loops(i).getchan);
if ~isempty(ch)
    fprintf('\nChannels read: ')
    fprintf('%-15s ', smdata.channels(ch).name);
end
fprintf('\n\n');
end

