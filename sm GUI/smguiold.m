function varargout = smguiold(varargin)
% Runs special measure's GUI
% to fix: -- deselect plots after changing setchannels
%         -- selecting files/directories/run numbers
%         -- add notifications + smaux compatibility
    
   %  Create and then hide the GUI as it is being constructed.
   f = figure('Visible','on',...
       'Name','Special Measure v0.7',...
       'NumberTitle','off',...
       'Position',[300,300,900,920],...
       'Toolbar','none',...
       'Resize','off');
   movegui(f,'center')
   

   % Setup Tabs
    hg=uitabgroup;
    ht(1)=uitab(hg,'Title','Rack');
    ht(2)=uitab(hg,'Title','Scan');
    %ht(3)=uitab(hg,'Title','Oxford');

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
        'Position',[260 50 sum(channelwidths)+5*(length(channelwidths)+2) 850]);
        align([channelpanel instpanel],'Fixed',10,'Top');
        channelnameheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Name',...
            'Position',[10+sum(channelwidths(1:1)),805,channelwidths(2), 20]);
        channelinstheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Instrument',...
            'Position',[15+sum(channelwidths(1:2)),805,channelwidths(3), 20]);
        channelchanheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Channel',...
            'Position',[20+sum(channelwidths(1:3)),805,channelwidths(4), 20]);
        channelminheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Min',...
            'Position',[25+sum(channelwidths(1:4)),805,channelwidths(5), 20]);
        channelmaxheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Max',...
            'Position',[30+sum(channelwidths(1:5)),805,channelwidths(6), 20]);
        channelrampheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Ramp',...
            'Position',[35+sum(channelwidths(1:6)),805,channelwidths(7), 20]);
        channelconvheader_sth = uicontrol('Parent',channelpanel,...
            'Style','Text',...
            'String','Multiplier',...
            'Position',[40+sum(channelwidths(1:7)),805,channelwidths(8), 20]);
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
        'Position',[80 850 60 20],...
        'Callback',{@openrackpushbutton_Callback});
    % Pushbutton to save rack [matlab data file]
    saverack = uicontrol('Parent',ht(1),'Style','pushbutton','String','Save Rack',...
        'Position',[160 850 60 20],...
        'Callback',{@saverackpushbutton_Callback});
    
    
    %
    % Scans
    %
    

    
    scan_constants_ph = [];
        update_consts_pbh = []; %pb to update all the scan constants (run smset)
        consts_pmh = []; %1d array of popups for scan constants
        consts_eth = []; %1d array of edits for scan constants

    loop_panels_ph = []; % handles to panels for each loop
    loopvars_sth = []; % handles to static text for each loop (2D)
    loopvars_eth = []; % handles to edit text for each loop (2D)
    loopvars_getchans_pmh = []; %getchannel popups for each loop (2D)
    loopcvars_sth = []; % loop channel variables for each loop setchannel (3D)
    loopcvars_eth = []; % edit text for setchannels (3D)
    loopcvars_delchan_pbh=[]; %delete loop setchannel pushbuttons
    

    
    numloops_sth = uicontrol('Parent',ht(2),'Style','text',...
        'String','Loops:',...
        'HorizontalAlignment','right',...
        'Position',[5 640 40 15]);
    numloops_eth = uicontrol('Parent',ht(2),'Style','edit',...
        'String','1',...
        'Position',[55 640 20 20],...
        'Callback',@numloops_eth_Callback);
    
    loadscan_pbh = uicontrol('Parent',ht(2),'Style','pushbutton',...
        'String','Load Scan',...
        'Position',[5 860 80 25],...
        'Callback',@loadscan_pbh_Callback);
    savescan_pbh = uicontrol('Parent',ht(2),'Style','pushbutton',...
        'String','Save Scan',...
        'Position',[95 860 80 25],...
        'Callback',@savescan_pbh_Callback);  
    

    
    pptpanel = uipanel('Parent',ht(2),'Title','PowerPoint Log',...
        'Units','pixels',...
        'Position',[3 795 174 60]);
        saveppt_pbh = uicontrol('Parent',pptpanel,'Style','pushbutton',...
            'String','File',...
            'Position',[4 27 60 20],...
            'FontSize',8,...
            'Callback',@saveppt_pbh_Callback); 
        pptfile_sth = uicontrol('Parent',pptpanel,'Style','text',...
            'String','',...
            'HorizontalAlignment','center',...
            'FontSize',7,...
            'Position',[2 2 167 23]);
        appendppt_cbh = uicontrol('Parent',pptpanel,'Style','checkbox',...
            'String','Log',...
            'Position',[100 26 60 20],...
            'HorizontalAlignment','left',...
            'FontSize',8);
        
    datapanel = uipanel('Parent',ht(2),'Title','Data File',...
        'Units','pixels',...
        'Position',[3 700 174 88]);
        savedata_pbh = uicontrol('Parent',datapanel,'Style','pushbutton',...
            'String','Path',...
            'Position',[4 53 60 20],...
            'Callback',@savedata_pbh_Callback);
        datapath_sth = uicontrol('Parent',datapanel,'Style','text',...
            'String','',...
            'HorizontalAlignment','left',...
            'FontSize',7,...
            'Max',20,...
            'Position',[70 53 90 23]);
        filename_pbh = uicontrol('Parent',datapanel,'Style','pushbutton',...
            'String','File',...
            'HorizontalAlignment','right',...
            'FontSize',8,...
            'ToolTipString','Full file name = path\filename_run.mat',...
            'Position',[4 28 60 20],...
            'Callback',@filename_pbh_Callback);
        filename_eth = uicontrol('Parent',datapanel,'Style','edit',...
            'String','',...
            'HorizontalAlignment','left',...
            'FontSize',8,...
            'Position',[65 30 100 15]);
        runnumber_sth = uicontrol('Parent',datapanel,'Style','text',...
            'String','Run:',...
            'HorizontalAlignment','right',...
            'FontSize',8,...
            'Position',[4 5 30 15]);
        runnumber_eth = uicontrol('Parent',datapanel,'Style','edit',...
            'String','',...
            'HorizontalAlignment','left',...
            'FontSize',8,...
            'Position',[40 5 25 15],...
            'Callback',@runnumber_eth_Callback);     
        autoincrement_cbh = uicontrol('Parent',datapanel,'Style','checkbox',...
            'String','AutoIncrement',...
            'HorizontalAlignment','left',...
            'FontSize',7,...
            'ToolTipString','Selecting this will automatically increase run after hitting measure',...
            'Position',[90 5 80 15]);   
        
            
    smrun_pbh = uicontrol('Parent',ht(2),'Style','pushbutton',...
        'String','Measure',...
        'Position',[5 670 170 25],...
        'Callback',@smrun_pbh_Callback);
    
    
    commenttext_sth = uicontrol('Parent',ht(2),'Style','text',...
        'String','Comments:',...
        'HorizontalAlignment','left',...
        'Position',[5 600 170 20]);
    commenttext_eth = uicontrol('Parent',ht(2),'Style','edit',...
        'String','',...
        'FontSize',8,...
        'Position',[5 300 170 300],...
        'HorizontalAlignment','left',...
        'max',20,...
        'Callback',@commenttext_eth_Callback);
    
    %UI Controls for plot selection
    oneDplot_sth = uicontrol('Parent',ht(2),'Style','text',...
        'String','1D Plots',...
        'Position',[5 250 80 20]);
    oneDplot_lbh = uicontrol('Parent',ht(2),'Style','listbox',...
        'String',{},...
        'Max',10,...
        'Position',[5 50 80 200],...
        'Callback',@plot_lbh_Callback);
    twoDplot_sth = uicontrol('Parent',ht(2),'Style','text',...
        'String','2D Plots',...
        'Position',[95 250 80 20]);
    twoDplot_lbh = uicontrol('Parent',ht(2),'Style','listbox',...
        'String',{},...
        'Max',10,...
        'Position',[95 50 80 200],...
        'Callback',@plot_lbh_Callback);
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Programming the GUI     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    mInputArgs = varargin;  % Command line arguments when invoking the GUI
    mOutputArgs = {};       % Variable for storing output when GUI returns
    global smdata smscan smaux;
    datasavefile='';
    plotchoices.string={};
    plotchoices.loop=[];

    set(datapath_sth,'String',datasavefile);
    numloops = 1;

    
    if isstruct(smdata)
        sminstrefresh;
        smchanrefresh;
    end
    
    if ~isstruct(smscan)
        smscan.loops(1).npoints=100;
        smscan.loops(1).rng=[0 1];
        smscan.loops(1).getchan={};
        smscan.loops(1).setchan={};
        smscan.loops(1).setchanranges={};
        smscan.loops(1).ramptime=[];
        smscan.loops(1).trafofn={};
        smscan.loops(1).trigfn=[];
        smscan.loops(1).numchans=0;
        smscan.loops(1).waittime=0;
        smscan.saveloop=1;
        smscan.disp(1).loop=[];
        smscan.disp(1).channel=[];
        smscan.disp(1).dim=[];        
        smscan.trafofn={};
        smscan.consts=[];
        smscan.comments='';
    else
        scaninit;
    end
    
    if isstruct(smaux)
        if isfield(smaux,'pptsavefile')
            [pptsavefilepath pptsavefilename pptextension]=fileparts(smaux.pptsavefile);
            set(pptfile_sth,'String',pptsavefilename);
            set(pptfile_sth,'TooltipString',smaux.pptsavefile);
            set(appendppt_cbh,'Value',1);
        end
        
        if isfield(smaux,'datadir')
            seplocations=findstr(filesep,smaux.datadir);
            displaystring=smaux.datadir(seplocations(end-1)+1:end);
            if length(displaystring)>40
                displaystring=displaystring(end-39:end);
            end
            set(datapath_sth,'String',displaystring);
            set(datapath_sth,'TooltipString',smaux.datadir);
        end
        
        if isfield(smaux,'run')
            set(runnumber_eth,'String',smaux.run);
            runnumber_eth_Callback(runnumber_eth);
        end
    end
    
    function scaninit
        numloops = length(smscan.loops);
        set(numloops_eth,'String',numloops);
        for i=1:length(smscan.loops)
            smscan.loops(i).numchans=length(smscan.loops(i).setchan);
        end
         if ~isfield(smscan,'consts')
             smscan.consts = [];
         end
        if isfield(smscan,'comments')
            set(commenttext_eth,'String',smscan.comments);
        else
            smscan.comments='';
        end
        makelooppanels;
        setplotchoices;
        makeconstpanel;
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
        
        channelyheight = 18; %in pixels
        channelyspacing = 22; %in pixels


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
                'Position',[5,workingsize(4)-channelyspacing*i-15,channelwidths(1),channelyheight],...
                'Visible','on',...
                'Callback',{@removechannel_Callback,i});
            channelname_eth(i) = uicontrol('Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).name,...
                'Position',[10+sum(channelwidths(1:1)),workingsize(4)-channelyspacing*i-15,channelwidths(2), channelyheight],...
                'Visible','on',...
                'Callback',{@edtchannelname_Callback,i});
            instname_pmh(i) = uicontrol('Parent',channelpanel,...
                'Style','popupmenu',...
                'String',['none' instnames],...
                'Value',smdata.channels(i).instchan(1)+1,...
                'Position',[15+sum(channelwidths(1:2)),workingsize(4)-channelyspacing*i-13,channelwidths(3), channelyheight],...
                'Callback',{@instname_pmh_Callback,i});
            instchan_pmh(i) = uicontrol('Parent',channelpanel,...
                'Style','popupmenu',...
                'String',['none' cellstr(smdata.inst(smdata.channels(i).instchan(1)).channels)'],...
                'Value',smdata.channels(i).instchan(2)+1,...
                'Position',[20+sum(channelwidths(1:3)),workingsize(4)-channelyspacing*i-13,channelwidths(4), channelyheight],...
                'Callback',{@instchan_pmh_Callback,i});
            channelmin_eth(i) = uicontrol('Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(1),...
                'Position',[25+sum(channelwidths(1:4)),workingsize(4)-channelyspacing*i-15,channelwidths(5), channelyheight],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelmin_eth_Callback,i});
            channelmax_eth(i) = uicontrol('Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(2),...
                'Position',[30+sum(channelwidths(1:5)),workingsize(4)-channelyspacing*i-15,channelwidths(6), channelyheight],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelmax_eth_Callback,i});
            channelramprate_eth(i) = uicontrol('Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(3),...
                'Position',[35+sum(channelwidths(1:6)),workingsize(4)-channelyspacing*i-15,channelwidths(7), channelyheight],...
                'HorizontalAlignment','Right',...
                'Callback',{@channelramprate_eth_Callback,i});
            channelconv_eth(i) = uicontrol('Parent',channelpanel,...
                'Style','edit',...
                'String',smdata.channels(i).rangeramp(4),...
                'Position',[40+sum(channelwidths(1:7)),workingsize(4)-channelyspacing*i-15,channelwidths(8), channelyheight],...
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
        makeconstpanel;
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

    %Change the number of loops in the scan
    function numloops_eth_Callback(hObject,eventdata)
        val = str2double(get(hObject,'String'));
        if (isnan(val) || mod(val,1)~=0 || val<1)
            errordlg('Please enter a positive integer','Invalid Input Value');
            set(hObject,'String',numloops);
            return;
        elseif ~isstruct(smdata)
            errordlg('Please load a rack','Illegal Action');
            return;
        else
            numloops = val;
        end        
        makelooppanels;
        makeconstpanel;
    end

    function makeconstpanel
        delete(scan_constants_ph);
        scan_constants_ph = uipanel('Parent',ht(2),'Title','Constants',...
            'Units','Pixels',...
            'Position', [180 600 700 290]);
    
        update_consts_pbh = uicontrol('Parent',scan_constants_ph,...
            'Style','pushbutton',...
            'String','Update Constants',...
            'Position',[550 10 130 30],...
            'Callback',@update_consts_pbh_Callback);
        
        numconsts=length(smscan.consts);
        channelnames = {};
        for k = 1:length(smdata.channels)
            channelnames{k}=smdata.channels(k).name;
        end
        
        parentsize=[180 600 700 290];
        pos1 = [5 parentsize(4)-40 0 0];
        cols = 4;      
        for i=1:numconsts
            if strmatch('none',smscan.consts(i).setchan, 'exact')
                chanval=1;
            else
                try
                  chanval=smchanlookup(smscan.consts(i).setchan)+1;
                catch 
                    errordlg([smscan.consts(i).setchan ' is not a channel'],...
                      'Invalid Channel in smscan');
                    chanval=1;
                end
            end
            consts_pmh(i) = uicontrol('Parent',scan_constants_ph,...
                'Style','popupmenu',...
                'String',['none' channelnames],...
                'Value',chanval,...
                'HorizontalAlignment','center',...
                'Position',pos1+[175*(mod(i-1,cols)) -33*(floor((i-1)/cols)) 100 20],...
                'Callback',{@consts_pmh_Callback,i});
            consts_eth(i) = uicontrol('Parent',scan_constants_ph,...
                'Style','edit',...
                'String',smscan.consts(i).val,...
                'HorizontalAlignment','center',...
                'Position',pos1+[175*(mod(i-1,cols))+105 -33*(floor((i-1)/cols)) 50 20],...
                'Callback',{@consts_eth_Callback,i});
        end
        if isempty(i)
            i=0;
        end
        i=i+1;
        chanval = 1;

        consts_pmh(i) = uicontrol('Parent',scan_constants_ph,...
            'Style','popupmenu',...
            'String',['none' channelnames],...
            'Value',chanval,...
            'HorizontalAlignment','center',...
            'Position',pos1+[175*(mod(i-1,cols)) -33*(floor((i-1)/cols)) 100 20],...
            'Callback',{@consts_pmh_Callback,i});

        consts_eth(i) = uicontrol('Parent',scan_constants_ph,...
            'Style','edit',...
            'String',0,...
            'HorizontalAlignment','center',...
            'Position',pos1+[175*(mod(i-1,cols))+105 -33*(floor((i-1)/cols)) 50 20],...
            'Callback',{@consts_eth_Callback,i});
        
    end


    % make or delete looppanels
    % postcon: length(loop_panels_ph) = length(smscan.loops) = numloops
    function makelooppanels
        panel1position = [180 600 700 190];

        for i=1:length(loop_panels_ph)
            delete(loop_panels_ph(i));
        end
        loop_panels_ph=[];
        

        for i = (length(loop_panels_ph)+1):numloops % display data from existing loops
            loop_panels_ph(i) = uipanel('Parent',ht(2),...
                'Units','pixels',...
                'Position',panel1position+[0*(i) -200*(i) -0*(i) 0]);
        
            % for new loops only
            if i>length(smscan.loops)
                smscan.loops(i).npoints=101;
                smscan.loops(i).rng=[0 1];
                smscan.loops(i).getchan=[];
                smscan.loops(i).setchan={'none'};
                %smscan.loops(i).setchanranges={[0 1]};
                smscan.loops(i).ramptime=[];
                smscan.loops(i).trafofn=[];
                smscan.loops(i).trigfn=[];
                smscan.loops(i).numchans=0;
                smscan.loops(i).waittime=0;
            end
            
            %Pushbutton for adding setchannels to the loop
            loopvars_addchan_pbh(i) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','pushbutton',...
                'String','Add Channel',...
                'Position',[25 147 100 20],...
                'Callback',{@loopvars_addchan_pbh_Callback,i});
            
            %Number of points in loop
            if isfield(smscan.loops(i),'npoints')
                numpoints(i)=smscan.loops(i).npoints;
            else
                numpoints(i)=nan;
            end
            loopvars_sth(i,1) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Points:',...
                'HorizontalAlignment','right',...
                'Position',[165 147 50 20]);
            loopvars_eth(i,1) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',numpoints(i),...
                'HorizontalAlignment','center',...
                'Position',[215 152 50 20],...
                'Callback',{@loopvars_eth_Callback,i,1});
            
            %Step Time
            loopvars_sth(i,2) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Step time:',...
                'HorizontalAlignment','right',...
                'Position',[355 147 55 20]);
            loopvars_eth(i,2) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',smscan.loops(i).ramptime,...
                'HorizontalAlignment','center',...
                'Position',[415 152 55 20],...
                'Callback',{@loopvars_eth_Callback,i,2});

            %Wait times            
            loopvars_sth(i,3) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Wait (s):',...
                'TooltipString','Wait before getting data',...
                'HorizontalAlignment','right',...
                'Position',[555 147 55 20]);
            loopvars_eth(i,3) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',0,...
                'HorizontalAlignment','center',...
                'Position',[615 152 55 20],...
                'Callback',{@loopvars_eth_Callback,i,3});
            if isfield(smscan.loops(i),'waittime')
                set(loopvars_eth(i,3),'String',smscan.loops(i).waittime);
            end

%             %trafofn
%             if isa(smscan.loops(i).trafofn,'function_handle')
%                 trafofn=smscan.loops(i).trafofn;
%             else
%                 trafofn='none';
%             end
%             loopvars_sth(i,3) = uicontrol('Parent',loop_panels_ph(i),...
%                 'Style','text',...
%                 'String','trafofn:',...
%                 'HorizontalAlignment','right',...
%                 'Position',[555 147 55 20]);
%             loopvars_eth(i,3) = uicontrol('Parent',loop_panels_ph(i),...
%                 'Style','edit',...
%                 'String',trafofn,...
%                 'HorizontalAlignment','center',...
%                 'Position',[615 152 55 20],...
%                 'Callback',{@loopvars_eth_Callback,i,3});
            
            %Add UI controls for set channels
            for j=1:smscan.loops(i).numchans
                makeloopchannelset(i,j);
            end
            
            
            %Add popup menus for get channels 
            loopvars_sth(i,4) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Record:',...
                'HorizontalAlignment','center',...
                'Position',[5 5 50 20]);
            makeloopgetchans(i);
            setplotchoices;
        end
           
       
        %delete loops   
        for i = (numloops+1):length(loop_panels_ph)       
            delete(loop_panels_ph(i));            
        end
        smscan.loops = smscan.loops(1:numloops);
        
        loop_panels_ph=loop_panels_ph(1:numloops);
        loopvars_eth=loopvars_eth(1:numloops,:);
        loopvars_sth=loopvars_sth(1:numloops,:);

        
        %label the loops
        set(loop_panels_ph(numloops),'Title',sprintf('Loop %d (outer)',numloops));
        set(loop_panels_ph(1),'Title',sprintf('Loop %d (inner)',1));
        for k = 2:numloops-1
            set(loop_panels_ph(k),'Title',sprintf('Loop %d',k));
        end      
        
        
        
    end

    % makes ui objects for setchannel j on loop i                
    function makeloopchannelset(i,j) 

        size = get(loop_panels_ph(i),'Position');
        pos = [5 size(4)-50-25*j 0 0];
        w = [100 40 40 40 40 40]; % widths
        h = [20 20 20 20 20 20 20 20 20 20 50]; % heights
        s = 95; %spacing       
        
        % button to delete this setchannel
        loopcvars_delchan_pbh(i,j) = uicontrol('Parent',loop_panels_ph(i),...
            'Style','pushbutton',...
            'String','Delete',...
            'Position',pos+[0 0 50 20],...
            'Callback',{@loopcvars_delchan_pbh_Callback,i,j});
        
        % select channel being ramped
        channelnames = {};
        for k = 1:length(smdata.channels)
            channelnames{k}=smdata.channels(k).name;
        end
        loopcvars_sth(i,j,1) = uicontrol('Parent',loop_panels_ph(i),...
            'Style','text',...
            'String','Channel:',...
            'HorizontalAlignment','right',...
            'Position',pos+[55 -5 45 h(1)]);
        
        if strmatch('none',smscan.loops(i).setchan{j}, 'exact')
            chanval=1;
        else
            try
                chanval=smchanlookup(smscan.loops(i).setchan{j})+1;
            catch 
                errordlg([smscan.loops(i).setchan{j} ' is not a channel'],...
                    'Invalid Channel in smscan');
                chanval=1;
            end
        end
        loopcvars_eth(i,j,1) = uicontrol('Parent',loop_panels_ph(i),...
            'Style','popupmenu',...
            'String',['none' channelnames],...
            'Value',chanval,...
            'HorizontalAlignment','center',...
            'Position',pos+[105 0 w(1) h(1)],...
            'Callback',{@loopcvars_eth_Callback,i,j,1});
        
        if isfield(smscan.loops(i), 'setchanranges')
            %minimum
            loopcvars_sth(i,j,2) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Min:',...
                'HorizontalAlignment','right');
            loopcvars_eth(i,j,2) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',smscan.loops(i).setchanranges{j}(1),...
                'HorizontalAlignment','center',...
                'Callback',{@loopcvars_eth_Callback,i,j,2});

            %max
            loopcvars_sth(i,j,3) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Max:',...
                'HorizontalAlignment','right');
            loopcvars_eth(i,j,3) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',smscan.loops(i).setchanranges{j}(2),...
                'HorizontalAlignment','center',...
                'Callback',{@loopcvars_eth_Callback,i,j,3});

            %mid
            loopcvars_sth(i,j,4) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Mid:',...
                'HorizontalAlignment','right');
            loopcvars_eth(i,j,4) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',mean(smscan.loops(i).setchanranges{j}),...
                'HorizontalAlignment','center',...
                'Callback',{@loopcvars_eth_Callback,i,j,4});

            %range
            loopcvars_sth(i,j,5) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Range:',...
                'HorizontalAlignment','right');
            loopcvars_eth(i,j,5) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',smscan.loops(i).setchanranges{j}(2)-smscan.loops(i).setchanranges{j}(1),...
                'HorizontalAlignment','center',...
                'Callback',{@loopcvars_eth_Callback,i,j,5});

            %stepsize
            loopcvars_sth(i,j,6) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Step:',...
                'HorizontalAlignment','right');
            loopcvars_eth(i,j,6) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',(smscan.loops(i).setchanranges{j}(2)-smscan.loops(i).setchanranges{j}(1))/(smscan.loops(i).npoints-1),...
                'HorizontalAlignment','center',...
                'Callback',{@loopcvars_eth_Callback,i,j,6});       

            for k=2:6
                set(loopcvars_sth(i,j,k),'Position',pos+[s*k-45+60 -5 w(k) h(k)]);
                set(loopcvars_eth(i,j,k),'Position',pos+[s*k+60 0 w(k) h(k)]);            
            end
            
        elseif j==1 %first setchan in locked trafofn mode, loop range != [0 1];
             %minimum
            loopcvars_sth(i,j,2) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Min:',...
                'HorizontalAlignment','right');
            loopcvars_eth(i,j,2) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',smscan.loops(i).rng(1),...
                'HorizontalAlignment','center',...
                'Callback',{@loopcvarsLOCKT_eth_Callback,i,j,2});

            %max
            loopcvars_sth(i,j,3) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Max:',...
                'HorizontalAlignment','right');
            loopcvars_eth(i,j,3) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',smscan.loops(i).rng(2),...
                'HorizontalAlignment','center',...
                'Callback',{@loopcvarsLOCKT_eth_Callback,i,j,3});

            %mid
            loopcvars_sth(i,j,4) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Mid:',...
                'HorizontalAlignment','right');
            loopcvars_eth(i,j,4) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',mean(smscan.loops(i).rng),...
                'HorizontalAlignment','center',...
                'Callback',{@loopcvarsLOCKT_eth_Callback,i,j,4});

            %range
            loopcvars_sth(i,j,5) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Range:',...
                'HorizontalAlignment','right');
            loopcvars_eth(i,j,5) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',smscan.loops(i).rng(2)-smscan.loops(i).rng(1),...
                'HorizontalAlignment','center',...
                'Callback',{@loopcvarsLOCKT_eth_Callback,i,j,5});

            %stepsize
            loopcvars_sth(i,j,6) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String','Step:',...
                'HorizontalAlignment','right');
            loopcvars_eth(i,j,6) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','edit',...
                'String',(smscan.loops(i).rng(2)-smscan.loops(i).rng(1))/(smscan.loops(i).npoints-1),...
                'HorizontalAlignment','center',...
                'Callback',{@loopcvarsLOCKT_eth_Callback,i,j,6});       

            for k=2:6
                set(loopcvars_sth(i,j,k),'Position',pos+[s*k-45+60 -5 w(k) h(k)]);
                set(loopcvars_eth(i,j,k),'Position',pos+[s*k+60 0 w(k) h(k)]);            
            end
        else
            %trafofn locked for this channel
            loopcvars_sth(i,j,2) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','text',...
                'String',['Values Locked.  Check smscan.loops(' int2str(i) ').trafofn at command line'],...
                'HorizontalAlignment','right',...
                'Position',pos+[s*2-45+60 -5 350 h(2)]);
        end     
       
            
    end

    % Make the getchannel UI popup objects for loop i
    function makeloopgetchans(i)
        numgetchans=length(smscan.loops(i).getchan);
        loopvars_getchans_pmh=[];
        channelnames = {};
        for k = 1:length(smdata.channels)
            channelnames{k}=smdata.channels(k).name;
        end
        

        for j=1:numgetchans
            try
                chanval=smchanlookup(smscan.loops(i).getchan{j})+1;
            catch 
                errordlg([smscan.loops(i).getchan{j} ' is not a channel'],...
                    'Invalid Channel in smscan');
                chanval=1;
            end
            loopvars_getchans_pmh(i,j) = uicontrol('Parent',loop_panels_ph(i),...
                'Style','popupmenu',...
                'String',['none' channelnames],...
                'Value',chanval,...
                'HorizontalAlignment','center',...
                'Position',[60+120*(j-1) 10 100 20],...
                'Callback',{@loopvars_getchans_pmh_Callback,i,j});
        end
        
        if numgetchans==0 j=0;
        end

        loopvars_getchans_pmh(i,j+1) = uicontrol('Parent',loop_panels_ph(i),...
            'Style','popupmenu',...
            'String',['none' channelnames],...
            'Value',1,...
            'HorizontalAlignment','center',...
            'Position',[60+120*(j) 10 100 20],...
            'Callback',{@loopvars_getchans_pmh_Callback,i,j+1});

        
    end

    function savescan_pbh_Callback(hObject,eventdata)
        [smscanFile,smscanPath] = uiputfile('*.mat','Save Scan As');
        save(fullfile(smscanPath,smscanFile),'smscan');
    end

    function loadscan_pbh_Callback(hObject,eventdata)
        [smscanFile,smscanPath] = uigetfile('*.mat','Select Scan File');
        S=load (fullfile(smscanPath,smscanFile));
        smscan=S.smscan;
        scaninit;
    end

    function loopvars_addchan_pbh_Callback(hObject,eventdata,i)
        smscan.loops(i).numchans=smscan.loops(i).numchans+1;
        smscan.loops(i).setchan{smscan.loops(i).numchans}='none';
        if isfield(smscan.loops(i), 'setchanranges')
            smscan.loops(i).setchanranges{smscan.loops(i).numchans}=[0 1];
        elseif smscan.loops(i).numchans == 1; %for locked trafofn mode
            smscan.loops(i).rng=[0 1];
        end
        makeloopchannelset(i,smscan.loops(i).numchans);
    end

    function loopcvars_delchan_pbh_Callback(hObject,eventdata,i,j)
        smscan.loops(i).numchans=smscan.loops(i).numchans-1;
        if smscan.loops(i).numchans<0
            smscan.loops(i).numchans=0;
        end
        smscan.loops(i).setchan(j)=[];
        if isfield(smscan.loops(i),'trafofn')&&(length(smscan.loops(i).trafofn)>=j)
            smscan.loops(i).trafofn(j)=[];
        end
        if isfield(smscan.loops(i),'setchanranges')&&(length(smscan.loops(i).setchanranges)>=j)
            smscan.loops(i).setchanranges(j)=[];
        end
        makelooppanels;
    end

    % Callbacks for loop variable edit text boxes (Points, ramptime,
    % trafofn)
    function loopvars_eth_Callback(hObject,eventdata,i,j)
        val = str2double(get(hObject,'String'));
        if j==1  %number of points being changed
            if (isnan(val) || mod(val,1)~=0 || val<1)
                errordlg('Please enter a positive integer','Invalid Input Value');
                set(hObject,'String',smscan.loops(i).npoints);
                return;
            else
                smscan.loops(i).npoints = val;
                for j=1:smscan.loops(i).numchans
                    makeloopchannelset(i,j)
                end
            end        
        elseif j==2  %Ramptime being changed
            val = str2double(get(hObject,'String'));         
            smscan.loops(i).ramptime=val;
        elseif j==3  %adjust wait time for scan
            val=str2double(get(hObject,'String'));
            if (val<0)
                errordlg('Please enter a nonzero number','Invalid Input Value');
                set(hObject,'String',smscan.loops(i).npoints);
                return;
            else
                smscan.loops(i).waittime=val;
            end
        end                
    end

    %Callbacks for loop variable channel edit text boxes (channel, min,
    %   max, mid, range, step)   
    function loopcvars_eth_Callback(hObject,eventdata,i,j,k)
        if k==1 % Change the channel being ramped
            smscan.loops(i).setchan(j)={smdata.channels(get(hObject,'Value')-1).name};
        elseif k==2 % Change the min value of the channel
            val = str2double(get(hObject,'String'));
            smscan.loops(i).setchanranges{j}(1)=val;
%             smscan.loops(i).trafofn{j}=@(x, y) x(i)*smscan.loops(i).setchanranges{j}(2)+(1-x(i))*smscan.loops(i).setchanranges{j}(1);
        elseif k==3 % Change the max value of the channel
            val = str2double(get(hObject,'String'));
            smscan.loops(i).setchanranges{j}(2)=val;
%             rng=smscan.loops(i).setchanranges{j};
%             smscan.loops(i).trafofn{j}=@(x, y) x(i)*rng(2)+(1-x(i))*rng(1);
        elseif k==4 %Change the mid value of the channel
            val = str2double(get(hObject,'String'));
            range=smscan.loops(i).setchanranges{j}(2)-smscan.loops(i).setchanranges{j}(1);
            smscan.loops(i).setchanranges{j}(1)=val-range/2;
            smscan.loops(i).setchanranges{j}(2)=val+range/2;
            rng=smscan.loops(i).setchanranges{j};
%             smscan.loops(i).trafofn{j}=@(x, y) x(i)*rng(2)+(1-x(i))*rng(1);
        elseif k==5 % Change the range of the channel
            val = str2double(get(hObject,'String'));
            mid = (smscan.loops(i).setchanranges{j}(2)+smscan.loops(i).setchanranges{j}(1))/2;
            smscan.loops(i).setchanranges{j}(1)=mid-val/2;
            smscan.loops(i).setchanranges{j}(2)=mid+val/2;
            rng=smscan.loops(i).setchanranges{j};
%             smscan.loops(i).trafofn{j}=@(x, y) x(i)*rng(2)+(1-x(i))*rng(1);
        elseif k==6 % change the stepsize *FOR ALL CHANNELS IN THIS LOOP*
            val = str2double(get(hObject,'String'));
            range=smscan.loops(i).setchanranges{j}(2)-smscan.loops(i).setchanranges{j}(1);
            smscan.loops(i).npoints=floor(range/val+1);
            set(loopvars_eth(i,1),'String',smscan.loops(i).npoints);
            for c=1:smscan.loops(i).numchans
                makeloopchannelset(i,c)
            end
        end
        makeloopchannelset(i,j);
    end

    %Callbacks for loop variable channel #1, in fixed trafofn mode (range
    %stored in loops.rng instead of in loops.setchanranges)
    function loopcvarsLOCKT_eth_Callback(hObject,eventdata,i,j,k)
        if k==1 % Change the channel being ramped
            smscan.loops(i).setchan(j)={smdata.channels(get(hObject,'Value')-1).name};
        elseif k==2 % Change the min value of the channel
            val = str2double(get(hObject,'String'));
            smscan.loops(i).rng(1)=val;
        elseif k==3 % Change the max value of the channel
            val = str2double(get(hObject,'String'));
            smscan.loops(i).rng(2)=val;
        elseif k==4 %Change the mid value of the channel
            val = str2double(get(hObject,'String'));
            range=smscan.loops(i).rng(2)-smscan.loops(i).rng(1);
            smscan.loops(i).rng(1)=val-range/2;
            smscan.loops(i).rng(2)=val+range/2;
        elseif k==5 % Change the range of the channel
            val = str2double(get(hObject,'String'));
            mid = (smscan.loops(i).rng(2)+smscan.loops(i).rng(1))/2;
            smscan.loops(i).rng(1)=mid-val/2;
            smscan.loops(i).rng(2)=mid+val/2; 
        elseif k==6 % change the stepsize 
            val = str2double(get(hObject,'String'));
            range=smscan.loops(i).rng(2)-smscan.loops(i).rng(1);
            smscan.loops(i).npoints=floor(range/val+1);
            set(loopvars_eth(i,1),'String',smscan.loops(i).npoints);
            for c=1:smscan.loops(i).numchans
                makeloopchannelset(i,c)
            end
        end
        makeloopchannelset(i,j);
    end

    %Callback for getchannel pmh
    function loopvars_getchans_pmh_Callback(hObject,eventdata,i,j)
        val = get(hObject,'Value');
        if val==1
            smscan.loops(i).getchan(j)=[];
        else
            smscan.loops(i).getchan{j}=smdata.channels(get(hObject,'Value')-1).name;
        end
        smscan.disp=[];
        makelooppanels;
    end

    %Callback for the constants pmh
    function consts_pmh_Callback(hObject,eventdata,i)
        val=get(hObject,'Value');
        if val==1
            smscan.consts(i)=[];
        else
            smscan.consts(i).setchan = smdata.channels(get(hObject,'Value')-1).name;
            if ~isfield(smscan.consts(i),'val')
                smscan.consts(i).val=0;
            end
        end
        makeconstpanel;
    end

    %Callback for the constants eth
    function consts_eth_Callback(hObject,eventdata,i)  
        val = str2double(get(hObject,'String'));
        if (isnan(val))
            errordlg('Please enter a real number','Invalid Input Value');
            set(hObject,'String',0);
            return;
        end
        smscan.consts(i).val=val;
    end

    %Callback for update constants pushbutton
    function update_consts_pbh_Callback(hObject,eventdata)  
        for i=1:length(smscan.consts)
            prolog_setchans{i}=smscan.consts(i).setchan;
            prolog_vals(i)=smscan.consts(i).val;
        end
        smset(prolog_setchans, prolog_vals);
    end
    
    % Callback for data file location pushbutton
    function savedata_pbh_Callback(hObject,eventdata)
        %[savedataFile,savedataPath] = uiputfile('*.mat','Save Data As');
        smaux.datadir = uigetdir;
        %datasavefile=fullfile(savedataPath,savedataFile);
        seplocations=findstr(filesep,smaux.datadir);
        displaystring=smaux.datadir(seplocations(end-1)+1:end);
        if length(displaystring)>40
            displaystring=displaystring(end-39:end);
        end
        set(datapath_sth,'String',displaystring);
        set(datapath_sth,'TooltipString',smaux.datadir);
    end

    function filename_pbh_Callback(hObject,eventdata)
        [savedataFile,savedataPath] = uiputfile('*.mat','Save Data As');
        if savedataPath ~= 0 
            smaux.datadir=savedataPath(1:end-1);
            seplocations=findstr(filesep,smaux.datadir);
            displaystring=smaux.datadir(seplocations(end-1)+1:end);
            if length(displaystring)>40
                displaystring=displaystring(end-39:end);
            end
            set(datapath_sth,'String',displaystring);
            set(datapath_sth,'TooltipString',smaux.datadir);

            savedataFile=savedataFile(1:end-4); %crop off .mat
            separators=strfind(savedataFile,'_');
            if separators
                runstring=savedataFile(separators(end)+1:end);
                rundouble=str2double(runstring);
                if ~isnan(rundouble)
                    runint=uint16(rundouble);
                    smaux.run=runint;
                    set(runnumber_eth,'String',smaux.run);
                    savedataFile=savedataFile(1:separators(end)-1); %crop off runstring
                end
            end
            set(filename_eth,'String',savedataFile);          
        end
    end

    % Callback for ppt file location pushbutton
    function saveppt_pbh_Callback(hObject,eventdata)
        [pptFile,pptPath] = uiputfile('*.ppt','Append to Presentation');
        if pptFile ~= 0
            smaux.pptsavefile=fullfile(pptPath,pptFile);   
            set(pptfile_sth,'String',pptFile);
        end
        
        set(pptfile_sth,'TooltipString',smaux.pptsavefile);
    end

    % Callback for updating run number
    function runnumber_eth_Callback(hObject,eventdata)
        if isempty(get(hObject,'String'))
            set(autoincrement_cbh,'Value',0);
            smaux.run=[];
        else
            val = str2double(get(hObject,'String'));
            if ~isnan(val) && isinteger(uint16(val)) && uint16(val)>=0 && uint16(val)<=999
                smaux.run=uint16(val);
                set(hObject,'String',smaux.run);
            else
                errordlg('Please enter an integer in [000 999]','Bad Run Number');
                set(hObject,'String','');
            end
        end
    end

    % Callback for running the scan (call to smrun)
    function smrun_pbh_Callback(hObject,eventdata)
        
        % handle setting up self-ramping trigger for inner loop
        if smscan.loops(1).ramptime<0 && (~isfield(smscan.loops(1),'trigfn') || ...
                                            isempty(smscan.loops(1).trigfn) || ...
                                            (isfield(smscan.loops(1).trigfn,'autoset') && smscan.loops(1).trigfn.autoset))
            smscan.loops(1).trigfn.fn=@smatrigfn;
            smscan.loops(1).trigfn.args{1}=smchaninst(smscan.loops(1).setchan);
        end
                
        
        
        % create a good filename
        pathstring = get(datapath_sth,'String');
        filestring = get(filename_eth,'String');      
        runstring = get(runnumber_eth,'String');
        if isempty(pathstring) || isempty(filestring)
            filename_pbh_Callback(filename_pbh);
            
            filestring = get(filename_eth,'String');
            if isempty(runstring)
                datasaveFile = fullfile(smaux.datadir,[filestring '.mat']);
            else
                runstring=sprintf('%03u',smaux.run);
                datasaveFile = fullfile(smaux.datadir,[filestring '_' runstring '.mat']);
            end
        else        
            if isempty(runstring)
                datasaveFile = fullfile(smaux.datadir,[filestring '.mat']);
            else
                runstring=sprintf('%03u',smaux.run);
                datasaveFile = fullfile(smaux.datadir,[filestring '_' runstring '.mat']);
            end

            if exist(datasaveFile,'file')
                if get(autoincrement_cbh,'Value') && isinteger(smaux.run)
                     while exist(datasaveFile,'file')
                        smaux.run=smaux.run+1;
                        set(runnumber_eth,'String',smaux.run);
                        runstring=sprintf('%03u',smaux.run);
                        datasaveFile = fullfile(smaux.datadir,[filestring '_' runstring '.mat']);
                     end
                else
                    filename_pbh_Callback(filename_pbh);
                    filestring = get(filename_eth,'String');
                    if isempty(runstring)
                        datasaveFile = fullfile(smaux.datadir,[filestring '.mat']);
                    else
                        runstring=sprintf('%03u',smaux.run);
                        datasaveFile = fullfile(smaux.datadir,[filestring '_' runstring '.mat']);
                    end
                end
            end
        end
                    
                
        
      smrun(smscan,datasaveFile);
        if get(appendppt_cbh,'Value')
            slide.title = [filestring '_' runstring '.mat'];
            slide.body = smscan.comments;
            slide.consts=smscan.consts;
            smsaveppt(smaux.pptsavefile,slide,'-f1000');
        end
    end

    
    %callback for comment text
    function commenttext_eth_Callback(hObject,eventdata)
        smscan.comments = (get(hObject,'String'));
    end

    %populates plot choices
    function setplotchoices
        temp={smscan.loops.getchan};
        plotchoices.string={};
        plotchoices.loop=[];
        for i=1:length(temp)
            for j=1:length(temp{i})
                plotchoices.string={plotchoices.string{:} temp{i}{j}};
                plotchoices.loop=[plotchoices.loop i];
            end
        end
        set(oneDplot_lbh,'String',plotchoices.string);       
        set(twoDplot_lbh,'String',plotchoices.string);       
        newoneDvals = [];
        newtwoDvals = [];
        for i=1:length(smscan.disp)
            if smscan.disp(i).dim==1
                newoneDvals = [newoneDvals smscan.disp(i).channel];
            elseif smscan.disp(i).dim == 2
                newtwoDvals = [newtwoDvals smscan.disp(i).channel];
            end
        end
        sort(newoneDvals);
        sort(newtwoDvals);
        set(oneDplot_lbh,'Val',newoneDvals);
        set(twoDplot_lbh,'Val',newtwoDvals);
    end

    %callback for plot list box objects
    function plot_lbh_Callback(hObject,eventdata)
       vals1d = get(oneDplot_lbh,'Val');
       vals2d = get(twoDplot_lbh,'Val');
       smscan.disp=[];
       for i = 1:length(vals1d)
           smscan.disp(i).loop=plotchoices.loop(vals1d(i));
           smscan.disp(i).channel=vals1d(i);
           smscan.disp(i).dim=1;
       end
       for i = (length(vals1d)+1):(length(vals1d)+length(vals2d))
           smscan.disp(i).loop=plotchoices.loop(vals2d(i-length(vals1d)))+1;
           smscan.disp(i).channel=vals2d(i-length(vals1d));
           smscan.disp(i).dim=2;
       end
    end
    set(f,'Visible','on')
    
    
end 