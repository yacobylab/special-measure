function varargout = sm(varargin)
% SM M-file for sm.fig
%      SM, by itself, creates a new SM or raises the existing
%      singleton*.
%
%      H = SM returns the handle to a new SM or the handle to
%      the existing singleton*.
%
%      SM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SM.M with the given input arguments.
%
%      SM('Property','Value',...) creates a new SM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%

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
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sm

% Last Modified by GUIDE v2.5 04-Mar-2011 10:05:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sm_OpeningFcn, ...
                   'gui_OutputFcn',  @sm_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before sm is made visible.
function sm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sm (see VARARGIN)

% Choose default command line output for sm
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
sm_Callback('Open',handles);
% UIWAIT makes sm wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sm_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in scans_lbh.
function scans_lbh_Callback(hObject, eventdata, handles)
% hObject    handle to scans_lbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('Scans');


% --- Executes during object creation, after setting all properties.
function scans_lbh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scans_lbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
sm_Callback('ScansCreate');
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in queue_lbh.
function queue_lbh_Callback(hObject, eventdata, handles)
% hObject    handle to queue_lbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('Queue');
% Hints: contents = cellstr(get(hObject,'String')) returns queue_lbh contents as cell array
%        contents{get(hObject,'Value')} returns selected item from queue_lbh


% --- Executes during object creation, after setting all properties.
function queue_lbh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to queue_lbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
sm_Callback('QueueCreate');
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function openscans_Callback(hObject, eventdata, handles)
% hObject    handle to openscans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('OpenScans');


% --------------------------------------------------------------------
function savescans_Callback(hObject, eventdata, handles)
% hObject    handle to savescans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('SaveScans');


% --------------------------------------------------------------------
function openrack_Callback(hObject, eventdata, handles)
% hObject    handle to openrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('OpenRack');


% --------------------------------------------------------------------
function saverack_Callback(hObject, eventdata, handles)
% hObject    handle to saverack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('SaveRack');


% --------------------------------------------------------------------
function editrack_Callback(hObject, eventdata, handles)
% hObject    handle to editrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('EditRack');


% --- Executes on selection change in smusers_lbh.
function smusers_lbh_Callback(hObject, eventdata, handles)
% hObject    handle to smusers_lbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('SMusers');

% Hints: contents = cellstr(get(hObject,'String')) returns smusers_lbh contents as cell array
%        contents{get(hObject,'Value')} returns selected item from smusers_lbh


% --- Executes during object creation, after setting all properties.
function smusers_lbh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smusers_lbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
sm_Callback('SMusersCreate');
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in enqueue.
function enqueue_Callback(hObject, eventdata, handles)
% hObject    handle to enqueue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('Enqueue');


% --- Executes on button press in editscan_pbh.
function editscan_pbh_Callback(hObject, eventdata, handles)
% hObject    handle to editscan_pbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('EditScan');


% --- Executes on button press in removescan_pbh.
function removescan_pbh_Callback(hObject, eventdata, handles)
% hObject    handle to removescan_pbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('RemoveScan');



function qtxt_eth_Callback(hObject, eventdata, handles)
% hObject    handle to qtxt_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('Qtxt');
% Hints: get(hObject,'String') returns contents of qtxt_eth as text
%        str2double(get(hObject,'String')) returns contents of qtxt_eth as a double


% --- Executes during object creation, after setting all properties.
function qtxt_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qtxt_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in txtenqueue.
function txtenqueue_Callback(hObject, eventdata, handles)
% hObject    handle to txtenqueue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('TXTenqueue');

% --- Executes on button press in pptauto_cbh.
function pptauto_cbh_Callback(hObject, eventdata, handles)
% hObject    handle to pptauto_cbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('PPTauto');
% Hint: get(hObject,'Value') returns toggle state of pptauto_cbh


% --- Executes on button press in pptfile_pbh.
function pptfile_pbh_Callback(hObject, eventdata, handles)
% hObject    handle to pptfile_pbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('PPTFile');



function comments_eth_Callback(hObject, eventdata, handles)
% hObject    handle to comments_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('Comments');
% Hints: get(hObject,'String') returns contents of comments_eth as text
%        str2double(get(hObject,'String')) returns contents of comments_eth as a double


% --- Executes during object creation, after setting all properties.
function comments_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comments_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pptsave_eth_Callback(hObject, eventdata, handles)
% hObject    handle to pptsave_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('PPTSaveFig');
% Hints: get(hObject,'String') returns contents of pptsave_eth as text
%        str2double(get(hObject,'String')) returns contents of pptsave_eth as a double


% --- Executes during object creation, after setting all properties.
function pptsave_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pptsave_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pptsave_pbh.
function pptsave_pbh_Callback(hObject, eventdata, handles)
% hObject    handle to pptsave_pbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('PPTSaveNow');


% --- Executes on button press in savepath_pbh.
function savepath_pbh_Callback(hObject, eventdata, handles)
% hObject    handle to savepath_pbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('SavePath');



function run_eth_Callback(hObject, eventdata, handles)
% hObject    handle to run_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('RunNum');
% Hints: get(hObject,'String') returns contents of run_eth as text
%        str2double(get(hObject,'String')) returns contents of run_eth as a double


% --- Executes during object creation, after setting all properties.
function run_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to run_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
sm_Callback('RunCreate');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runincrement_cbh.
function runincrement_cbh_Callback(hObject, eventdata, handles)
% hObject    handle to runincrement_cbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('RunIncrement');
% Hint: get(hObject,'Value') returns toggle state of runincrement_cbh


% --- Executes on button press in run_pbh.
function run_pbh_Callback(hObject, eventdata, handles)
% hObject    handle to run_pbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('Run');

% --- Executes on button press in pause_pbh.
function pause_pbh_Callback(hObject, eventdata, handles)
% hObject    handle to pause_pbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('Pause');

% --- Executes on button press in pptfile2_pbh.
function pptfile2_pbh_Callback(hObject, eventdata, handles)
% hObject    handle to pptfile2_pbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('PPTFile2');

% --- Executes on button press in pptsavepriority_cbh.
function pptsavepriority_cbh_Callback(hObject, eventdata, handles)
% hObject    handle to pptsavepriority_cbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('PPTPriority');
% Hint: get(hObject,'Value') returns toggle state of pptsavepriority_cbh



function console_eth_Callback(hObject, eventdata, handles)
% hObject    handle to console_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('Console');
% Hints: get(hObject,'String') returns contents of console_eth as text
%        str2double(get(hObject,'String')) returns contents of console_eth as a double


% --- Executes during object creation, after setting all properties.
function console_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to console_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in evaluate_pbh.
function evaluate_pbh_Callback(hObject, eventdata, handles)
% hObject    handle to evaluate_pbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('Eval');


% --- Executes on key press with focus on queue_lbh and none of its controls.
function queue_lbh_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to queue_lbh (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
%sm_Callback('QueueKeyPress',eventdata);
sm_Callback('QueueKey',eventdata);


% --- Executes on key press with focus on scans_lbh and none of its controls.
function scans_lbh_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to scans_lbh (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('ScansKey',eventdata);


% --- Executes on button press in editscan2_pbh.
function editscan2_pbh_Callback(hObject, eventdata, handles)
% hObject    handle to editscan2_pbh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_Callback('EditScan2');
