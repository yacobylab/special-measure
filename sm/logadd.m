function logadd(index, varargin)
% function logadd(index, varargin)
% add string to logfile, continuing last entry
%if the "index" is not given, it writes to the general file (index = 1)
% if you give more than 2 arguments, remaining args will be used as
% variables in string. 



global loginfo;

if isempty(loginfo) 
    return;
end

if ischar(index) 
    str = index;
    index = 1;
else
    str = varargin{1};
    varargin = varargin(2:end);
end


logfile = fopen(loginfo(index).logfile, 'a');
logstr = sprintf(str, varargin{:});
fprintf(logfile, '       %s\n', logstr);
fclose(logfile);