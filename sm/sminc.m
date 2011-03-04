function sminc(channels, vals)
% sminc(channels, vals)
%
% increment channel values

vals = vals + cell2mat(smget(channels));
smset(channels, vals);
