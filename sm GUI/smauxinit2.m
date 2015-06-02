global smaux
smaux.datadir = pwd; %uigetdir('C:\Documents and Settings\spm\My Documents\MX 400 Data','Select Data Directory');

pptsavefile = '';

if ~isfield(smaux,'run')
    smaux.run=100;
end

smaux.initialized=1;
