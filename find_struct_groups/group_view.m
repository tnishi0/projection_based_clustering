function varargout = group_view(varargin)
% GROUP_VIEW M-file for group_view.fig
%      GROUP_VIEW, by itself, creates a new GROUP_VIEW or raises the existing
%      singleton*.
%
%      H = GROUP_VIEW returns the handle to a new GROUP_VIEW or the handle to
%      the existing singleton*.
%
%      GROUP_VIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GROUP_VIEW.M with the given input arguments.
%
%      GROUP_VIEW('Property','Value',...) creates a new GROUP_VIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before group_view_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to group_view_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help group_view

% Last Modified by GUIDE v2.5 03-Oct-2011 18:45:47

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
                   'gui_OpeningFcn', @group_view_OpeningFcn, ...
                   'gui_OutputFcn',  @group_view_OutputFcn, ...
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


% --- Executes just before group_view is made visible.
function group_view_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to group_view (see VARARGIN)

x = varargin{2}; y = varargin{3};
orig_units = get(hObject, 'units');
set(hObject, 'units', 'pixels');
pos = get(hObject, 'position');
pos(1:2) = [x - pos(3)/2, y - pos(4)/2];
set(hObject, 'position', pos)
set(hObject, 'units', orig_units)

% Choose default command line output for group_view
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Load network data
load_network(varargin{1}, handles);
    
% UIWAIT makes group_view wait for user response (see UIRESUME)
% uiwait(handles.group_view_figure);


% --- Outputs from this function are returned to the command line.
function varargout = group_view_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
varargout{1} = hObject;


% --- Executes on slider movement.
function num_groups_slider_Callback(hObject, eventdata, handles)
% hObject    handle to num_groups_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Change the height at which to cut the dendrogram
network = handles.network; 
n = size(network.np,2);
delete(get(handles.group_panel, 'Children'))
h_dendrogram = axes('position', [0.15 0.1 0.8 0.85], 'parent', handles.group_panel);
Z = network.Z_som_linkage;
[h,Coord,Color,height] = som_dendrogram(Z);
threshold = floor(get(hObject, 'value'));
if threshold < 0.5
    threshold = 0;
end
if threshold > get(hObject, 'max')
    threshold = get(hObject, 'max');
end
set(handles.threshold_text, 'string', num2str(threshold+0.5))
yl = ylim; yl(2) = max(height)+1; ylim(yl);
xl = xlim;
xl(2) = max(Coord)+1;
line(xl, [1 1]*(threshold+0.5), 'Color', 'r')
xlim(xl)
grouping = cell(1,n);
for j = 1:n
    grouping{j} = j;
end
jj = 1; k = n;
while jj < size(Z,1) && Z(jj,3) <= threshold
    k = k + 1;
    grouping{k}...
        = [grouping{Z(jj,1)}, grouping{Z(jj,2)}];
    grouping{Z(jj,1)} = []; 
    grouping{Z(jj,2)} = [];
    jj = jj + 1;
end

if max(height) == 0 || threshold >= max(height)
    groups = ones(1,n);
else
    groups = zeros(1,n);
    jj = 0;
    for kk = 1:length(grouping)
        if ~isempty(grouping{kk})
            jj = jj + 1;
            for ii = 1:length(grouping{kk})
                groups(grouping{kk}(ii)) = jj;
            end
        end
    end
end

network.combined_grouping = groups;
set(handles.num_groups_text, 'string', num2str(max(groups)))

% Update network.gr_info
for k = 1:max(groups)
    node_idx = find(groups == k);
    network.gr_info(k).node_idx = node_idx;
    network.gr_info(k).total_num_nodes = length(node_idx);
end

redraw_parallel_coords(handles, [])
K = max(groups);

% Colors for different groups are taken around the color cirlcle with equal
% spacing.
c = hsv2rgb([(0:K-1)'/K, ones(K,2)]); 
network.group_colors = c;

hold(h_dendrogram, 'on')
for i = 1:n
    plot(h_dendrogram, Coord(i), 0, '.', 'color', c(groups(i),:))
end
hold(h_dendrogram, 'off')
marker_shapes = {'o', 's', 'd', '^', 'v', '<', '>', 'p', 'h'};
h = handles.projected_points;
for i = 1:length(h)
    if isfield(network, 'known_groups')
        k = network.known_groups(i);
        marker = marker_shapes{mod(k-1, length(marker_shapes)) + 1};
    else
        marker = 'o';
    end
    set(h(i), 'marker', marker,...
        'markerfacecolor', c(groups(i),:),...
        'markeredgecolor', ones(1,3)*0.3)
end

if get(handles.proj_method_menu, 'value') == 3
    handles.G = update_lda_proj(network, handles);
end

handles.network = network;
handles.h_dendrogram = h_dendrogram;
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function num_groups_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_groups_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in proj_method_menu.
function proj_method_menu_Callback(hObject, eventdata, handles)
% hObject    handle to proj_method_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns proj_method_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from proj_method_menu
network = handles.network;
h_xlabel = get(handles.projection_view, 'xlabel');
h_ylabel = get(handles.projection_view, 'ylabel');        
switch get(hObject,'Value')
    case 1 % node property coordinates with parallel coordinate view
        h = handles.projected_points;
        xi = get(h_xlabel, 'userdata');
        if isempty(xi), xi = 1; set(h_xlabel, 'userdata', xi), end
        yi = get(h_ylabel, 'userdata');
        if isempty(yi), yi = 2; set(h_ylabel, 'userdata', yi), end
        for i = 1:length(h)
            set(h(i), 'xdata', network.np0(xi,i))
            set(h(i), 'ydata', network.np0(yi,i))
        end
        set(handles.projection_view, 'XLimMode', 'auto', 'YLimMode', 'auto')
        set(h_xlabel,...
            'string', sprintf('%s (#%d)', network.prop_name{xi}, xi))
        set(h_ylabel,...
            'string', sprintf('%s (#%d)', network.prop_name{yi}, yi))
        set(handles.forward, 'visible', 'off')
        set(handles.backward, 'visible', 'off')
        handles.selected_axis = h_xlabel;
        set(h_xlabel, 'backgroundcolor', 'r')
        
        % Show parallel coordinate view
        set(handles.para_coord, 'visible', 'on')
        set(handles.proj_basis_1, 'visible', 'off')
        set(handles.proj_basis_2, 'visible', 'off')
        cla(handles.proj_basis_1)
        cla(handles.proj_basis_2)
        redraw_parallel_coords(handles, [])

    case 2 % User-selected projections
        if isfield(handles, 'current_proj')
            k = handles.current_proj;
        else
            for k = 1:length(network.proj_data)
                if ~isempty(network.proj_data(k).grouping), break, end
            end
            if k == length(network.proj_data), k = 1; end
        end
        handles.current_proj = k;
        guidata(hObject, handles)
        update_projection(network, handles, k)
        set(handles.forward, 'visible', 'on')
        set(handles.backward, 'visible', 'on')
        set(h_xlabel, 'string', 'coordinate #1', 'backgroundcolor', 'none')
        set(h_ylabel, 'string', 'coordinate #2', 'backgroundcolor', 'none')
        
        % basis view
        cla(handles.para_coord)
        set(handles.para_coord, 'visible', 'off')
        set(handles.proj_basis_1, 'visible', 'on')
        set(handles.proj_basis_2, 'visible', 'on')
        draw_bases(network, handles, k)
        
    case 3 % LDA-based projection
        cla(handles.para_coord)
        set(handles.para_coord, 'visible', 'off')
        set(handles.proj_basis_1, 'visible', 'on')
        set(handles.proj_basis_2, 'visible', 'on')
        handles.G = update_lda_proj(network, handles);
        set(handles.forward, 'visible', 'off')
        set(handles.backward, 'visible', 'off')
        set(h_xlabel, 'string', 'coordinate #1', 'backgroundcolor', 'none')
        set(h_ylabel, 'string', 'coordinate #2', 'backgroundcolor', 'none')
end

guidata(hObject, handles)


% --------------------------------------------------------------------
function G = update_lda_proj(network, handles, grouping)

if nargin < 3
    if isfield(network, 'combined_grouping') ...
            && ~isempty(network.combined_grouping)
        grouping = network.combined_grouping;
    else
        grouping = ones(size(network.np(1,:)));
    end
end
ix = grouping >= 0;
if ~any(ix), return, end
h = handles.projected_points;
G = lda_qr(network.np(:,ix), grouping(ix));
x = G'*network.np;
for i = 1:length(h)
    set(h(i), 'xdata', x(1,i))
    set(h(i), 'ydata', x(2,i))
end

bar(handles.proj_basis_1, G(:,1), 'tag', 'proj_basis_1')
set(handles.proj_basis_1, 'tag', 'proj_basis_1')
bar(handles.proj_basis_2, G(:,2), 'tag', 'proj_basis_2')
set(handles.proj_basis_2, 'tag', 'proj_basis_2')
title(handles.proj_basis_1, 'coordinate #1')
title(handles.proj_basis_2, 'coordinate #2')
set(handles.proj_basis_1,...
    'xlim', [0.5, size(G,1)+0.5],...
    'ytick', [])
set(handles.proj_basis_2,...
    'xlim', [0.5, size(G,1)+0.5],...
    'ytick', [])



% --------------------------------------------------------------------
function draw_bases(network, handles, k)

bar(handles.proj_basis_1, network.proj_data(k).u, 'tag', 'proj_basis_1')
set(handles.proj_basis_1, 'tag', 'proj_basis_1')
bar(handles.proj_basis_2, network.proj_data(k).v, 'tag', 'proj_basis_2')
set(handles.proj_basis_2, 'tag', 'proj_basis_2')
title(handles.proj_basis_1, 'coordinate #1')
title(handles.proj_basis_2, 'coordinate #2')
set(handles.proj_basis_1,...
    'xlim', [0.5, length(network.proj_data(k).u)+0.5],...
    'ytick', [])
set(handles.proj_basis_2,...
    'xlim', [0.5, length(network.proj_data(k).v)+0.5],...
    'ytick', [])


% --------------------------------------------------------------------
function update_projection(network, handles, k)

h = handles.projected_points;
for i = 1:length(h)
    set(h(i), 'xdata', network.proj_data(k).xp(i))
    set(h(i), 'ydata', network.proj_data(k).yp(i))
end
set(findobj(handles.group_view_figure, 'tag', 'x'),...
    'string', 'coordinate #1', 'backgroundcolor', 'none')
set(findobj(handles.group_view_figure, 'tag', 'y'),...
    'string', 'coordinate #2', 'backgroundcolor', 'none')
title(handles.projection_view,...
    sprintf('Random projection #%d', k))
set(handles.projection_view, 'XLimMode', 'auto', 'YLimMode', 'auto')


% --- Executes during object creation, after setting all properties.
function proj_method_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to proj_method_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
% function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function handles = load_network(network, handles)

if isfield(network, 'Z_som_linkage')
    Z = network.Z_som_linkage;
else
    D = hamming_distances(network.groupings);
    Z = som_linkage(network.np', 'dist', D, 'single');
    network.Z_som_linkage = Z; 
end
if max(Z(:,3)) <= 1
    sliderstep = [1 1];
    slidermax = 1;
else
    sliderstep = [1 3]/(max(Z(:,3))-1);
    slidermax = max(Z(:,3));
end

% Create node_info if not present
if ~isfield(network, 'node_info')
    network.node_info = cell(1,size(network.A,1));
    for i = 1:length(network.node_info)
        network.node_info{i} = sprintf('Node %d', i);
    end
end

% save as application data
handles.network = network;

% draw projection view
marker_type = generate_marker_type;
if isfield(network, 'combined_grouping') ...
        && ~isempty(network.combined_grouping)
    group = network.combined_grouping;
else
    group = ones(size(network.np(1,:)));
end
h = zeros(1,length(group));
hold(handles.projection_view, 'on')
for i = 1:length(group)
    h(i) = plot(handles.projection_view,...
                network.np0(1,i), ...
                network.np0(2,i), ...
                marker_type{group(i)}{2},...
                'markerfacecolor', marker_type{group(i)}{1},...
                'markeredgecolor', 'k', 'markersize', 6,...
                'tag', 'projected_points');
    if isfield(network, 'node_info') && iscell(network.node_info) ...
            && length(network.node_info) >= i
        set(h(i), 'userdata', network.node_info{i});
    else
        node_info = {['Node ',num2str(i)]};
        set(h(i), 'userdata', node_info);
    end
end
hold(handles.projection_view, 'off')
handles.projected_points = h;
num_groups = max(group);

set(handles.projection_view, 'XLimMode', 'auto', 'YLimMode', 'auto')
xlabel(handles.projection_view, 'x', 'tag', 'x', 'HandleVisibility', 'on')
ylabel(handles.projection_view, 'y', 'tag', 'y', 'HandleVisibility', 'on')

proj_method_menu_Callback(handles.proj_method_menu, [], handles)

set(handles.num_groups_slider, ...
    'enable', 'on', ...
    'max', slidermax, 'min', 0, ...
    'sliderstep', sliderstep, 'value', slidermax-1)
num_groups_slider_Callback(handles.num_groups_slider, [], handles)


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function group_view_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to group_view_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected_object = get(hObject, 'CurrentObject');
if isempty(selected_object), return, end
if handles.projection_view == selected_object ...
    && isfield(handles, 'sep_line_mode') && handles.sep_line_mode == 1

    % create line between clicked point and current pointer
    % position
    p = get(handles.projection_view, 'CurrentPoint');
    set(handles.projection_view, ...
        'XLimMode', 'manual', 'YLimMode', 'manual')
    axes(handles.projection_view)
    handles.sep_line = line([p(1,1) p(1,1)], [p(1,2) p(1,2)]);
    handles.sep_line_mode = 2;
    
    guidata(hObject, handles)
    return
end     

if handles.h_dendrogram == selected_object
    curr_pt = get(handles.h_dendrogram, 'CurrentPoint');
    set(handles.num_groups_slider, 'value', floor(curr_pt(1,2)))
    num_groups_slider_Callback(handles.num_groups_slider, eventdata, handles)
    return
end

object_tag = get(selected_object, 'tag');
if isempty(object_tag), return, end
switch object_tag
    case {'x','y'}
        set(handles.selected_axis, 'backgroundcolor', 'none')
        if strcmp(object_tag,'x')
            set(selected_object, 'backgroundcolor', 'r')
        else
            set(selected_object, 'backgroundcolor', 'g')
        end
        handles.selected_axis = selected_object;
        guidata(hObject, handles)
        return
        
    case 'coordinate'
        if isempty(handles.selected_axis), return, end
        
        % update coordinates of the projected points
        network = handles.network;
        selected_axis = handles.selected_axis;
        h = handles.projected_points;
        k = get(selected_object, 'userdata');
        axis_type = get(selected_axis, 'tag');
        switch axis_type
            case 'x'
                for i = 1:length(h)
                    set(h(i), 'xdata', network.np0(k,i))
                end
                set(selected_object, 'facecolor', 'r')
            case 'y'
                for i = 1:length(h)
                    set(h(i), 'ydata', network.np0(k,i))
                end
                set(selected_object, 'facecolor', 'g')
        end
        s = sprintf('%s (#%d)', network.prop_name{k}, k);
        set(selected_axis, 'string', s)
        old_coord = get(selected_axis, 'userdata');
        set(findobj(findobj(handles.group_view_figure, 'tag', 'coordinate'), 'userdata', old_coord), 'facecolor', 'b')
        set(selected_axis, 'userdata', k)
        guidata(hObject, handles)
        return
        
    case 'group' 
        % Do this when a group is selected by clicking on the corresponding
        % pie chart.
        
        selected_pie = selected_object;
        selected_group = get(selected_pie, 'userdata');
        
        if ~isempty(selected_group)

            if ~isfield(handles, 'selected_groups')...
                    || get(handles.proj_method_menu, 'value') == 1
                handles.selected_groups = selected_group;
            else
                ix = find(handles.selected_groups == selected_group);
                if isempty(ix)
                    handles.selected_groups ...
                        = [handles.selected_groups, selected_group];
                else
                    handles.selected_groups(ix) = [];
                end
            end

            % Put red box around the pie chart
            set(handles.pie_charts, 'linestyle', 'none')
            set(handles.pie_charts(handles.selected_groups), ...
                'linestyle', '-', 'linewidth', 3, 'edgecolor', 'r')
            
            if get(handles.proj_method_menu, 'value') == 1
                h = handles.projected_points;
                set(h, 'markerfacecolor', [.8 .8 .8], ...
                    'markeredgecolor', [.8 .8 .8])
                j = selected_group;
                group = handles.network.combined_grouping;
                marker_type = generate_marker_type;
                set(h(group == j), ...
                    'marker', marker_type{j}{2},...
                    'markerfacecolor', marker_type{j}{1}, ...
                    'markeredgecolor', [0 0 0])
            else
                switch get(handles.group_focus_mode, 'state')

                    case 'on' % group focus mode

                        % Make other points invisible
                        group = handles.network.combined_grouping;
                        h = handles.projected_points;
                        if isempty(handles.selected_groups)
                            set(h, 'visible', 'on')
                        else
                            set(h, 'markerfacecolor', [.8 .8 .8], ...
                                'markeredgecolor', [.8 .8 .8])
                            marker_type = generate_marker_type;
                            for i = 1:length(handles.selected_groups)
                                j = handles.selected_groups(i);
                                set(h(group == j), ...
                                    'marker', marker_type{j}{2},...
                                    'markerfacecolor', marker_type{j}{1}, ...
                                    'markeredgecolor', [0 0 0])
                            end

                        end

                        % For LDA-baed projection, update projection
                        if get(handles.proj_method_menu, 'value') == 3
                           grouping = handles.network.combined_grouping;
                           if isempty(handles.selected_groups)
                               focused_grouping = grouping;
                           else
                               focused_grouping = ones(size(grouping));
                               for i = 1:length(handles.selected_groups)
                                   focused_grouping(grouping == handles.selected_groups(i)) ...
                                       = handles.selected_groups(i) + 1;
                               end
                           end
                           handles.G = update_lda_proj(handles.network, handles, focused_grouping);
                        end

                    case 'off' % group highlight mode

                        % Make points in other groups gray
                        group = handles.network.combined_grouping;
                        marker_type = generate_marker_type;
                        h = handles.projected_points;
                        if isempty(handles.selected_groups)
                            for i = 1:length(h)
                                set(h(i), 'marker', marker_type{group(i)}{2},...
                                    'markerfacecolor', marker_type{group(i)}{1}, ...
                                    'markeredgecolor', [0 0 0])
                            end
                        else
                            set(h, 'markerfacecolor', [.8 .8 .8], ...
                                'markeredgecolor', [.8 .8 .8])
                            for i = 1:length(handles.selected_groups)
                                j = handles.selected_groups(i);
                                set(h(group == j), ...
                                    'marker', marker_type{j}{2},...
                                    'markerfacecolor', marker_type{j}{1}, ...
                                    'markeredgecolor', [0 0 0])
                            end
                        end

                        % For LDA-baed projection, update projection
                        if get(handles.proj_method_menu, 'value') == 3
                           grouping = handles.network.combined_grouping;
                           if isempty(handles.selected_groups)
                               focused_grouping = grouping;
                           else
                               focused_grouping = ones(size(grouping));
                               for i = 1:length(handles.selected_groups)
                                   focused_grouping(grouping == handles.selected_groups(i)) ...
                                       = 2;
                               end
                           end
                           handles.G = update_lda_proj(handles.network, handles, focused_grouping);
                        end
                end
            end
            
            % Update parallel coordinate plot
            redraw_parallel_coords(handles, selected_group)
            
        end
        
        guidata(hObject, handles)
        return
        
    case {'proj_basis_1','proj_basis_2'}
        curr_axes = get(hObject, 'CurrentAxes');
        p = get(curr_axes, 'CurrentPoint');
        i = floor(p(1,1));
        if i > 0
            set(handles.group_info_text, 'string', sprintf('%s', handles.network.prop_name{i}))
            set(handles.uipanel4, 'title', 'Node property clicked')
        end
        guidata(hObject, handles)
        return
        
    case 'projected_points'
        node_info = get(selected_object, 'userdata');
        set(handles.group_info_text, ...
            'string', node_info)
        set(handles.uipanel4, 'title', 'Node clicked')
        return
        
    otherwise
        set(handles.group_info_text, ...
            'string', ...
            'Click a point in left plot to see node info;  Click on a bar in top graph to see info on corresponding node property')
        set(handles.uipanel4, 'title', '')
        return
end
        
        
% --- Executes on mouse motion over figure - except title and menu.
function group_view_figure_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to group_view_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles, 'sep_line_mode'), return, end

if handles.sep_line_mode == 2
    % update separating line position
    p = get(handles.projection_view, 'CurrentPoint');
    x = get(handles.sep_line, 'xdata');
    y = get(handles.sep_line, 'ydata');
    x(2) = p(1,1); y(2) = p(1,2);
    set(handles.sep_line, 'xdata', x)
    set(handles.sep_line, 'ydata', y)
end

% --------------------------------------------------------------------
function next_proj_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to next_proj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% go to the next projection that user selected
network = handles.network;
if handles.current_proj == length(network.proj_data), return, end
for k = (handles.current_proj + 1):length(network.proj_data)
    if ~isempty(network.proj_data(k).grouping)
        handles.current_proj = k;
        update_projection(network, handles, k)
        draw_bases(network, handles, k)
        guidata(hObject, handles)
        return
    end
end

% --------------------------------------------------------------------
function previous_proj_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to previous_proj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% go to the next projection that user selected
if handles.current_proj == 1, return, end
network = handles.network;
for k = (handles.current_proj - 1):-1:1
    if ~isempty(network.proj_data(k).grouping)
        handles.current_proj = k;
        update_projection(network, handles, k)
        draw_bases(network, handles, k)
        guidata(hObject, handles)
        return
    end
end


% --------------------------------------------------------------------
function redraw_parallel_coords(handles, selected_coord)

if get(handles.proj_method_menu, 'value') == 1
    parallel_coordinates(handles.network, selected_coord, handles.para_coord)
    i = get(findobj(handles.group_view_figure, 'tag', 'x'), 'userdata');
    set(findobj(findobj(handles.group_view_figure, 'tag', 'coordinate'), 'userdata', i), 'facecolor', 'r')
    i = get(findobj(handles.group_view_figure, 'tag', 'y'), 'userdata');
    set(findobj(findobj(handles.group_view_figure, 'tag', 'coordinate'), 'userdata', i), 'facecolor', 'g')
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function group_view_figure_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to group_view_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'info_popup') && ishandle(handles.info_popup)
    delete(handles.info_popup)
end

if ~isfield(handles, 'sep_line_mode'), return, end
if handles.sep_line_mode == 2
    get(handles.sep_line, 'xdata')
    get(handles.sep_line, 'ydata')
    delete(handles.sep_line)
    handles.sep_line = [];
    handles.sep_line_mode = 1;
    
    guidata(hObject, handles)
end


% --------------------------------------------------------------------
function group_focus_mode_OnCallback(hObject, eventdata, handles)
% hObject    handle to group_focus_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.group_panel, 'title', 'Group: choose groups to focus on')
handles.selected_groups = [];
handles.G = update_lda_proj(handles.network, handles);
h = handles.projected_points;
set(h, 'visible', 'on')
marker_type = generate_marker_type;
group = handles.network.combined_grouping;
for i = 1:length(h)
    set(h(i), 'marker', marker_type{group(i)}{2},...
        'markerfacecolor', marker_type{group(i)}{1}, ...
        'markeredgecolor', [0 0 0])
end
set(handles.pie_charts, 'linestyle', 'none')
guidata(hObject, handles)


% --- Executes when user attempts to close group_view_figure.
function group_view_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to group_view_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


function DrawCircle(x,y,r,c)

th = 0:2*pi/100:2*pi;
% plot(x + r*cos(th), y + r*sin(th), '-', 'color', c, 'LineWidth', 2)
patch(x + r*cos(th), y + r*sin(th), c, 'EdgeColor', c, 'FaceAlpha', 0.2,...
    'LineWidth', 2)


% --- Executes on key press with focus on group_view_figure and none of its controls.
function group_view_figure_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to group_view_figure (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in forward.
function forward_Callback(hObject, eventdata, handles)
% hObject    handle to forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
network = handles.network;
if handles.current_proj == length(network.proj_data), return, end
for k = (handles.current_proj + 1):length(network.proj_data)
    if ~isempty(network.proj_data(k).grouping)
        handles.current_proj = k;
        update_projection(network, handles, k)
        draw_bases(network, handles, k)
        guidata(hObject, handles)
        return
    end
end


% --- Executes on button press in backward.
function backward_Callback(hObject, eventdata, handles)
% hObject    handle to backward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.current_proj == 1, return, end
network = handles.network;
for k = (handles.current_proj - 1):-1:1
    if ~isempty(network.proj_data(k).grouping)
        handles.current_proj = k;
        update_projection(network, handles, k)
        draw_bases(network, handles, k)
        guidata(hObject, handles)
        return
    end
end


% --------------------------------------------------------------------
function quit_Callback(hObject, eventdata, handles)
% hObject    handle to quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
group_view_figure_CloseRequestFcn(handles.group_view_figure, eventdata, handles)


% --- Executes on button press in visualize_network.
function visualize_network_Callback(hObject, eventdata, handles)
% hObject    handle to visualize_network (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure('menu', 'none', 'name', 'Network Visualization',...
    'Position', [10 10 650 650], 'Color', 'w', 'NumberTitle', 'off')
text(0.5, 0.5, 'Drawing... please wait.', 'horizontalalignment', 'center')
axis off
drawnow

network = handles.network;
grouping2 = network.combined_grouping;
num_groups = max(grouping2);

R = 2.2;
r = 0.9;

if num_groups > 1
    d_theta = 2*pi/num_groups;
    group_radius = sqrt((cos(d_theta) - 1)^2 + sin(d_theta)^2) / R;
    group_center = [cos(d_theta*[1:num_groups]'), sin(d_theta*[1:num_groups]')];
else
    group_radius = 1;
    group_center = [0 0];
end

idx = cell(1, num_groups);
for i = 1:num_groups
    idx{i} = find(grouping2 == i);
end

A = network.A;
n = size(A, 1);
for i = 1:num_groups
    if length(idx{i}) < 2
        X(idx{i},1) = group_center(i,1);
        X(idx{i},2) = group_center(i,2);
    else
        Ag = sparse(A(idx{i}, idx{i}) + ones(length(idx{i}))*0.2);
        [ci sizes] = components(Ag);
        if length(sizes) > 1
            options.iterations = 2;
            options.topology = 'circle';
            Xg = gursoy_atun_layout(Ag,options);
        else
            Xg = kamada_kawai_spring_layout(Ag);
        end
        Xg = Xg - ones(size(Xg,1),1)*mean(Xg,1);
        Xg = Xg/max(sqrt(Xg(:,1).^2 + Xg(:,2).^2));
        X(idx{i},1) = group_center(i,1) + r*group_radius*Xg(:,1);
        X(idx{i},2) = group_center(i,2) + r*group_radius*Xg(:,2);
    end
end

clf
axes('Position', [0 0.025 0.95 0.95])
hold on

if num_groups > 1
    for i = 1:num_groups
        DrawCircle(cos(i*d_theta), sin(i*d_theta), group_radius, ...
            network.group_colors(i,:))
    end
    xlim([-1 1]*(1 + group_radius))
    ylim([-1 1]*(1 + group_radius))
end

[i,j] = find(A);
P = 1;
for k = 1:length(i)
    if rand < P
        line([X(i(k),1), X(j(k),1)], [X(i(k),2), X(j(k),2)], [-1 -1],...
            'color', [1 1 1]*0.8, 'userdata', A(i(k),j(k)));
    end
end

for i = 1:length(grouping2)
    plot(X(i,1), X(i,2), 'o', ...
        'markerfacecolor', network.group_colors(grouping2(i),:), ...
        'markersize', 6, 'markeredgecolor', 'black',...
        'userdata', i)
end

hold off
axis equal off


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over visualize_network.
function visualize_network_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to visualize_network (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


