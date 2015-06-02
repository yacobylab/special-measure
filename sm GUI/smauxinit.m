global smaux
smaux.datadir = uigetdir('C:\Documents and Settings\spm\My Documents\MX 400 Data','Select Data Directory');

[pptFile,pptPath] = uiputfile('*.ppt','Append to Presentation');
if pptFile ~= 0
    smaux.pptsavefile=fullfile(pptPath,pptFile);   
else
    pptsavefile = '';
end

if ~isfield(smaux,'run')
    smaux.run=100;
end

smaux.initialized=1;