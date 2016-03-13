function smaSwitch(ico,chanConn,opts)
%function smaSwitch(ico,chanConn,opts)
global smdata
    if ~exist('opts','var') 
        opts = '';
    end
    inst = smdata.inst(ico(1)).data.inst; 
    nChan = 4;
    
    if ~isempty(chanConn)
        chanConnStr = chanConn; 
        if iscell(chanConn)            
            chanConn = lookupSwitch(chanConn,ico(1));
        end
        if iscell(smdata.inst(ico(1)).data.oldConn)
            oldConn = lookupSwitch(smdata.inst(ico(1)).data.oldConn,ico(1));
        end
        %sameVal = chanConn(:,1)==oldConn(:,1) & (chanConn(:,2) ==oldConn(:,2)); 
        %chanConn = chanConn(~sameVal);
        for i = 1:size(chanConn,1)
            if chanConn(i,1) == 0 %ground
                dacwrite(inst,sprintf('ON 0%d;',chanConn(i,2))); % set to ground
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
        global smdata
        out=cellfun(@(x) find(strcmp(smdata.inst(inst).data.outChans, x)),chanConn(:,2),'UniformOutput',false);        
        in=cellfun(@(x) find(strcmp(smdata.inst(inst).data.inChans, x)),chanConn(:,1),'UniformOutput',false);
        chanConn = [[in{:}]',[out{:}]']; 
        chanConn(chanConn==6)=NaN;         
        chanConn(chanConn==5)=0;    
 end
 
 function dacwrite(inst, str)
 try
     a=query(inst, str);
 catch
     fprintf('WARNING: error in DAC (%s) communication. Flushing buffer.\n',inst.Port);
     while inst.BytesAvailable > 0
         fprintf(fscanf(inst));
     end
 end
 end