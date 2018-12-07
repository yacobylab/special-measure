function good = isopt(opts, arg,varargin)
% check if something is an opt. Now only checks for whole words, doesn't do
% text search. 
%function good = isopt(opts, arg)

if ~exist('arg','var') 
    error('No arg given'); 
end
optsList = strsplit(opts); 
    if any(strcmpi(optsList,arg))
        good = 1; 
    else
        good = 0; 
    end
end

