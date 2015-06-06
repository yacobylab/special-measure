function sminc(channels, vals,ramprate)
% function sminc(channels, vals,ramprate)
%
% increment channel values

vals = vals + cell2mat(smget(channels));
if exist('ramprate','var')
    smset(channels, vals,ramprate);
else
    smset(channels, vals);
end
