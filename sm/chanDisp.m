function chanDisp(channels,chanvals)
% function chanDisp
% Initialize figure 999 to display current channel values.

nchans = length(channels); chanvals = num2cell(chanvals); 
screenData=get(0,'MonitorPositions');
f= figure(999); clf; f.MenuBar= 'none'; f.Name=  'Channels';
f.Position = [10+screenData(2,1), screenData(2,4)-50-14*nchans, 220, 14*nchans+20];
%f.Position = [10, screenData(1,4)-50-14*nchans, 220, 14*nchans+20];
func = @(x,y) sprintf('%-20s %.5g', x,y); 
str = cellfun(func,channels,chanvals,'UniformOutput',false);
dispChan = uicontrol;     
dispChan.Style = 'text'; 
%dispChan.Position = [10+screenData(2,1), 10, 200, 14*nchans]; dispChan.HorizontalAlignment = 'Left';
%dispChan.Position = [10+screenData(2,1), 550, 200, 14*nchans]; dispChan.HorizontalAlignment = 'Left';
dispChan.Position = [10, 10, 200, 14*nchans]; dispChan.HorizontalAlignment = 'Left';
dispChan.String =  str;
dispChan.BackgroundColor= [.8 .8 .8];

