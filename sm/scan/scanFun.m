function scan = scanFun(scan,funcName,varargin) 
% function scan = scanFun(scan,funcName,varargin) 
% general function used to perform all the special functions inside
% special measure. 
% Currently includes: 
%   config
%   cleanup
%   prefn
%   postfn
%   datafn
switch funcName
    case 'config'
        if isfield(scan, 'configfn')
            for i = 1:length(scan.configfn)
                if ~isfield(scan.configfn,'args') || isempty(scan.configfn(i).args)
                    scan.configfn(i).args = {}; 
                end
                scan = scan.configfn(i).fn(scan, scan.configfn(i).args{:});
            end
        end
    case 'cleanup'
        if isfield(scan, 'cleanupfn')
            for i = 1:length(scan.cleanupfn)
                if ~isfield(scan.cleanupfn,'args') || isempty(scan.cleanupfn(i).args)
                    scan.cleanupfn(i).args = {}; 
                end
                scan = scan.cleanupfn(i).fn(scan, scan.cleanupfn(i).args{:});
            end
        end
    case 'prefn'
        if isfield(scan,'prefn') 
            fncall(scan.prefn,varargin{:})
            scan = [];
        end
    case 'postfn' 
        if isfield(scan,'postfn') 
            fncall(scan.postfn,varargin{:})
            scan=[];
        end
    case 'datafn'
        fncall(scan.datafn,varargin{:})
        scan=[];
end
end

function fncall(fns, varargin)   
if iscell(fns)
    for i = 1:length(fns)
        if ischar(fns{i})
          fns{i} = str2func(fns{i});
        end
        fns{i}(varargin{:});
    end
else
    for i = 1:length(fns)
        if ischar(fns(i).fn)
          fns(i).fn = str2func(fns(i).fn);
        end
        if ~isfield(fns,'args') || ~iscell(fns(i).args)
            if ~isfield(fns,'args') || isempty(fns(i).args)
                fns(i).args={};
            else
                error('Arguments to functions must be a cell array');
            end
        end
        fns(i).fn(varargin{:}, fns(i).args{:});        
    end
end
end