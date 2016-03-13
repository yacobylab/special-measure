function smramp(channels, vals, rates,trignum)
global smdata
% Use self ramping drivers w/ smset, allowing smset to quit. Takes vector
% or cell of channels, vals, rates, but only one trignum possible. 
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