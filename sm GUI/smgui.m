function varargout = smgui(varargin)
% Runs special measure's GUI
% to fix: -- deselect plots after changing setchannels
%         -- selecting files/directories/run numbers
%         -- add notifications + smaux compatibility
 global smdata smscan smaux;
 
switch nargin
    case 1
        eval(varargin{1});
        return;
    case 2
        eval([varargin{1} '(varargin{2});']);
        return;
end

    if isfield(smaux,'smgui') && ishandle(smaux.smgui.figure1)
        Update
        figure(smaux.smgui.figure1)
        movegui(smaux.smgui.figure1,'center')
        return
    end

    %  Create and then hide the GUI as it is being constructed.
   smaux.smgui.figure1 = figure('Visible','on',...
       'Name','Special Measure v0.9',...
       'MenuBar','none', ...
       'NumberTitle','off',...
       'IntegerHandle','off',...
       'Position',[300,300,900,920],...
       'Toolbar','none',...
       'Resize','off');
   movegui(smaux.smgui.figure1,'center')
   
   %put everything in this panel for aesthetic purposes
   smaux.smgui.nullpanel=uipanel('Parent',smaux.smgui.figure1,...
        'Units','pixels','Position',[0,0,905,925]);
    
    %Menu Configuration
    smaux.smgui.FileMenu = uimenu('Parent',smaux.smgui.figure1,...
        'HandleVisibility','callback',...
        'Label','File');
    
        smaux.smgui.OpenScan = uimenu('Parent',smaux.smgui.FileMenu,...
            'Label','Open Scan',...
            'HandleVisibility','Callback',...
            'Accelerator','o',...
            'Callback',@LoadScan);
        smaux.smgui.SaveScan = uimenu('Parent',smaux.smgui.FileMenu,...
            'Label','Save Scan',...
            'HandleVisibility','Callback',...
            'Accelerator','s',...
            'Callback',@SaveScan);

        smaux.smgui.OpenRack = uimenu('Parent',smaux.smgui.FileMenu,...
            'Separator','on',...
            'Label','Open Rack',...
            'HandleVisibility','Callback',...
            'Callback',@OpenRack);
        smaux.smgui.SaveRack = uimenu('Parent',smaux.smgui.FileMenu,...
            'Label','Save Rack',...
            'HandleVisibility','Callback',...
            'Callback',@SaveRack);
       smaux.smgui.EditRack = uimenu('Parent',smaux.smgui.FileMenu,...
            'Label','Edit Rack',...
            'HandleVisibility','Callback',...
            'Callback',@EditRack);

    smaux.smgui.scan_constants_ph = [];
        smaux.smgui.update_consts_pbh = []; %pb to update all the scan constants (run smset)
        smaux.smgui.consts_pmh = []; %1d array of popups for scan constants (set)
        smaux.smgui.consts_eth = []; %1d array of edits for scan constants (set)
        smaux.smgui.setconsts_cbh=[];
    smaux.smgui.loop_panels_ph = []; % handles to panels for each loop
    smaux.smgui.loopvars_sth = []; % handles to static text for each loop (2D)
    smaux.smgui.loopvars_eth = []; % handles to edit text for each loop (2D)
    smaux.smgui.loopvars_getchans_pmh = []; %getchannel popups for each loop (2D)
    smaux.smgui.loopcvars_sth = []; % loop channel variables for each loop setchannel (3D)
    smaux.smgui.loopcvars_eth = []; % edit text for setchannels (3D)
    smaux.smgui.loopcvars_delchan_pbh=[]; %delete loop setchannel pushbuttons
    

    
    
    
    smaux.smgui.scantitle_panel = uipanel('Parent',smaux.smgui.nullpanel,'Title','Scan Name',...
        'Units','pixels',...
        'Position',[3 850 174 40]);
        smaux.smgui.scantitle_eth = uicontrol('Parent',smaux.smgui.scantitle_panel,'Style','edit',...
            'String','',...
            'HorizontalAlignment','left',...
            'FontSize',8,...
            'Position',[3 4 166 20],...
            'Callback',@ScanTitle);

    
    smaux.smgui.pptpanel = uipanel('Parent',smaux.smgui.nullpanel,'Title','PowerPoint Log',...
        'Units','pixels',...
        'Position',[3 791 174 60]);
        smaux.smgui.saveppt_pbh = uicontrol('Parent',smaux.smgui.pptpanel,'Style','pushbutton',...
            'String','File',...
            'Position',[4 27 60 20],...
            'FontSize',8,...
            'Callback',@SavePPT); 
        smaux.smgui.pptfile_sth = uicontrol('Parent',smaux.smgui.pptpanel,'Style','text',...
            'String','',...
            'HorizontalAlignment','center',...
            'FontSize',7,...
            'Position',[2 2 167 23]);
        smaux.smgui.appendppt_cbh = uicontrol('Parent',smaux.smgui.pptpanel,'Style','checkbox',...
            'String','Log',...
            'Position',[100 26 60 20],...
            'HorizontalAlignment','left',...
            'FontSize',8);
        
    smaux.smgui.datapanel = uipanel('Parent',smaux.smgui.nullpanel,'Title','Data File',...
        'Units','pixels',...
        'Position',[3 700 174 88]);
        smaux.smgui.savedata_pbh = uicontrol('Parent',smaux.smgui.datapanel,'Style','pushbutton',...
            'String','Path',...
            'Position',[4 53 60 20],...
            'Callback',@SavePath);
        smaux.smgui.datapath_sth = uicontrol('Parent',smaux.smgui.datapanel,'Style','text',...
            'String','',...
            'HorizontalAlignment','left',...
            'FontSize',7,...
            'Max',20,...
            'Position',[70 53 90 23]);
        smaux.smgui.filename_pbh = uicontrol('Parent',smaux.smgui.datapanel,'Style','pushbutton',...
            'String','File',...
            'HorizontalAlignment','right',...
            'FontSize',8,...
            'ToolTipString','Full file name = path\filename_run.mat',...
            'Position',[4 28 60 20],...
            'Callback',@FileName);
        smaux.smgui.filename_eth = uicontrol('Parent',smaux.smgui.datapanel,'Style','edit',...
            'String','',...
            'HorizontalAlignment','left',...
            'FontSize',8,...
            'Position',[65 30 100 15]);
        smaux.smgui.runnumber_sth = uicontrol('Parent',smaux.smgui.datapanel,'Style','text',...
            'String','Run:',...
            'HorizontalAlignment','right',...
            'FontSize',8,...
            'Position',[4 5 30 15]);
        smaux.smgui.runnumber_eth = uicontrol('Parent',smaux.smgui.datapanel,'Style','edit',...
            'String','',...
            'HorizontalAlignment','left',...
            'FontSize',8,...
            'Position',[40 5 25 15],...
            'Callback',@RunNumber);     
        smaux.smgui.autoincrement_cbh = uicontrol('Parent',smaux.smgui.datapanel,'Style','checkbox',...
            'String','AutoIncrement',...
            'HorizontalAlignment','left',...
            'FontSize',7,...
            'ToolTipString','Selecting this will automatically increase run after hitting measure',...
            'Position',[90 5 80 15]);   
        
            
    
    
    smaux.smgui.numloops_sth = uicontrol('Parent',smaux.smgui.nullpanel,'Style','text',...
        'String','Loops:',...
        'HorizontalAlignment','right',...
        'Position',[5 672 40 15]);
    smaux.smgui.numloops_eth = uicontrol('Parent',smaux.smgui.nullpanel,'Style','edit',...
        'String','1',...
        'Position',[55 672 20 20],...
        'Callback',@NumLoops);
    
    smaux.smgui.commenttext_sth = uicontrol('Parent',smaux.smgui.nullpanel,'Style','text',...
        'String','Comments:',...
        'HorizontalAlignment','left',...
        'Position',[5 635 170 20]);
    smaux.smgui.commenttext_eth = uicontrol('Parent',smaux.smgui.nullpanel,'Style','edit',...
        'String','',...
        'FontSize',8,...
        'Position',[5 405 170 230],...
        'HorizontalAlignment','left',...
        'max',20,...
        'Callback',@Comment);
    
    %UI Controls for plot selection
    smaux.smgui.oneDplot_sth = uicontrol('Parent',smaux.smgui.nullpanel,'Style','text',...
        'String','1D Plots',...
        'Position',[5 375 80 20]);
    smaux.smgui.oneDplot_lbh = uicontrol('Parent',smaux.smgui.nullpanel,'Style','listbox',...
        'String',{},...
        'Max',10,...
        'Position',[5 175 80 200],...
        'Callback',@Plot);
    smaux.smgui.twoDplot_sth = uicontrol('Parent',smaux.smgui.nullpanel,'Style','text',...
        'String','2D Plots',...
        'Position',[95 375 80 20]);
    smaux.smgui.twoDplot_lbh = uicontrol('Parent',smaux.smgui.nullpanel,'Style','listbox',...
        'String',{},...
        'Max',10,...
        'Position',[95 175 80 200],...
        'Callback',@Plot);
    
    %UI Controls to add smscan to collection of scans or measurement queue
    smaux.smgui.toscans_pbh = uicontrol('Parent',smaux.smgui.nullpanel,'Style','pushbutton',...
        'String','TO SCANS',...
        'FontSize',14,...
        'Position', [5 120 170 50],...
        'Callback',@ToScans);
        
    smaux.smgui.toqueue_pbh = uicontrol('Parent',smaux.smgui.nullpanel,'Style','pushbutton',...
        'String','TO QUEUE',...
        'FontSize',14,...
        'Position', [5 65 170 50],...
        'Callback',@ToQueue);
    
    smaux.smgui.smrun_pbh = uicontrol('Parent',smaux.smgui.nullpanel,'Style','pushbutton',...
        'String','RUN',...
        'FontSize',14,...
        'Position',[5 10 170 50],...
        'BackgroundColor','green',...
        'Callback',@Run);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Programming the GUI     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    datasavefile='';
    plotchoices.string={};
    plotchoices.loop=[];

    Update;
    
function SaveScan(hObject,eventdata)
    [smscanFile,smscanPath] = uiputfile('*.mat','Save Scan As');
    save(fullfile(smscanPath,smscanFile),'smscan');
end

function LoadScan(hObject,eventdata)
    [smscanFile,smscanPath] = uigetfile('*.mat','Select Scan File');
    S=load (fullfile(smscanPath,smscanFile));
    smscan=S.smscan;
    if isfield(smscan,'consts') && ~isfield(smscan.consts,'set')
        for i=1:length(smscan.consts)
            smscan.consts(i).set=1;
        end
    end
    scaninit;
end

function LoadRack(hObject,eventdata)
    [smdataFile,smdataPath] = uigetfile('*.mat','Select Rack File');
    if smdataFile
        S=load (fullfile(smdataPath,smdataFile));
        smdata=S.smdata;
    end
end

function SaveRack(hObject,eventdata)
    [smdataFile,smdataPath] = uiputfile('*.mat','Save Rack As');
    if smdataFile
        save(fullfile(smdataPath,smdataFile),'smdata');
    end
end

set(smaux.smgui.figure1,'Visible','on')
end 

function EditRack(hObject,eventdata)
    smguichannels;
end

function loopvars_addchan_pbh_Callback(hObject,eventdata,i)
    global smscan;
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
global smaux smscan;
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
    global smaux smscan;
    obj=smaux.smgui.loopvars_eth(i,j);
    val = str2double(get(obj,'String'));
    if j==1  %number of points being changed
        if (isnan(val) || mod(val,1)~=0 || val<1)
            errordlg('Please enter a positive integer','Invalid Input Value');
            set(obj,'String',smscan.loops(i).npoints);
            return;
        else
            smscan.loops(i).npoints = val;
            for j=1:smscan.loops(i).numchans
                makeloopchannelset(i,j)
            end
        end        
    elseif j==2  %Ramptime being changed
        val = str2double(get(obj,'String'));         
        smscan.loops(i).ramptime=val;
    elseif j==3  %adjust wait time for scan
        val=str2double(get(obj,'String'));
        if (val<0)
            errordlg('Please enter a positive number','Invalid Input Value');
            set(obj,'String','0');
            return;
        else
            smscan.loops(i).waittime=val;
        end
    end                
end


%Callbacks for loop variable channel edit text boxes (channel, min,
%   max, mid, range, step)   
function loopcvars_eth_Callback(hObject,eventdata,i,j,k)
    global smaux smscan smdata;
    obj=smaux.smgui.loopcvars_eth(i,j,k);
    if k==1 % Change the channel being ramped
        smscan.loops(i).setchan(j)={smdata.channels(get(obj,'Value')-1).name};
    elseif k==2 % Change the min value of the channel
        val = str2double(get(obj,'String'));
        smscan.loops(i).setchanranges{j}(1)=val;
    elseif k==3 % Change the max value of the channel
        val = str2double(get(obj,'String'));
        smscan.loops(i).setchanranges{j}(2)=val;
    elseif k==4 %Change the mid value of the channel
        val = str2double(get(obj,'String'));
        range=smscan.loops(i).setchanranges{j}(2)-smscan.loops(i).setchanranges{j}(1);
        smscan.loops(i).setchanranges{j}(1)=val-range/2;
        smscan.loops(i).setchanranges{j}(2)=val+range/2;
        rng=smscan.loops(i).setchanranges{j};
    elseif k==5 % Change the range of the channel
        val = str2double(get(obj,'String'));
        mid = (smscan.loops(i).setchanranges{j}(2)+smscan.loops(i).setchanranges{j}(1))/2;
        smscan.loops(i).setchanranges{j}(1)=mid-val/2;
        smscan.loops(i).setchanranges{j}(2)=mid+val/2;
        rng=smscan.loops(i).setchanranges{j};
    elseif k==6 % change the stepsize *FOR ALL CHANNELS IN THIS LOOP*
        val = str2double(get(obj,'String'));
        range=smscan.loops(i).setchanranges{j}(2)-smscan.loops(i).setchanranges{j}(1);
        smscan.loops(i).npoints=floor(range/val+1);
        set(smaux.smgui.loopvars_eth(i,1),'String',smscan.loops(i).npoints);
        for c=1:smscan.loops(i).numchans
            makeloopchannelset(i,c)
        end
    end
    makeloopchannelset(i,j);
end


%Callbacks for loop variable channel #1, in fixed trafofn mode (range
%stored in loops.rng instead of in loops.setchanranges)
function loopcvarsLOCKT_eth_Callback(hObject,eventdata,i,j,k)
    global smaux smscan;
    obj=smaux.smgui.loopcvars_eth(i,j,k);
    if k==1 % Change the channel being ramped
        smscan.loops(i).setchan(j)={smdata.channels(get(obj,'Value')-1).name};
    elseif k==2 % Change the min value of the channel
        val = str2double(get(obj,'String'));
        smscan.loops(i).rng(1)=val;
    elseif k==3 % Change the max value of the channel
        val = str2double(get(obj,'String'));
        smscan.loops(i).rng(2)=val;
    elseif k==4 %Change the mid value of the channel
        val = str2double(get(obj,'String'));
        range=smscan.loops(i).rng(2)-smscan.loops(i).rng(1);
        smscan.loops(i).rng(1)=val-range/2;
        smscan.loops(i).rng(2)=val+range/2;
    elseif k==5 % Change the range of the channel
        val = str2double(get(obj,'String'));
        mid = (smscan.loops(i).rng(2)+smscan.loops(i).rng(1))/2;
        smscan.loops(i).rng(1)=mid-val/2;
        smscan.loops(i).rng(2)=mid+val/2; 
    elseif k==6 % change the stepsize 
        val = str2double(get(obj,'String'));
        range=smscan.loops(i).rng(2)-smscan.loops(i).rng(1);
        smscan.loops(i).npoints=floor(range/val+1);
        set(smaux.smgui.loopvars_eth(i,1),'String',smscan.loops(i).npoints);
        for c=1:smscan.loops(i).numchans
            makeloopchannelset(i,c)
        end
    end
    makeloopchannelset(i,j);
end

%Callback for getchannel pmh
function GetChannel(hObject,eventdata,i,j)
global smaux smscan smdata;
    val = get(smaux.smgui.loopvars_getchans_pmh(i,j),'Value');
    if val==1
        smscan.loops(i).getchan(j)=[];
    else
        smscan.loops(i).getchan{j}=smdata.channels(val-1).name;
    end
    smscan.disp=[];
    makelooppanels;
end

%Callback for the constants pmh
function ConstMenu(hObject,eventdata,i)
global smaux smscan smdata;
    val=get(smaux.smgui.consts_pmh(i),'Value');
    if val==1
        smscan.consts(i)=[];
    else
        smscan.consts(i).setchan = smdata.channels(val-1).name;
        if ~isfield(smscan.consts(i),'val')
            smscan.consts(i).val=0;
        end
        if ~isfield(smscan.consts(i),'set')
            smscan.consts(i).set=1;
        end
    end
    makeconstpanel;
end

%Callback for the constants eth
function ConstTXT(hObject,eventdata,i)
global smaux smscan;
    val = str2double(get(smaux.smgui.consts_eth(i),'String'));
    if (isnan(val))
        errordlg('Please enter a real number','Invalid Input Value');
        set(smaux.smgui.consts_eth(i),'String',0);
        return;
    end
    smscan.consts(i).val=val;
end

% Callback for constants checkboxes
function SetConsts(hObject,eventdata,i)
global smaux smscan;
    smscan.consts(i).set = get(smaux.smgui.setconsts_cbh(i),'Value');  
end

%Callback for update constants pushbutton
function UpdateConstants(varargin)
global smaux smscan;
    allchans = {smscan.consts.setchan};
    setchans = {};
    setvals = [];
    for i=1:length(smscan.consts)
        if smscan.consts(i).set
            setchans{end+1}=smscan.consts(i).setchan;
            setvals(end+1)=smscan.consts(i).val;
        end
    end
    smset(setchans, setvals);
    newvals = cell2mat(smget(allchans));
    for i=1:length(smscan.consts)
        smscan.consts(i).val=newvals(i);
        if abs(floor(log10(newvals(i))))>3
            set(smaux.smgui.consts_eth(i),'String',sprintf('%0.1e',newvals(i)));
        else
            set(smaux.smgui.consts_eth(i),'String',round(1000*newvals(i))/1000);
        end
    end
end

 % Callback for data file location pushbutton
function SavePath(varargin)
    global smaux
    x=uigetdir;
    if x
        smaux.datadir = x;
        seplocations=findstr(filesep,smaux.datadir);
        if length(seplocations)>1
            displaystring=smaux.datadir(seplocations(end-1)+1:end);
        else
            displaystring=smaux.datadir;
        end
        if length(displaystring)>40
            displaystring=displaystring(end-39:end);
        end
        set(smaux.smgui.datapath_sth,'String',displaystring);
        set(smaux.smgui.datapath_sth,'TooltipString',smaux.datadir);
    end
end

% Callback for changing title of scan
function ScanTitle(varargin)
    global smaux smscan;
    smscan.name = get(smaux.smgui.scantitle_eth,'String');
end


%Callback for filename pushbutton
function FileName(varargin)
global smaux smscan;
    [savedataFile,savedataPath] = uiputfile('*.mat','Save Data As');
    if savedataPath ~= 0
        smaux.datadir=savedataPath(1:end-1);
        seplocations=findstr(filesep,smaux.datadir);
        displaystring=smaux.datadir(seplocations(end-1)+1:end);
        if length(displaystring)>40
            displaystring=displaystring(end-39:end);
        end
        set(smaux.smgui.datapath_sth,'String',displaystring);
        set(smaux.smgui.datapath_sth,'TooltipString',smaux.datadir);

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
        set(smaux.smgui.filename_eth,'String',savedataFile);
        smscan.name=savedataFile;
    end
end

% Callback for ppt file location pushbutton
function SavePPT(varargin)
global smaux;
    [pptFile,pptPath] = uiputfile('*.ppt','Append to Presentation');
    if pptFile ~= 0
        smaux.pptsavefile=fullfile(pptPath,pptFile);   
        set(smaux.smgui.pptfile_sth,'String',pptFile);
        set(smaux.smgui.pptfile_sth,'TooltipString',smaux.pptsavefile);
    end
end
    
%callback for comment text
function Comment(varargin)
global smaux smscan;
    smscan.comments = (get(smaux.smgui.commenttext_eth,'String'));
end

% Callback for updating run number
function RunNumber(varargin)
    global smaux;
    if isempty(get(smaux.smgui.runnumber_eth,'String'))
        set(autoincrement_cbh,'Value',0);
        smaux.run=[];
    else
        val = str2double(get(smaux.smgui.runnumber_eth,'String'));
        if ~isnan(val) && isinteger(uint16(val)) && uint16(val)>=0 && uint16(val)<=999
            smaux.run=uint16(val);
            set(smaux.smgui.runnumber_eth,'String',smaux.run);
        else
            errordlg('Please enter an integer in [000 999]','Bad Run Number');
            set(smaux.smgui.runnumber_eth,'String','');
        end
    end
end

%callback for plot list box objects
function Plot(varargin)
    global smaux smscan;
       vals1d = get(smaux.smgui.oneDplot_lbh,'Val');
       vals2d = get(smaux.smgui.twoDplot_lbh,'Val');
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

%populates plot choices
function setplotchoices(varargin)
    global smscan smaux;
        temp={smscan.loops.getchan};
        plotchoices.string={};
        plotchoices.loop=[];
        for i=1:length(temp)
            for j=1:length(temp{i})
                plotchoices.string={plotchoices.string{:} temp{i}{j}};
                plotchoices.loop=[plotchoices.loop i];
            end
        end
        set(smaux.smgui.oneDplot_lbh,'String',plotchoices.string);       
        set(smaux.smgui.twoDplot_lbh,'String',plotchoices.string);       
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
        set(smaux.smgui.oneDplot_lbh,'Val',newoneDvals);
        set(smaux.smgui.twoDplot_lbh,'Val',newtwoDvals);
end

% Callback for running the scan (call to smrun)
function Run(varargin)
        global smaux smscan smdata;
        
        % create a good filename
        pathstring = get(smaux.smgui.datapath_sth,'String');
        filestring = get(smaux.smgui.filename_eth,'String');      
        runstring = get(smaux.smgui.runnumber_eth,'String');
        if isempty(pathstring) || isempty(filestring)
            FileName;
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
                if get(smaux.smgui.autoincrement_cbh,'Value') && isinteger(smaux.run)
                     while exist(datasaveFile,'file')
                        smaux.run=smaux.run+1;
                        set(smaux.smgui.runnumber_eth,'String',smaux.run);
                        runstring=sprintf('%03u',smaux.run);
                        datasaveFile = fullfile(smaux.datadir,[filestring '_' runstring '.mat']);
                     end
                else
                    FileName;
                    filestring = get(smaux.smgui.filename_eth,'String');
                    if isempty(runstring)
                        datasaveFile = fullfile(smaux.datadir,[filestring '.mat']);
                    else
                        runstring=sprintf('%03u',smaux.run);
                        datasaveFile = fullfile(smaux.datadir,[filestring '_' runstring '.mat']);
                    end
                end
            end
        end
                    
                
      UpdateConstants;
      smrun(smscan,datasaveFile);
    if get(smaux.smgui.appendppt_cbh,'Value')
        slide.title = [filestring '_' runstring '.mat'];
        slide.body = smscan.comments;
        slide.consts=smscan.consts;
        smsaveppt(smaux.pptsavefile,slide,'-f1000');
    end
end

% Callback to send smscan to smaux.scans
function ToScans(varargin)
    global smaux smscan
    smaux.scans{end+1}=smscan;
    sm
    sm_Callback('UpdateToGUI');
end

% Callback to send smscan to smaux.queue
function ToQueue(varargin)
    global smaux smscan
    smaux.smq{end+1}=smscan;
    sm
    sm_Callback('UpdateToGUI');
end

% updates the GUI components
function Update(varargin)
    global smaux smscan smdata;
    datasavefile='';
    plotchoices.string={};
    plotchoices.loop=[];

    set(smaux.smgui.datapath_sth,'String',datasavefile);
    numloops = 1;

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
        smscan.name='';
    else
        scaninit;
    end
    
    if isstruct(smaux)
        if isfield(smaux,'pptsavefile')
            [pptsavefilepath pptsavefilename pptextension]=fileparts(smaux.pptsavefile);
            set(smaux.smgui.pptfile_sth,'String',pptsavefilename);
            set(smaux.smgui.pptfile_sth,'TooltipString',smaux.pptsavefile);
            set(smaux.smgui.appendppt_cbh,'Value',1);
        end
        
        if isfield(smaux,'datadir')
            seplocations=findstr(filesep,smaux.datadir);
            displaystring=smaux.datadir(seplocations(end-1)+1:end);
            if length(displaystring)>40
                displaystring=displaystring(end-39:end);
            end
            set(smaux.smgui.datapath_sth,'String',displaystring);
            set(smaux.smgui.datapath_sth,'TooltipString',smaux.datadir);
        end
        
        if isfield(smaux,'run')
            set(smaux.smgui.runnumber_eth,'String',smaux.run);
            RunNumber;
        end
    end
end

function scaninit(varargin)
        global smaux smscan smdata;
        numloops = length(smscan.loops);
        set(smaux.smgui.numloops_eth,'String',numloops);
        if isfield(smscan,'name')
            set(smaux.smgui.scantitle_eth,'String',smscan.name);
        end
        for i=1:length(smscan.loops)
            smscan.loops(i).numchans=length(smscan.loops(i).setchan);
        end
         if ~isfield(smscan,'consts')
             smscan.consts = [];
         end
        if isfield(smscan,'comments')
            set(smaux.smgui.commenttext_eth,'String',smscan.comments);
        else
            smscan.comments='';
        end
        makelooppanels;
        setplotchoices;
        makeconstpanel;
end

% make or delete looppanels
% postcon: length(loop_panels_ph) = length(smscan.loops) = numloops
function makelooppanels(varargin)
    global smaux smscan smdata;
    numloops = length(smscan.loops);
    
    panel1position = [180 600 700 190];

    for i=1:length(smaux.smgui.loop_panels_ph)
        delete(smaux.smgui.loop_panels_ph(i));
    end
    smaux.smgui.loop_panels_ph=[];

    for i = (length(smaux.smgui.loop_panels_ph)+1):numloops % display data from existing loops
        smaux.smgui.loop_panels_ph(i) = uipanel('Parent',smaux.smgui.nullpanel,...
            'Units','pixels',...
            'Position',panel1position+[0*(i) -190*(i) -0*(i) 0]);

        % for new loops only
        if i>length(smscan.loops)
            smscan.loops(i).npoints=101;
            smscan.loops(i).rng=[0 1];
            smscan.loops(i).getchan=[];
            smscan.loops(i).setchan={'none'};
            smscan.loops(i).setchanranges={[0 1]};
            smscan.loops(i).ramptime=[];
            smscan.loops(i).trafofn=[];
            smscan.loops(i).trigfn=[];
            smscan.loops(i).numchans=0;
            smscan.loops(i).waittime=0;
        end

        %Pushbutton for adding setchannels to the loop
        smaux.smgui.loopvars_addchan_pbh(i) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
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
        smaux.smgui.loopvars_sth(i,1) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Points:',...
            'HorizontalAlignment','right',...
            'Position',[165 147 50 20]);
        smaux.smgui.loopvars_eth(i,1) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',numpoints(i),...
            'HorizontalAlignment','center',...
            'Position',[215 152 50 20],...
            'Callback',{@loopvars_eth_Callback,i,1});

        %Step Time
        smaux.smgui.loopvars_sth(i,2) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Step time:',...
            'HorizontalAlignment','right',...
            'Position',[355 147 55 20]);
        smaux.smgui.loopvars_eth(i,2) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',smscan.loops(i).ramptime,...
            'HorizontalAlignment','center',...
            'Position',[415 152 55 20],...
            'Callback',{@loopvars_eth_Callback,i,2});

        %Wait times            
        smaux.smgui.loopvars_sth(i,3) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Wait (s):',...
            'TooltipString','Wait before getting data',...
            'HorizontalAlignment','right',...
            'Position',[555 147 55 20]);
        smaux.smgui.loopvars_eth(i,3) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',0,...
            'HorizontalAlignment','center',...
            'Position',[615 152 55 20],...
            'Callback',{@loopvars_eth_Callback,i,3});
        if isfield(smscan.loops(i),'waittime')
            set(smaux.smgui.loopvars_eth(i,3),'String',smscan.loops(i).waittime);
        end


        %Add UI controls for set channels
        for j=1:smscan.loops(i).numchans
            makeloopchannelset(i,j);
        end


        %Add popup menus for get channels 
        smaux.smgui.loopvars_sth(i,4) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Record:',...
            'HorizontalAlignment','center',...
            'Position',[5 35 50 20]);
        makeloopgetchans(i);
        setplotchoices;
    end


    %delete loops   
    for i = (numloops+1):length(smaux.smgui.loop_panels_ph)       
        delete(smaux.smgui.loop_panels_ph(i));            
    end
    smscan.loops = smscan.loops(1:numloops);

    smaux.smgui.loop_panels_ph=smaux.smgui.loop_panels_ph(1:numloops);
    smaux.smgui.loopvars_eth=smaux.smgui.loopvars_eth(1:numloops,:);
    smaux.smgui.loopvars_sth=smaux.smgui.loopvars_sth(1:numloops,:);


    %label the loops
    set(smaux.smgui.loop_panels_ph(numloops),'Title',sprintf('Loop %d (outer)',numloops));
    set(smaux.smgui.loop_panels_ph(1),'Title',sprintf('Loop %d (inner)',1));
    for k = 2:numloops-1
        set(smaux.smgui.loop_panels_ph(k),'Title',sprintf('Loop %d',k));
    end      
end

% makes ui objects for setchannel j on loop i                
function makeloopchannelset(i,j) 
    global smaux smscan smdata;
    size = get(smaux.smgui.loop_panels_ph(i),'Position');
    pos = [5 size(4)-50-25*j 0 0];
    w = [100 40 40 40 40 40]; % widths
    h = [20 20 20 20 20 20 20 20 20 20 50]; % heights
    s = 95; %spacing

    % button to delete this setchannel
    smaux.smgui.loopcvars_delchan_pbh(i,j) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
        'Style','pushbutton',...
        'String','Delete',...
        'Position',pos+[0 0 50 20],...
        'Callback',{@loopcvars_delchan_pbh_Callback,i,j});

    % select channel being ramped
    channelnames = {};
    for k = 1:length(smdata.channels)
        channelnames{k}=smdata.channels(k).name;
    end
    smaux.smgui.loopcvars_sth(i,j,1) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
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
    smaux.smgui.loopcvars_eth(i,j,1) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
        'Style','popupmenu',...
        'String',['none' channelnames],...
        'Value',chanval,...
        'HorizontalAlignment','center',...
        'Position',pos+[105 0 w(1) h(1)],...
        'Callback',{@loopcvars_eth_Callback,i,j,1});

    if isfield(smscan.loops(i), 'setchanranges')
        %minimum
        smaux.smgui.loopcvars_sth(i,j,2) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Min:',...
            'HorizontalAlignment','right');
        smaux.smgui.loopcvars_eth(i,j,2) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',smscan.loops(i).setchanranges{j}(1),...
            'HorizontalAlignment','center',...
            'Callback',{@loopcvars_eth_Callback,i,j,2});

        %max
        smaux.smgui.loopcvars_sth(i,j,3) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Max:',...
            'HorizontalAlignment','right');
        smaux.smgui.loopcvars_eth(i,j,3) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',smscan.loops(i).setchanranges{j}(2),...
            'HorizontalAlignment','center',...
            'Callback',{@loopcvars_eth_Callback,i,j,3});

        %mid
        smaux.smgui.loopcvars_sth(i,j,4) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Mid:',...
            'HorizontalAlignment','right');
        smaux.smgui.loopcvars_eth(i,j,4) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',mean(smscan.loops(i).setchanranges{j}),...
            'HorizontalAlignment','center',...
            'Callback',{@loopcvars_eth_Callback,i,j,4});

        %range
        smaux.smgui.loopcvars_sth(i,j,5) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Range:',...
            'HorizontalAlignment','right');
        smaux.smgui.loopcvars_eth(i,j,5) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',smscan.loops(i).setchanranges{j}(2)-smscan.loops(i).setchanranges{j}(1),...
            'HorizontalAlignment','center',...
            'Callback',{@loopcvars_eth_Callback,i,j,5});

        %stepsize
        smaux.smgui.loopcvars_sth(i,j,6) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Step:',...
            'HorizontalAlignment','right');
        smaux.smgui.loopcvars_eth(i,j,6) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',(smscan.loops(i).setchanranges{j}(2)-smscan.loops(i).setchanranges{j}(1))/(smscan.loops(i).npoints-1),...
            'HorizontalAlignment','center',...
            'Callback',{@loopcvars_eth_Callback,i,j,6});       

        for k=2:6
            set(smaux.smgui.loopcvars_sth(i,j,k),'Position',pos+[s*k-45+60 -5 w(k) h(k)]);
            set(smaux.smgui.loopcvars_eth(i,j,k),'Position',pos+[s*k+60 0 w(k) h(k)]);            
        end

    elseif j==1 %first setchan in locked trafofn mode, loop range != [0 1];
         %minimum
        smaux.smgui.loopcvars_sth(i,j,2) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Min:',...
            'HorizontalAlignment','right');
        smaux.smgui.loopcvars_eth(i,j,2) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',smscan.loops(i).rng(1),...
            'HorizontalAlignment','center',...
            'Callback',{@loopcvarsLOCKT_eth_Callback,i,j,2});

        %max
        smaux.smgui.loopcvars_sth(i,j,3) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Max:',...
            'HorizontalAlignment','right');
        smaux.smgui.loopcvars_eth(i,j,3) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',smscan.loops(i).rng(2),...
            'HorizontalAlignment','center',...
            'Callback',{@loopcvarsLOCKT_eth_Callback,i,j,3});

        %mid
        smaux.smgui.loopcvars_sth(i,j,4) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Mid:',...
            'HorizontalAlignment','right');
        smaux.smgui.loopcvars_eth(i,j,4) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',mean(smscan.loops(i).rng),...
            'HorizontalAlignment','center',...
            'Callback',{@loopcvarsLOCKT_eth_Callback,i,j,4});

        %range
        smaux.smgui.loopcvars_sth(i,j,5) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Range:',...
            'HorizontalAlignment','right');
        smaux.smgui.loopcvars_eth(i,j,5) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',smscan.loops(i).rng(2)-smscan.loops(i).rng(1),...
            'HorizontalAlignment','center',...
            'Callback',{@loopcvarsLOCKT_eth_Callback,i,j,5});

        %stepsize
        smaux.smgui.loopcvars_sth(i,j,6) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String','Step:',...
            'HorizontalAlignment','right');
        smaux.smgui.loopcvars_eth(i,j,6) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','edit',...
            'String',(smscan.loops(i).rng(2)-smscan.loops(i).rng(1))/(smscan.loops(i).npoints-1),...
            'HorizontalAlignment','center',...
            'Callback',{@loopcvarsLOCKT_eth_Callback,i,j,6});       

        for k=2:6
            set(smaux.smgui.loopcvars_sth(i,j,k),'Position',pos+[s*k-45+60 -5 w(k) h(k)]);
            set(smaux.smgui.loopcvars_eth(i,j,k),'Position',pos+[s*k+60 0 w(k) h(k)]);            
        end
    else
        %trafofn locked for this channel
        smaux.smgui.loopcvars_sth(i,j,2) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','text',...
            'String',['Values Locked.  Check smscan.loops(' int2str(i) ').trafofn at command line'],...
            'HorizontalAlignment','right',...
            'Position',pos+[s*2-45+60 -5 350 h(2)]);
    end     


end

% Make the getchannel UI popup objects for loop i
function makeloopgetchans(i)
    global smscan smaux smdata;
    numgetchans=length(smscan.loops(i).getchan);
    smaux.smgui.loopvars_getchans_pmh=[];
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
        smaux.smgui.loopvars_getchans_pmh(i,j) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
            'Style','popupmenu',...
            'String',['none' channelnames],...
            'Value',chanval,...
            'HorizontalAlignment','center',...
            'Position',[60+90*(mod((j-1),7)) 40-30*floor((j-1)/7) 80 20],...
            'Callback',{@GetChannel,i,j});
    end

    if numgetchans==0 j=0;
    end

    smaux.smgui.loopvars_getchans_pmh(i,j+1) = uicontrol('Parent',smaux.smgui.loop_panels_ph(i),...
        'Style','popupmenu',...
        'String',['none' channelnames],...
        'Value',1,...
        'HorizontalAlignment','center',...
        'Position',[60+90*(mod(j,7)) 40-30*floor(j/7) 80 20],...
        'Callback',{@GetChannel,i,j+1});


end

function makeconstpanel(varargin)
    global smaux smscan smdata;
    
    delete(smaux.smgui.scan_constants_ph);
    smaux.smgui.scan_constants_ph = uipanel('Parent',smaux.smgui.nullpanel,'Title','Constants (check to set, uncheck to record)',...
        'Units','Pixels',...
        'Position', [180 600 700 290]);

    smaux.smgui.update_consts_pbh = uicontrol('Parent',smaux.smgui.scan_constants_ph,...
        'Style','pushbutton',...
        'String','Update Constants',...
        'Position',[560 5 130 25],...
        'Callback',@UpdateConstants);

    numconsts=length(smscan.consts);
    channelnames = {smdata.channels.name};


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
                  'Invalid Channel in smscan.consts');
                chanval=1;
            end
        end
        if isempty(smscan.consts(i).set)
            smscan.consts(i).set=1;
        end
        smaux.smgui.consts_pmh(i) = uicontrol('Parent',smaux.smgui.scan_constants_ph,...
            'Style','popupmenu',...
            'String',['none' channelnames],...
            'Value',chanval,...
            'HorizontalAlignment','center',...
            'Position',pos1+[173*(mod(i-1,cols)) -27*(floor((i-1)/cols)) 96 20],...
            'Callback',{@ConstMenu,i});
        smaux.smgui.consts_eth(i) = uicontrol('Parent',smaux.smgui.scan_constants_ph,...
            'Style','edit',...
            'String',smscan.consts(i).val,...
            'HorizontalAlignment','center',...
            'Position',pos1+[173*(mod(i-1,cols))+98 -27*(floor((i-1)/cols)) 50 20],...
            'Callback',{@ConstTXT,i});
        smaux.smgui.setconsts_cbh(i) = uicontrol('Parent',smaux.smgui.scan_constants_ph,...
            'Style','checkbox',...
            'Position',pos1+[173*(mod(i-1,cols))+150 -27*(floor((i-1)/cols)) 20 20],...
            'Value',smscan.consts(i).set,...
            'Callback',{@SetConsts,i});
    end
    if isempty(i)
        i=0;
    end
    i=i+1;
    chanval = 1;

    smaux.smgui.consts_pmh(i) = uicontrol('Parent',smaux.smgui.scan_constants_ph,...
        'Style','popupmenu',...
        'String',['none' channelnames],...
        'Value',chanval,...
        'HorizontalAlignment','center',...
        'Position',pos1+[173*(mod(i-1,cols)) -27*(floor((i-1)/cols)) 96 20],...
        'Callback',{@ConstMenu,i});

    smaux.smgui.consts_eth(i) = uicontrol('Parent',smaux.smgui.scan_constants_ph,...
        'Style','edit',...
        'String',0,...
        'HorizontalAlignment','center',...
        'Position',pos1+[173*(mod(i-1,cols))+98 -27*(floor((i-1)/cols)) 50 20],...
        'Callback',{@ConstTXT,i});
    smaux.smgui.setconsts_cbh(i) = uicontrol('Parent',smaux.smgui.scan_constants_ph,...
            'Style','checkbox',...
            'Position',pos1+[173*(mod(i-1,cols))+150 -27*(floor((i-1)/cols)) 20 20],...
            'Value',1,...
            'Callback',{@SetConsts,i});

end

%Change the number of loops in the scan
function NumLoops(hObject,eventdata)
    global smaux smdata smscan;
    val = str2double(get(smaux.smgui.numloops_eth,'String'));
    if (isnan(val) || mod(val,1)~=0 || val<1)
        errordlg('Please enter a positive integer','Invalid Input Value');
        set(smaux.smgui.numloops_eth,'String',numloops);
        return;
    elseif ~isstruct(smdata)
        errordlg('Please load a rack','Illegal Action');
        return;
    else
        if length(smscan.loops) > val
            smscan.loops = smscan.loops(1:val);
        else
            for i=length(smscan.loops)+1:val
                smscan.loops(i).npoints=101;
                smscan.loops(i).rng=[0 1];
                smscan.loops(i).getchan=[];
                smscan.loops(i).setchan={'none'};
                smscan.loops(i).setchanranges={[0 1]};
                smscan.loops(i).ramptime=[];
                smscan.loops(i).trafofn=[];
                smscan.loops(i).trigfn=[];
                smscan.loops(i).numchans=0;
                smscan.loops(i).waittime=0;
            end
        end
    end
       
    makelooppanels;
    makeconstpanel;
end