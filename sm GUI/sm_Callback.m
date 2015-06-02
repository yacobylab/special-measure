function sm_Callback(what,arg)
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
    switch nargin
        case 1
            eval(what);
        case 2
            eval([what '(arg);']);
    end
end

function Open(h)
    global smaux
    smaux.sm=h;
    UpdateToGUI;
end

function Scans
end

function ScansCreate
end

function Queue
    global smaux

    UpdateToGUI;
end

function QueueCreate
end

function OpenScans
    global smaux
    [file,path] = uigetfile('*.mat','Select Rack File');
    if file
        S=load(fullfile(path,file));
        smaux.scans=S.scans;
    end
    UpdateToGUI;
end

function SaveScans
    global smaux
    [file,path] = uiputfile('*.mat','Save Scans As');
    if file
        save(fullfile(path,file),'-struct','smaux','scans');
    end        
end

function OpenRack
    global smdata
    [smdataFile,smdataPath] = uigetfile('*.mat','Select Rack File');
    if smdataFile
        S=load(fullfile(smdataPath,smdataFile));
        smdata=S.smdata;
    end
end

function SaveRack
    global smdata
    [smdataFile,smdataPath] = uiputfile('*.mat','Save Rack As');
    if smdataFile
        save(fullfile(smdataPath,smdataFile),'smdata');
    end
end

function EditRack
    smguichannels;
end

function SMusers
    global smaux
    vals=get(smaux.sm.smusers_lbh,'Value');
    for i=1:length(smaux.users)
        smaux.users(i).notifyon=0;
    end
    for i=vals
        smaux.users(i).notifyon=1;
    end
    UpdateToGUI;
end

function SMusersCreate
end

function Enqueue
    global smaux
    scan_index=get(smaux.sm.scans_lbh,'Value');
    queue_index=get(smaux.sm.queue_lbh,'Value');
    if ~isfield(smaux,'smq')
        smaux.smq{1}=smaux.scans{scan_index};
    else
        smaux.smq=[smaux.smq(1:queue_index) smaux.scans(scan_index) smaux.smq(queue_index+1:end)];
    end
    UpdateToGUI;
end

function QueueKey(eventdata)
    global smaux

    key=eventdata.Key;
    mod=eventdata.Modifier;
    queue_index=get(smaux.sm.queue_lbh,'Value');
    
    switch key
        case {'delete','backspace'}
            smaux.smq(queue_index)=[];
        case 'uparrow'
            if ~isempty(mod)
                if queue_index>1
                    temp=smaux.smq{queue_index-1};
                    smaux.smq{queue_index-1}=smaux.smq{queue_index};
                    smaux.smq{queue_index}=temp;
                end
            end
        case 'u'
            if queue_index>1
                temp=smaux.smq{queue_index-1};
                smaux.smq{queue_index-1}=smaux.smq{queue_index};
                smaux.smq{queue_index}=temp;
                set(smaux.sm.queue_lbh,'Value',queue_index-1);
            end
        case 'downarrow'
            if ~isempty(mod)
                if queue_index<length(smaux.smq)
                    temp=smaux.smq{queue_index+1};
                    smaux.smq{queue_index+1}=smaux.smq{queue_index};
                    smaux.smq{queue_index}=temp;
                end
            end
        case 'd'
            if queue_index<length(smaux.smq)
                temp=smaux.smq{queue_index+1};
                smaux.smq{queue_index+1}=smaux.smq{queue_index};
                smaux.smq{queue_index}=temp;
                set(smaux.sm.queue_lbh,'Value',queue_index+1);
            end
    end
    UpdateToGUI;
end

function ScansKey(eventdata)
    global smaux

    key=eventdata.Key;
    mod=eventdata.Modifier;
    queue_index=get(smaux.sm.scans_lbh,'Value');
    
    switch key
        case {'delete','backspace'}
            smaux.scans(queue_index)=[];
        case 'uparrow'
            if ~isempty(mod)
                if queue_index>1
                    temp=smaux.scans{queue_index-1};
                    smaux.scans{queue_index-1}=smaux.scans{queue_index};
                    smaux.scans{queue_index}=temp;
                end
            end
        case 'u'
            if queue_index>1
                temp=smaux.scans{queue_index-1};
                smaux.scans{queue_index-1}=smaux.scans{queue_index};
                smaux.scans{queue_index}=temp;
                set(smaux.sm.scans_lbh,'Value',queue_index-1);
            end
        case 'downarrow'
            if ~isempty(mod)
                if queue_index<length(smaux.scans)
                    temp=smaux.scans{queue_index+1};
                    smaux.scans{queue_index+1}=smaux.scans{queue_index};
                    smaux.scans{queue_index}=temp;
                end
            end
        case 'd'
            if queue_index<length(smaux.scans)
                temp=smaux.scans{queue_index+1};
                smaux.scans{queue_index+1}=smaux.scans{queue_index};
                smaux.scans{queue_index}=temp;
                set(smaux.sm.scans_lbh,'Value',queue_index+1);
            end
    end
    UpdateToGUI;
end

function EditScan
    global smaux smscan;
    queue_index=get(smaux.sm.queue_lbh,'Value');
    if ~isfield(smaux.smq{queue_index},'loops') && isfield(smaux.smq{queue_index},'eval')
        set(smaux.sm.qtxt_eth,'String',smaux.smq{queue_index}.eval);
        smaux.smq(queue_index)=[];
    else
        smscan = smaux.smq{queue_index};
        smgui;
    end
    UpdateToGUI;
end

function EditScan2
    global smaux smscan;
    scan_index=get(smaux.sm.scans_lbh,'Value');
    smscan = smaux.scans{scan_index};
    smgui;
end

function RemoveScan
    global smaux

    UpdateToGUI;
end

function Qtxt
end

function TXTenqueue
    global smaux
    clear scan;
    scan.eval = get(smaux.sm.qtxt_eth,'String');
    set(smaux.sm.qtxt_eth,'String','');
    scan.name = ['EVAL(' scan.eval(1,:) '...)'];
    queue_index=get(smaux.sm.queue_lbh,'Value');
    if ~isfield(smaux,'smq')
        smaux.smq{1}=scan;
    else
        smaux.smq=[smaux.smq(1:queue_index) scan smaux.smq(queue_index+1:end)];
    end
    UpdateToGUI;
end

function PPTauto
end

function PPTFile
    global smaux
    [pptFile,pptPath] = uiputfile('*.ppt','Append to Presentation');
    if pptFile
        smaux.pptsavefile=fullfile(pptPath,pptFile);   
        set(smaux.sm.pptfile_sth,'String',pptFile);
        set(smaux.sm.pptfile_sth,'TooltipString',smaux.pptsavefile);
    end    
end

function PPTFile2
    global smaux
    [pptFile,pptPath] = uiputfile('*.ppt','Append to Presentation');
    if pptFile
        smaux.pptsavefile2=fullfile(pptPath,pptFile);   
        set(smaux.sm.pptfile2_sth,'String',pptFile);
        set(smaux.sm.pptfile2_sth,'TooltipString',smaux.pptsavefile);
    end    
end 

function PPTSaveFig
    global smaux
    if ~ishandle(str2num(get(smaux.sm.pptsave_eth,'String')))
        errordlg('Invalid Figure Handle');
        set(smaux.sm.pptsave_eth,'String',1000);
    end
end

function PPTSaveNow
    global smaux
    slide.title = '';
    slide.body = smaux.comments;
    slide.consts=[];
    fig=str2num(get(smaux.sm.pptsave_eth,'String'));
    if get(smaux.sm.pptsavepriority_cbh,'Value')
        smsaveppt(smaux.pptsavefile2,slide,['-f' num2str(fig)]);
    else
        smsaveppt(smaux.pptsavefile,slide,['-f' num2str(fig)]);
    end
end 

function PPTPriority
    global smaux

    UpdateToGUI;
end

function Comments
    global smaux
    smaux.comments=get(smaux.sm.comments_eth,'String');
end

function SavePath
    global smaux
    x=uigetdir;
    if x
        smaux.datadir = x;
    end
    UpdateToGUI;
end

function RunNum
    global smaux
    s=get(smaux.sm.run_eth,'String');
    if isempty(s)
        set(smaux.sm.runincrement_cbh,'Value',0);
        smaux.run=[];  
    else
        val = str2double(s)
        if ~isnan(val) && isinteger(uint16(val)) && uint16(val)>=0 && uint16(val)<=999
            smaux.run=uint16(val);
            set(smaux.sm.run_eth,'String',smaux.run);
        else
            errordlg('Please enter an integer in [000 999]','Bad Run Number');
            set(smaux.sm.run_eth,'String','');
        end
    end
end

function RunCreate
end

function RunIncrement
end

function Run
    global smaux
    while ~isempty(smaux.smq);
        %grab the next scan in the queue
        scan = smaux.smq{1};
        smaux.smq(1)=[];
        UpdateToGUI;
        
        if ~isfield(scan,'loops') && isfield(scan,'eval') %to evaluate commands
            string=scan.eval;
            for i=1:size(string,1)
                evalin('base',string(i,:));
            end
        else
            %filename for this run
            runstring=sprintf('%03u',smaux.run);
            datasaveFile = fullfile(smaux.datadir,[scan.name '_' runstring '.mat']);
            while exist(datasaveFile,'file')
                smaux.run=smaux.run+1;
                runstring=sprintf('%03u',smaux.run);
                datasaveFile = fullfile(smaux.datadir,[scan.name '_' runstring '.mat']);
            end
            
            scan = UpdateConstants(scan);
            smrun(scan,datasaveFile);
            
            %save to powerpoint
            if get(smaux.sm.pptauto_cbh,'Value')
                slide.title = [scan.name '_' runstring '.mat'];
                slide.body = strvcat(smaux.comments,scan.comments);
                slide.consts=scan.consts;
                if isfield(scan,'priority') && scan.priority && isfield(smaux,'pptsavefile2')
                    smsaveppt(smaux.pptsavefile2,slide,'-f1000');
                else
                    smsaveppt(smaux.pptsavefile,slide,'-f1000');
                end
            end
            
            UpdateToGUI;
        end
    end
end

function Pause
    pause
end


function Console
end

function Eval
    global smaux
    string=get(smaux.sm.console_eth,'String');
    set(smaux.sm.console_eth,'String','');
    for i=1:size(string,1)
        evalin('base',string(i,:));
    end
end

function scan = UpdateConstants(scan)
    global smaux smscan;

    if nargin==0
        scan = smscan;
    end
    
    
    allchans = {scan.consts.setchan};
    setchans = {};
    setvals = [];
    for i=1:length(scan.consts)
        if scan.consts(i).set
            setchans{end+1}=scan.consts(i).setchan;
            setvals(end+1)=scan.consts(i).val;
        end
    end
    smset(setchans, setvals);
    newvals = cell2mat(smget(allchans));
    for i=1:length(scan.consts)
        scan.consts(i).val=newvals(i);
    end
end

function UpdateToGUI
    global smaux
    %populates available scans
    scannames = {};
    scan_index=get(smaux.sm.scans_lbh,'Value');
    if isfield(smaux,'scans') && iscell(smaux.scans)
        for i=1:length(smaux.scans)
            if ~isfield(smaux.scans{i},'name')
                smaux.scans{i}.name=['Scan ' num2str(i)];
            end
            scannames{i}=smaux.scans{i}.name;
        end
    else
        smaux.scans = {};
    end
    set(smaux.sm.scans_lbh,'String',scannames);
    if scan_index>length(smaux.scans) || (scan_index==0 && ~isempty(smaux.scans))
        set(smaux.sm.scans_lbh,'Value',length(smaux.scans));
    end
    
    %populates queue list box
    qnames = {};
    
    queue_index=get(smaux.sm.queue_lbh,'Value');
    if isempty(queue_index) && ~isempty(get(smaux.sm.queue_lbh,'String'))
        queue_index = 1;
        set(smaux.sm.queue_lbh,'Value',queue_index);
    end
    queue_index=get(smaux.sm.queue_lbh,'Value');
    
    if isfield(smaux,'smq') && iscell(smaux.smq)
        for i=1:length(smaux.smq)
            if isfield(smaux.smq{i},'name')
                qnames{i}=smaux.smq{i}.name;
            else
                qnames{i}='Unnamed Scan';
            end
        end
    else
        smaux.smq={};
    end
    set(smaux.sm.queue_lbh,'String',qnames);
    if queue_index>length(smaux.smq) || (queue_index==0 && ~isempty(smaux.smq))
        set(smaux.sm.queue_lbh,'Value',length(smaux.smq));
    end
    
    %populate data path sth
    if exist(smaux.datadir,'dir')
        seplocations=findstr(filesep,smaux.datadir);
        if length(seplocations)>1
            displaystring=smaux.datadir(seplocations(end-1)+1:end);
        else
            displaystring=smaux.datadir;
        end
        if length(displaystring)>40
            displaystring=displaystring(end-39:end);
        end
        set(smaux.sm.datapath_sth,'String',displaystring);
        set(smaux.sm.datapath_sth,'TooltipString',smaux.datadir);
    end
    
    %populate run number eth
    if isfield(smaux,'run') && isinteger(smaux.run)
        val = smaux.run;
        if ~isnan(val) && isinteger(uint16(val)) && uint16(val)>=0 && uint16(val)<=999
            smaux.run=uint16(val);
            set(smaux.sm.run_eth,'String',smaux.run);
        else
            errordlg('Please enter an integer in [000 999]','Bad Run Number');
            set(smaux.sm.run_eth,'String','');
        end
    end
    
    %populate powerpoint main file sth
    if isfield(smaux,'pptsavefile') && exist(smaux.pptsavefile,'file')
        [pathstr, name, ext] = fileparts(smaux.pptsavefile);
        set(smaux.sm.pptfile_sth,'String',[name ext]);
        set(smaux.sm.pptfile_sth,'TooltipString',smaux.pptsavefile);
    end
    
    %populate powerpoint priority file sth
    if isfield(smaux,'pptsavefile2') && exist(smaux.pptsavefile2,'file')
        [pathstr, name, ext] = fileparts(smaux.pptsavefile2);
        set(smaux.sm.pptfile2_sth,'String',[name ext]);
        set(smaux.sm.pptfile2_sth,'TooltipString',smaux.pptsavefile2);
    end
    
    %populate comment text
    if ~isfield(smaux,'comments')
        smaux.comments='';
    end
    set(smaux.sm.comments_eth,'String',smaux.comments);
    
    %populate smusers listbox
    if isfield(smaux,'users')
        set(smaux.sm.smusers_lbh,'String',{smaux.users.name});
        set(smaux.sm.smusers_lbh,'Value',find(cell2mat({smaux.users.notifyon})));
    end
        

end


