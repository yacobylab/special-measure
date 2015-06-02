function scan = smaconfigwrap(scan, fn, varargin)
%function scan = smaconfigwrap(scan, fn, varargin)
% Run fn, varargin on config without changing scan.
fn(varargin{:});
