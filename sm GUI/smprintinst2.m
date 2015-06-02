function [s1 s2 s3]=smprintinst2(inst)
% smprintinst2(inst)
%
% Print information about instruments inst (Default all).  First output
% string has instrument numbers, second has device, third has name.

global smdata;

if nargin < 1
    inst = 1:length(smdata.inst);
else
    inst = sminstlookup(inst);
end

fmt1 = '%-2d\n';
fmt2 = '%-15s\n';
fmt3 = '%-15s\n';
s1=sprintf('Inst\n');
s2=sprintf(fmt2, 'Device');
s3=sprintf(fmt3,'Dev. Name');
s1=sprintf([s1, repmat('-', 1, 6), '\n']);
s2=sprintf([s2, repmat('-', 1, 18), '\n']);
s3=sprintf([s3, repmat('-', 1, 18), '\n']);
for i = inst;
    s1=sprintf([s1, fmt1],i);
    s2=sprintf([s2, fmt2],smdata.inst(i).device);
    s3=sprintf([s3, fmt3],smdata.inst(i).name);
end
