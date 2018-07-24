function smundo(opts)
% function smundo()
% Double check with the user, and delete the last data file.
% If file is more than 5 minutes old or larger than 3 kB, check with user again. 
% if opt 'noc' is given, deletes without checking. 
global smn_lastfile;
if ~exist('opts','var'), opts = ''; end
if ~isopt(opts, 'noc')
    if ~exist(smn_lastfile,'file')
        warning('File ''%s'' does not exist',smn_lastfile);
    end
    
    s=input(sprintf('Delete "%s"? (Y/N)',smn_lastfile),'s');
    if upper(s) ~= 'Y'
        fprintf('Please make up your mind!\n');
        return;
    end
    
    st=dir(smn_lastfile);
    if (now - st.datenum)*24*60 > 5
        s=input(sprintf('Warning -- this file is %g minutes old.  Are you sure? ',(now-st.datenum)*24*60),'s');
        if upper(s) ~= 'Y'
            fprintf('Please make up your mind!\n');
            return;
        end
    end
    if st.bytes > 3e3
        s=input(sprintf('Warning -- this file is %g bytes long.  Are you sure? ',st.bytes),'s');
        if upper(s) ~= 'Y'
            fprintf('Please make up your mind!\n');
            return;
        end
    else
        fprintf('File is %g bytes long\n',st.bytes);
    end
end
fprintf('Deleting...\n');
delete(smn_lastfile);
end