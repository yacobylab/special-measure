function varargout = smguirack(varargin)
% Runs special measure's GUI, rack only
    
   %  Create and then hide the GUI as it is being constructed.
   f = figure('Visible','off',...
       'Name','Special Measure v0.5',...
       'NumberTitle','off',...
       'Position',[300,300,900,920],...
       'Toolbar','none',...
       'Resize','off');
   movegui(f,'center')
   

   % Setup Tabs
    hg=uitabgroup;
    ht(1)=uitab(hg,'Title','Rack');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Construct the components.  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %
    % Rack
    %
    
    %  Panel for Instruments
    instpanel = uipanel('Parent',ht(1),'Title','Instruments',...
        'Units','pixels',...
        'Position',[50 50 200 780]);
        % Textbox for instrument number (first column)
        insttext1 = uicontrol('Parent',instpanel,'Style','text',...
                'HorizontalAlignment', 'Left',...
                'Position',[5 5 30 750]);
        % Textbox for instrument name
        insttext2 = uicontrol('Parent',instpanel,'Style','text',...
                'String','Empty',...
                'HorizontalAlignment', 'Left',...
                'Position',[35 5 75 750]);
        % Textbox for device name to distinguish degenerate names
        insttext3 = uicontrol('Parent',instpanel,'Style','text',...
                'HorizontalAlignment', 'Left',...
                'Position',[110 5 75 750]);
        % Add instrument button [! not functional]
        instadd = uicontrol('Parent',instpanel,'Style','pushbutton',...
            'String','Add',...
            'Position',[5 5 60 20],...
            'Callback',{@instadd_Callback});       
        % Remove instrument button [! not functional]
        instdel = uicontrol('Parent',instpanel,'Style','pushbutton',...
            'String','Remove',...
            'Position',[70 5 60 20],...
            'Callback',{@instdel_Callback});
        % Edit instrument button [! not functional]
        instdel = uicontrol('Parent',instpanel,'Style','pushbutton',...
            'String','Edit',...
            'Position',[135 5 60 20],...
            'Callback',{@instedt_Callback});
        % Open all instruments (smopen)
        instopen = uicontrol('Parent',instpanel,'Style','pushbutton',...
            'String','Open Instruments',...
            'Position',[5 30 190 20],...
            'Callback',{@instopen_Callback});
        
    %  Panel for Channels
    channelwidths = [40 75 100 75 50 50 50 50]; %widths of each column
    channelpanel = uipanel('Parent',ht(1),'Title','Channels',...
        'Units','pixels',...
        'Position',[260 50 sum(channelwidths)+5*(length(channelwidths)+2) 780]);
        align([channelpanel instpanel],'Fixed',10,'Top');
        channelnameheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Name',...
            'Position',[10+sum(channelwidths(1:1)),735,channelwidths(2), 20]);
        channelinstheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Instrument',...
            'Position',[15+sum(channelwidths(1:2)),735,channelwidths(3), 20]);
        channelchanheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Channel',...
            'Position',[20+sum(channelwidths(1:3)),735,channelwidths(4), 20]);
        channelminheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Min',...
            'Position',[25+sum(channelwidths(1:4)),735,channelwidths(5), 20]);
        channelmaxheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Max',...
            'Position',[30+sum(channelwidths(1:5)),735,channelwidths(6), 20]);
        channelrampheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Ramp',...
            'Position',[35+sum(channelwidths(1:6)),735,channelwidths(7), 20]);
        channelconvheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Multiplier',...
            'Position',[40+sum(channelwidths(1:7)),735,channelwidths(8), 20]);
        channeladd_pbh = uicontrol('Parent',channelpanel,...
            'String','Add Channel',...
            'Style','pushbutton',...
            'Position',[5 5 80 20],...
            'Callback',@channeladd_pbh_Callback);
        
        delchan_pbh = [];  % handles to delete channel pushbuttons
        channelname_eth = []; % handles to channelname edit boxes
        instname_pmh = []; % handles to inst name pupup menus
        instchan_pmh = []; % ...
        channelmin_eth = [];
        channelmax_eth = [];
        channelramprate_eth = [];
        channelconv_eth = [];
        
    % Pushbutton to open saved rack [matlab data file]
    openrack = uicontrol('Parent',ht(1),'Style','pushbutton','String','Open Rack',...
        'Position',[380 850 60 20],...
        'Callback',{@openrackpushbutton_Callback});
    % Pushbutton to save rack [matlab data file]
    saverack = uicontrol('Parent',ht(1),'Style','pushbutton','String','Save Rack',...
        'Position',[460 850 60 20],...
        'Callback',{@saverackpushbutton_Callback});
    
    
    %
    % Scans
    %
    

    

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Programming the GUI     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    mInputArgs = varargin;  % Command line arguments when invoking the GUI
    mOutputArgs = {};       % Variable for storing output when GUI returns
    global smdata;

    
    if isstruct(smdata)
        sminstrefresh;
        smchanrefresh;
    end
 
    function sminstrefresh
        [s1 s2 s3]=smprintinst2;
        set(insttext1,'String',s1);
        set(insttext2,'String',s2);
        set(insttext3,'String',s3);
    end
    
    % refreshes the channel panel
    function smchanrefresh
        nchan = length(smdata.channels);
        workingsize=get(channelpanel,'Position');
        workingsize(4)=workingsize(4)-25;
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
        for i = 1:nchan
            delchan_pbh(i) = uicontrol('Parent',channelpanel,...
                'Style','pushbutton',...
                'String','Delete',...
                'Position',[5,workingsize(4)-25*i-15,channelwidths(1),20],...
                'Visible','on',...
                'Callback',{@removechannel_Callback,i});
            channelname_eth(i) = uicontrol('Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).name,...
                'Position',[10+sum(channelwidths(1:1)),workingsize(4)-25*i-15,channelwidths(2), 20],...
                'Visible','on',...
                'Callback',{@edtchannelname_Callback,i});
            instname_pmh(i) = uicontrol('Parent',channelpanel,...
                'Style','popupmenu',...
                'String',['none' instnames],...
                'Value',smdata.channels(i).instchan(1)+1,...
                'Position',[15+sum(channelwidths(1:2)),workingsize(4)-25*i-15,channelwidths(3), 20],...
                'Callback',{@instname_pmh_Callback,i});
            instchan_pmh(i) = uicontrol('Parent',channelpanel,...
                'Style','popupmenu',...
                'String',['none' cellstr(smdata.inst(smdata.channels(i).instchan(1)).channels)'],...
                'Value',smdata.channels(i).instchan(2)+1,...
                'Position',[20+sum(channelwidths(1:3)),workingsize(4)-25*i-15,channelwidths(4), 20],...
                'Callback',{@instchan_pmh_Callback,i});
            channelmin_eth(i) = uicontrol('Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(1),...
                'Position',[25+sum(channelwidths(1:4)),workingsize(4)-25*i-15,channelwidths(5), 20],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelmin_eth_Callback,i});
            channelmax_eth(i) = uicontrol('Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(2),...
                'Position',[30+sum(channelwidths(1:5)),workingsize(4)-25*i-15,channelwidths(6), 20],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelmax_eth_Callback,i});
            channelramprate_eth(i) = uicontrol('Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(3),...
                'Position',[35+sum(channelwidths(1:6)),workingsize(4)-25*i-15,channelwidths(7), 20],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelramprate_eth_Callback,i});
            channelconv_eth(i) = uicontrol('Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(4),...
                'Position',[40+sum(channelwidths(1:7)),workingsize(4)-25*i-15,channelwidths(8), 20],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelconv_eth_Callback,i});            
        end
    end

    function removechannel_Callback(hObject,eventdata,i)
        smdata.channels(i)=[];
        smchanrefresh;
        makeconstpanel;
        makelooppanels;
    end

    function channeladd_pbh_Callback(hObject,eventdata)
        if (~isstruct(smdata) || ~isfield(smdata,'inst'))
            errordlg('Please setup instruments before adding channels','Action not allowed');
        elseif isstruct(smdata)
            smdata.channels(end+1).instchan=[1 1];
            smdata.channels(end).rangeramp=[0 0 0 1];
            smdata.channels(end).name='New';
            smchanrefresh;
            makeconstpanel;
            makelooppanels;
        else
            smdata.channels(1).instchan=[1 1];
            smdata.channels(1).rangeramp=[0 0 0 1];
            smdata.channels(1).name='New';
            smchanrefresh;
            makeconstpanel;
            makelooppanels;            
        end
    end

    function edtchannelname_Callback(hObject,eventdata,i)
        smdata.channels(i).name=get(hObject,'String');
        makeconstpanel;
        makelooppanels;
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

    function openrackpushbutton_Callback(hObject,eventdata)
        [smdataFile,smdataPath] = uigetfile('*.mat','Select Rack File');
        S=load (fullfile(smdataPath,smdataFile));
        smdata=S.smdata;
        sminstrefresh;
        smchanrefresh;
        
    end

    function saverackpushbutton_Callback(hObject,eventdata)  
        [smdataFile,smdataPath] = uiputfile('*.mat','Save Rack As');
        save(fullfile(smdataPath,smdataFile),'smdata');
    end

    %Add a new instrument (??)
    function instadd_Callback(hObject,eventdata)
    end

    %Delete an instrument
    function instdel_Callback(hObject,eventdata)
    end

    %Edit an instrument
    function instedt_Callback(hObject,eventdata)
    end

    % Open instruments
    function instopen_Callback(hObject,eventdata)
        smopen;
    end

   
    set(f,'Visible','on')
    
    
end 