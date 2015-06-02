function logsetfile(index, file)
% logsetfile(index, file)
% initialise logging to 'file' and reset date
% index specifies which file to set and defaults to 1.
% file must be a string.

global loginfo;

if nargin < 2
    file = index;
    index = 1;
end

if length(loginfo) < index || isempty(loginfo(index).logfile) ...
        || ~strcmp(loginfo(index).logfile, file)
    % larger list, new file or different file
    loginfo(index).logfile = file;
    loginfo(index).lastdate = [];
end