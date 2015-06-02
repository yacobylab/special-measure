function val = smquery(inst, fmt, varargin)
% smquery(inst, fmt, varargin)
%
% Call query on instrument inst

global smdata;

inst = sminstlookup(inst);

if isfield(smdata.inst(inst), 'data') && isfield(smdata.inst(inst).data, 'inst')
    val = query(smdata.inst(inst).data.inst, fmt, varargin{:});
end
    
    