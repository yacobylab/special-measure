function smbatch(scans,filename)
% smbatch(scans,files) takes in a cell array of scan structures and a base
% filename.  files are labelled filename_runnumber, (with runnumber found
% in smaux and incremented between scans).  save directory is
% smaux.datadir.  try smauxinit to initialize these preferences.

global smaux;



for i=1:length(scans)
    if iscell(filename)
        fn = filename{i};
    else
        fn = filename;
    end
    runstring=sprintf('%03u',smaux.run);
    datasaveFile = fullfile(smaux.datadir,[fn '_' runstring '.mat']);
    while exist(datasaveFile,'file')
        smaux.run=smaux.run+1;
        runstring=sprintf('%03u',smaux.run);
        datasaveFile = fullfile(smaux.datadir,[fn '_' runstring '.mat']);
    end
    
    % set constants
    allchans = {scans{i}.consts.setchan};
        setchans = {};
        setvals = [];
        for j=1:length(scans{i}.consts)
            if scans{i}.consts(j).set
                setchans{end+1}=scans{i}.consts(j).setchan;
                setvals(end+1)=scans{i}.consts(j).val;
            end
        end
        smset(setchans, setvals);
        newvals = cell2mat(smget(allchans));
        for j=1:length(scans{i}.consts)
            scans{i}.consts(j).val=newvals(j);
        end
    
    smrun(scans{i},datasaveFile);
    
    
    
    slide.title = [fn '_' runstring '.mat'];
    slide.body = scans{i}.comments;
    slide.consts=scans{i}.consts;
    smsaveppt(smaux.pptsavefile,slide,'-f1000');
    
    smaux.run=smaux.run+1;
end

    