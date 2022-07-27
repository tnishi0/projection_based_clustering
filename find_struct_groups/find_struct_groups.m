function find_struct_groups
% Visual Analytics Software for Discovering Structural Groups in
% Complex Networks.
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

% Get the path of this application
app_dir = fileparts(mfilename('fullpath'));

% Temporarily add these directories to the search path
% To be removed when quitting.
% addpath(app_dir, fullfile(app_dir,'matlab_bgl'), fullfile(app_dir,'somtoolbox'))
addpath(app_dir, fullfile(app_dir,'somtoolbox'))

%------------------------------------
% Internal data
%------------------------------------

h_points = [];
xp = []; yp = [];
h_rec = []; rec_x = []; rec_y = [];
h_line = []; line_x = []; line_y = [];
num_groups = 1;
cur_group = 1;
group = []; % current grouping
p = []; % number of properties
n = []; % number of nodes
node_prop_selector = [];
h_group_view = []; % handle to group_view figure
network_name = []; % name of the network
h_about = []; % handle to the "About..." window

np_functions = default_np_functions;

% Maximum number of groups is set to 15, as too many would make it
% difficult to distinguish by colors.  Colors are chosen equally
% distributed around the color circle with value and saturation equal to
% one (+ black as the first color), putting consecutive color indices to be
% almost the other side of the circle.
max_num_groups = 15;
hue = mod((0:max_num_groups-2)*(0.5+1/(max_num_groups-1)), 1);
cm = hsv2rgb([0, 0, 0; hue', ones(max_num_groups-1,2)]);


%------------------------------------
% GUI setup
%------------------------------------

main_window = figure(... % Main figure
    'name', 'Visual Analytics for Discovering Structural Groups', 'NumberTitle', 'off', ...
    'menubar', 'none', 'toolbar', 'none', ...
    'HandleVisibility', 'callback', ...
    'CloseRequestFcn', @quit_callback, ...
    'KeyPressFcn', @figure_KeyPressFcn, ...
    'position', [214   646   746   701], ...
    'Color', get(0, 'defaultuicontrolbackgroundcolor'));

% set up application data to communicate with other components
setappdata(main_window, 'A', [])
setappdata(main_window, 'data', [])
setappdata(main_window, 'data0', [])
setappdata(main_window, 'prop_names', {})
setappdata(main_window, 'proj_data', [])
setappdata(main_window, 'curr_proj', 0)

% projection plot axis
h_proj = axes( ...
    'parent', main_window, 'HandleVisibility', 'callback', ...
    'position', [0.03 0.16 0.76 0.78], ...
    'box', 'on', 'xtick', [], 'ytick', []);

%--------------------------------------------------
% Menu: File
h_menu_file = uimenu( ... 
    'parent', main_window, 'label', 'Menu', ...
    'HandleVisibility', 'callback');

uimenu(h_menu_file, ...
    'label', 'Choose a network', ...
    'HandleVisibility', 'callback', ...
    'callback', @choose_network);

h_menu_node_prop_selector = uimenu(h_menu_file, ...
    'label', 'Re-select & compute node properties', ...
    'HandleVisibility', 'callback', ...
    'enable', 'off', ...
    'callback', @node_prop_selector_callback);

h_menu_projections = uimenu(h_menu_file, ...
    'label', 'Re-compute projections', ...
    'HandleVisibility', 'callback', ...
    'enable', 'off', ...
    'callback', @projections_callback);

h_menu_group_view = uimenu(h_menu_file, ...
    'label', 'Analyze result', ...
    'HandleVisibility', 'callback', ...
    'enable', 'off', ...
    'callback', @group_view_callback);

uimenu(h_menu_file, ...
    'label', 'Quit', ...
    'Separator','on', ...
    'HandleVisibility', 'callback', ...
    'callback', @quit_callback)

uimenu(h_menu_file, ...
    'label', 'About this software', ...
    'HandleVisibility', 'callback', ...
    'callback', @about_callback);

%--------------------------------------------------
% Buttons
h_next_button = uicontrol(...
    'parent', main_window, 'style','pushbutton','string','Next',...
    'units','normalized','position',[0.82,0.9,0.16,0.08], ...
    'HandleVisibility', 'callback',...
    'enable', 'off', ...
    'callback',@next_proj);
h_back_button = uicontrol(...
    'parent', main_window, 'style','pushbutton','string','Back',...
    'units','normalized','position',[0.82,0.8,0.16,0.08], ...
    'HandleVisibility', 'callback',...
    'enable', 'off', ...
    'callback',@prev_proj);
h_new_group_button = uicontrol(...
    'parent', main_window, 'style','pushbutton','string','New Group',...
    'units','normalized','position',[0.82,0.7,0.16,0.08], ...
    'HandleVisibility', 'callback',...
    'enable', 'off', ...
    'callback',@new_group);
h_ungroup_button = uicontrol(...
    'parent', main_window, 'style','pushbutton','string','Ungroup',...
    'units','normalized','position',[0.82,0.6,0.16,0.08], ...
    'HandleVisibility', 'callback',...
    'enable', 'off', ...
    'callback',@ungroup);

h_buttons = [h_next_button, h_new_group_button, h_ungroup_button];

% Status info
h_status = uicontrol(...
    'parent', main_window, 'style','text', ...
    'HorizontalAlignment','left', ...
    'BackgroundColor', get(0, 'defaultuicontrolbackgroundcolor'),...
    'units','normalized','position',[0.03,0.0,0.76,0.15]);
setappdata(main_window, 'h_status', h_status)
update_status

% Initial selection of network data
choose_network


%------------------------------------------------------
%  Callback functions
%------------------------------------------------------

    %------------------------------------------------------
    % Menu: File
    %------------------------------------------------------
    function choose_network(src, event)
        
        cla(h_proj)
        set(h_next_button, 'enable', 'off')
        set(h_back_button, 'enable', 'off')
        set(h_new_group_button, 'enable', 'off')
        set(h_ungroup_button, 'enable', 'off')
       
        setappdata(main_window, 'A', [])
        setappdata(main_window, 'data', [])
        setappdata(main_window, 'data0', [])
        setappdata(main_window, 'prop_names', {})
        setappdata(main_window, 'proj_data', [])
        setappdata(main_window, 'curr_proj', 0)
        setappdata(main_window, 'groupings', [])
        setappdata(main_window, 'barcode_groupings', [])
        setappdata(main_window, 'barcode_div_lines', [])
        setappdata(main_window, 'combined_groupings', [])

        % Open network data file

        str = {
            'Network of Fig. 1'
            'karate network'
            'football network'
            'adjnoun network'
            'polbooks network'
            'disease network'
            'netscience network'
            'Sample benchmark networks from Fig. 3:'
            '  p_out = 0.0242'
            '  p_out = 0.0485'
            '  p_out = 0.0727'
            '  p_out = 0.0970'
            '  p_out = 0.1212'
            '  p_out = 0.1455'
            '  p_out = 0.1697'
            '  p_out = 0.1939'
            '  p_out = 0.2182'
            '  p_out = 0.2424'
            };
        [selection,ok] = listdlg(...
            'PromptString', 'Choose a network',...
            'SelectionMode', 'single',...
            'ListString', str,...
            'ListSize', [260 300],...
            'InitialValue', 1);
        if ~ok
            network_name = '(No network)';
            update_status
            return
        end
        switch selection
            case 1
                data_file = 'network_fig1.mat';
            case 2
                data_file = 'karate.mat';
            case 3
                data_file = 'football.mat';
            case 4
                data_file = 'adjnoun.mat';
            case 5
                data_file = 'polbooks.mat';
            case 6
                data_file = 'disease.mat';
            case 7
                data_file = 'netscience.mat';
            case 8
                h = errordlg('Please choose a p_out value for networks of Fig. 3.');
                waitfor(h)
                choose_network
                return
            case 9
                data_file = 'benchmark1.mat';
            case 10
                data_file = 'benchmark2.mat';
            case 11
                data_file = 'benchmark3.mat';
            case 12
                data_file = 'benchmark4.mat';
            case 13
                data_file = 'benchmark5.mat';
            case 14
                data_file = 'benchmark6.mat';
            case 15
                data_file = 'benchmark7.mat';
            case 16
                data_file = 'benchmark8.mat';
            case 17
                data_file = 'benchmark9.mat';
            case 18
                data_file = 'benchmark10.mat';
        end
        x = load(fullfile(app_dir, 'data', data_file));
        network_name = str{selection};
        if 9 <= selection && selection <=18
            network_name = sprintf('Network of Fig. 3 (%s)', network_name(3:end));
        end
        load_network(x.network)
        set(h_menu_node_prop_selector, 'enable', 'on')
        node_prop_selector_callback
        group = ones(1,n);
    end
    
    %------------------------------------------------------
    function load_network(network)
        % load data from struct network
        
        setappdata(main_window, 'A', network.A)
        set(h_menu_node_prop_selector, 'enable', 'on')
        if isfield(network, 'node_info')
            setappdata(main_window, 'node_info', network.node_info)
        end
        if isfield(network, 'np') && isfield(network, 'np0') ...
                && isfield(network, 'prop_name')
            update_data(network.np, network.np0, network.prop_name)
            if isfield(network, 'groupings')
                setappdata(main_window, 'groupings', network.groupings)
            end
            if isfield(network, 'combined_grouping')
                setappdata(main_window, 'combined_grouping', network.combined_grouping)
            end
            if isfield(network, 'gr_info')
                setappdata(main_window, 'gr_info', network.gr_info)
            end
            if isfield(network, 'proj_data')
                setappdata(main_window, 'proj_data', network.proj_data)
                setappdata(main_window, 'curr_proj', 1)
                if ~isempty(network.proj_data)
                    set(h_buttons, 'enable', 'on')
                    plot_projection
                    title(h_proj, sprintf('Projection #%d', 1))
                    restore_grouping(1, network.proj_data)
                end
            end
        end
    end

    %------------------------------------------------------
    function quit_callback(src,event)
        if ishandle(h_group_view), delete(h_group_view), end
%         rmpath(app_dir, fullfile(app_dir,'matlab_bgl'), fullfile(app_dir,'somtoolbox'))
        rmpath(app_dir, fullfile(app_dir,'somtoolbox'))
        delete(main_window)
    end

    %------------------------------------------------------
    function compute_node_prop(new_np_functions)
        
        A = getappdata(main_window, 'A');
        if isempty(A)
            errordlg('You must load network adjacency data first.')
            return
        end
        
        % Compute node properties
        np_functions = new_np_functions;
        [data, prop_names, data0] = node_prop(A, np_functions, 0); % '0' to supress printout to command window
        
        % Ignore node properties that doesn't provide useful information
        keep = true(1,size(data0,1));
        tol = 1e-3;
        for i = 1:size(data0,1)
            x = data0(i,:);
            if length(find(abs(x - mean(x)) < tol))/length(x) > 0.95
                qtext = sprintf(...
                    '"%s" does not appear to provide useful information (> 95%% are within %g of the average).  Ignore?',...
                    prop_names{i}, tol);
                button = questdlg(qtext,'Ignore this property?','Yes','No','Yes');
                switch button
                    case 'Yes'
                        keep(i) = false;
                end        
            end
            if any(isnan(data(i,:)))
                keep(i) = false;
            end
        end
        data = data(keep,:);
        data0 = data0(keep,:);
        prop_names = prop_names(keep);
        
        update_data(data, data0, prop_names);
    end

    %------------------------------------------------------
    function node_prop_selector_callback(src,event)
        
            node_prop_selector = NodePropSelector(np_functions);
            waitfor(node_prop_selector.h_fig)
            compute_np = node_prop_selector.compute_np;
            if compute_np
                compute_node_prop(node_prop_selector.np_functions(:))
            end
            delete(node_prop_selector)
            if compute_np
                projections_callback
            end
    end

    %------------------------------------------------------
    function group_view_callback(src, event)
        
        if ishandle(h_group_view)
            close(h_group_view)
        end
        
        data = getappdata(main_window, 'data');
        if isempty(data)
            errordlg('You must generate node property data first.')
            return
        end
        
        if ~getappdata(main_window, 'curr_proj')
            errordlg('You need to compute projections first.')
            return
        end
        
        % make sure to incorporate result from current projection
        update_groupings
        
        network.A = getappdata(main_window, 'A');
        network.np = getappdata(main_window, 'data');
        network.np0 = getappdata(main_window, 'data0');
        network.prop_name = getappdata(main_window, 'prop_names');
        network.groupings = getappdata(main_window, 'groupings');
        network.proj_data = getappdata(main_window, 'proj_data');
        network.node_info = getappdata(main_window, 'node_info');
        orig_units = get(main_window, 'units');
        set(main_window, 'units', 'pixels')
        pos = get(main_window, 'position');
        set(main_window, 'units', orig_units)
        x = pos(1) + pos(3)/2;
        y = pos(2) + pos(4)/2;
        h_group_view = group_view(network, x, y);
    end

    %------------------------------------------------------
    function projections_callback(src,event)
        setappdata(main_window, 'proj_data', ...
            compute_projections(getappdata(main_window, 'data')))
        setappdata(main_window, 'curr_proj', 1)
        set(h_buttons, 'enable', 'on')
        set(h_back_button, 'enable', 'off')
        plot_projection
        title(h_proj, sprintf('Projection #%d', 1))
    end

    %------------------------------------------------------
    function figure_KeyPressFcn(src,event)
        if isempty(getappdata(main_window, 'proj_data')), return, end
        switch event.Character
            case 'q'
                quit_callback(src,event)
            case 'f'
                next_proj(src,event)
            case 'b'
                prev_proj(src,event)
        end
    end

    %------------------------------------------------------
    function about_callback(src, event)
        if ishandle(h_about)
            figure(h_about)
            return
        end
        im = imread('data/about_this_software.png');
        h_about = figure('menu','none','NumberTitle','off',...
            'resize', 'off', 'position',[0 0 400 400]);
        axes('position',[0 0 1 1])
        image(im), axis image off
        uicontrol(...
            'parent', h_about, 'style','pushbutton','string','See full License',...
            'units','normalized','position',[0.35,0.05,0.3,0.08], ...
            'HandleVisibility', 'callback',...
            'enable', 'on', ...
            'callback',@open_license);
    end

    function open_license(src, event)
        open(fullfile(app_dir,'License.txt'));
    end

    %------------------------------------------------------
    % Buttons
    %------------------------------------------------------
    function next_proj(src,event)
        
        update_groupings
        curr_proj = getappdata(main_window, 'curr_proj') + 1;
        proj_data = getappdata(main_window, 'proj_data');
        if curr_proj >= length(proj_data) % last projection in the list
            set(h_next_button, 'enable', 'off')
            curr_proj = length(proj_data);
        elseif curr_proj == 2
            set(h_back_button, 'enable', 'on')
        end
        setappdata(main_window, 'curr_proj', curr_proj);
        
        xp = proj_data(curr_proj).xp;
        yp = proj_data(curr_proj).yp;
        
        for i = 1:n
            set(h_points(i),...
                'xdata', xp(i), ...
                'ydata', yp(i), ...
                'color', cm(num_groups,:))
        end
        
        set_axis_lim(xp,yp)
        title(h_proj, sprintf('Projection #%d', curr_proj))
        restore_grouping(curr_proj, proj_data)
        update_status
    end

    %------------------------------------------------------
    function prev_proj(src,event)
        
        update_groupings
        curr_proj = getappdata(main_window, 'curr_proj') - 1;
        if curr_proj < 1
            curr_proj = 1;
        end
        setappdata(main_window, 'curr_proj', curr_proj);
        proj_data = getappdata(main_window, 'proj_data');
        if curr_proj == 1 % first projection in the list
            set(h_back_button, 'enable', 'off')
        elseif curr_proj == length(proj_data) - 1
            set(h_next_button, 'enable', 'on')
        end
        
        xp = proj_data(curr_proj).xp;
        yp = proj_data(curr_proj).yp;
        
        for i = 1:n
            set(h_points(i),...
                'xdata', xp(i), ...
                'ydata', yp(i), ...
                'color', cm(num_groups,:))
        end
        
        set_axis_lim(xp,yp)
        title(h_proj, sprintf('Projection #%d', curr_proj))
        restore_grouping(curr_proj, proj_data)
        update_status
    end

    %------------------------------------------------------
    function restore_grouping(curr_proj, proj_data)
        
        groupings = getappdata(main_window, 'groupings');
        if isempty(proj_data(curr_proj).grouping)
            ungroup
        else
            group = groupings(curr_proj,:);
            num_groups = max(group);
            for i = 1:n
                set(h_points(i), 'color',cm(group(i),:))
            end
        end
    end

    %------------------------------------------------------
    function update_groupings
        
        % update the groupings
        proj_data = getappdata(main_window, 'proj_data');
        curr_proj = getappdata(main_window, 'curr_proj');
        groupings = getappdata(main_window, 'groupings');
        if curr_proj < 1 || curr_proj > length(proj_data), return, end
        groupings(curr_proj, :) = group;
        setappdata(main_window, 'groupings', groupings);
        if num_groups == 1
            proj_data(curr_proj).grouping = [];
        else
            proj_data(curr_proj).grouping = 1; % will be reset below
        end
        
        % set proj_data.grouping correctly
        cnt = 1;
        for i = 1:length(proj_data)
            if ~isempty(proj_data(i).grouping)
                proj_data(i).grouping = cnt;
                cnt = cnt + 1;
            end
        end
        
        setappdata(main_window, 'proj_data', proj_data);
    end

    %------------------------------------------------------
    function new_group(src, event)
        cur_group = num_groups + 1;
        update_status        
    end

    %------------------------------------------------------
    function choose_rectangle_mode(src,event)
        curr_proj = getappdata(main_window, 'curr_proj');
        proj_data = getappdata(main_window, 'proj_data');
        if isempty(proj_data(curr_proj).grouping)
            ungroup
        end
        set(main_window, 'WindowButtonDownFcn', @choose_rec1)
        set(h_new_group_button, 'enable', 'on')
    end

    %------------------------------------------------------
    function choose_rec1(src,event)
        if isempty(getappdata(main_window, 'proj_data')), return, end
        if strcmp(get(main_window, 'SelectionType'), 'extend')
            choose_line1(src,event)
            return
        end
        if ~strcmp(get(main_window, 'SelectionType'), 'alt')
            cp = get(h_proj,'CurrentPoint');
            xinit = cp(1,1); yinit = cp(1,2);
            xlimits = get(h_proj, 'xlim');
            ylimits = get(h_proj, 'ylim');
            if xinit < xlimits(1) || xlimits(2) < xinit ...
                    || yinit < ylimits(1) || ylimits(2) < yinit
                return
            end
            rec_x = [xinit xinit xinit xinit xinit];
            rec_y = [yinit yinit yinit yinit yinit];
            h_rec = line(rec_x,rec_y);
            set(main_window,'WindowButtonMotionFcn',@update_rec)
            set(main_window, 'WindowButtonUpFcn',@choose_rec2)
        end
    end

    %------------------------------------------------------
    function update_rec(src,event)
        if ishandle(h_rec)
            cp = get(h_proj,'CurrentPoint');
            rec_x(3) = cp(1,1); rec_x(4) = cp(1,1);
            rec_y(2) = cp(1,2); rec_y(3) = cp(1,2);
            set(h_rec,'xdata',rec_x,'ydata',rec_y); drawnow
        end
    end

    %------------------------------------------------------
    function choose_rec2(src,event)
        is_grouped = false;
        for i = 1:n
            x = get(h_points(i),'xdata');
            y = get(h_points(i),'ydata');
            xmax = max(rec_x); xmin = min(rec_x);
            ymax = max(rec_y); ymin = min(rec_y);
            if xmin < x && x < xmax && ymin < y && y < ymax
                set(h_points(i), 'color',cm(cur_group,:))
                group(i) = cur_group;
                is_grouped = true;
            end
        end
        num_groups = cur_group;
        update_status

        if ishandle(h_rec), delete(h_rec), end
        set(main_window,'WindowButtonMotionFcn','')
        set(main_window,'WindowButtonDownFcn',@choose_rec1)
        set(main_window, 'WindowButtonUpFcn', [])
        if is_grouped
            set(h_proj, 'UIContextMenu', [])
        end
    end

    %------------------------------------------------------
    function choose_line1(src,event)
        if ~strcmp(get(main_window, 'SelectionType'), 'extend')
            choose_rec1(src,event)
            return
        end
        if ~strcmp(get(main_window, 'SelectionType'), 'alt')
            cp = get(h_proj,'CurrentPoint');
            xinit = cp(1,1); yinit = cp(1,2);
            xlimits = get(h_proj, 'xlim');
            ylimits = get(h_proj, 'ylim');
            if xinit < xlimits(1) || xlimits(2) < xinit ...
                    || yinit < ylimits(1) || ylimits(2) < yinit
                return
            end
            ungroup
            line_x = [xinit xinit];
            line_y = [yinit yinit];
            h_line = line(line_x, line_y);
            set(main_window,'WindowButtonMotionFcn', @update_line)
            set(main_window, 'WindowButtonUpFcn', @choose_line2)
        end
    end

    %------------------------------------------------------
    function update_line(src,event)
        if ishandle(h_line)
            cp = get(h_proj,'CurrentPoint');
            line_x(2) = cp(1,1); 
            line_y(2) = cp(1,2);
            set(h_line,'xdata', line_x,'ydata', line_y); 
            drawnow
        end
    end

    %------------------------------------------------------
    function choose_line2(src,event)
        
        is_grouped = false;
        for i = 1:n           
            x = get(h_points(i),'xdata');
            y = get(h_points(i),'ydata');

            % Vector normal to the line of separation
            vn = [line_y(1) - line_y(2), line_x(2) - line_x(1)]; 
            
            if vn*[x - line_x(1); y - line_y(1)] > 0
                set(h_points(i), 'color',cm(cur_group,:))
                group(i) = cur_group;
                is_grouped = true;
            end
        end
        num_groups = cur_group;
        update_status

        if ishandle(h_line), delete(h_line), end
        set(main_window, 'WindowButtonMotionFcn', '')
        set(main_window, 'WindowButtonDownFcn', @choose_line1)
        set(main_window, 'WindowButtonUpFcn', [])
        if is_grouped
            set(h_proj, 'UIContextMenu', [])
        end
    end

    %------------------------------------------------------
    function ungroup(src,event)
        num_groups = 1;
        group = ones(1,n);
        
        proj_data = getappdata(main_window, 'proj_data');
        curr_proj = getappdata(main_window, 'curr_proj');
        proj_data(curr_proj).grouping = [];
        setappdata(main_window, 'proj_data', proj_data);
        
        for i = 1:n
            set(h_points(i),'color',cm(1,:))
        end
        if ishandle(h_rec), delete(h_rec), end
        new_group
    end


%------------------------------------------------------
%  Utility functions
%------------------------------------------------------

    function update_data(data, data0, prop_names)
        
        setappdata(main_window, 'data', data)
        setappdata(main_window, 'data0', data0)
        setappdata(main_window, 'prop_names', prop_names)
        [p,n] = size(data);
        set(h_menu_projections, 'enable', 'on')
        set(h_menu_group_view, 'enable', 'on')
        update_status
    end

    %------------------------------------------------------
    function set_axis_lim(xp,yp)
        r = 1.1*max(max(xp)-min(xp),max(yp)-min(yp))/2;
        xm = (max(xp)+min(xp))/2;
        ym = (max(yp)+min(yp))/2;
        set(h_proj,'xlim',[xm-r,xm+r],'ylim',[ym-r,ym+r])
    end

    %------------------------------------------------------
    function update_status
                
        status_text = get(h_status, 'string');
        
        if isempty(network_name)
            status_text{1} = 'No network loaded';
        else
            A = getappdata(main_window, 'A');
            [n,m] = size(A);
            status_text{1} ...
                = sprintf('%s (%d nodes, %d links)', network_name, n, nnz(A)/2);
            status_text{4} = 'Click & drag to create a rectangle to enclose nodes to group together.';
            status_text{5} = 'Shift-click & drag to draw a line to separate nodes into 2 groups.';
        end
        
        data = getappdata(main_window, 'data');
        [p,n] = size(data);
        if isempty(data)
            status_text{2} = 'Node properties not computed';
        else
            status_text{2} ...
                = ['Node property computed: ', ...
                    sprintf('n = %d, p = %d', n, p)];
        end
        
        curr_proj = getappdata(main_window, 'curr_proj');
        if curr_proj == 0
            status_text{3} = 'No projections computed';
        else
            status_text{3} ...
                = [sprintf('Random projections: #%d ', curr_proj), ...
                    sprintf('(%d current groups)', num_groups)];
        end
        
        set(h_status, 'string', status_text)
    end

    %------------------------------------------------------
    function plot_projection
    % Plot the projection

        curr_proj = getappdata(main_window, 'curr_proj');
        proj_data = getappdata(main_window, 'proj_data');
        xp = proj_data(curr_proj).xp;
        yp = proj_data(curr_proj).yp;
        n = length(xp);
        cla(h_proj)
        h_points = zeros(1,n);
        for i = 1:n
            h_points(i) = plot(h_proj, xp(i),yp(i),'.','color',cm(1,:));
            set(h_proj, 'box', 'on', 'xtick', [], 'ytick', [])
            hold(h_proj, 'on')
        end
        hold(h_proj, 'off')
        set_axis_lim(xp,yp)
        new_group
        choose_rectangle_mode
        update_status
    end

end
