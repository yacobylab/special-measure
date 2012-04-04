function smundo()
% function smundo()
% double check with the user, and delete the last data file.

global smn_lastfile;
if ~exist(smn_lastfile,'file')
    error('File ''%s'' does not exist',smn_lastfile);
end

s=input(sprintf('Delete "%s"? (y/N)',smn_lastfile),'s');
if upper(s) ~= 'Y'
    fprintf('Please make up your mind!\n');
    return;
end

st=dir(smn_lastfile)
if (now - st.datenum)*24*60 > 5  
  s=input(sprintf('Warning -- this file is %g minutes old.  Are you sure? ',(now-st.datenum)*24*60),'s');
  if upper(s) ~= 'Y'
    fprintf('Please make up your mind!\n');
    return;
  end
end
if st.bytes > 1e3
    s=input(sprintf('Warning -- this file is %g bytes long.  Are you sure? ',st.bytes),'s');  
    if upper(s) ~= 'Y'
      fprintf('Please make up your mind!\n');
      return;
    end
else
    fprintf('File is %g bytes long\n',st.bytes);
end

fprintf('Deleting...\n');
delete(smn_lastfile);
end