function smprintrange(ch)
% smprintrange(ch)
% 
% Print limit and rate information about channels ch (Default all).

global smdata;

if nargin < 1
    ch = 1:length(smdata.channels);
else
    ch = smchanlookup(ch)';
end

fmt = '%2d   %-10s  %10.2g  %10.2g  %10.2g  %10.2g\n';
fprintf('%2s   %-10s  %10s  %10s  %10s  %10s\n', 'CH' ,  'Name', 'Min', 'Max', 'Rate (1/s)', 'Factor');
fprintf([repmat('-', 1, 63), '\n']);
for i = ch;
    fprintf(fmt, i, smdata.channels(i).name, smdata.channels(i).rangeramp);
end