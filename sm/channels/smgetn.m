function [val,mval] = smgetn(channel,n,rate) 
% 
% function [val,mval] = smgetn(channel,n,rate) 

for i = 1:n 
    val(i) = smget(channel);
    if exist('rate','var') && ~isempty(rate) 
        pause(1/rate) 
    end
    fprintf('%g \n',(cell2mat(val(i)))); 
end

mval = mean(cell2mat(val)); 
fprintf('Mean %g. std %g. \n',mval, std(cell2mat(val)))
end