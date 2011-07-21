function smundo()
% function smundo()
% double check with the user, and delete the last data file.

global smn_lastfile;

s=input(sprintf('Delete "%s"? (y/N)',smn_lastfile),'s');
if upper(s) == 'Y'
  fprintf('Deleting...\n');
  delete(smn_lastfile);
else
  fprintf('Please make up your mind!\n');
end