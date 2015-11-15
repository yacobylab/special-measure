function smramp(channels, vals, rates,trignum)
% Use self ramping drivers w/ smset, allowing smset to quit. Takes vector
% or cell of channels, vals, rates, but only one trignum possible. 
if ~exist('trignum','var') || isempty(trignum)
    trignum =3;
end
channels = smchanlookup(channels);


smset(channels,vals,rates)
ic = smchaninst(channels); 
smatrigfn(ic,[],trignum);
end