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

% Last Modified by GUIDE v2.5 18-Oct-2011 21:15:21

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
                   'gui_LayoutFcn',  @compute_projections_dialog_LayoutFcn, ...
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

% --- Creates and returns a handle to the GUI figure. 
function h1 = compute_projections_dialog_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end
load compute_projections_dialog.mat


appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', 2, ...
    'pushbutton', 4, ...
    'axes', 2, ...
    'text', 4, ...
    'checkbox', 2, ...
    'edit', 3, ...
    'uipanel', 2), ...
    'override', 1, ...
    'release', 13, ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', 1, ...
    'callbacks', 1, ...
    'singleton', 1, ...
    'syscolorfig', 1, ...
    'blocking', 0, ...
    'lastSavedFile', '/Users/tnishi/Documents/PROJECTS/Paper - visual analytics/Software/find_struct_groups/private/compute_projections_dialog.m', ...
    'lastFilename', '/Users/tnishi/Documents/PROJECTS/Paper - visual analytics/Software/find_struct_groups copy/compute_projections_dialog.fig');
appdata.lastValidTag = 'compute_projection_dialog_fig';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'compute_projection_dialog_fig');

h1 = figure(...
'Units','characters',...
'CloseRequestFcn',mat{1},...
'Color',[0.701960784313725 0.701960784313725 0.701960784313725],...
'Colormap',[0 0 0;1 1 1;0.984313725490196 0.956862745098039 0.6;0.984313725490196 0.952941176470588 0.6;0 0 0.6;0.988235294117647 0.956862745098039 0.603921568627451;0.988235294117647 0.956862745098039 0.6;0.690196078431373 0.662745098039216 0.666666666666667;0.0549019607843137 0.0509803921568627 0.0549019607843137;0.0627450980392157 0.0588235294117647 0.0627450980392157;0.0705882352941176 0.0666666666666667 0.0705882352941176;0.0156862745098039 0.0117647058823529 0.0196078431372549;0.0352941176470588 0.0313725490196078 0.0392156862745098;0.623529411764706 0.596078431372549 0.658823529411765;0.0196078431372549 0.0156862745098039 0.0274509803921569;0.501960784313725 0.482352941176471 0.647058823529412;0.447058823529412 0.427450980392157 0.643137254901961;0.388235294117647 0.372549019607843 0.63921568627451;0.270588235294118 0.258823529411765 0.627450980392157;0.294117647058824 0.282352941176471 0.627450980392157;0.309803921568627 0.298039215686275 0.631372549019608;0.352941176470588 0.341176470588235 0.635294117647059;0.125490196078431 0.12156862745098 0.611764705882353;0.149019607843137 0.145098039215686 0.615686274509804;0.192156862745098 0.184313725490196 0.619607843137255;0.223529411764706 0.215686274509804 0.619607843137255;0 0 0.00784313725490196;0 0 0.00392156862745098;0.0196078431372549 0.0196078431372549 0.603921568627451;0.0470588235294118 0.0431372549019608 0.603921568627451;0.0784313725490196 0.0745098039215686 0.607843137254902;0.0823529411764706 0.0784313725490196 0.607843137254902;0.105882352941176 0.101960784313725 0.611764705882353;0.00392156862745098 0.00392156862745098 0.0196078431372549;0.00784313725490196 0.00784313725490196 0.0196078431372549;0.0117647058823529 0.0117647058823529 0.0274509803921569;0.0235294117647059 0.0235294117647059 0.0352941176470588;0.0274509803921569 0.0274509803921569 0.0392156862745098;1 0.996078431372549 0.623529411764706;1 1 0.627450980392157;1 0.996078431372549 0.631372549019608;1 1 0.635294117647059;1 1 0.643137254901961;1 1 0.650980392156863;0.0705882352941176 0.0705882352941176 0.0509803921568627;0.305882352941176 0.305882352941176 0.227450980392157;0.16078431372549 0.16078431372549 0.12156862745098;0.0392156862745098 0.0392156862745098 0.0352941176470588;0.0705882352941176 0.0705882352941176 0.0666666666666667;0.0862745098039216 0.0862745098039216 0.0823529411764706;0.184313725490196 0.184313725490196 0.176470588235294;0.0941176470588235 0.0941176470588235 0.0901960784313725;0.101960784313725 0.101960784313725 0.0980392156862745;0.145098039215686 0.145098039215686 0.141176470588235;1 0.988235294117647 0.615686274509804;1 0.992156862745098 0.619607843137255;0.925490196078431 0.913725490196078 0.6;0.423529411764706 0.419607843137255 0.298039215686275;1 0.976470588235294 0.611764705882353;0.996078431372549 0.972549019607843 0.607843137254902;1 0.980392156862745 0.615686274509804;1 0.984313725490196 0.619607843137255;1 0.976470588235294 0.619607843137255;0.988235294117647 0.972549019607843 0.615686274509804;1 0.980392156862745 0.627450980392157;0.988235294117647 0.972549019607843 0.619607843137255;0.984313725490196 0.964705882352941 0.615686274509804;0.219607843137255 0.215686274509804 0.145098039215686;0.4 0.392156862745098 0.270588235294118;0.258823529411765 0.254901960784314 0.192156862745098;0.145098039215686 0.141176470588235 0.0862745098039216;0.992156862745098 0.96078431372549 0.603921568627451;0.988235294117647 0.96078431372549 0.6;0.96078431372549 0.929411764705882 0.584313725490196;0.996078431372549 0.968627450980392 0.607843137254902;0.988235294117647 0.96078431372549 0.603921568627451;0.96078431372549 0.933333333333333 0.588235294117647;0.945098039215686 0.913725490196078 0.576470588235294;0.996078431372549 0.964705882352941 0.611764705882353;0.984313725490196 0.952941176470588 0.603921568627451;0.964705882352941 0.941176470588235 0.592156862745098;0.964705882352941 0.937254901960784 0.592156862745098;0.956862745098039 0.925490196078431 0.588235294117647;0.949019607843137 0.92156862745098 0.584313725490196;0.984313725490196 0.96078431372549 0.607843137254902;0.952941176470588 0.925490196078431 0.588235294117647;0.972549019607843 0.949019607843137 0.607843137254902;0.956862745098039 0.929411764705882 0.6;0.937254901960784 0.909803921568627 0.588235294117647;0.929411764705882 0.901960784313726 0.584313725490196;0.92156862745098 0.898039215686275 0.584313725490196;0.909803921568627 0.882352941176471 0.576470588235294;0.850980392156863 0.827450980392157 0.541176470588235;0.611764705882353 0.596078431372549 0.4;0.407843137254902 0.396078431372549 0.270588235294118;0.458823529411765 0.447058823529412 0.309803921568627;0.368627450980392 0.36078431372549 0.258823529411765;0.329411764705882 0.32156862745098 0.235294117647059;0.231372549019608 0.227450980392157 0.176470588235294;0.988235294117647 0.952941176470588 0.6;0.988235294117647 0.952941176470588 0.603921568627451;0.984313725490196 0.949019607843137 0.6;0.92156862745098 0.890196078431372 0.580392156862745;0.819607843137255 0.792156862745098 0.52156862745098;0.83921568627451 0.811764705882353 0.537254901960784;0.8 0.772549019607843 0.509803921568627;0.764705882352941 0.737254901960784 0.494117647058824;0.713725490196078 0.690196078431373 0.462745098039216;0.741176470588235 0.713725490196078 0.482352941176471;0.580392156862745 0.56078431372549 0.380392156862745;0.215686274509804 0.207843137254902 0.141176470588235;0.698039215686274 0.674509803921569 0.458823529411765;0.619607843137255 0.6 0.407843137254902;0.682352941176471 0.658823529411765 0.450980392156863;0.450980392156863 0.435294117647059 0.301960784313725;0.262745098039216 0.254901960784314 0.176470588235294;0.584313725490196 0.564705882352941 0.396078431372549;0.486274509803922 0.470588235294118 0.329411764705882;0.6 0.580392156862745 0.407843137254902;0.470588235294118 0.454901960784314 0.32156862745098;0.505882352941176 0.490196078431373 0.349019607843137;0.388235294117647 0.376470588235294 0.274509803921569;0.403921568627451 0.392156862745098 0.290196078431373;0.266666666666667 0.258823529411765 0.192156862745098;0.180392156862745 0.176470588235294 0.137254901960784;0.72156862745098 0.694117647058824 0.470588235294118;0.6 0.576470588235294 0.392156862745098;0.101960784313725 0.0980392156862745 0.0705882352941176;0.309803921568627 0.298039215686275 0.215686274509804;0.313725490196078 0.301960784313725 0.219607843137255;0.250980392156863 0.243137254901961 0.180392156862745;0.141176470588235 0.137254901960784 0.105882352941176;0.156862745098039 0.152941176470588 0.12156862745098;0.0862745098039216 0.0823529411764706 0.0588235294117647;0.494117647058824 0.474509803921569 0.349019607843137;0.286274509803922 0.274509803921569 0.203921568627451;0.219607843137255 0.211764705882353 0.164705882352941;0.243137254901961 0.235294117647059 0.184313725490196;0.0627450980392157 0.0588235294117647 0.0392156862745098;0.192156862745098 0.184313725490196 0.145098039215686;0.443137254901961 0.43921568627451 0.419607843137255;0.0784313725490196 0.0745098039215686 0.0588235294117647;0.164705882352941 0.156862745098039 0.125490196078431;0.117647058823529 0.113725490196078 0.0980392156862745;0.152941176470588 0.145098039215686 0.117647058823529;0.850980392156863 0.815686274509804 0.682352941176471;0.835294117647059 0.8 0.67843137254902;0.0470588235294118 0.0431372549019608 0.0313725490196078;0.0862745098039216 0.0823529411764706 0.0705882352941176;0.803921568627451 0.772549019607843 0.67843137254902;0.23921568627451 0.235294117647059 0.223529411764706;0.513725490196078 0.505882352941176 0.482352941176471;0.568627450980392 0.56078431372549 0.537254901960784;0.56078431372549 0.552941176470588 0.529411764705882;0.556862745098039 0.549019607843137 0.525490196078431;0.552941176470588 0.545098039215686 0.52156862745098;0.270588235294118 0.266666666666667 0.254901960784314;0.607843137254902 0.6 0.576470588235294;0.576470588235294 0.568627450980392 0.545098039215686;0.290196078431373 0.286274509803922 0.274509803921569;0.498039215686275 0.490196078431373 0.470588235294118;0.482352941176471 0.474509803921569 0.454901960784314;0.47843137254902 0.470588235294118 0.450980392156863;0.533333333333333 0.525490196078431 0.505882352941176;0.529411764705882 0.52156862745098 0.501960784313725;0.513725490196078 0.505882352941176 0.486274509803922;0.505882352941176 0.498039215686275 0.47843137254902;0.501960784313725 0.494117647058824 0.474509803921569;0.552941176470588 0.545098039215686 0.525490196078431;0.772549019607843 0.741176470588235 0.674509803921569;0.662745098039216 0.650980392156863 0.623529411764706;0.647058823529412 0.635294117647059 0.607843137254902;0.701960784313725 0.690196078431373 0.662745098039216;0.686274509803922 0.674509803921569 0.647058823529412;0.670588235294118 0.658823529411765 0.631372549019608;0.0352941176470588 0.0313725490196078 0.0235294117647059;0.129411764705882 0.12156862745098 0.105882352941176;0.6 0.588235294117647 0.564705882352941;0.588235294117647 0.576470588235294 0.552941176470588;0.580392156862745 0.568627450980392 0.545098039215686;0.63921568627451 0.627450980392157 0.603921568627451;0.627450980392157 0.615686274509804 0.592156862745098;0.623529411764706 0.611764705882353 0.588235294117647;0.619607843137255 0.607843137254902 0.584313725490196;0.611764705882353 0.6 0.576470588235294;0.423529411764706 0.415686274509804 0.4;0.686274509803922 0.674509803921569 0.650980392156863;0.682352941176471 0.670588235294118 0.647058823529412;0.67843137254902 0.666666666666667 0.643137254901961;0.674509803921569 0.662745098039216 0.63921568627451;0.666666666666667 0.654901960784314 0.631372549019608;0.662745098039216 0.650980392156863 0.627450980392157;0.654901960784314 0.643137254901961 0.619607843137255;0.650980392156863 0.63921568627451 0.615686274509804;0.454901960784314 0.447058823529412 0.431372549019608;0.450980392156863 0.443137254901961 0.427450980392157;0.43921568627451 0.431372549019608 0.415686274509804;0.435294117647059 0.427450980392157 0.411764705882353;0.227450980392157 0.223529411764706 0.215686274509804;0.466666666666667 0.458823529411765 0.443137254901961;0.247058823529412 0.243137254901961 0.235294117647059;0.243137254901961 0.23921568627451 0.231372549019608;0.23921568627451 0.235294117647059 0.227450980392157;0.235294117647059 0.231372549019608 0.223529411764706;0.258823529411765 0.254901960784314 0.247058823529412;0.294117647058824 0.290196078431373 0.282352941176471;0.32156862745098 0.317647058823529 0.309803921568627;0.745098039215686 0.717647058823529 0.670588235294118;0.529411764705882 0.517647058823529 0.498039215686275;0.52156862745098 0.509803921568627 0.490196078431373;0.572549019607843 0.56078431372549 0.541176470588235;0.564705882352941 0.552941176470588 0.533333333333333;0.545098039215686 0.533333333333333 0.513725490196078;0.592156862745098 0.580392156862745 0.56078431372549;0.694117647058824 0.67843137254902 0.654901960784314;0.352941176470588 0.345098039215686 0.333333333333333;0.345098039215686 0.337254901960784 0.325490196078431;0.368627450980392 0.36078431372549 0.349019607843137;0.407843137254902 0.4 0.388235294117647;0.4 0.392156862745098 0.380392156862745;0.388235294117647 0.380392156862745 0.368627450980392;0.490196078431373 0.47843137254902 0.462745098039216;0.474509803921569 0.462745098039216 0.447058823529412;0.733333333333333 0.705882352941177 0.670588235294118;0.0588235294117647 0.0549019607843137 0.0509803921568627;0.101960784313725 0.0980392156862745 0.0941176470588235;0.133333333333333 0.129411764705882 0.125490196078431;0.701960784313725 0.682352941176471 0.662745098039216;0.27843137254902 0.270588235294118 0.262745098039216;0.145098039215686 0.141176470588235 0.137254901960784;0.333333333333333 0.325490196078431 0.317647058823529;0.317647058823529 0.309803921568627 0.301960784313725;0.309803921568627 0.301960784313725 0.294117647058824;0.164705882352941 0.16078431372549 0.156862745098039;0.203921568627451 0.2 0.196078431372549;0.0196078431372549 0.0156862745098039 0.0156862745098039;0.0470588235294118 0.0431372549019608 0.0431372549019608;0.0549019607843137 0.0509803921568627 0.0509803921568627;0.0705882352941176 0.0666666666666667 0.0666666666666667;0.0745098039215686 0.0705882352941176 0.0705882352941176;0.0784313725490196 0.0745098039215686 0.0745098039215686;0.12156862745098 0.117647058823529 0.117647058823529;0.113725490196078 0.109803921568627 0.109803921568627;0.172549019607843 0.168627450980392 0.168627450980392;0.109803921568627 0.109803921568627 0.109803921568627;0.105882352941176 0.105882352941176 0.105882352941176;0.0941176470588235 0.0941176470588235 0.0941176470588235;0.0823529411764706 0.0823529411764706 0.0823529411764706;0.0627450980392157 0.0627450980392157 0.0627450980392157;0.0588235294117647 0.0588235294117647 0.0588235294117647;0.0509803921568627 0.0509803921568627 0.0509803921568627;0.0392156862745098 0.0392156862745098 0.0392156862745098;0.0313725490196078 0.0313725490196078 0.0313725490196078;0.0274509803921569 0.0274509803921569 0.0274509803921569;0.00784313725490196 0.00784313725490196 0.00784313725490196;0.752941176470588 0.752941176470588 0.752941176470588],...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'KeyPressFcn',mat{2},...
'MenuBar','none',...
'Name','Options for computing projections',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'Position',[131.142857142857 36.9285714285714 55.5714285714286 11.8571428571429],...
'Resize','off',...
'HandleVisibility','callback',...
'Tag','compute_projection_dialog_fig',...
'UserData',[],...
'Visible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );



%%%

appdata = [];
appdata.lastValidTag = 'uipanel1';

h7 = uipanel(...
'Parent',h1,...
'Units','characters',...
'Tag','uipanel1',...
'UserData',[],...
'Clipping','on',...
'Position',[1.71428571428571 1 51 10],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

%%%


appdata = [];
appdata.lastValidTag = 'use_q';

h2 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',mat{3},...
'Position',[4.57142857142857 8.21428571428569 33.2857142857143 1.64285714285714],...
'String','Random selection of coordinates',...
'Style','checkbox',...
'Value',1,...
'Tag','use_q',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'min_coord';

h3 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',mat{4},...
'Position',[37.5714285714285 6.07142857142855 8.71428571428571 2.21428571428571],...
'String','4',...
'Style','edit',...
'CreateFcn',mat{5},...
'Tag','min_coord');

local_CreateFcn(h3, [], '', appdata);

appdata = [];
appdata.lastValidTag = 'min_coord_text';

h4 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'HorizontalAlignment','left',...
'Position',[9.71428571428571 6.35714285714283 28.4285714285714 1.5],...
'String','- Minimum number of coordinates:',...
'Style','text',...
'Tag','min_coord_text',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text3';

h5 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'HorizontalAlignment','left',...
'Position',[7.42857142857143 3.92857142857142 22.5714285714286 1.57142857142857],...
'String','Number of 2D projections:',...
'Style','text',...
'Tag','text3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'num_proj';

h6 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',mat{6},...
'Position',[29.1428571428571 3.78571428571428 9.28571428571428 2.07142857142857],...
'String','30',...
'Style','edit',...
'CreateFcn',mat{7},...
'Tag','num_proj');

local_CreateFcn(h6, [], '', appdata);

% appdata = [];
% appdata.lastValidTag = 'uipanel1';
% 
% h7 = uipanel(...
% 'Parent',h1,...
% 'Units','characters',...
% 'Tag','uipanel1',...
% 'UserData',[],...
% 'Clipping','on',...
% 'Position',[1.71428571428571 1 51 10],...
% 'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ok_button';

h8 = uicontrol(...
'Parent',h7,...
'Units','characters',...
'Callback',mat{8},...
'CData',[],...
'Position',[38.5714285714286 0.500000000000007 9.42857142857143 1.92857142857143],...
'String','OK',...
'Tag','ok_button',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );


hsingleton = h1;


% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   eval(createfcn);
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error('MATLAB:gui_mainfcn:FieldNotFound', 'Could not find field %s in the gui_State struct in GUI M-file %s', gui_StateFields{i}, gui_Mfile);
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % COMPUTE_PROJECTIONS_DIALOG
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % COMPUTE_PROJECTIONS_DIALOG(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallbak(gui_State, varargin{:})
    % COMPUTE_PROJECTIONS_DIALOG('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % COMPUTE_PROJECTIONS_DIALOG(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~isa(handle(fig),'matlab.ui.Figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || isprop(fig,'__GUIDEFigure');
    end
        
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else       
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end

    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.

    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.   
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);

        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')

        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end

    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI M-file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;

    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end

    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end

    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});

    if isscalar(gui_hFigure) && ishandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure); 
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);

        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end

        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end

    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end

    if isscalar(gui_hFigure) && ishandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end

function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    gui_hFigure = openfig(name, singleton, visible);
end

function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
             && isequal(varargin{1},gcbo);
catch
    result = false;
end

function result = local_isInvokeHGCallbak(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
             (ischar(varargin{1}) ...
             && isequal(ishandle(varargin{2}), 1) ...
             && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
                ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch
    result = false;
end


