function config=smaSRS830(ico,config) 
%config=smaSRS830(ico,config) 
% opts : def 
% possibilities are meas, shield, couple, line, reserve, filter, sync, ref 

global smdata;
if ischar(ico) || iscell(ico) 
    ico = sminstlookup(ico); 
end
inst = smdata.inst(ico(1)).data.inst;
if ~isfield(config,'opts') 
    config.opts ='';
end
if isfield(config,'opts') && isopt(config.opts,'def')
    config = struct('shield','float','couple','ac','line','none','reserve','norm','filter',24,'sync','on','opts','');
end
if isfield(config,'filter') && ~isempty(config.filter)
    config.filter = num2str(config.filter); 
end
if 1
SRinfo.meas.cmd = 'ISRC'; SRinfo.meas.vals = {'a','ab','i'}; 
SRinfo.shield.cmd = 'IGND'; SRinfo.shield.vals = {'float','ground'}; 
SRinfo.couple.cmd = 'ICPL'; SRinfo.couple.vals = {'ac','dc'}; 
SRinfo.line.cmd = 'ILIN'; SRinfo.line.vals = {'none','one','two','all'}; 
SRinfo.reserve.cmd = 'RMOD'; SRinfo.reserve.vals = {'high','norm','low'}; 
SRinfo.filter.cmd = 'OFSL'; SRinfo.filter.vals = {'6','12','18','24'}; 
SRinfo.sync.cmd = 'SYNC'; SRinfo.sync.vals = {'off','on'}; 
SRinfo.ref.cmd = 'FMOD'; SRinfo.ref.vals = {'ext','int'}; 
 end
configVals = fieldnames(config); 
configVals = configVals(~strcmp(configVals,'opts')); 
for i = 1:length(configVals)
    name = configVals{i}; 
    vals = SRinfo.(name).vals; cmd = SRinfo.(name).cmd; 
    if ~isopt(config.opts,'q')
        msg = find(strcmp(vals,config.(name))); 
        if ~isempty(msg)
            fprintf(inst, sprintf('%s %d',cmd,msg-1));                
        end
    else
        val = str2double(query(inst,sprintf('%s ?',cmd)));
        config.(name) = vals{val+1}; 
    end
end
end
% 
% if isfield(config,'meas')
%     name = 'meas'; cmd = 'ISRC'; 
%     vals = {'a','ab','i'}; 
%     if ~isopt(config.opts,'q')
%         msg = find(strcmp(vals,config.(name))); 
%         if ~isempty(msg)
%             fprintf(inst, sprintf('%s %d',cmd,msg-1));                
%         end
%     else
%         val = str2num(query(inst,sprintf('%s ?',cmd)));
%         config.(name) = vals{val+1}; 
%     end
% end
% 
% if isfield(config,'shield') 
%     vals = {'float','ground'}; 
%     switch config.shield
%         case 'float'
%             m = 0; 
%         case 'ground' 
%             m = 1; 
%     end
%     fprintf(inst, sprintf('IGND %d',m));                
% end
% 
% if isfield(config,'couple') 
%     vals = {'ac','dc'}; 
%     switch config.couple
%         case 'ac'
%             m = 0; 
%         case 'dc' 
%             m = 1; 
%     end
%     fprintf(inst, sprintf('ICPL %d',m));                
% end
% 
% if isfield(config,'line') 
%     vals = {'none','one','two','all'}; 
%     switch config.line
%         case 'none'
%             m = 0; 
%         case 'one' 
%             m = 1; 
%         case 'two'
%             m = 2; 
%         case 'all' 
%             m = 3; 
%     end
%     fprintf(inst, sprintf('ILIN %d',m));                
% end
% 
% if isfield(config,'reserve') 
%     vals = {'high','norm','low'}; 
%     switch config.reserve
%         case 'high'
%             m = 0; 
%         case 'norm' 
%             m = 1; 
%         case 'low'
%             m = 2; 
%     end
%     fprintf(inst, sprintf('RMOD %d',m));                
% end
% 
% if isfield(config,'filter') 
%    
%     if config.filter == 6 
%         m = 0; 
%     elseif config.filter == 12
%         m=1;         
%     elseif config.filter ==18 
%         m=2; 
%     elseif config.filter == 24 
%         m=3; 
%     end
%     fprintf(inst, sprintf('OFSL %d',m));                
% end
% 
% if isfield(config,'sync') 
%     vals = {'off','on'}; 
%     switch config.sync
%         case 'on'
%             m = 1; 
%         case 'off' 
%             m = 0; 
%     end
%     fprintf(inst, sprintf('SYNC %d',m));                
% end
% 
% if isfield(config,'ref') 
%     vals = {'ext','int'}; 
%     switch config.shield
%         case 'int'
%             m = 1; 
%         case 'ext' 
%             m = 0; 
%     end
%     fprintf(inst, sprintf('FMOD %d',m));                
% end
% 
% 
% end