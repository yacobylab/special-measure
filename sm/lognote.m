function lognote(str)
% lognote(str)
% write a note to logfile 

global loginfo;

logfile = fopen(loginfo.logfile, 'a');

fprintf(logfile, str);

fclose(logfile);