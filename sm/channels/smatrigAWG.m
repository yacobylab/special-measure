function smatrigAWG(inst)
%set AWG triggers CH1M1, CH3M1 High (2.6 V), then Low (0.0 V). 
%function smatrigAWG(inst)
if ~exist('inst','var') || isempty(inst)
    inst = sminstlookup('AWG5000'); 
elseif ischar(inst) 
    inst = sminstlookup(inst); 
end
global smdata;

%fprintf(smdata.inst(inst).data.inst, 'SOUR1:MARK1:VOLT:HIGH 2');
fprintf(smdata.inst(inst).data.inst, 'SOUR3:MARK1:VOLT:LOW 2.6');
fprintf(smdata.inst(inst).data.inst, 'SOUR1:MARK1:VOLT:LOW 2.6');
fprintf(smdata.inst(inst).data.inst, 'SOUR2:MARK1:VOLT:LOW 2.6');
fprintf(smdata.inst(inst).data.inst, 'SOUR3:MARK1:VOLT:LOW 0');
fprintf(smdata.inst(inst).data.inst, 'SOUR1:MARK1:VOLT:LOW 0');
fprintf(smdata.inst(inst).data.inst, 'SOUR2:MARK1:VOLT:LOW 0');