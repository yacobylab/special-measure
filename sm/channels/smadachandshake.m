function out = smadachandshake(inst)
% Establish that the DAC that you are talking to has the correct serial number.
% function smadachandshake(inst)
% This builds in protection against windows switching COM ports on reboot

global smdata;

if ~exist('inst','var')
    inst = sminstlookup('DecaDAC');
else
    inst = sminstlookup(inst);
end
out = [];
for i = inst
   if isfield(smdata.inst(i).data, 'handshake') && ~isempty(smdata.inst(i).data.handshake)
      hndshk = query(smdata.inst(i).data.inst, sprintf('A1107296264;p;'));
      out = [out, (sscanf(hndshk, 'A1107296264!p%d')==smdata.inst(i).data.handshake)]; 
   else
       out = [out 1];
   end    
end

if ~all(out)
   error('Instruments %i do not match their handshakes ', inst(out==0)); 
end