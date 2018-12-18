function smcheckdata
% Finish setting rack up by adding missing variables to smdata. 
% function smcheckdata 

global smdata;

if ~isfield(smdata, 'configch')
    smdata.configch = [];
end

if ~isfield(smdata, 'configfn')
    smdata.configfn = [];
end

if ~isfield(smdata, 'chanvals')
    smdata.chanvals = [];
end
end