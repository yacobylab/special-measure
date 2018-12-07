function out = smaN5183A(ic, command, ~)

global smdata;
if ~exist('ic','var') || isempty(ic)
    ic = sminstlookup('N5183'); 
end
inst = smdata.inst(ic(1)).data.inst;
switch command
    case 'RFOn' %Turn the RF on
        fprintf(inst,'OUTP ON');
        out = 1; 
    case 'RFOff'         %Turn the RF off
        fprintf(inst,'OUTP OFF');
        out = 0; 
    case 'GetState'
        out = eval(query(inst,'OUTP:STAT?'));
    case 'contOn'
        fprintf(inst,'INIT:CONT ON\n');
end
end