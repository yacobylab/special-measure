function sminitdisp
% sminitdisp
%
% Initialize figure 1001 to display current channel values.
% The displayed values of all scalar channels will be updated by every 
% call of smset or smget as long is figure 1001 is open.

global smdata;
nchan = length(smdata.channels);

figure(1001);
set(1001, 'position', [10, 700-14*nchan, 220, 14*nchan+20], 'MenuBar', 'none', ...
    'Name', 'Channels');

str = cell(1, nchan);
for i = 1:nchan
    str{i} = sprintf('%-25s', smdata.channels(i).name);
end
    
uicontrol('style', 'text', 'position', [10, 10, 200, 14*nchan], ...
    'HorizontalAlignment', 'Left', 'string',  str, 'BackgroundColor', [.8 .8 .8]);

smdata.chandisph = uicontrol('style', 'text', 'position', [110, 10, 100, 14*nchan], ...
    'HorizontalAlignment', 'Left', 'string',  repmat({''}, nchan, 1), 'BackgroundColor', [.8 .8 .8]);
    
