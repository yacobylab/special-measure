function smramp(channels, vals, rates,trignum)
% Use self ramping drivers w/ smset, allowing smset to quit (useful for long
% magnet ramps) 
% function smramp(channels, vals, rates,trignum)
% Takes vector or cell of channels, vals, rates, but only one trignum
% possible. Default trignum is 3. 

global smdata

if ~exist('trignum','var') || isempty(trignum)
    trignum =3;
end
channels = smchanlookup(channels);

if exist('rates','var') && ~isempty(rates)
    smset(channels,vals,-rates)
else 
    smset(channels,vals,-smdata.channels(channels(1)).rangeramp(3))
end
ic = smchaninst(channels); 
smatrigfn(ic,[],trignum);
end