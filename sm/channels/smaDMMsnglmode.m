function smaDMMsnglmode(dmms)
% smaDMMsnglmode(dmms)
%
% Set dmms to default configuration. Default is all HP34401A instruments.
% Sets sample count to 1, trigger mode to immediate and trigger delay to 
% auto. This reverts the effect of programming buffered readout.

global smdata;

if nargin < 1
    dmms = sminstlookup('HP34401A');
end
    
for i = dmms
    if strcmp(smdata.inst(i).device, 'HP34401A')
        smprintf(i, 'SAMP:COUN 1');
        smprintf(i, 'TRIG:SOUR IMM');
        smprintf(i, 'TRIG:DEL:AUTO 1');
    end
end