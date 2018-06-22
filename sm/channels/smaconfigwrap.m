function scan = smaconfigwrap(scan, fn, varargin)
% Run a function as part of smrun configfn without changing scan. 
% function scan = smaconfigwrap(scan, fn, varargin)
% calls fn(varargin) 
if ischar(fn)
    fn = str2func(fn);
end
fn(varargin{:});
end