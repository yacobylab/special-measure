function [nextstr nextnum]=smnext(name)
% function [nextstr nextnum]=smnext(name)
% Return a numbered name for the next scan.  If name is present, it is
% prepended to the number with an _ inbetween.
tic
global smn_lastname;
global smn_lastfile;
global smn_lastnum;
if exist('name','var')
    name=[name '_'];
else
    name='';
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
fprintf('Next file: %s\n',nextstr);
smn_lastname=name;
smn_lastfile=sprintf('sm_%s.mat',nextstr);
smn_lastnum=nextnum;
toc
end
