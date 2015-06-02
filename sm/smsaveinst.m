function smsaveinst(ind)
% smsaveinst(ind)
% Export insts from current rack into separate files after stripping
% data.inst if present. Instrument information is saved in a driver independent 
% format for serial, gpib and visa-tcpip instruments.

global smdata;

if nargin < 1
    ind = 1:length(smdata.inst);
end

for i = ind
    inst = smdata.inst(i);    
    inst.name = '';
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
    
    save(sprintf('sminst_%s', inst.device), 'inst', 'constructor');
end
   