function [nextstr,nextnum]=smnext(name, opts)
% function [nextstr,nextnum]=smnext(name, opts)
% Return a 4 digit numbered name for the next scan.  If name is present, it is
% prepended to the number with an _ inbetween, copying filename to cut
% buffer. 
% opts = 'quiet' will not print next filename to cmd line
% opts = 'nocutbuffer' prevents copying name.
% Only works if you are saving files in the current directory. 
% If not using with smrun, necessary to preface file with sm_, as in 
% save(['sm_' smnext('filename')],'data')

global smn_lastname; global smn_lastfile; global smn_lastnum;

if exist('name','var')
    name=[name '_'];
else
    name='';
end

if ~exist('opts','var') || isempty(opts), opts = ''; end

% If smn_lastnum exists, just check that the file exists, and that the file
% with the num smn_lastnum+1 does not. 
search=1; 
if exist('smn_lastnum','var') && ~isempty('smn_lastnum') 
    if exist(smn_lastfile,'file')
      nextnum = smn_lastnum+1;
    else
      nextnum = smn_lastnum;
    end
    
    files1=dir(sprintf('sm*%04d.mat',nextnum));
    files2=dir(sprintf('sm*%04d.mat',nextnum-1));
    if isempty(files1) && ~isempty(files2)
      search=0;      
    end
end

% if smn_lastnum doesn't exist or the requisite files suggest it's not
% correct, look at all the files in directory and find largest number, then
% increment to get next number.
if search
    files = dir('sm*.mat');
    if isempty(files)
        nextnum = 1;
    else
        numsCell=regexp([files.name],'(\d{4}).mat','tokens');
        nums = cellfun(@str2num,[numsCell{:}]);
        lastnum = max(nums);
        nextnum = lastnum+1;
    end
end

nextstr=sprintf('%s%04d',name,nextnum);

if ~isopt(opts,'quiet')
    fprintf('Next file: %s\n',nextstr);
end

if ~isopt(opts, 'nocutbuffer')
    clipboard('copy',nextstr);
end
smn_lastname=name;
smn_lastfile=sprintf('sm_%s.mat',nextstr);
smn_lastnum=nextnum;
end