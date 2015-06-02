function varargout = smguichannels(varargin)
% Runs special measure's GUI
% to fix: -- deselect plots after changing setchannels
%         -- selecting files/directories/run numbers
%         -- add notifications + smaux compatibility
%  Create and then hide the GUI as it is being constructed.

% Copyright 2011 Hendrik Bluhm, Vivek Venkatachalam
% This file is part of Special Measure.
% 
%     Special Measure is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     Special Measure is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with Special Measure.  If not, see
%     <http://www.gnu.org/licenses/>.

global smaux smdata;
channelyheight = 18; %in pixels
channelyspacing = 22; %in pixels
heightinchannels=36;
        
        
channelwidths = [40 75 100 75 50 50 50 50]; %widths of each column
if isfield(smaux,'smguichannels') && ishandle(smaux.smguichannels)
    figure(smaux.smguichannels)
    movegui(smaux.smguichannels,'center')
    rackrefreshpushbutton_Callback;
    return
end

page=1;
smaux.smguichannels = figure('Visible','on',...
       'Name','Configure Channels',...
       'NumberTitle','off',...
       'IntegerHandle','off',...
       'Position',[100,100,sum(channelwidths)+5*(length(channelwidths)+10)-25,(heightinchannels+2)*channelyspacing],...
       'Toolbar','none',...
       'HandleVisibility','callback',...
       'MenuBar','none',...
       'Resize','off');

movegui(smaux.smguichannels,'center')

   


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Construct the components.  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    channelpanel = uipanel('Parent',smaux.smguichannels,...
        'Units','pixels');
    
        channeladd_pbh = uicontrol( ...
            'Parent',channelpanel,...
            'String','Add Channel',...
            'Style','pushbutton',...
            'Position',[1 1 80 20],...
            'Callback',@channeladd_pbh_Callback);
            % Pushbutton to open saved rack [matlab data file]
            
    openrack = uicontrol('Style','pushbutton','String','Open Rack',...
        'Parent',channelpanel,...
        'Position',[400 1 60 20],...
        'Callback',{@openrackpushbutton_Callback});
    
    rackrefresh = uicontrol('Style','pushbutton','String','Refresh',...
        'Parent',channelpanel,...
        'Position',[300 1 60 20],...
        'Callback',{@rackrefreshpushbutton_Callback});
    % Pushbutton to save rack [matlab data file]
    saverack = uicontrol('Style','pushbutton','String','Save Rack',...
        'Parent',channelpanel,...
        'Position',[470 1 60 20],...
        'Callback',{@saverackpushbutton_Callback});
    scrollbar = uicontrol(...
        'Parent',smaux.smguichannels,...
        'Style','slider',...
        'Value',1,...
        'Position',[sum(channelwidths)+5*(length(channelwidths)+2) 0 15  (heightinchannels+2)*channelyspacing],...
        'Callback',{@scrollbar_Callback,channelpanel});

        delchan_pbh = [];  % handles to delete channel pushbuttons
        channelname_eth = []; % handles to channelname edit boxes
        instname_pmh = []; % handles to inst name pupup menus
        instchan_pmh = []; % ...
        channelmin_eth = [];
        channelmax_eth = [];
        channelramprate_eth = [];
        channelconv_eth = [];
        


    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Programming the GUI     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    mInputArgs = varargin;  % Command line arguments when invoking the GUI
    mOutputArgs = {};       % Variable for storing output when GUI returns


    
    if isstruct(smdata)
        smchanrefresh;
    end
    
    % refreshes the channel panel
    function smchanrefresh
    
        nchan = length(smdata.channels);
        panelsize=[0 min(0,(heightinchannels-nchan)*channelyspacing) sum(channelwidths)+5*(length(channelwidths)+2) (nchan+2)*channelyspacing];
    %  Panel for Channels

    set(channelpanel,'Position',panelsize);

        

    
        workingsize=panelsize;
        if ~isempty(delchan_pbh)
            delete([delchan_pbh channelname_eth instname_pmh instchan_pmh ...
                 channelmin_eth channelmax_eth channelramprate_eth ...
                 channelconv_eth]);           
        end
        delchan_pbh = [];
        channelname_eth = [];
        instname_pmh = [];
        instchan_pmh = [];
        channelmin_eth = [];
        channelmax_eth = [];
        channelramprate_eth = [];
        channelconv_eth = []; 
        



        if ~isfield(smdata,'inst')
            smdata.inst(1).device = 'none';
            smdata.inst(1).name = ' ';
        end

        for i = 1:length(smdata.inst)
            instnames{i}=[smdata.inst(i).device,' ',smdata.inst(i).name];
        end
        channelnameheader_sth = uicontrol( ...
            'Parent',channelpanel,...
            'Style','Text',...
            'String','Name',...
            'Position',[10+sum(channelwidths(1:1)),panelsize(4)-channelyspacing,channelwidths(2), 20]);
        channelinstheader_sth = uicontrol( ...
            'Parent',channelpanel,...
            'Style','Text',...
            'String','Instrument',...
            'Position',[15+sum(channelwidths(1:2)),panelsize(4)-channelyspacing,channelwidths(3), 20]);
        channelchanheader_sth = uicontrol( ...
            'Parent',channelpanel,...
            'Style','Text',...
            'String','Channel',...
            'Position',[20+sum(channelwidths(1:3)),panelsize(4)-channelyspacing,channelwidths(4), 20]);
        channelminheader_sth = uicontrol( ...
            'Parent',channelpanel,...
            'Style','Text',...
            'String','Min',...
            'Position',[25+sum(channelwidths(1:4)),panelsize(4)-channelyspacing,channelwidths(5), 20]);
        channelmaxheader_sth = uicontrol( ...
            'Parent',channelpanel,...
            'Style','Text',...
            'String','Max',...
            'Position',[30+sum(channelwidths(1:5)),panelsize(4)-channelyspacing,channelwidths(6), 20]);
        channelrampheader_sth = uicontrol( ...
            'Parent',channelpanel,...
            'Style','Text',...
            'String','Ramp',...
            'Position',[35+sum(channelwidths(1:6)),panelsize(4)-channelyspacing,channelwidths(7), 20]);
        channelconvheader_sth = uicontrol( ...
            'Parent',channelpanel,...
            'Style','Text',...
            'String','Multiplier',...
            'Position',[40+sum(channelwidths(1:7)),panelsize(4)-channelyspacing,channelwidths(8), 20]);
        for i = 1:nchan
            delchan_pbh(i) = uicontrol( ...
                'Parent',channelpanel,...
                'Style','pushbutton',...
                'String','Delete',...
                'Position',[5,workingsize(4)-channelyspacing*i-15,channelwidths(1),channelyheight],...
                'Visible','on',...
                'Callback',{@removechannel_Callback,i});
            channelname_eth(i) = uicontrol( ...
                'Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).name,...
                'Position',[10+sum(channelwidths(1:1)),workingsize(4)-channelyspacing*i-15,channelwidths(2), channelyheight],...
                'Visible','on',...
                'Callback',{@edtchannelname_Callback,i});
            instname_pmh(i) = uicontrol( ...
                'Parent',channelpanel,...
                'Style','popupmenu',...
                'String',['none' instnames],...
                'Value',smdata.channels(i).instchan(1)+1,...
                'Position',[15+sum(channelwidths(1:2)),workingsize(4)-channelyspacing*i-13,channelwidths(3), channelyheight],...
                'Callback',{@instname_pmh_Callback,i});
            instchan_pmh(i) = uicontrol( ...
                'Parent',channelpanel,...
                'Style','popupmenu',...
                'String',['none' cellstr(smdata.inst(smdata.channels(i).instchan(1)).channels)'],...
                'Value',smdata.channels(i).instchan(2)+1,...
                'Position',[20+sum(channelwidths(1:3)),workingsize(4)-channelyspacing*i-13,channelwidths(4), channelyheight],...
                'Callback',{@instchan_pmh_Callback,i});
            channelmin_eth(i) = uicontrol( ...
                'Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(1),...
                'Position',[25+sum(channelwidths(1:4)),workingsize(4)-channelyspacing*i-15,channelwidths(5), channelyheight],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelmin_eth_Callback,i});
            channelmax_eth(i) = uicontrol( ...
                'Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(2),...
                'Position',[30+sum(channelwidths(1:5)),workingsize(4)-channelyspacing*i-15,channelwidths(6), channelyheight],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelmax_eth_Callback,i});
            channelramprate_eth(i) = uicontrol( ...
                'Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(3),...
                'Position',[35+sum(channelwidths(1:6)),workingsize(4)-channelyspacing*i-15,channelwidths(7), channelyheight],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelramprate_eth_Callback,i});
            channelconv_eth(i) = uicontrol( ...
                'Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(4),...
                'Position',[40+sum(channelwidths(1:7)),workingsize(4)-channelyspacing*i-15,channelwidths(8), channelyheight],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelconv_eth_Callback,i});            
        end
        scrollbar_Callback(scrollbar,[],channelpanel)
    end

    function removechannel_Callback(hObject,eventdata,i)
        smdata.channels(i)=[];
        smchanrefresh;
    end

    function channeladd_pbh_Callback(hObject,eventdata)
        if (~isstruct(smdata) || ~isfield(smdata,'inst'))
            errordlg('Please setup instruments before adding channels','Action not allowed');
        elseif isstruct(smdata)
            smdata.channels(end+1).instchan=[1 1];
            smdata.channels(end).rangeramp=[0 0 0 1];
            smdata.channels(end).name='New';
            smchanrefresh;
        else
            smdata.channels(1).instchan=[1 1];
            smdata.channels(1).rangeramp=[0 0 0 1];
            smdata.channels(1).name='New';
            smchanrefresh;         
        end
    end

    function edtchannelname_Callback(hObject,eventdata,i)
        smdata.channels(i).name=get(hObject,'String');
    end

    function instname_pmh_Callback(hObject,eventdata,i)
        smdata.channels(i).instchan(1)=get(hObject,'Value')-1;
        smdata.channels(i).instchan(2)=1;
        set(instchan_pmh(i),'String',['none' cellstr(smdata.inst(smdata.channels(i).instchan(1)).channels)']);
        set(instchan_pmh(i),'Value',1);
    end

    function instchan_pmh_Callback(hObject,eventdata,i)
        smdata.channels(i).instchan(2)=get(hObject,'Value')-1;
    end

    function channelmin_eth_Callback(hObject,eventdata,i)
        val = str2double(get(hObject,'String'));
        if ~isnan(val)
            smdata.channels(i).rangeramp(1)= val;
            set(hObject,'String',smdata.channels(i).rangeramp(1));
        else
            errordlg('Please enter a real number or "inf"','Invalid Input Value');
            set(hObject,'String',smdata.channels(i).rangeramp(1));
        end
    end

    function channelmax_eth_Callback(hObject,eventdata,i)
        val = str2double(get(hObject,'String'));
        if ~isnan(val)
            smdata.channels(i).rangeramp(2)= val;
            set(hObject,'String',smdata.channels(i).rangeramp(2));
        else
            errordlg('Please enter a real number or "inf"','Invalid Input Value');
            set(hObject,'String',smdata.channels(i).rangeramp(2));
        end
    end

    function channelramprate_eth_Callback(hObject,eventdata,i)
        val = str2double(get(hObject,'String'));
        if ~isnan(val)
            smdata.channels(i).rangeramp(3)= val;
            set(hObject,'String',smdata.channels(i).rangeramp(3));
        else
            errordlg('Please enter a real number or "inf"','Invalid Input Value');
            set(hObject,'String',smdata.channels(i).rangeramp(3));
        end
    end

    function channelconv_eth_Callback(hObject,eventdata,i)
        val = str2double(get(hObject,'String'));
        if ~isnan(val)
            smdata.channels(i).rangeramp(4)= val;
            set(hObject,'String',smdata.channels(i).rangeramp(4));
        else
            errordlg('Please enter a real number or "inf"','Invalid Input Value');
            set(hObject,'String',smdata.channels(i).rangeramp(4));
        end
    end

    function scrollbar_Callback(hObject,eventdata,channelpanel)
        a=get(hObject,'Value');
        panelpos = get(channelpanel,'Position');
        totalheight=panelpos(4);
        availableheight=(heightinchannels+2)*channelyspacing;
        if panelpos(4)>availableheight
            panelpos(2)=-a*(totalheight-availableheight);
        else
            panelpos(2)=0;
        end
        set(channelpanel,'Position',panelpos);
    end

    function openrackpushbutton_Callback(hObject,eventdata)
        [smdataFile,smdataPath] = uigetfile('*.mat','Select Rack File');
        S=load (fullfile(smdataPath,smdataFile));
        smdata=S.smdata;
        smchanrefresh;
    end

    function saverackpushbutton_Callback(hObject,eventdata)  
        [smdataFile,smdataPath] = uiputfile('*.mat','Save Rack As');
        save(fullfile(smdataPath,smdataFile),'smdata');
    end

    function rackrefreshpushbutton_Callback(hObject,eventdata)
        smchanrefresh;
    end

end 