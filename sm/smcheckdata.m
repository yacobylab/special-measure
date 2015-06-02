function smcheckdata
% function smcheckdata
% Add (some) missing fields to smdata.

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
