function smprintchannels(ch)
% function smprintchannels(ch)
%
% Print information about channels ch (Default all).

global smdata;

if ~exist('ch','var')
    ch = 1:length(smdata.channels);
elseif ischar(ch)||iscell(ch)
    ch = smchanlookup(ch);
end

fmt = '%2d   %-10s  %-10s  %-12s  %-10s %-7s %-4s \n';
fprintf(['CH', fmt(4:end)], 'Name', 'Device', 'Dev. Name', 'Dev. Ch.','Ramping','Dim');
fprintf([repmat('-', 1, 60), '\n']);
for i = ch;
    ic = smdata.channels(i).instchan;
    if ic(1) > length(smdata.inst) 
        fprintf('%2d %-10s BORKED: refers to an instrument that doesn''t exist\n',i,smdata.channels(i).name);
    elseif ic(2) > size(smdata.inst(ic(1)).channels,1) 
        fprintf('%2d %-10s %-10s BORKED: refers to a channel that doesn''t exist\n',i,smdata.channels(i).name,smdata.inst(ic(1)).device);
    else
        if size(smdata.inst(ic(1)).type,1)<ic(2)
            chanType = num2str(NaN);
        else
            if smdata.inst(ic(1)).type(ic(2)) == 1;
                chanType = 'Yes'; 
            else 
                chanType = 'No'; 
            end
        end
        if all(size(smdata.inst(ic(1)).datadim) >0)
            if size(smdata.inst(ic(1)).datadim,1)<ic(2)
                chanDim = num2str(NaN);
            elseif smdata.inst(ic(1)).datadim(ic(2))==0
                chanDim = num2str(1);
            else
                chanDim = num2str(smdata.inst(ic(1)).datadim(ic(2)));
            end                        
        else
            chanDim = num2str(1);
        end
        dev = smdata.inst(ic(1)).device; 
        instName = smdata.inst(ic(1)).name;
        fprintf(fmt, i, smdata.channels(i).name, dev, instName, smdata.inst(ic(1)).channels(ic(2),:), chanType,chanDim);    
    end    
end