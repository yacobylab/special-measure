function smprintf(inst, fmt, varargin)
% smprintf(inst, fmt, varargin)
%
% Call fprintf with same arguments on instrument inst.

global smdata;

inst = sminstlookup(inst);

if isfield(smdata.inst(inst), 'data') && isfield(smdata.inst(inst).data, 'inst')
    fprintf(smdata.inst(inst).data.inst, fmt, varargin{:});
end
    
    