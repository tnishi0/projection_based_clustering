function varargout = compute_projections_dialog(varargin)
% COMPUTE_PROJECTIONS_DIALOG M-file for compute_projections_dialog.fig
%      COMPUTE_PROJECTIONS_DIALOG by itself, creates a new COMPUTE_PROJECTIONS_DIALOG or raises the
%      existing singleton*.
%
%      H = COMPUTE_PROJECTIONS_DIALOG returns the handle to a new COMPUTE_PROJECTIONS_DIALOG or the handle to
%      the existing singleton*.
%
%      COMPUTE_PROJECTIONS_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPUTE_PROJECTIONS_DIALOG.M with the given input arguments.
%
%      COMPUTE_PROJECTIONS_DIALOG('Property','Value',...) creates a new COMPUTE_PROJECTIONS_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before compute_projections_dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to compute_projections_dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help compute_projections_dialog

% Last Modified by GUIDE v2.5 16-Aug-2010 13:50:42

%
% Copyright (C) 2011  Takashi Nishikawa
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or (at
% your option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
% USA. 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @compute_projections_dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @compute_projections_dialog_OutputFcn, ...
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

% --- Executes just before compute_projections_dialog is made visible.
function compute_projections_dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to compute_projections_dialog (see VARARGIN)

% Choose default command line output for compute_projections_dialog
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
load dialogicons.mat

IconData=questIconData;
questIconMap(256,:) = get(handles.compute_projection_dialog_fig, 'Color');
IconCMap=questIconMap;

% Make the GUI modal
set(handles.compute_projection_dialog_fig,'WindowStyle','modal')

% UIWAIT makes compute_projections_dialog wait for user response (see UIRESUME)
uiwait(handles.compute_projection_dialog_fig);

% --- Outputs from this function are returned to the command line.
function varargout = compute_projections_dialog_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
output.use_q = get(handles.use_q, 'value');
switch get(handles.min_coord, 'enable')
    case 'on'
        output.min_coord = str2num(get(handles.min_coord, 'string'));
end
output.num_proj = str2num(get(handles.num_proj, 'string'));
varargout{1} = output;

% The figure can be deleted now
delete(handles.compute_projection_dialog_fig);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.compute_projection_dialog_fig);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.compute_projection_dialog_fig);


% --- Executes when user attempts to close compute_projection_dialog_fig.
function compute_projection_dialog_fig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to compute_projection_dialog_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isstruct(handles)
    if isequal(get(handles.compute_projection_dialog_fig, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(handles.compute_projection_dialog_fig);
    else
        % The GUI is no longer waiting, just close it
        delete(handles.compute_projection_dialog_fig);
    end
else
    delete(hObject)
end

% --- Executes on key press over compute_projection_dialog_fig with no controls selected.
function compute_projection_dialog_fig_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to compute_projection_dialog_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.compute_projection_dialog_fig);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.compute_projection_dialog_fig);
end    


% --- Executes on button press in use_q.
function use_q_Callback(hObject, eventdata, handles)
% hObject    handle to use_q (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_q
if get(hObject,'Value')
    set([handles.min_coord_text, handles.min_coord], 'enable', 'on')
else
    set([handles.min_coord_text, handles.min_coord], 'enable', 'off')
end
    

function min_coord_Callback(hObject, eventdata, handles)
% hObject    handle to min_coord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_coord as text
%        str2double(get(hObject,'String')) returns contents of min_coord as a double
if str2num(get(hObject,'String')) < 2
    msgbox('Minimum number of coordinates must be at least 2')
    set(hObject, 'String', 2)
end


% --- Executes during object creation, after setting all properties.
function min_coord_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_coord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_proj_Callback(hObject, eventdata, handles)
% hObject    handle to num_proj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_proj as text
%        str2double(get(hObject,'String')) returns contents of num_proj as a double


% --- Executes during object creation, after setting all properties.
function num_proj_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_proj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isstruct(handles)
    close(handles.compute_projection_dialog_fig)
end