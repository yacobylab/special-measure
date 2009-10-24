function [newdata, data] = smpSpect2(newdata, data)

persistent olddata;
persistent nold;
persistent count;
persistent win;

npls = size(data, 1)/3;
nsamp = size(data, 2) * 2; % # samples per window
nnew = length(newdata);

if isnan(data(1))
    nold = 0;
    count = 0;    
    olddata = nan(3 * nsamp * npls/2, 1);
    data(:) = 0;
    win = window(@hann, nsamp);
end

nwin = floor((nold + nnew)/(nsamp * npls)-.5);

if nwin > 0
    nold2 = nold + nnew - nwin*nsamp*npls;
    olddata2 = [olddata(nwin*nsamp*npls+1:nold) ; newdata(max(0, end-nold2)+1:end)];
    % nnew - nold2 = nwin*nsamp*npls - nold
    newdata = [olddata(1:nold); newdata(1:(nwin+.5)*nsamp*npls-nold)];
    newdata = reshape(newdata, npls, length(newdata)/npls)';


    ft = ifft( [reshape(newdata(1:end-nsamp/2, :), nsamp, nwin, npls), reshape(newdata(1+nsamp/2:end, :), nsamp, nwin, npls)] ...
        .* repmat(win, [1, 2*nwin, npls]));

    ft2 = permute(mean(repmat(ft(1:end/2, :, 1), [1, 1, npls]) .* conj(ft(1:end/2, :, :)), 2), [3, 1, 2]);

    w = nwin/(count+nwin);
    data =   w * [permute(mean(abs(ft(1:end/2, :, :)).^2, 2),  [3, 1, 2]);  real(ft2); imag(ft2)] + (1-w) * data;
    count = count + nwin;


    nold = nold2;
    olddata(1:nold, :) = olddata2(1:nold, :);
else
    olddata(nold+(1:nnew)) = newdata;
    nold = nold + nnew;
end
%fprintf('%d\n', nold)


newdata = []; % save copying