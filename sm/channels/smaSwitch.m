function smaSwitch(chanConn,opts)
%function smaSwitch(ico,chanConn,opts)
% chanConn should be a cell with format {chanOut, chanInd} 
% % chanOut will usually be breakout box channels. 
% chanIn will usually be lock in channels, ground, or open.
% possible opts: ground, open, print
global smdata
if ~exist('opts','var')
    opts = '';
end
ico = sminstlookup('Switch');
inst = smdata.inst(ico(1)).data.inst;
nChan = 4; % number of in / out channels switfch has. 

if ~isempty(chanConn)
    chanConntmp = chanConn; chanConn(:,1) = chanConntmp(:,2); chanConn(:,2) = chanConntmp(:,1);  %Switch dir so that now form is in, out. 
    chanConnStr = chanConn;
    if iscell(chanConn)
        chanConn = lookupSwitch(chanConn,ico(1)); % convert the strings to channel numbers. 
    end
    if iscell(smdata.inst(ico(1)).data.oldConn)
        oldConn = lookupSwitch(smdata.inst(ico(1)).data.oldConn,ico(1)); % convert the strings of formerly connected channels to channel numbers. 
    end
    %sameVal = chanConn(:,1)==oldConn(:,1) & (chanConn(:,2) ==oldConn(:,2));
    %chanConn = chanConn(~sameVal);
    for i = 1:size(chanConn,1) 
        if chanConn(i,1) == 0 %ground; first ground, then disconnect former channel. 
            dacwrite(inst, sprintf('ON 0%d;',chanConn(i,2))); % set to ground
            if ~isnan(oldConn(chanConn(i,2),1))                
                dacwrite(inst, sprintf('OF %d%d',oldConn(chanConn(i,2),1),oldConn(chanConn(i,2),2)));
            end
        elseif isnan(chanConn(i,1))
            dacwrite(inst,sprintf('OF %d%d;',oldConn(chanConn(i,2),1),oldConn(chanConn(i,2),2))); % disconnect old
        else
            dacwrite(inst,sprintf('ON 0%d;',chanConn(i,2))); % set to ground
            if ~isnan(oldConn(chanConn(i,2),1))
                dacwrite(inst,sprintf('OF %d%d;',oldConn(chanConn(i,2),1),oldConn(chanConn(i,2),2))); % disconnect old
            end
            dacwrite(inst,sprintf('ON %d%d;',chanConn(i,1),chanConn(i,2)));  % connect new
            dacwrite(inst,sprintf('OF 0%d;',chanConn(i,2)));    % disconnect ground
        end
        smdata.inst(ico(1)).data.oldConn(chanConn(i,2),:) = chanConnStr(i,:);
    end
end

if isopt(opts,'ground')
    for i = 1:nChan
        dacwrite(inst,sprintf('ON 0%d;',i));
    end
    smdata.inst(ico(1)).data.oldConn = [repmat({'ground'},4,1),smdata.inst(ico(1)).data.outChans'];
    opts = [opts 'open'];
end

if isopt(opts,'open')
    for i = 1:nChan
        for j = 1:nChan
            dacwrite(inst,sprintf('OF %d%d;',i,j));
        end
    end
    if ~isopt(opts,'ground')
        for i =1:nChan
            dacwrite(inst,sprintf('OF 0%d;',i));
        end
        smdata.inst(ico(1)).data.oldConn = [repmat({'open'},4,1),smdata.inst(ico(1)).data.outChans'];
    end
    
end


if isopt(opts, 'print')
    for i =1:size(smdata.inst(ico(1)).data.oldConn,1)
        fprintf('%s : %s\n',smdata.inst(ico(1)).data.oldConn{i,1}, smdata.inst(ico(1)).data.oldConn{i,2});
    end
end

dacwrite(inst,'SV;')
end

function [chanConn] = lookupSwitch(chanConn,inst)
% convert channel strings into numbers. 
% 0 is ground; nan is open
global smdata
out=cellfun(@(x) find(strcmp(smdata.inst(inst).data.outChans, x)),chanConn(:,2),'UniformOutput',false);
in=cellfun(@(x) find(strcmp(smdata.inst(inst).data.inChans, x)),chanConn(:,1),'UniformOutput',false);
chanConn = [[in{:}]',[out{:}]'];
chanConn(chanConn==6)=NaN;
chanConn(chanConn==5)=0;
end

function dacwrite(inst, str)
try
    query(inst, str);
catch
    fprintf('WARNING: error in DAC (%s) communication. Flushing buffer.\n',inst.Port);
    while inst.BytesAvailable > 0
        fprintf(fscanf(inst));
    end
end
end