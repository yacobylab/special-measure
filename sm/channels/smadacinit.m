function smadacinit(inst, opts)
% Activate DAC outputs, check handshakes, set update rate, and (optional) set value to 0.
% smadacinit(inst, opts)
% inst defaults to all instruments named DecaDAC in rack. 
% opts can be 'zero', to set all DAC channels to zero

global smdata;
if ~exist('inst','var') || isempty(inst)
    inst = sminstlookup('DecaDAC');
else
    inst = sminstlookup(inst);
end

if smadachandshake(inst) % smadachandshake will throw an error if dacs don't match handshakes, but if it changes to returning false, this will add protection. 
    for k=inst'
        for i = 0:((size(smdata.inst(k).channels, 1)-1)/8-1) % for 20 channels, this is 5, for the 5 blocks of 4 channels. 
            query(smdata.inst(k).data.inst, sprintf('B%d;M2;', i)); % M turns relays to 4 channel mode for each block i. 
            if isfield(smdata.inst(k).data, 'update')
                for j = 0:3
                    query(smdata.inst(k).data.inst, sprintf('C%d;T%d;', j, smdata.inst(k).data.update(4*i+j+1))); % T sets channel j's timebase in us. 
                end
            end
        end
    end
end

if exist('opts','var') && contains(opts,'zero')
    for k=inst'
        for i = 1:size(smdata.inst(k).channels, 1)/2
            smdata.inst(inst(1)).cntrlfn([k, i, 1], 0,1);
        end
    end
end
end