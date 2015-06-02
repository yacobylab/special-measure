function out = smadachandshake(inst)
%function smadachandshake(inst)
% establish that the DAC that you are talking to has the correct serial
% number.
% this builds in protection against windows switching COM ports on reboot


global smdata;

if nargin < 1
    inst = sminstlookup('DecaDAC');
else
    inst = sminstlookup(inst);
end
out = [];
for j = inst'
   if isfield(smdata.inst(j).data, 'handshake') && ~isempty(smdata.inst(j).data.handshake)
      hndshk = query(smdata.inst(j).data.inst, sprintf('A1107296264;p;'));
      out = [out, (sscanf(hndshk, 'A1107296264!p%d')==smdata.inst(j).data.handshake)]; 
   else
       out = [out 1];
   end    
end

if ~all(out)
   error('instruments %i do not match their handshakes ', inst(find(out==0))); 
end