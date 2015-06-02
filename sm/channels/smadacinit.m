function smadacinit(inst, opts)
%dacinit(inst, opts)
% activate dac outputs and set value to 0.
% also sets update rate if smdata.inst(inst).data.update exists.
% inst defaults to DecaDAC.
% opts can be 'zero', to set all dac channels to zero

global smdata;

if nargin < 1
    inst = sminstlookup('DecaDAC');
else
    inst = sminstlookup(inst);
end

% smadachandshake will throw an error if dacs don't match handshakes, but
% if it changes to returning false, this will add protection. 
if smadachandshake(inst)
    for k=inst'
        for i = 0:((size(smdata.inst(k).channels, 1)-1)/8-1)
            query(smdata.inst(k).data.inst, sprintf('B%d;M2;', i));
            if isfield(smdata.inst(k).data, 'update')
                for j = 0:3
                    query(smdata.inst(k).data.inst, sprintf('C%d;T%d;', j, smdata.inst(k).data.update(4*i+j+1)));
                end
            end
        end
    end
end


if exist('opts','var') && ~isempty(strfind(opts,'zero'))
    for k=inst'
        for i = 1:size(smdata.inst(k).channels, 1)/2
            smdata.inst(inst(1)).cntrlfn([k, i, 1], 0,1);
        end
    end
end