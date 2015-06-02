function logadd(index, varargin)
% logadd(index, str, varargin)
% add line to logfile, continuing last entry

global loginfo;

if isempty(loginfo) 
    return;
end

if isstr(index) 
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