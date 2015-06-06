function val = smscanf(inst, varargin)
% function val = smscanf(inst, varargin);
%
% Call fscanf on instrument inst

global smdata;

inst = sminstlookup(inst);

if isfield(smdata.inst(inst), 'data') && isfield(smdata.inst(inst).data, 'inst')
    val = fscanf(smdata.inst(inst).data.inst, varargin{:});
end
    
    