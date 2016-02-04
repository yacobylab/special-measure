function smundof()
% function smundo()
% Double check with the user, and delete the last data file.
% If file is more than 5 minutes old or larger than 3 kB, check with user again. 

global smn_lastfile;
if ~exist(smn_lastfile,'file')
    warning('File ''%s'' does not exist',smn_lastfile);
    return
end

fprintf('Deleting...\n');
delete(smn_lastfile);
end