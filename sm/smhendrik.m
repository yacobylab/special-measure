function out=smhendrik(fname)
%  function out=smhendrik(fname)
%    Reformat a matlab .m file in a Bluhm-centric fashion and return
%  the resulting contents as a string.
%    fname may be a file name or a function name.
%    Prints warning messages for non-canonical code.
if exist('fname','file')
  f=fopen(fname);
else
  try
    f=fopen(which(fname));
  catch
    error(['Unable to open file or function ',fname])
  end
end

out='';
loops=0;
while 1
   str=fgets(f);
   if ~ischar(str)
       break;
   end
   nstr=regexp(str,'^([^%'']|(''[^'']*''))*','match');
   if isempty(nstr)
       continue;
   end
   loops=loops + ~isempty(regexp(nstr{1},'^\s*(for|while)'));
   out=[out nstr{1}];
end
if loops ~= 0
    fprintf('Warning: %d loops detected.  Replace with vector operations for true Bluhminess\n',loops);
end
fclose(f);
if nargout == 0
    fprintf('%s',regexprep(out,sprintf('\r'),''));
    out=[];
end