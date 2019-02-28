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

% smadachandshake will throw an error if dacs don't match handshakes, but if it changes to returning false, this will add protection.
if smadachandshake(inst) 
    for k=inst'
        if ~isfield(smdata.inst(k).data,'nChansPerSlot')
            nChansPerSlot = 4;
        else
            nChansPerSlot = smdata.inst(k).data.nChansPerSlot;
        end
        % Cycle through slots
        for i = 0:((size(smdata.inst(k).channels, 1)-1)/(2*nChansPerSlot)-1) 
            if nChansPerSlot == 4
                query(smdata.inst(k).data.inst, sprintf('B%d;M2;', i)); % M turns relays to 4 channel mode for each block i.
            elseif nChansPerSlot ==2
                query(smdata.inst(k).data.inst, sprintf('B%d;M3;', i)); % M turns relays to 2 channel mode
            else
                warning('Not setting channel mode, non standard number of channels per slot');
            end
            if isfield(smdata.inst(k).data, 'update')
                for j = 0:nChansPerSlot-1
                    query(smdata.inst(k).data.inst, sprintf('C%d;T%d;', j, smdata.inst(k).data.update(nChansPerSlot*i+j+1))); % T sets channel j's timebase in us.
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