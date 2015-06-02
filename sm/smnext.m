function [nextstr nextnum]=smnext(name, opts)
% function [nextstr nextnum]=smnext(name, opts)
% Return a numbered name for the next scan.  If name is present, it is
% prepended to the number with an _ inbetween.
% opts = 'quiet' will not print next filename to cmd line

global smn_lastname;
global smn_lastfile;
global smn_lastnum;
if exist('name','var')
    name=[name '_'];
else
    name='';
end

if ~exist('opts','var') || isempty(opts)
    opts = '';
end

search=1;
if exist('smn_lastnum','var') && ~isempty('smn_lastnum') 
    if exist(smn_lastfile,'file')
      nextnum = smn_lastnum+1;
    else
      nextnum = smn_lastnum;
    end
    
    files1=dir(sprintf('sm*%04d.mat',nextnum));
    files2=dir(sprintf('sm*%04d.mat',nextnum-1));
    if length(files1) == 0 && length(files2) > 0
      search=0;
    end
end

if search
    files=dir('sm*.mat');
    files=regexp({files.name},'[0123456789]*\.mat','match');
    nums(length(files))=0;
    for i=1:length(files)
        nums(i)=max([0 sscanf(files{i}{1},'%d.mat')]);
    end
    nextnum=max(nums)+1;
end

nextstr=sprintf('%s%04d',name,nextnum);

if isempty(strfind(opts, 'quiet'))    
    fprintf('Next file: %s\n',nextstr);
end

if isempty(strfind(opts, 'nocutbuffer'))
    clipboard('copy',nextstr);
end
smn_lastname=name;
smn_lastfile=sprintf('sm_%s.mat',nextstr);
smn_lastnum=nextnum;

end
