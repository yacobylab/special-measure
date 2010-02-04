function smbatch(scans,filename)
% smbatch(scans,files) takes in a cell array of scan structures and a base
% filename.  files are labelled filename_runnumber, (with runnumber found
% in smaux and incremented between scans).  save directory is
% smaux.datadir.  try smauxinit to initialize these preferences.

global smaux;

for i=1:length(scans)
    runstring=sprintf('%03u',smaux.run);
    datasaveFile = fullfile(smaux.datadir,[filename '_' runstring '.mat']);
    smrun(scans{i},datasaveFile);
    
    slide.title = [filename '_' runstring];
    slide.body = scans{i}.comments;
    slide.consts=scans{i}.consts;
    smsaveppt(smaux.pptsavefile,slide,'-f1000');
    
    smaux.run=smaux.run+1;
end

    