function smprintinst(inst,opts)
% function smprintinst(inst)
% Print information about instruments inst (Default all).
% if full 
% If inst is a single instrument, the avialable channels are printed.
global smdata;

if ~exist('opts','var') 
    opts = '';     
end

if ~exist('inst','var') || isempty(inst)
    inst = 1:length(smdata.inst);
else
    inst = sminstlookup(inst);
end

if ~isopt(opts,'full')
    fmt = '%4d %-10s  %-12s  \n';
    fprintf(['Inst', fmt(4:end)], 'Device', 'Dev. Name');
    fprintf([repmat('-', 1, 40), '\n']);
else
    fmt = '%4d %-10s  %-12s   %-12s %-16s %-6s \n';
    fprintf(['Inst', fmt(4:end)], 'Device', 'Dev. Name','Inst Type','Inst Num','Status');
    fprintf([repmat('-', 1, 70), '\n']);
end

for i = inst
    if isopt(opts,'full')
        if isfield(smdata.inst(i),'data') && isfield(smdata.inst(i).data,'inst') && ~isempty(smdata.inst(i).data.inst) && isobject(smdata.inst(i).data.inst)
            instType = smdata.inst(i).data.inst.type;
            if strcmp(instType,'serial')
                instNum = num2str(smdata.inst(i).data.inst.Port(4:end));
                openInst = smdata.inst(i).data.inst.Status;
            elseif strcmp(instType,'visa-tcpip') || strcmp(instType,'tcpip')
                instNum = smdata.inst(i).data.inst.RemoteHost;
                openInst = smdata.inst(i).data.inst.Status;
            elseif strcmp(instType,'visa-gpib') || strcmp(instType,'gpib')
                instNum = num2str(smdata.inst(i).data.inst.PrimaryAddress);
                openInst = smdata.inst(i).data.inst.Status;
            elseif strcmp(instType,'visa-usb')
                instNum = smdata.inst(i).data.inst.SerialNumber;
                openInst = smdata.inst(i).data.inst.Status;
            else
                instNum = ''; openInst = ''; instType = 'Other';
            end
            % Port % Name
        else
            instType = 'Other';
            instNum = '';
            openInst = '';
        end
        fprintf(fmt, i, smdata.inst(i).device, smdata.inst(i).name,instType,instNum,openInst);
    else
        fprintf(fmt, i, smdata.inst(i).device, smdata.inst(i).name);
    end
    
end
if length(inst) == 1
    disp(char(smdata.inst(i).channels));
end