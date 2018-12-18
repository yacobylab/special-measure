function smaDMMsnglmode(dmms)
% Set dmms to default configuration to turn off buffered readout. Default is all HP34401A instruments.
% function smaDMMsnglmode(dmms)
% Sets sample count to 1, trigger mode to immediate and trigger delay to 
% auto. This reverts the effect of programming buffered readout.

global smdata;

if ~exist('var','dmms')
    dmms = sminstlookup('HP34401A');
end
    
for i = dmms
    if strcmp(smdata.inst(i).device, 'HP34401A')
        smprintf(i, 'SAMP:COUN 1');
        smprintf(i, 'TRIG:SOUR IMM');
        smprintf(i, 'TRIG:DEL:AUTO 1');
    end
end