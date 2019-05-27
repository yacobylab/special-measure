function [val,mval] = smgetn(channel,n,rate,opts) 
% Perform smget repeatedly with a defined time spacing. 
% function [val,mval] = smgetn(channel,n,rate) 
% n is number of times to get date, rate is rate in Hz. 
% By default, prints the data as it comes in, but if nodisp given as
% option, will just return data. 
% mval returns the meanval and std of the data. 

if ~exist('opts','var') || isempty(opts),  opts = ''; end
for i = 1:n 
    val(i) = smget(channel);
    if exist('rate','var') && ~isempty(rate) 
        mpause(1/rate) 
    end
    if ~isopt(opts,'quiet')
        fprintf('%g \n',(cell2mat(val(i)))); 
    end
end

mval = [mean(cell2mat(val)),std(cell2mat(val))]; 
if ~isopt(opts,'quiet')
    fprintf('Mean %g. std %g. \n',mval(1), mval(2))
end
end