function [disp,figurenumber] = initDisp(scan,updateLoop,ndim,datadim,data)
global smdata

nloops = length(scan.loops); 
getch = vertcat(scan.loops.getchan);
if ~isfield(scan, 'disp') || isempty(scan.disp)
    disp = struct('loop', {}, 'channel', {}, 'dim', {});
else
    disp = scan.disp;
end
switch length(disp)
    case 1, subplotSize = [1 1];         
    case 2, subplotSize = [1 2];
    case {3, 4},  subplotSize = [2 2];      
    case {5, 6},  subplotSize = [2 3];        
    otherwise
        subplotSize = [3 3];
        disp(10:end) = [];
end

if isfield(scan,'figure') % Determine the next available figure after 1000 for this measurement.  A figure is available unless its userdata field is the string 'SMactive'
    figurenumber=scan.figure;
    if isnan(figurenumber)
        figurenumber = 1000;
        while ishandle(figurenumber) && strcmp(get(figurenumber,'userdata'),'SMactive')
            figurenumber=figurenumber+1;
        end
    end
else
    figurenumber=1000;
end
if ~ishandle(figurenumber);
    figure(figurenumber)
    set(figurenumber, 'pos', [10, 10, 800, 400]);
else
    figure(figurenumber);
    clf;
end
set(figurenumber,'userdata','SMactive'); % tag this figure as being used by SM
set(figurenumber, 'CurrentCharacter', char(0));

if ~isfield(disp, 'loop')% default for disp loop
    for i = 1:length(disp)
        disp(i).loop = updateLoop(disp(i).channel)-1; %why subtract?
    end
end

s.type = '()';
for i = 1:length(disp)    
    subplot(subplotSize(1), subplotSize(2), i);
    dispChan = disp(i).channel; %index of channel to be displayed        
    nDimCurr = ndim(dispChan); 
    disp(i).ndim = nDimCurr; 
    disp(i).updateLoop = updateLoop(dispChan);  % updateLoop(dispchan) gives which loop the data is updated on    
    disp(i).datadim = datadim(dispChan,:);    
    s.subs = num2cell(ones(1, ndims(data{dispChan})));
    [s.subs{end-disp(i).dim+1:end}] = deal(':');
    xvalLoop = disp(i).updateLoop - disp(i).ndim; % Loop being updated on x-axis of plot. 
    if xvalLoop < 1 % if this is < 1, don't have channel names or range to associate with x axis. 
        xRng = 1:datadim(dispChan, disp(i).ndim); % instead of range, just find number of data points. 
        xLab = 'n';
    else
        xRng = scan.loops(xvalLoop).rng; % if possible, set the x axis to have range of sweep channel and name of setchan.       
        if ~isempty(scan.loops(xvalLoop).setchan)
            xLab = smdata.channels(scan.loops(xvalLoop).setchan(1)).name;
        else
            xLab = '';
        end
    end
    if disp(i).dim == 2        
        if xvalLoop < 0 % if this is < 0, we don't have channel names to associate with y axis. 
            yRng = 1:datadim(dispChan, nDimCurr-1);
            yLab = 'n';
        else
            yRng = scan.loops(xvalLoop + 1).rng;
            if ~isempty(scan.loops(xvalLoop + 1).setchan)
                yLab = smdata.channels(scan.loops(xvalLoop + 1).setchan(1)).name;
            else
                yLab = '';
            end
        end
        z = zeros(length(yRng), length(xRng));
        z(:, :) = subsref(data{dispChan}, s);
        disp(i).dispHandle = imagesc(xRng, yRng, z);                
        set(gca, 'YDir', 'Normal');
        colorbar;
        if dispChan <= length(getch)
            title(smdata.channels(getch(dispChan)).name);
        end
        xlabel(xLab);
        ylabel(yLab);
    else % 1d plot
        yRng = zeros(size(xRng));
        yRng(:) = subsref(data{dispChan}, s);
        disp(i).dispHandle = plot(xRng, yRng);        
        xlim(sort(xRng([1, end])));
        xlabel(xLab);
        if dispChan <= length(getch)
            ylabel(smdata.channels(getch(dispChan)).name);
        end
    end
end  