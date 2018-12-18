function smsaveinst(ind,opts)
% function smsaveinst(ind)
% Export insts from current rack into separate files after stripping
% data.inst if present (this does not save well, especially across multiple setups). 
% Instrument information is saved in a driver independent format for serial, gpib and visa-tcpip
% instruments.
% If option chans given, saves all associated channels with the instrument. 

global smdata;

if ~exist('ind','var') || isempty(ind)
    ind = 1:length(smdata.inst);
end
if ~exist('opts','var'), opts = ''; end

for i = ind
    inst = smdata.inst(i);    
    inst.name = ''; %why?
    constructor = [];
    if isfield(inst, 'data') && isfield(inst.data, 'inst') 
        switch class(inst.data.inst)
            case 'serial'
                constructor.fn = @serial;
                constructor.params = {'OutputBufferSize', 'BaudRate', 'DataBits', 'Parity', 'StopBits'};
                constructor.args = {'Port'};
                
            case 'gpib'
                constructor.fn = @gpib;
                constructor.params = {'OutputBufferSize', 'EOSCharCode', 'EOIMode', 'EOSMode'};
                constructor.args = {'BoardIndex', 'PrimaryAddress'};
                
            case 'visa'
                constructor.fn = @visa;
                constructor.params = {'OutputBufferSize'};
                constructor.args = {'RsrcName'};
        end
        if ~isempty(constructor)
            constructor.vals = get(inst.data.inst, constructor.params);
            constructor.args = get(inst.data.inst, constructor.args);
        end
        inst.data = rmfield(inst.data, 'inst');
    end
    
    if isopt(opts,'chan') 
        chans = findChans('','',i); 
        channels = smdata.channels(chans); 
        save(sprintf('sminst_%s', inst.device), 'inst', 'constructor','channels');
    else
        save(sprintf('sminst_%s', inst.device), 'inst', 'constructor');
    end 
end
end