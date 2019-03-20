function smprint(scan)
% function smprint(scan)

if ~isfield(scan.loops, 'npoints')
    [scan.loops.npoints] = deal([]);
end
if ~isfield(scan.loops, 'ramptime')
     [scan.loops.ramptime] = deal([]);
end
if isfield(scan,'consts') && ~isempty(scan.consts)
    fprintf('Consts: \n')
    for i = 1 :length(scan.consts) 
        fprintf('    %g: %s = %g \n', i, scan.consts(i).setchan,scan.consts(i).val);
    end
end
if isfield(scan,'configfn')&&~isempty(scan.configfn)
    fprintf('Configfns: \n')
    for i = 1:length(scan.configfn)
        fprintf('    %g: fn: %s, args: ',i,func2str(scan.configfn(i).fn))
        printFmt(scan.configfn(i).args)
    end
    fprintf('\n')
end
if isfield(scan,'cleanupfn')&& ~isempty(scan.cleanupfn) 
    fprintf('cleanupfn: \n') 
    for i = 1:length(scan.cleanupfn) 
        fprintf('    %g: fn: %s, args: ',i,func2str(scan.cleanupfn(i).fn)) 
        printFmt(scan.cleanupfn(i).args)
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
    if length(scan.saveloop) == 1 
        scan.saveloop(2) = 1; 
    end
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
    if isempty(scan.loops(i).npoints)
        scan.loops(i).npoints = length(scan.loops(i).rng);
    elseif ~isfield(scan.loops,'rng') || isempty(scan.loops(i).rng)
        scan.loops(i).rng = 1:scan.loops(i).npoints;
    end
    fprintf('Loop %d\n-------\nx = %.3g to %.3g,   %d  points\n', i, scan.loops(i).rng([1, end]), scan.loops(i).npoints);
    if ischar(scan.loops(i).setchan)
        ch = {scan.loops(i).setchan};
    elseif isempty(scan.loops(i).setchan)
        ch = {};
    else
        ch = scan.loops(i).setchan;
    end
    fprintf('Channels set : ')
    for j=1:length(ch)
        fprintf('%-15s ', ch{j});
    end
    if isempty(scan.loops(i).ramptime)
        scan.loops(i).ramptime = nan(length(ch), 1);
    end
    if ~isempty(scan.loops(i).ramptime) && all(~isnan(scan.loops(i).ramptime))
        fprintf('\nRamptimes    : ')
        fprintf('%-4.4f s/point    ', scan.loops(i).ramptime);
    end
    if ~isempty(scan.loops(i).getchan)
        if ischar(scan.loops(i).getchan)
            ch = {scan.loops(i).getchan};
        elseif isempty(scan.loops(i).getchan)
            ch = {}; 
        else
            ch = scan.loops(i).getchan; 
        end
        fprintf('\nChannels read: ')
        for j = 1:length(ch)
            fprintf('%-15s ', ch{j});
        end
        fprintf('\n');
    else
        if iscell(scan.loops(i).getchan) && ~isempty(scan.loops(i).getchan)
            fprintf('\nChannels read: ')
            for j = 1:length(scan.loops(i).getchan)
                fprintf('%-15s ', scan.loops(i).getchan{j});
            end
            fprintf('\n');
        elseif ischar(scan.loops(i).getchan) && ~isempty(scan.loops(i).getchan)
            fprintf('\nChannels read: ')
            fprintf('%-15s ', scan.loops(i).getchan);
            fprintf('\n');
        end
    end
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
        fprintf('\n');
    end
    
    try
        scanfn(scan,i);
    end
    if isfield(scan.loops(i),'prefn')&&~isempty(scan.loops(i).prefn)
        fprintf('prefn: \n')
        for k = 1:length(scan.loops(i).prefn)
            if ~ischar(scan.loops(i).prefn(k).fn)
                fn = func2str(scan.loops(i).prefn(k).fn);
            else
                fn = scan.loops(i).prefn(k).fn;
            end
            fprintf('    %g: fn: %s, args: ',k,fn)
            for j = 1:length(scan.loops(i).prefn(k).args)
                try
                    fprintf('%g ',scan.loops(i).prefn(k).args{j});
                end
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
        fprintf('trigfn:')
        for k = 1:length(scan.loops(i).trigfn)
            fprintf('    %s, args: ',func2str(scan.loops(i).trigfn(k).fn))
            for j = 1:length(scan.loops(i).trigfn(k).args)
                if ischar(scan.loops(i).trigfn(k).args{j})
                    fprintf('%s ',scan.loops(i).trigfn(k).args{j});
                else
                    fprintf('%g ',scan.loops(i).trigfn(k).args{j});
                end
            end
            
            fprintf('\n')
        end
    end
    fprintf('\n');
end
end