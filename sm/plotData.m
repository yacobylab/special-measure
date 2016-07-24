function disp = plotData(disp,data,j,count,nloops)
% display data.
for k = find([disp.loop] == j) %update everything set to updated this loop
    dispChan = disp(k).channel;  % channel to update.    
    nouterLoops = nloops - disp(k).updateLoop + 1; %outerloops for current getchan
    nLoopsPlotted = nloops + 1 - j + disp(k).dim; % number of loops plotted at once + number of loops data replotted
    %dataCellDim = nouterLoops + disp(k).ndim; % % is this the size of data?
    dataNDims = ndims(data{dispChan}); 
    underSamp = dataNDims - nLoopsPlotted;   % this is done in the case that we are updating a later loop than we can to display all the data. in this case, select just the first row.    
    loopList = fliplr(count); % current indices to to be plotting from outer to inner loop.
    nInds = min(nloops+1-j,nloops+1-j+underSamp);  % if we underSamp < 0, will need to get total length of s.subs correct.
    s.subs = [num2cell([loopList(1:nInds), ones(1, max(0,underSamp))]),repmat({':'},1, disp(k).dim)];    
    s.type = '()'; 
    if disp(k).dim == 2
        dataSize = size(data{dispChan});
        z = zeros(dataSize(end-1:end));
        z(:, :) = subsref(data{dispChan}, s);
        set(disp(k).dispHandle, 'CData', z);
    else
        set(disp(k).dispHandle, 'YData', subsref(data{dispChan}, s));
    end
    drawnow;
end
