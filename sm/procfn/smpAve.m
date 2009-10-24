function [newdata, data] = smpAve(newdata, data)

persistent count;

if isnan(data(1))
    count = 0;    
    data(:) = 0;
 end

w = 1/(floor((count/size(data, 1))) + 1);
data(mod(count, end)+1, :) =  w * newdata' + (1-w) * data(mod(count, end)+1, :);
newdata = []; % save copying

count = count + 1;