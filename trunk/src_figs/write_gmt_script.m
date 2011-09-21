function varargout = write_gmt_script(varargin)
% Helper window to generate a GMT script that reproduces the Mirone's figure contents

% $ID:$
%	Copyright (c) 2004-2011 by J. Luis
%
% 	This program is part of Mirone and is free software; you can redistribute
% 	it and/or modify it under the terms of the GNU Lesser General Public
% 	License as published by the Free Software Foundation; either
% 	version 2.1 of the License, or any later version.
% 
% 	This program is distributed in the hope that it will be useful,
% 	but WITHOUT ANY WARRANTY; without even the implied warranty of
% 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% 	Lesser General Public License for more details.
%
%	Contact info: w3.ualg.pt/~jluis/mirone
% --------------------------------------------------------------------

hObject = figure('Vis','off');
write_gmt_script_LayoutFcn(hObject);
handles = guihandles(hObject);
move2side(hObject,'center');

sizes_cm = {'A0 (83.96 118.82 cm)'; 'A1 (59.41 83.96 cm)'; 'A2 (41.98 59.41 cm)'; 'A3 (29.70 41.98 cm)'
    'A4 (20.99 29.70 cm)'; 'A5 (14.85 20.99 cm)'; 'A6 (10.48 14.85 cm)'; 'A7 (7.41 10.48 cm)'
    'A8 (5.22 7.41 cm)'; 'A9 (3.70 5.22 cm)'; 'A10 (2.61 3.70 cm)'; 'B0 (100.05 141.39 cm)'
    'B1 (70.70 100.05 cm)'; 'B2 (50.02 70.70 cm)'; 'B3 (35.35 50.02 cm)'; 'B4 (25.01 35.35 cm)'
    'B5 (17.67 25.01 cm)'; 'archA (22.86 30.48 cm)'; 'archB (30.48 45.72 cm)'; 'archC (45.72 60.96 cm)'
    'archD (60.96 91.44 cm)'; 'archE (91.44 121.92 cm)'; 'flsa (21.59 33.02 cm)'; 'halfletter (13.97 21.59 cm)'
    'note (19.05 25.40 cm)'; 'letter (21.59 27.94 cm)'; 'legal (21.59 35.56 cm)'; '11x17 (27.94 43.18 cm)'
    'ledger (43.18 27.94 cm)'};

sizes_pt = {'A0  (2380 3368 pt)'; 'A1  (1684 2380 pt)'; 'A2  (1190 1684 pt)'; 'A3  (842 1190 pt)'
    'A4  (595 842 pt)'; 'A5  (421 595 pt)'; 'A6  (297 421 pt)'; 'A7  (210 297 pt)'; 'A8  (148 210 pt)'
    'A9  (105 148 pt)'; 'A10 (74 105 pt)'; 'B0  (2836 4008 pt)'; 'B1  (2004 2836 pt)'; 'B2  (1418 2004 pt)'
    'B3  (1002 1418 pt)'; 'B4  (709 1002 pt)'; 'B5  (501 709 pt)'; 'archA (648 864 pt)'; 'archB (864 1296 pt)'
    'archC (1296 1728 pt)'; 'archD (1728 2592 pt)'; 'archE (2592 3456 pt)'; 'flsa  (612 936 pt)'
    'halfletter (396 612 pt)'; 'note   (540 720 pt)'; 'letter (612 792 pt)'; 'legal  (612 1008 pt)'
    '11x17  (792 1224 pt)'; 'ledger (1224 792 pt)'};

sizes_in = {'A0 (33.06 46.78 cm)'; 'A1 (23.39 33.06 in)'; 'A2 (16.53 23.39 in)'; 'A3 (11.69 16.53 in)'
    'A4 (8.26 11.69 in)'; 'A5 (5.85 8.26 in)'; 'A6 (4.13 5.85 in)'; 'A7 (2.92 4.13 in)'
    'A8 (2.06 2.92 in)'; 'A9 (1.46 2.06 in)'; 'A10 (1.03 1.46 in)'; 'B0 (39.39 55.67 in)'
    'B1 (27.83 39.39 in)'; 'B2 (19.69 27.83 in)'; 'B3 (13.92 19.69 in)'; 'B4 (9.85 13.92 in)'
    'B5 (6.96 9.85 in)'; 'archA (9.0 12.0 in)'; 'archB (12.0 18.0 in)'; 'archC (18.0 24.0 in)'
    'archD (24.0 36.0 in)'; 'archE (36.0 48.0 in)'; 'flsa (8.5 13.0 in)'; 'halfletter (5.5 8.5 in)'
    'note (7.5 10.0 in)'; 'letter (8.5 11.0 in)'; 'legal (8.5 14.0 in)'; '11x17 (11.0 17.0 in)'
    'ledger (17.0 11.0 in)'};

paper_cm = [83.96 118.82; 59.41 83.96; 41.98 59.41; 29.70 41.98; 20.99 29.70; 14.85 20.99; ...
        10.48 14.85; 7.41 10.48; 5.22 7.41; 3.70 5.22; 2.61 3.70; 100.05 141.40; 70.70 100.05; ...
        50.02 70.70; 35.35 50.02; 25.01 35.35; 17.67 25.01; 22.86 30.48; 30.48 45.72; ...
        45.72 60.96; 60.96 91.44; 91.44 121.92; 21.59 33.02; 13.97 21.59; 19.05 25.40; ...
        21.59 27.94; 21.59 35.56; 27.94 43.18; 43.18 27.94];

paper_pt = [2380 3368; 1684 2380; 1190 1684; 842 1190; 595 842; 421 595; 297 421; 210 297; 148 210; ...
    105 148; 74 105; 2836 4008; 2004 2836; 1418 2004; 1002 1418; 709 1002; 501 709; 648 864; 864 1296; ...
    1296 1728; 1728 2592; 2592 3456; 612 936; 396 612; 540 720; 612 792; 612 1008; 792 1224; 1224 792];

paper_in = [33.06 46.78; 23.39 33.06; 16.53 23.39; 11.69 16.53; 8.26 11.69; 5.85 8.26; 4.13 5.85; ...
    2.92 4.13; 2.06 2.92; 1.46 2.06; 1.03 1.46; 39.39 55.67; 27.83 39.39; 19.69 27.83; 13.92 19.69; ...
    9.85 13.92; 6.96 9.85; 9.0 12.0; 12.0 18.0; 18.0 24.0; 24.0 36.0; 36.0 48.0; 8.5 13.0; 5.5 8.5; ...
    7.5 10.0; 8.5 11.0; 8.5 14.0; 11.0 17.0; 17.0 11.0];

	set(handles.popup_PaperSize,'String',sizes_cm,'Value',5)

	handles.sizes_cm = sizes_cm;    handles.paper_cm = paper_cm;
	handles.sizes_pt = sizes_pt;    handles.paper_pt = paper_pt;
	handles.sizes_in = sizes_in;    handles.paper_in = paper_in;
	handles.opt_L = [];             handles.opt_U = [];
	handles.opt_psc = [];			% To eventualy hold several of the pscoast options
	handles.scale_set = 0;			% To signal that user changed scale

	mirone_handles = varargin{1};
	if (mirone_handles.no_file)     % Stupid call with nothing loaded on the Mirone window
		delete(hObject);    return
	end
	handles.script_type = varargin{2};
	if (strcmp(handles.script_type,'bat'))
		set(hObject,'Name','Write GMT batch')
		set(handles.push_OK,'String','Write batch')
	else
		set(hObject,'Name','Write GMT script')
	end

	% Add this figure handle to the carra�as list
	plugedWin = getappdata(mirone_handles.figure1,'dependentFigs');
	plugedWin = [plugedWin hObject];
	setappdata(mirone_handles.figure1,'dependentFigs',plugedWin);

	imgXlim = get(mirone_handles.axes1,'XLim');    imgYlim = get(mirone_handles.axes1,'YLim');
	if (mirone_handles.image_type == 2 || mirone_handles.image_type == 20)     % "trivial" images
		[ny,nx,nz] = size(get(mirone_handles.hImg,'CData'));
		handles.x_min = imgXlim(1);     handles.x_max = imgXlim(2);
		handles.y_min = imgYlim(1);     handles.y_max = imgYlim(2);
	else
		head = mirone_handles.head;
		if ( diff(imgXlim) < diff(head(1:2))*0.9 )		% Figure is zoomed
			handles.x_min = imgXlim(1) + head(8)/2;		handles.x_max = imgXlim(2) - head(8)/2;
			handles.y_min = imgYlim(1) + head(9)/2;		handles.y_max = imgYlim(2) - head(9)/2;
		else
			handles.x_min = head(1);    handles.x_max = head(2);
			handles.y_min = head(3);    handles.y_max = head(4);
		end
		nx = round((head(2) - head(1)) / head(8));		% May not be exactly correct but is good enough here
		ny = round((head(4) - head(3)) / head(9));
	end    
	width  = 15;					% Default starting width in cm
	fac_15 = nx / width;
	height = round(ny) / fac_15;
	if (height > 27)				% That is, if height + Y0 nearly outside the A4 page
		while (height > 27)			% Make it approximately fit the page height
			height = round(height * 0.1);
			width  = round(width * 0.1);
		end
	end

	handles.opt_R = sprintf('-R%.12g/%.12g/%.12g/%.12g', handles.x_min, handles.x_max, handles.y_min, handles.y_max);

	handles.mirone_handles = mirone_handles;
	handles.width_or = width;  handles.height_or = height;
	handles.scale = width;
	handles.which_unit = 'cm';
	handles.d_path = mirone_handles.path_data;

	% Compute image aspect ratio and set axes 'PlotBoxAspectRatio' to it
	handles.paper = [paper_cm(5,1) paper_cm(5,2)];         % Set to A4 (x,y)
	handles.paper_aspect = handles.paper(2)/handles.paper(1);
	% set(handles.axes1,'XLim',[0 handles.paper(1)],'YLim',[0 handles.paper(2)], ...
	%         'PlotBoxAspectRatio',[1 handles.paper_aspect 1]);
	set(handles.axes1,'XLim',[0 handles.paper(1)],'YLim',[0 handles.paper(2)], 'DataAspectRatio',[1 1 1]);
	X0 = 2.5;				Y0 = 2.5;		% This is the GMT default's plot origin in cm
	rect_x = [X0 X0 X0+width X0+width X0];
	rect_y = [Y0 Y0+height Y0+height Y0 Y0];
	handles.rect_x = rect_x;   handles.rect_y = rect_y;
	handles.scale = sprintf('%.2g', width);
	set(handles.edit_mapWidth,'String',sprintf('%.2f', width))		% Fill the width editbox
	set(handles.edit_mapHeight,'String',sprintf('%.2f',height))		% Fill the height editbox

	% ---------- Draw the grid->image rectangle
	h = patch('XData',rect_x,'YData',rect_y,'FaceColor','w','EdgeColor','k','LineWidth',.5,'Tag','PlotRect');

	ui_edit_polygon(h)					% Set edition functions

	handles.hand_rect = h;				% Save the rectangle hand
	handles.hand_frame_proj = [];

	coord_system_script = [];
	directory_list = [];
	load([handles.d_path 'mirone_pref.mat']);
	% Check that the coord_system structure has no errors. If it has, load the default value.
	% The result is used to update the handles structure.
	[handles,handles.coord_system_script] = check_coord_system(handles,coord_system_script,'_script');

	handles.all_ellipsoides = DefineEllipsoide;		% This is already in mirone_prefs

	%----------- Recall previous settings stored in mirone_pref -------------------
	handles.h_txt_info = findobj(hObject,'Tag','text_ProjDescription');
	handles.txt_info_pos = get(handles.h_txt_info,'Position');
	if (~mirone_handles.geog && iscell(handles.proj_info_txt_script))     % Need to do this because grid is not geog
		if (length(handles.proj_info_txt_script) == 5),     handles.proj_info_txt_script(3) = [];   end
		k = strfind(handles.proj_info_txt_script{1},'->');
		handles.proj_info_txt_script{1} = handles.proj_info_txt_script{1}(1:k+1);
		k = strfind(handles.proj_info_txt_script{2},'->');
		handles.proj_info_txt_script{2} = [handles.proj_info_txt_script{2}(1:k+2) '   Linear'];
		% Also remove the Ellipsoid info
		k = strfind(handles.proj_info_txt_script{end-1},'->');
		handles.proj_info_txt_script{end-1} = [handles.proj_info_txt_script{end-1}(1:k+2) '   NA'];
		% Change the -J... to -JX...
		k = strfind(handles.proj_info_txt_script{end},'-J');
		handles.proj_info_txt_script{end} = [handles.proj_info_txt_script{end}(1:k+2) 'X' width handles.which_unit(1)];
		handles.coord_system_script.projection = ['-JX' width handles.which_unit(1)];
	end
	set(handles.h_txt_info,'String',handles.proj_info_txt_script,'Position',handles.txt_info_pos)
	handles.all_datums = datums;    % datums is a function in utils

	% ---------- Split the scale from the projection string
	tmp = handles.coord_system_script.projection;
	if (~isempty(tmp))
		if (numel(tmp) == 4 && strcmp(tmp(3),'m'))		% Simple Mercator has the form "-Jm1"
			handles.opt_J_no_scale = [tmp(1:2) upper(tmp(3))];
		elseif (numel(tmp) == 3 && strcmpi(tmp(3),'X'))	% Linear proj has the form "-JX"
			handles.opt_J_no_scale = [tmp(1:2) upper(tmp(3))]; % Save this
		else											% All other should terminate as "-J.../1"
			tmp = tmp(1:end-2);
			handles.opt_J_no_scale = [tmp(1:2) upper(tmp(3)) tmp(4:end)];           % Save this
		end
	else
		handles.opt_J_no_scale = '-JX10';				% Use this default
	end
	%opt_J = [tmp(1:2) upper(tmp(3)) tmp(4:end) '/' handles.scale handles.which_unit(1)];
	handles.curr_datum = handles.all_datums{handles.coord_system_script.datum_val,2};   % Save this

	% ----------- Use the directory list from mirone_pref
	j = false(1,numel(directory_list));					% vector for eventual cleaning non-existing dirs

	if iscell(directory_list)							% When exists a dir list in mirone_pref
		for i = 1:length(directory_list)
			if ~exist(directory_list{i},'dir'),   j(i) = 1;   end
		end
		directory_list(j) = [];							% clean eventual non-existing directories
		if ~isempty(directory_list)						% If there is one left
			set(handles.popup_directory_list,'String',directory_list)
			handles.last_directories = directory_list;
		else
			set(handles.popup_directory_list,'String',cd)
			handles.last_directories = cellstr(cd);
		end
	else												% mirone_pref had no dir list
		handles.last_directories = cellstr(cd);
		set(handles.popup_directory_list,'String',handles.last_directories)
	end

	% --------- Set prefix name based on month and day numbers
	prefix = clock;
	prefix = ['mir' sprintf('%d',prefix(3)) '-' sprintf('%d',prefix(2))];
	set(handles.edit_prefix,'String',prefix)

	if (~mirone_handles.geog)   % Non geogs don't use scale bars
		set(handles.toggle_Option_L,'Visible','off')
		set(findobj(hObject,'Style','text','Tag','text_MapScale'), 'Visible','off');
	end

	% ---------- See if we have pscoast stuff
	ALLlineHand = findobj(get(mirone_handles.axes1,'Child'),'Type','line');
	handles.psc_res = [];   handles.psc_opt_W = [];     handles.psc_type_p = [];    handles.psc_type_r  = [];
	if (~isempty(findobj(ALLlineHand,'Tag','CoastLineNetCDF')) || ~isempty(findobj(ALLlineHand,'Tag','Rivers')) ...
			|| ~isempty(findobj(ALLlineHand,'Tag','PoliticalBoundaries')) )
		[handles.ALLlineHand, handles.psc_res, handles.psc_opt_W, handles.psc_type_p, handles.psc_type_r] = ...
			find_psc_stuff(ALLlineHand);
	else
		set(handles.push_coastLines,'Visible', 'off')
		handles.ALLlineHand = ALLlineHand;
	end
	clear ALLlineHand;

	%------------ Give a Pro look (3D) to the frame boxes  -------------------------------
	new_frame3D(hObject, NaN)
	%------------- END Pro look (3D) -----------------------------------------------------

	% ------------ Apply inherited projection
	guidata(hObject, handles);
	push_uppdate_CB(handles.push_uppdate, handles)
	handles = guidata(hObject);     % Recover in "this handles" the changes donne in push_uppdate

	guidata(hObject, handles);
	set(hObject,'Visible','on');
	if (nargout),   varargout{1} = hObject;     end

% -----------------------------------------------------------------------------------
function popup_PaperSize_CB(hObject, handles)
	val = get(hObject,'Value');
	switch handles.which_unit
		case 'cm'
			lims = handles.paper_cm(val,1:2);
		case 'in'
			lims = handles.paper_in(val,1:2);
		case 'pt'
			lims = handles.paper_pt(val,1:2);
	end
	if (get(handles.radio_P,'Value'))
		set(handles.axes1,'XLim',[0 lims(1)],'YLim',[0 lims(2)]);
	else
		set(handles.axes1,'XLim',[0 lims(2)],'YLim',[0 lims(1)]);
	end

% -----------------------------------------------------------------------------------
function radio_P_CB(hObject, handles)
	if (~get(hObject,'Val')),	set(hObject,'Val',1),	return,		end
	img_size_x = get(handles.axes1,'YLim');     % Just swap x & y
	img_size_y = get(handles.axes1,'XLim');
	set(handles.axes1,'XLim',img_size_x,'YLim',img_size_y);
	set(handles.radio_L,'Value',0)

% -----------------------------------------------------------------------------------
function radio_L_CB(hObject, handles)
	if (~get(hObject,'Val')),	set(hObject,'Val',1),	return,		end
	img_size_x = get(handles.axes1,'YLim');     % Just swap x & y
	img_size_y = get(handles.axes1,'XLim');
	set(handles.axes1,'XLim',img_size_x,'YLim',img_size_y);
	set(handles.radio_P,'Value',0)

% -----------------------------------------------------------------------------------
function radio_cm_CB(hObject, handles)
	if (~get(hObject,'Val')),	set(hObject,'Val',1),	return,		end
	val = get(handles.popup_PaperSize,'Value');
	set(handles.popup_PaperSize,'String',handles.sizes_cm,'Value',val)
	if (get(handles.radio_P,'Value'))
		set(handles.axes1,'XLim',[0 handles.paper_cm(val,1)],'YLim',[0 handles.paper_cm(val,2)])
	else
		set(handles.axes1,'XLim',[0 handles.paper_cm(val,2)],'YLim',[0 handles.paper_cm(val,1)])
	end    
	conv_units(handles,'cm')
	set(handles.radio_in,'Value',0)
	set(handles.radio_pt,'Value',0)
	handles.which_unit = 'cm';      guidata(hObject,handles);

% -----------------------------------------------------------------------------------
function radio_in_CB(hObject, handles)
	if (~get(hObject,'Val')),	set(hObject,'Val',1),	return,		end
	val = get(handles.popup_PaperSize,'Value');
	set(handles.popup_PaperSize,'String',handles.sizes_in,'Value',val)
	if (get(handles.radio_P,'Value'))
		set(handles.axes1,'XLim',[0 handles.paper_in(val,1)],'YLim',[0 handles.paper_in(val,2)])
	else
		set(handles.axes1,'XLim',[0 handles.paper_in(val,2)],'YLim',[0 handles.paper_in(val,1)])
	end
	conv_units(handles,'in')
	set(handles.radio_cm,'Value',0)
	set(handles.radio_pt,'Value',0)
	handles.which_unit = 'in';      guidata(hObject,handles);

% -----------------------------------------------------------------------------------
function radio_pt_CB(hObject, handles)
	if (~get(hObject,'Val')),	set(hObject,'Val',1),	return,		end
	val = get(handles.popup_PaperSize,'Value');
	set(handles.popup_PaperSize,'String',handles.sizes_pt,'Value',val)
	if (get(handles.radio_P,'Value'))
		set(handles.axes1,'XLim',[0 handles.paper_pt(val,1)],'YLim',[0 handles.paper_pt(val,2)])
	else
		set(handles.axes1,'XLim',[0 handles.paper_pt(val,2)],'YLim',[0 handles.paper_pt(val,1)])
	end
	conv_units(handles,'pt')
	set(handles.radio_cm,'Value',0)
	set(handles.radio_in,'Value',0)
	handles.which_unit = 'pt';      guidata(hObject,handles);

% -----------------------------------------------------------------------------------
function conv_units(handles,dest)
xx = get(handles.hand_rect,'XData');        yy = get(handles.hand_rect,'YData');
xf = get(handles.hand_frame_proj,'XData');  yf = get(handles.hand_frame_proj,'YData');
if (strcmp(handles.which_unit,'cm') && strcmp(dest,'in'))
    xx = xx / 2.54;     yy = yy / 2.54;
    xf = xf / 2.54;     yf = yf / 2.54;
    set(handles.edit_mapWidth,'String',sprintf( '%.2f',str2double(get(handles.edit_mapWidth,'String'))/2.54 ))
    set(handles.edit_mapHeight,'String',sprintf( '%.2f',str2double(get(handles.edit_mapHeight,'String'))/2.54 ))
    set(handles.edit_X0,'String',sprintf( '%.2f',str2double(get(handles.edit_X0,'String'))/2.54 ))
    set(handles.edit_Y0,'String',sprintf( '%.2f',str2double(get(handles.edit_Y0,'String'))/2.54 ))
elseif (strcmp(handles.which_unit,'cm') && strcmp(dest,'pt'))
    xx = xx * 72/2.54;  yy = yy * 72/2.54;
    xf = xf * 72/2.54;  yf = yf * 72/2.54;
    set(handles.edit_mapWidth,'String',sprintf( '%.2f',str2double(get(handles.edit_mapWidth,'String'))* 72/2.54 ))
    set(handles.edit_mapHeight,'String',sprintf( '%.2f',str2double(get(handles.edit_mapHeight,'String'))* 72/2.54 ))
    set(handles.edit_X0,'String',sprintf( '%.2f',str2double(get(handles.edit_X0,'String'))* 72/2.54 ))
    set(handles.edit_Y0,'String',sprintf( '%.2f',str2double(get(handles.edit_Y0,'String'))* 72/2.54 ))
elseif (strcmp(handles.which_unit,'in') && strcmp(dest,'cm'))
    xx = xx * 2.54;     yy = yy * 2.54;
    xf = xf * 2.54;     yf = yf * 2.54;
    set(handles.edit_mapWidth,'String',sprintf( '%.2f',str2double(get(handles.edit_mapWidth,'String'))*2.54 ))
    set(handles.edit_mapHeight,'String',sprintf( '%.2f',str2double(get(handles.edit_mapHeight,'String'))*2.54 ))
    set(handles.edit_X0,'String',sprintf( '%.2f',str2double(get(handles.edit_X0,'String'))*2.54 ))
    set(handles.edit_Y0,'String',sprintf( '%.2f',str2double(get(handles.edit_Y0,'String'))*2.54 ))
elseif (strcmp(handles.which_unit,'in') && strcmp(dest,'pt'))
    xx = xx * 72;       yy = yy * 72;
    xf = xf * 72;       yf = yf * 72;
    set(handles.edit_mapWidth,'String',sprintf( '%.2f',str2double(get(handles.edit_mapWidth,'String'))*72 ))
    set(handles.edit_mapHeight,'String',sprintf( '%.2f',str2double(get(handles.edit_mapHeight,'String'))*72 ))
    set(handles.edit_X0,'String',sprintf( '%.2f',str2double(get(handles.edit_X0,'String'))*72 ))
    set(handles.edit_Y0,'String',sprintf( '%.2f',str2double(get(handles.edit_Y0,'String'))*72 ))
elseif (strcmp(handles.which_unit,'pt') && strcmp(dest,'cm'))
    xx = xx * 2.54/72;  yy = yy * 2.54/72;
    xf = xf * 2.54/72;  yf = yf * 2.54/72;
    set(handles.edit_mapWidth,'String',sprintf( '%.2f',str2double(get(handles.edit_mapWidth,'String'))*2.54/72 ))
    set(handles.edit_mapHeight,'String',sprintf( '%.2f',str2double(get(handles.edit_mapHeight,'String'))*2.54/72 ))
    set(handles.edit_X0,'String',sprintf( '%.2f',str2double(get(handles.edit_X0,'String'))*2.54/72 ))
    set(handles.edit_Y0,'String',sprintf( '%.2f',str2double(get(handles.edit_Y0,'String'))*2.54/72 ))
elseif (strcmp(handles.which_unit,'pt') && strcmp(dest,'in'))
    xx = xx / 72;       yy = yy / 72;
    xf = xf / 72;       yf = yf / 72;
    set(handles.edit_mapWidth,'String',sprintf( '%.2f',str2double(get(handles.edit_mapWidth,'String'))/72 ))
    set(handles.edit_mapHeight,'String',sprintf( '%.2f',str2double(get(handles.edit_mapHeight,'String'))/72 ))
    set(handles.edit_X0,'String',sprintf( '%.2f',str2double(get(handles.edit_X0,'String'))/72 ))
    set(handles.edit_Y0,'String',sprintf( '%.2f',str2double(get(handles.edit_Y0,'String'))/72 ))
end
set(handles.hand_rect,'XData',xx);      set(handles.hand_rect,'YData',yy);
if (~isempty(handles.hand_frame_proj))
    set(handles.hand_frame_proj,'XData',xf);      set(handles.hand_frame_proj,'YData',yf);
end

% Also uppdate the projection info text
str = get(handles.h_txt_info,'String');
try
	k = strfind(str{end},'/');
	if (~isempty(k))
        new_w = get(handles.edit_mapWidth,'String');
        str{end} = [str{end}(1:k(end)) new_w handles.which_unit(1)];
        set(handles.h_txt_info,'String',str)
	end
end

% -----------------------------------------------------------------------------------
function radio_setWidth_CB(hObject, handles)
	if (~get(hObject,'Val')),	set(hObject,'Val',1),	return,		end
	set(handles.radio_setHeight,'Value',0)

% -----------------------------------------------------------------------------------
function radio_setHeight_CB(hObject, handles)
	if (~get(hObject,'Val')),	set(hObject,'Val',1),	return,		end
	set(handles.radio_setWidth,'Value',0)

% -----------------------------------------------------------------------------------
function radio_180_180_CB(hObject, handles)
	if (~get(hObject,'Val')),	set(hObject,'Val',1),	return,		end
	set(handles.radio_0_360,'Value',0)

% -----------------------------------------------------------------------------------
function radio_0_360_CB(hObject, handles)
	if (~get(hObject,'Val')),	set(hObject,'Val',1),	return,		end
	set(handles.radio_180_180,'Value',0)

% -----------------------------------------------------------------------------------
function push_uppdate_CB(hObject, handles)
xx = get(handles.hand_rect,'XData');
yy = get(handles.hand_rect,'YData');
set(handles.edit_X0,'String',num2str(xx(1),'%.1f'));
set(handles.edit_Y0,'String',num2str(yy(1),'%.1f'));

if (strcmp(handles.opt_J_no_scale(1:3),'-JX'))      % Linear proj has a different treatment
	scale_x = (xx(3) - xx(2)) / handles.width_or;
	scale_y = (yy(2) - yy(1)) / handles.height_or;
	new_y = handles.height_or * scale_x;
	new_x = handles.width_or * scale_y;
	if (get(handles.radio_setWidth,'Value'))
        yy(2) = new_y + yy(1);      yy(3) = new_y + yy(1);
	elseif (get(handles.radio_setHeight,'Value'))
        xx(3) = new_x + xx(2);      xx(4) = new_x + xx(1);
	else
        yy(2) = new_y + yy(1);      yy(3) = new_y + yy(1);  % It will become "True" scale
	end
	set(handles.hand_rect, 'XData', xx, 'YData', yy);
	set(handles.edit_mapWidth,'String',num2str((xx(3) - xx(2)),'%.2f'));    % Uppdate map width
	set(handles.edit_mapHeight,'String',num2str((yy(2) - yy(1)),'%.2f'));   % Uppdate map height
    set(handles.edit_scale,'String','1:1')
    % Also update the projection info text
    str = get(handles.h_txt_info,'String');
    try
        new_w = get(handles.edit_mapWidth,'String');
        str{end} = ['J<options> ->  -JX' new_w handles.which_unit(1)];
        set(handles.h_txt_info,'String',str)
    end
    return      % We are donne
end

new_w = num2str((xx(3) - xx(2)),'%.2f');
set(handles.edit_mapWidth,'String',new_w);
opt_J = [handles.opt_J_no_scale '/' new_w handles.which_unit(1)];
in = [handles.x_min handles.y_min; handles.x_min handles.y_max; handles.x_max handles.y_max; handles.x_max handles.y_min];
try
	opt_R = sprintf('-R%.12g/%.12g/%.12g/%.12g', handles.x_min, handles.x_max, handles.y_min, handles.y_max);
    out = mapproject_m(in,opt_R,opt_J,['-D' handles.which_unit(1)]);
catch
    return
end

% scale_prj = abs(out(2,2) - out(1,2)) / abs(out(4,1) - out(1,1));    % = dy / dx     NA TA SEMPRE CERTO
% scale_x = (xx(3) - xx(2)) / handles.width_or;
% scale_y = (yy(2) - yy(1)) / handles.height_or;
% new_y = handles.height_or * scale_x * scale_prj;
% new_x = handles.width_or * scale_y / scale_prj;

new_x = max(out(:,1)) - min(out(:,1));
new_y = max(out(:,2)) - min(out(:,2));

if (get(handles.radio_setWidth,'Value'))
    yy(2) = new_y + yy(1);      yy(3) = new_y + yy(1);
elseif (get(handles.radio_setHeight,'Value'))
    xx(3) = new_x + xx(2);      xx(4) = new_x + xx(1);
else
    yy(2) = new_y + yy(1);      yy(3) = new_y + yy(1);  % It will become "True" scale
end
set(handles.hand_rect, 'XData', xx, 'YData', yy);
set(handles.edit_mapWidth,'String',num2str((xx(3) - xx(2)),'%.2f'));    % Uppdate map width
set(handles.edit_mapHeight,'String',num2str((yy(2) - yy(1)),'%.2f'));   % Uppdate map height
handles.scale = num2str((xx(3) - xx(2)),'%.2f');

% --- Compute a projected mini frame
n = 21;
xf = linspace(handles.x_min,handles.x_max,n)';
yf = linspace(handles.y_min,handles.y_max,n)';
in = [repmat(xf(1),n,1) yf; xf(2:end) repmat(yf(end),n-1,1); repmat(xf(end),n-1,1) yf(end-1:-1:1); ...
        xf(end:-1:1) repmat(yf(1),n,1)];
%out_f = mapproject_m(in,opt_R,'-C','-F',[handles.opt_J_no_scale '/' handles.scale handles.which_unit(1)]);
out_f = mapproject_m(in,opt_R,opt_J,['-D' handles.which_unit(1)]);
new_x = xx(1) + out_f(:,1);
new_y = yy(1) + out_f(:,2);

% Draw it if it's not a rectangle
if ~(out_f(1,1) == out_f(n,1) && out_f(n,2) == out_f(2*n-1,2))
    if (isempty(handles.hand_frame_proj))      % First time. Creat it.
        handles.hand_frame_proj = line('XData',new_x,'YData',new_y, 'Color','r','LineWidth',.5,'Tag','PlotFrameProj');
        uistack(handles.hand_frame_proj, 'down')
    else
        set(handles.hand_frame_proj, 'XData', new_x, 'YData', new_y);
    end
else    % It is a rectangle
    if (~isempty(handles.hand_frame_proj))  % If we have a previous red frame, delete it
        delete(handles.hand_frame_proj);  handles.hand_frame_proj = [];
    end
end

% ----------- Compute scale 1:xxxx
if (~handles.scale_set)     % If user changed scale, don't compute it here
	xm = (handles.x_min + handles.x_max) / 2;   ym = (handles.y_min + handles.y_max) / 2;
	opt_R = sprintf('-R%f/%f/%f/%f', xm-2, xm+2, ym-2, ym+2);
	in = [handles.x_min handles.y_min; handles.x_min handles.y_max; handles.x_max handles.y_max; handles.x_max handles.y_min];
	opt_J = [handles.opt_J_no_scale '/1'];
	out = mapproject_m(in,opt_R,'-C','-F',opt_J);
	dx_prj = out(4,1) - out(1,1);   % It's in projected meters
	dy_prj = out(2,2) - out(1,2);   % It's in projected meters
	dx_rect = xx(4) - xx(1);        % Is in "cm", "in" or "pt". So convert to "cm"
	dy_rect = yy(2) - yy(1);        % Is in "cm", "in" or "pt". So convert to "cm"
	if (strcmp(handles.which_unit,'in')),     dx_rect = dx_rect * 2.54;     dy_rect = dy_rect * 2.54;     end
	if (strcmp(handles.which_unit,'pt')),     dx_rect = dx_rect * 2.54/72;  dy_rect = dy_rect * 2.54/72;  end
	scale = max(dx_rect/dx_prj/100, dy_rect/dy_prj/100);
	[n,d] = rat(scale,1e-9);
	if (n > 1),    d = d / n;      end
	set(handles.edit_scale,'String',['1:' num2str(d)])
	handles.scale_set = 0;
end

% ------------ Also uppdate the projection info text
str = get(handles.h_txt_info,'String');
try
    new_w = get(handles.edit_mapWidth,'String');
	k = strfind(str{end},'/');
	if (~isempty(k))
        str{end} = [str{end}(1:k(end)) new_w handles.which_unit(1)];
    else        % We have a -J without any '/'. Linear projection
        k = strfind(str{end},'-J');
        str{end} = [str{end}(1:k+2) new_w handles.which_unit(1)];
	end
    set(handles.h_txt_info,'String',str)
end
%zoom on
guidata(hObject,handles)

% -----------------------------------------------------------------------------------
function edit_X0_CB(hObject, handles)
% Set new x origin
	str = get(hObject,'String');        x0 = str2double(str);
	xx = get(handles.hand_rect,'XData');
	if (isnan(x0)),     set(hObject,'String',str);      return;     end
	set(handles.hand_rect,'XData',xx - xx(1) + x0)
	if (~isempty(handles.hand_frame_proj))
		set(handles.hand_frame_proj,'XData',get(handles.hand_frame_proj,'XData') - xx(1) + x0)
	end

% -----------------------------------------------------------------------------------
function edit_Y0_CB(hObject, handles)
% Set new y origin
	str = get(hObject,'String');        y0 = str2double(str);
	yy = get(handles.hand_rect,'YData');
	if (isnan(y0)),     set(hObject,'String',str);      return;     end
	set(handles.hand_rect,'YData',yy - yy(1) + y0)
	if (~isempty(handles.hand_frame_proj))
		set(handles.hand_frame_proj,'YData',get(handles.hand_frame_proj,'YData') - yy(1) + y0)
	end

% -----------------------------------------------------------------------------------
function edit_mapWidth_CB(hObject, handles)
% Set new map width
	str = get(hObject,'String');        w = str2double(str);
	xx = get(handles.hand_rect,'XData');
	if (isnan(w)),     set(hObject,'String',str);      return;     end
	xx(3) = xx(2) + w;      xx(4) = xx(1) + w;
	set(handles.hand_rect,'XData',xx)
	push_uppdate_CB(handles.push_uppdate, handles)

% -----------------------------------------------------------------------------------
function edit_mapHeight_CB(hObject, handles)
% Set new map height
	str = get(hObject,'String');		h = str2double(str);
	yy = get(handles.hand_rect,'YData');
	if (isnan(h)),			set(hObject,'String',str);		return,		end
	yy(2) = yy(1) + h;		yy(3) = yy(4) + h;
	set(handles.hand_rect,'YData',yy)
	push_uppdate_CB(handles.push_uppdate, handles)

% -----------------------------------------------------------------------------------------
function popup_directory_list_CB(hObject, handles)
	val = get(hObject,'Value');		str = get(hObject, 'String');
	% Put the selected field on top of the String list.
	tmp = str(val);			str(val) = [];
	new_str = [tmp; str];	set(hObject,'String',new_str,'Value',1); 

% -----------------------------------------------------------------------------------------
function push_change_dir_CB(hObject, handles)
	contents = get(handles.popup_directory_list,'String');
	if (iscell(contents))
		pato = contents{1};         % Start at default's directory
	else
		pato = contents;            % Start at default's directory
	end
	if (strcmp(computer, 'PCWIN'))
		work_dir = uigetfolder_win32('Select scripts folder',pato);
	else			% This guy doesn't let to be compiled
		work_dir = uigetdir(pato, 'Select scripts folder');
	end
	if ~isempty(work_dir)
		handles.last_directories = [cellstr(work_dir); handles.last_directories];
		set(handles.popup_directory_list,'String',handles.last_directories)
		guidata(hObject, handles);
	end

% -----------------------------------------------------------------------------------
function edit_scale_CB(hObject, handles)
	str = get(hObject,'String');
	xx = get(handles.hand_rect,'XData');		yy = get(handles.hand_rect,'YData');
	opt_J = [handles.opt_J_no_scale '/' str];	opt_J(3) = lower(opt_J(3));
	in = [handles.x_min handles.y_min; handles.x_min handles.y_max; handles.x_max handles.y_max; handles.x_max handles.y_min];
	try
		opt_R = sprintf('-R%.6f/%.6f/%.6f/%.6f', handles.x_min, handles.x_max, handles.y_min, handles.y_max);
		out = mapproject_m(in,opt_R,opt_J,['-D' handles.which_unit(1)]);
	catch
		return
	end
	xmax = max(out(:,1));		ymax = max(out(:,2));
	xx(3) = xmax+xx(1);			xx(4) = xmax+xx(1);
	yy(2) = ymax+yy(1);			yy(3) = ymax+yy(1);
	set(handles.hand_rect,'XData',xx,'YData',yy)
	handles.scale_set = 1;
	guidata(hObject, handles);
	push_uppdate_CB(handles.push_uppdate, handles)

% -----------------------------------------------------------------------------------
function push_mapProjections_CB(hObject, handles)
	if (~handles.mirone_handles.geog)
		msg = ['I will tell you a secret. A map projection is an operation where GEOGRAPHIC ' ...
				'coordinates (representing a nearly spherical surface) are transformed into ' ...
				'planar (flat) coordinates. You got the message?'];
		warndlg(msg,'Warning');     return
	end
	fname = [handles.d_path 'mirone_pref.mat'];
	coord_system_script = coordinate_system(handles.coord_system_script,handles.all_datums,[]);
	if (isempty(coord_system_script)),   return;     end
	handles.coord_system_script = coord_system_script;

	% Split the scale from the projection string
	tmp = coord_system_script.projection;
	if (isempty(tmp)),		return,		end
	if (length(tmp) == 4 && strcmp(tmp(3),'m'))     % Simple Mercator cames in the form "-Jm1"
		tmp = tmp(1:end-1);
	elseif (numel(tmp) == 3 && strcmp(tmp(3),'x')) % Linear proj cames in the form "-Jx"
	else                                            % All other should terminate as "-J.../1"
		tmp = tmp(1:end-2);
	end
	xx = get(handles.hand_rect,'XData');
	handles.scale = num2str( (xx(3) - xx(2)),'%.2g');
	if (length(tmp) > 3)
		opt_J = [tmp(1:2) upper(tmp(3)) tmp(4:end) '/' handles.scale handles.which_unit(1)];
		handles.opt_J_no_scale = [tmp(1:2) upper(tmp(3)) tmp(4:end)];           % Save this
	else        % Linear projections
		opt_J = [tmp(1:2) upper(tmp(3)) handles.scale handles.which_unit(1)];
		handles.opt_J_no_scale = [tmp(1:2) upper(tmp(3))];                      % Save this
	end
	set(handles.edit_mapWidth,'String',handles.scale)
	handles.curr_datum = handles.all_datums{coord_system_script.datum_val,2};   % Save this

	string = {['System   -> ' coord_system_script.SysName];...
			['Projection -> ' coord_system_script.ProjName];...
			['Ellipsoid  ->  ' handles.all_datums{coord_system_script.datum_val,2}];...
			['J<options> ->  ' opt_J]};
	[outstring,newpos] = textwrap(handles.h_txt_info,string);
	pos = handles.txt_info_pos;
	pos(4) = newpos(4);
	set(handles.h_txt_info,'String',outstring,'Position',[pos(1),pos(2),pos(3),pos(4)])
	coord_system_script.proj_info_txt = outstring;
	coord_system_script.proj_info_pos = pos;

	save(fname,'coord_system_script','-append');      % Update mirone_pref
	guidata(hObject,handles)
	push_uppdate_CB(handles.push_uppdate, handles)

% ----------------------------------------------------------------------------------------
function toggle_Option_L_CB(hObject, handles)
if (get(hObject,'Value'))
    xx = draw_scale;
    if (~isempty(xx))
        set(handles.check_removeOptionL,'Visible','on','Value',0)
        handles.opt_L = [' ' xx];
    else
        set(hObject,'Value',0)
    end
else
    handles.opt_L = [];
    set(handles.check_removeOptionL,'Visible','off')
end
guidata(hObject, handles);

% ----------------------------------------------------------------------------------------
function toggle_Option_U_CB(hObject, handles)
if (get(hObject,'Value'))
    xx = time_stamp;
    if (~isempty(xx))
        set(handles.check_removeOptionU,'Visible','on','Value',0)
        handles.opt_U = [' ' xx];
    else
        set(hObject,'Value',0)
    end
else
    handles.opt_U = [];
    set(handles.check_removeOptionU,'Visible','off')
end
guidata(hObject, handles);

% ----------------------------------------------------------------------------------------
function check_removeOptionL_CB(hObject, handles)
if (get(hObject,'Value'))
    set(handles.toggle_Option_L,'Value',0)    % Reset the associated togglebutton to off
    set(hObject,'Visible','off')                    % Hide this button
    handles.opt_L = [];
    guidata(hObject, handles);
end

% -----------------------------------------------------------------------------------------
function check_removeOptionU_CB(hObject, handles)
if (get(hObject,'Value'))
    set(handles.toggle_Option_U,'Value',0)    % Reset the associated togglebutton to off
    set(hObject,'Visible','off')                    % Hide this button
    handles.opt_U = [];
    guidata(hObject, handles);
end

% -----------------------------------------------------------------------------------
function push_coastLines_CB(hObject, handles)
handles.opt_psc = pscoast_options_Mir(handles.mirone_handles, handles.psc_res, handles.psc_opt_W, ...
    handles.psc_type_p, handles.psc_type_r);
    % Testar se ha -N e -I repetidas
guidata(hObject, handles);

%-------------------------------------------------------------------------------------
function push_OK_CB(hObject, handles)
% Here we transmit the: -J<...>, paper name, files prefix, X0, Y0 and destination directory
	if (~strcmp(handles.opt_J_no_scale(1:3),'-JX'))
		opt_J = [handles.opt_J_no_scale '/' handles.scale handles.which_unit(1)];
	else        % Linear projection
		opt_J = [handles.opt_J_no_scale handles.scale handles.which_unit(1)];
	end
	val = get(handles.popup_PaperSize,'Value');
	list = get(handles.popup_PaperSize,'String');
	str = list{val};        k = strfind(str,' ');
	paper = str(1:k(1)-1);
	d_dir = get(handles.popup_directory_list,'String');
	if (iscell(d_dir)),     d_dir = d_dir{1};    end
	prefix = get(handles.edit_prefix,'String');

	X0 = get(handles.edit_X0,'String');     Y0 = get(handles.edit_Y0,'String');
	X0 = ['-X' X0 handles.which_unit(1)];   Y0 = ['-Y' Y0 handles.which_unit(1)];

	if (get(handles.radio_180_180,'Value'))   % [-180;180] range
		opt_deg = '--PLOT_DEGREE_FORMAT=ddd:mm:ss';
	else                                            % [0;360] range
		opt_deg = '--PLOT_DEGREE_FORMAT=+ddd:mm:ss';
	end

    % Before calling the write script routine we have to find if we have any pscoast stuff
    if (isempty(handles.opt_psc))       % Means that the pscoast_options was not used
		if (~isempty(handles.psc_res))  % Means that we have coastlines and will use the Mirone settings
			handles.opt_psc = [handles.psc_res ' ' handles.psc_opt_W ' ' handles.psc_type_p ' ' handles.psc_type_r];
		end
    end
    if (get(handles.radio_P,'Value')),    opt_P = ' -P';
    else                                        opt_P = '';
    end
    out_msg = build_write_script(handles, opt_J, d_dir, prefix, paper, X0, Y0, opt_P, opt_deg);
    msg{1} = ['File ' prefix '_mir.' handles.script_type ' successufuly created in:  ' d_dir];
    if (out_msg)
		msg{2} = [];   
		msg{3} = 'WARNING: Read the important message on the header of the script';
    end
    msgbox(msg);

%-------------------------------------------------------------------------------------
function [handles,out] = check_coord_system(handles,coord_system,side)
% Currently the coord_system structure must contain the following fields:
%              group_val
%             system_val
%              datum_val
%        cilindrical_val
%          azimuthal_val
%              conic_val
%       miscelaneous_val
%               ProjName    % Projection Name (used in the text info)
%       map_scale_factor
%        MeasureUnit_val    % Currently selected measure unitie
%      DegreeFormat1_val    % Degree format value for point conversions
%      DegreeFormat2_val    % Degree format value for file conversions
%           system_FE_FN    % False eastings/northings
%                is_geog    % Signals if we have geogs coordinates
%             projection    % -J string
%     ProjParameterValue    % projection parameters
%          proj_info_txt
%          proj_info_pos    % This one has to be dealt inside the opening function (don't know here a def value)

if (isempty(coord_system))   % If it doesn't exist, create an empty one
    coord_system = struct([]);
end

% If any of those is missing, assign it a default value
if (~isfield(coord_system,'group_val')),    out.group_val = 1;
else		out.group_val = coord_system.group_val;
end
if (~isfield(coord_system,'system_val')),   out.system_val = 1;
else		out.system_val = coord_system.system_val;
end
if (~isfield(coord_system,'datum_val')),    out.datum_val = 221;   % Default to wgs84
else		out.datum_val = coord_system.datum_val;
end
if (~isfield(coord_system,'cilindrical_val')),  out.cilindrical_val = 1;
else		out.cilindrical_val = coord_system.cilindrical_val;
end
if (~isfield(coord_system,'azimuthal_val')),    out.azimuthal_val = 1;
else		out.azimuthal_val = coord_system.azimuthal_val;
end
if (~isfield(coord_system,'conic_val')),        out.conic_val = 1;
else		out.conic_val = coord_system.conic_val;
end
if (~isfield(coord_system,'miscelaneous_val')), out.miscelaneous_val = 1;
else		out.miscelaneous_val = coord_system.miscelaneous_val;
end
if (~isfield(coord_system,'ProjName')),         out.ProjName = 'Unknown';
else		out.ProjName = coord_system.ProjName;
end
if (~isfield(coord_system,'map_scale_factor')), out.map_scale_factor = [];
else		out.map_scale_factor = coord_system.map_scale_factor;
end
if (~isfield(coord_system,'system_FE_FN')),     out.system_FE_FN = [];
else		out.system_FE_FN = coord_system.system_FE_FN;
end
if (~isfield(coord_system,'projection')),       out.projection = [];
else		out.projection = coord_system.projection;
end
if (~isfield(coord_system,'ProjParameterValue')),out.ProjParameterValue = [];
else		out.ProjParameterValue = coord_system.ProjParameterValue;
end
if (~isfield(coord_system,'proj_info_txt')),    out.proj_info_txt = 'Nikles';
else		out.proj_info_txt = coord_system.proj_info_txt;
end
if (~isfield(coord_system,'MeasureUnit_val')),  out.MeasureUnit_val = 1;
else		out.MeasureUnit_val = coord_system.MeasureUnit_val;
end
if (~isfield(coord_system,'DegreeFormat1_val')),  out.DegreeFormat1_val = 1;
else		out.DegreeFormat1_val = coord_system.DegreeFormat1_val;
end
if (~isfield(coord_system,'DegreeFormat2_val')),  out.DegreeFormat2_val = 1;
else		out.DegreeFormat2_val = coord_system.DegreeFormat2_val;
end
if (~isfield(coord_system,'is_geog')),  out.is_geog = 1;
else		out.is_geog = coord_system.is_geog;
end

% This is my solution to cat 2 structures. There must be a clever way.
hand_cell = struct2cell(handles);       % Convert handles struct to cell
out_cell = struct2cell(out);            % Convert coord_system struct to cell
both_cell = [hand_cell; out_cell];      % Cat them
names_hand = fieldnames(handles);       % Get handles field names
names_out = fieldnames(out);            % Get coord_system field names
for (i=1:length(names_out))             % Append the "side" to the coord_system field names
    names_out{i} = [names_out{i} side];
end
both_names = [names_hand; names_out];   % Cat the handles and the coord_system field names
handles = cell2struct(both_cell,both_names,1);  % Finaly, rebuild the handles structure.

% ----------------------------------------------------------------------------------
function [ALLlineHand, res, opt_W, type_p, type_r] = find_psc_stuff(ALLlineHand)
% See if we have any pscoast stuff
haveCoasts = 0;     havePolitical = 0;  haveRivers = 0;
res = [];           opt_W = [];         type_p = [];        type_r = [];
h_c = findobj(ALLlineHand,'Tag','CoastLineNetCDF');
if (~isempty(h_c))
	if (length(h_c) > 1),   h_c = h_c(1);     end
	CoastRes = get(h_c,'UserData');
	LineWidth_c = get(h_c,'LineWidth');
	LineColor_c = get(h_c,'Color');
	LineStyle_c = get(h_c,'LineStyle');
	haveCoasts = 1;
end
h_p = findobj(ALLlineHand,'Tag','PoliticalBoundaries');
if (~isempty(h_p))
	if (length(h_p) > 1),   h_p = h_p(1);     end
	zz = get(h_p,'UserData');
	if (iscell(zz)),    zz = zz{1};     end
	PoliticalRes = zz(1);        PoliticalType = zz(2);
	LineWidth_p = get(h_p,'LineWidth');
	LineColor_p = get(h_p,'Color');
	LineStyle_p = get(h_p,'LineStyle');
	havePolitical = 1;
end
h_r = findobj(ALLlineHand,'Tag','Rivers');
if (~isempty(h_r))
	if (length(h_r) > 1),   h_r = h_r(1);     end
	zz = get(h_r,'UserData');
	if (iscell(zz)),        zz = zz{1};     end
	RiversRes = zz(1);          RiversType = zz(2);
	LineWidth_r = get(h_r,'LineWidth');
	LineColor_r = get(h_r,'Color');
	LineStyle_r = get(h_r,'LineStyle');
	haveRivers = 1;
end
ALLlineHand = setxor(ALLlineHand, [h_c; h_p; h_r]);

if (haveCoasts || havePolitical || haveRivers)
    res_c = '';     res_p = '';     res_r = '';
    if (haveCoasts)
        cor = round(LineColor_c * 255);
        cor = [num2str(cor(1)) '/' num2str(cor(2)) '/' num2str(cor(3))];
        switch CoastRes
            case 'f',   res_c = ['-Df -W' num2str(LineWidth_c) 'p,' cor];
            case 'h',   res_c = ['-Dh -W' num2str(LineWidth_c) 'p,' cor];
            case 'i',   res_c = ['-Di -W' num2str(LineWidth_c) 'p,' cor];
            case 'l',   res_c = ['-Dl -W' num2str(LineWidth_c) 'p,' cor];
            case 'c',   res_c = ['-Dc -W' num2str(LineWidth_c) 'p,' cor];
        end
        if (~strcmp(LineStyle_c,'-'))   % If we have a line style other than solid
            switch LineStyle_c
                case '--',  res_c = [res_c 'ta'];
                case ':',   res_c = [res_c 'to'];
                case '-.',  res_c = [res_c 't10_2_2_5:5'];
            end
        end
    end
    if (havePolitical)
        switch PoliticalRes
			case 'f',   res_p = '-Df';
			case 'h',   res_p = '-Dh';
			case 'i',   res_p = '-Di';
			case 'l',   res_p = '-Dl';
			case 'c',   res_p = '-Dc';
        end
        cor = round(LineColor_p * 255);
        cor = [num2str(cor(1)) '/' num2str(cor(2)) '/' num2str(cor(3))];
        switch PoliticalType
            case '1',   type_p = ['-N1/'  num2str(LineWidth_p) 'p,' cor];
            case '2',   type_p = ['-N2/'  num2str(LineWidth_p) 'p,' cor];
            case '3',   type_p = ['-N3/'  num2str(LineWidth_p) 'p,' cor];
            case 'a',   type_p = ['-Na/'  num2str(LineWidth_p) 'p,' cor];
        end
        if (~strcmp(LineStyle_p,'-'))   % If we have a line style other than solid
            switch LineStyle_p
                case '--',  type_p = [type_p 'ta'];
                case ':',   type_p = [type_p 'to'];
                case '-.',  type_p = [type_p 't10_2_2_5:5'];
            end
        end
    end
    if (haveRivers)
        switch RiversRes
            case 'f',   res_r = '-Df';
            case 'h',   res_r = '-Dh';
            case 'i',   res_r = '-Di';
            case 'l',   res_r = '-Dl';
            case 'c',   res_r = '-Dc';
        end
        cor = round(LineColor_r * 255);
        cor = [num2str(cor(1)) '/' num2str(cor(2)) '/' num2str(cor(3))];
        switch RiversType
			case '1',   type_r = ['-I1/' num2str(LineWidth_r) 'p,' cor];
			case '2',   type_r = ['-I2/' num2str(LineWidth_r) 'p,' cor];
			case '3',   type_r = ['-I3/' num2str(LineWidth_r) 'p,' cor];
			case '4',   type_r = ['-I4/' num2str(LineWidth_r) 'p,' cor];
			case '5',   type_r = ['-I5/' num2str(LineWidth_r) 'p,' cor];
			case '6',   type_r = ['-I6/' num2str(LineWidth_r) 'p,' cor];
			case '7',   type_r = ['-I7/' num2str(LineWidth_r) 'p,' cor];
			case '8',   type_r = ['-I8/' num2str(LineWidth_r) 'p,' cor];
			case '9',   type_r = ['-I9/' num2str(LineWidth_r) 'p,' cor];
			case '10',  type_r = ['-I10/' num2str(LineWidth_r) 'p,' cor];
			case 'a',   type_r = ['-Ia/' num2str(LineWidth_r) 'p,' cor];
			case 'r',   type_r = ['-Ir/' num2str(LineWidth_r) 'p,' cor];
			case 'i',   type_r = ['-Ii/' num2str(LineWidth_r) 'p,' cor];
			case 'c',   type_r = ['-Ic/' num2str(LineWidth_r) 'p,' cor];
        end
        if (~strcmp(LineStyle_r,'-'))   % If we have a line style other than solid
            switch LineStyle_r
                case '--',  type_r = [type_r 'ta'];
                case ':',   type_r = [type_r 'to'];
                case '-.',  type_r = [type_r 't10_2_2_5:5'];
            end
        end
    end
        res = unique([res_c(1:3); res_p; res_r],'rows');  % We don't want repeated resolution strings
        if (size(res,1) > 1)        % Shit, we have mixed resolutions
            res = '-Di';            % TEMPORARY SOLUTION UNTIL I FIND HOW TO FIND THE HIGHEST COMMON RES
        end
        if (~isempty(res_c)),   opt_W = res_c(5:end);
        else                    opt_W = [];     end
end

% --------------------------------------------------------------------------------------------------------
function out_msg = build_write_script(handles, opt_J, dest_dir, prefix, paper, X0, Y0, opt_P, opt_deg)
% This function do most of the hard work in finding the script components. The pscoast stuff is
% worked out by the "find_psc_stuff" function.

	handMir = handles.mirone_handles;
	ALLlineHand = handles.ALLlineHand;
	opt_R = handles.opt_R;		opt_L = handles.opt_L;		opt_U = handles.opt_U;
	sc = handles.script_type;	ellips = handles.curr_datum;
	opt_psc = handles.opt_psc;
	hAlfaPatch = [];			haveAlfa = 0;		% These ones are used to tell if transparency
	nameRGB = [];			% When not empty it means we'll do a screen capture ('image' or to capture transp)

	if (isempty(opt_psc)),  have_psc = 0;       % We do not have any pscoast commands
	else                    have_psc = 1;
	end

	if (~strcmp(paper,'A4')),   paper_media = paper;
	else                        paper_media = [];
	end
	if (strcmp(sc,'bat'))
		comm = 'REM ';      pb = '%';   pf = '%';
	else
		comm = '# ';        pb = '$';   pf = '';
	end
	if (strcmp(ellips,'WGS-84'))     % It is the default, so don't use any
		ellips = [];
	else
		ellips = [' --ELLIPSOID=' ellips];
	end

	opt_annotsize = '--ANNOT_FONT_SIZE_PRIMARY=10p';

% ------------ Some (maybe) needed vars ------------------------------------------------------------------
	haveSymbol = 0;     used_grd = 0;  out_msg = 0;
	need_path = 0;      used_countries = 0;
	script = cell(16,1);
	if (~isempty(handMir.grdname))
		[PATH,FNAME,EXT] = fileparts(handMir.grdname);
		just_grd_name = [FNAME EXT];
		if (strcmp(PATH,dest_dir)),		need_path = 0;
		else							need_path = 1;
		end
		clear PATH FNAME EXT;
	end
	grd_name = handMir.grdname;

% -------------------- Build -B string -------------------------------------------------
	Bx = get(handMir.axes1,'XTick');      d_Bx = diff(Bx);
	By = get(handMir.axes1,'YTick');      d_By = diff(By);
	opt_B = ['-B' num2str(d_Bx(1)) '/' num2str(d_By(1)) 'WSen'];
	clear Bx By d_Bx d_By;
% --------------------------------------------------------------------------------------

l = 1;
if (~strcmp(sc,'bat'))							% Write a csh script
    script{l} = '#!/bin/csh -f';				l=l+1;
	script{l} = comm;							l=l+1;
	script{l} = [comm 'Coffeeright Mirone Tec'];l=l+1;
	script{l} = comm;							l=l+1;
	script{l} = [comm ' ---- Projection. You may change it if you know how to'];    l=l+1;
	script{l} = ['set proj = ' opt_J];			l=l+1;      % Map scale
	script{l} = [comm ' ---- Frame annotations. You may change it if you know how to'];    l=l+1;
	script{l} = ['set frm = ' opt_B];			l=l+1;      saveBind = l-1;
	script{l} = [comm ' ---- Map limits. You may change it if you know how to'];    l=l+1;
	script{l} = ['set lim = ' opt_R];			l=l+1;
	script{l} = comm;							l=l+1;
	script{l} = [comm ' ---- Longitude annotation style. The +ddd:mm:ss form => [0;360] range '];    l=l+1;
	script{l} = ['set deg_form=' opt_deg];      l=l+1;
	script{l} = '';                             l=l+1;
    prefix_ddir = [dest_dir filesep prefix];    % Add destination dir to the name prefix
	if (~isempty(grd_name))
		if (~need_path)
			script{l} = ['set grd = ' just_grd_name];   id_grd = l; l=l+1;
		else
			script{l} = ['set grd = ' grd_name];        id_grd = l; l=l+1;
		end
	end
    script{l} = ['set cpt = ' prefix '.cpt']; id_cpt = l;   l=l+1;
	script{l} = ['set ps = ' prefix '.ps'];     l=l+1;
    if (~isempty(paper_media))
    	script{l} = [comm ' We are not using A4'];  l=l+1;
        script{l} = ['gmtset PAPER_MEDIA=' paper_media]; l=l+1;
    	script{l} = comm;                       l=l+1;        
    end
else											% Write a dos batch    
	script{l} = '@echo OFF';					l=l+1;
	script{l} = [comm 'Coffeewrite Mirone Tec'];l=l+1;
	script{l} = comm;                           l=l+1;
	script{l} = [comm ' ---- Projection. You may change it if you know how to'];    l=l+1;
	script{l} = ['set proj=' opt_J];            l=l+1;      % Map scale
	script{l} = [comm ' ---- Frame annotations. You may change it if you know how to'];    l=l+1;
	script{l} = ['set frm=' opt_B];             l=l+1;      saveBind = l-1;
	script{l} = [comm ' ---- Map limits. You may change it if you know how to'];    l=l+1;
	script{l} = ['set lim=' opt_R];				l=l+1;
	script{l} = comm;							l=l+1;
	script{l} = [comm ' ---- Longitude annotation style. The +ddd:mm:ss form => [0;360] range '];    l=l+1;
	script{l} = ['set deg_form=' opt_deg];		l=l+1;
	script{l} = '';								l=l+1;
	script{l} = [comm ' ---- Annotation font size in points'];    l=l+1;
	script{l} = ['set annot_size=' opt_annotsize];      l=l+1;
	script{l} = '';                             l=l+1;
    prefix_ddir = [dest_dir filesep prefix];    % Add destination dir to the name prefix
	if (~isempty(grd_name))
		if (~need_path)
			script{l} = ['set grd=' just_grd_name];     id_grd = l; l=l+1;
		else
			script{l} = ['set grd=' grd_name];          id_grd = l; l=l+1;
		end
	end
	script{l} = ['set cpt=' prefix '.cpt'];     id_cpt = l; l=l+1;
	script{l} = ['set ps=' prefix '.ps'];       l=l+1;
	if (~isempty(paper_media))
    	script{l} = [comm ' ---- We are not using A4'];  l=l+1;
        script{l} = ['gmtset PAPER_MEDIA=' paper_media]; l=l+1;
    	script{l} = comm;                       l=l+1;        
	end
end

% ------------ Start writing GMT commands --------------------------------
script{l} = ' ';            l=l+1;
script{l} = [comm '-------- Start by creating the basemap frame'];  l=l+1;
if (~strcmp(sc,'bat'))		% In Unix like sys let the annot_font_size param be controled by the .gmtdefaults
	script{l} = ['psbasemap ' pb 'lim' pf ' ' pb 'proj' pf ' ' pb 'frm' pf ' ' X0 ' ' Y0 opt_U opt_P ' ' pb 'deg_form' pf ' -K > ' pb 'ps' pf];
else
	script{l} = ['psbasemap ' pb 'lim' pf ' ' pb 'proj' pf ' ' pb 'frm' pf ' ' X0 ' ' Y0 opt_U opt_P ' ' pb 'deg_form' pf ' ' pb 'annot_size' pf ' -K > ' pb 'ps' pf];
end
l=l+1;
if (~isempty(grd_name))
	% If renderer == OpenGL, that is interpreted as a transparency request. In that case we need a screen capture
	if (strcmp(get(handMir.figure1,'Renderer'), 'OpenGL'))
		if ( ~isempty(findobj(get(handMir.axes1,'Child'),'Type','patch')) )		% Extra test
			handMir.Illumin_type = 10;		% Dumb fake value just to force screen capture
			haveAlfa = 1;
		end
	end
    if ( handMir.Illumin_type > 0 && handMir.Illumin_type <= 4 )
        % We have a image illuminated with grdgradient. Rebuild de illumination
        illumComm = getappdata(handMir.figure1,'illumComm');
        opt_M = '';
        if (handMir.Illumin_type == 1 && handMir.geog),   opt_M = ' -M';     end
        opt_N = '';
        if (handMir.Illumin_type == 1),      opt_N = ' -Nt';     end
        name_illum = [prefix '_intens.grd=cf'];
        script{l} = '';                      l=l+1;
        script{l} = [comm '-------- Compute the illumination grid'];    l=l+1;
        script{l} = ['grdgradient ' pb 'grd' pf opt_M ' ' illumComm opt_N ' -G' name_illum ellips];    l=l+1;
        have_gmt_illum = 1;     used_grd = 1;
        illum = [' -I' name_illum];
    elseif ( handMir.Illumin_type > 4 || handMir.is_draped )
        % We have a Manip or draping illumination. Here we have to use the R,G,B trick
        nameRGB = [prefix_ddir '_channel'];    name_sc = [prefix '_channel'];
        illum = [nameRGB '_r.grd ' nameRGB '_g.grd ' nameRGB '_b.grd']; % ????
        have_gmt_illum = 0;
    else        % We don't have any illumination
        have_gmt_illum = 0;
        used_grd = 1;
    end
    script{l} = ' ';                          l=l+1;
    if (have_gmt_illum)                     % grdimage with illumination
        script{l} = [comm '-------- Plot the the base image using grdimage & illumination'];    l=l+1;
        script{l} = ['grdimage ' pb 'grd' pf ' -R -J -C' pb 'cpt' pf illum ellips ' -O -K >> ' pb 'ps' pf];
        l=l+1;
        used_grd = 1;
    elseif (used_grd && ~have_gmt_illum)     % Simple grdimage call
        script{l} = [comm '-------- Plot the the base image using grdimage'];    l=l+1;
        script{l} = ['grdimage ' pb 'grd' pf ' -R -J -C' pb 'cpt' pf ellips ' -O -K >> ' pb 'ps' pf];   l=l+1;
        used_grd = 1;
    else                                    % No grd used, use the R,G,B channels
        script{l} = [comm '-------- Plot the 3 RGB base images using grdimage'];    l=l+1;
        script{l} = ['grdimage ' name_sc '_r.grd ' name_sc '_g.grd ' name_sc '_b.grd' ellips ' -R -J -O -K >> ' pb 'ps' pf];
        l=l+1;    
    end
    clear grd_name have_gmt_illum illum;
elseif (handMir.image_type == 20)
    % Do nothing regarding the basemap image (in fact we don't have any image)
else    % We don't have a grid, so we need to fish the image and save it as R,G,B triplet
	nameRGB = [prefix_ddir '_channel'];    name_sc = [prefix '_channel'];
	script{l} = ' ';
	script{l} = [comm '-------- Plot the 3 RGB base images using grdimage'];    l=l+1;
	script{l} = ['grdimage ' name_sc '_r.grd ' name_sc '_g.grd ' name_sc '_b.grd' ellips ' -R -J -O -K >> ' pb 'ps' pf];
	l=l+1;    
end

% ------------ If we have used a GMT grid file build the GMT palette -----------------------
if (used_grd || strcmp(get(handMir.PalAt,'Check'),'on') || strcmp(get(handMir.PalIn,'Check'),'on') )
    tmp = cell(261,1);
    pal = get(handMir.figure1,'colormap');
    %Z = getappdata(handMir.figure1,'dem_z');
    % SE Z == [] FAZER QUALQUER COISA
    if (handMir.have_nans),     cor_nan = pal(1,:);     pal = pal(2:end,:);   end     % Remove the bg color
    
    pal_len = size(pal,1);
    z_min = handMir.head(5);    z_max = handMir.head(6);
    
    dz = (z_max - z_min) / pal_len;
    tmp{1} = '# Color palette exported by Mirone';
    tmp{2} = '# COLOR_MODEL = RGB';
    cor = round(pal*255);
	for i=1:pal_len
        cor_str = sprintf([num2str(cor(i,1),'%.12g') '\t' num2str(cor(i,2),'%.12g') '\t' num2str(cor(i,3),'%.12g')]);
        z1 = num2str(z_min+dz*(i-1),'%.3f');
        z2 = num2str(z_min+dz*i,'%.3f');
        tmp{i+2} = sprintf([z1 '\t' cor_str '\t' z2 '\t' cor_str]);
	end
    tmp{pal_len+3} = sprintf('F\t255\t255\t255');
    tmp{pal_len+4} = sprintf('B\t0\t0\t0');
	if (handMir.have_nans)
        cor = round(cor_nan*255);
        cor_str = sprintf(['N\t' num2str(cor(1),'%.12g') '\t' num2str(cor(2),'%.12g') '\t' num2str(cor(3),'%.12g')]);
        tmp{pal_len+5} = sprintf(cor_str);
	else
        tmp{pal_len+5} = sprintf('N\t255\t255\t255');
	end
    sc_cpt = [dest_dir filesep prefix '.cpt'];
	fid = fopen(sc_cpt,'wt');
	for (i=1:pal_len+5),   fprintf(fid,'%s\n',tmp{i});     end
	fclose(fid);
    clear tmp z_min z_max pal_len pal cor cor_str fid dz z1 z2
else        % Remove the cpt declaration. After all we won't go to use it
    script(id_cpt) = [];    l=l-1;
end

% ------------- Coastlines section -----------------------------------
if (have_psc)       % We have pscoast commands
    script{l} = ' ';                        l=l+1;
    script{l} = [comm 'Plot coastlines'];   l=l+1;
    script{l} = ['pscoast ' opt_psc ellips opt_L ' -R -J -O -K >> ' pb 'ps' pf];    l=l+1;
elseif (~isempty(opt_L))
    script{l} = ['psbasemap ' opt_L ' -R -J -O -K >> ' pb 'ps' pf];    l=l+1;
end

% ------------- Search for contour lines ----------------------------------------------------
ALLtextHand = findobj(get(handMir.axes1,'Child'),'Type','text');
% % If we have focal mecanisms with labels, remove their handles right away
% h = findobj(ALLtextHand,'Tag','TextMeca');                                  % I'M NOT SURE ON THIS ONE
% if (~isempty(h))    ALLtextHand = setxor(ALLtextHand, h);   end

tag = get(ALLlineHand,'Tag');
if (~isempty(tag) && ~isempty(handMir.grdname))
    h = findobj(ALLlineHand,'Tag','contour');
    if (~isempty(h))
        h_label = findobj(ALLtextHand,'Tag','contour');   % Search for contour labels
        if (~isempty(h_label))
            lab = get(h_label,'UserData');
            if (iscell(lab)),   lab = unique(cat(1,lab{:}));    end
        else
            lab = [];
        end
        conts = zeros(length(h),1);
        for i=1:length(h)
            conts(i) = getappdata(h(i),'cont_label');
        end
        conts = unique(conts);
        no_anot = setxor(conts,lab);    % Contour levels that are not annotated
        name = [prefix_ddir '_cont.dat'];
        fid = fopen(name,'wt');
        if (isempty(no_anot))           % Annotate all contours
            fprintf(fid,'%.5f\tA\n',conts);
        else                            % Annotate only some contours
            conts = [[lab; no_anot] [ones(length(lab),1)*double('A'); ones(length(no_anot),1)*double('C')]];
            conts = sortrows(conts);
            fprintf(fid,'%.5f\t%c\n',conts');
        end
        fclose(fid);
        script{l} = ' ';                            l=l+1;
        script{l} = [comm ' ---- Plot contours'];	l=l+1;
        script{l} = ['grdcontour ' pb 'grd' pf ' -R -J -C' [prefix '_cont.dat'] ellips ' -O -K >> ' pb 'ps' pf];
        l=l+1;
        used_grd = 1;
        ALLlineHand = setxor(ALLlineHand, h);       % h is processed, so remove it from handles list
        ALLtextHand = setxor(ALLtextHand, h_label); % same for contour label strings
        clear h conts fid name no_anot lab;
    end
end

% ------------- Search for symbols -----------------------------------------------------------    
	tag = get(ALLlineHand,'Tag');
	if (~isempty(tag))
		h = findobj(ALLlineHand,'Tag','Symbol');
		h = [h; findobj(ALLlineHand,'Tag','City_major')];
		h = [h; findobj(ALLlineHand,'Tag','City_other')];
		h = [h; findobj(ALLlineHand,'Tag','volcano')];
		h = [h; findobj(ALLlineHand,'Tag','hotspot')];
		h = [h; findobj(ALLlineHand,'Tag','Earthquakes')];
		h = [h; findobj(ALLlineHand,'Tag','DSDP')];
		h = [h; findobj(ALLlineHand,'Tag','ODP')];

		% Search for points as Markers (that is, line with no line - just symbols on vertices)
		h_shit = get(ALLlineHand,'LineStyle');
		h_num_shit = strmatch('none',h_shit);
		if (h_num_shit)
			id = ismember(h, ALLlineHand(h_num_shit));		% Many, if not all, can be repeated
			h(id) = [];										% This will remove repeted elements
			h = [h; ALLlineHand(h_num_shit)];
		end
		clear h_shit h_num_shit;

		if (~isempty(h))
			symbols = get_symbols(h);
			haveSymbol = true;
			ALLlineHand = setxor(ALLlineHand, h);			% h is processed, so remove it from handles list
		end
		clear h;
	end

	if (haveSymbol)
		ns = numel(symbols.x);
		name = [prefix_ddir '_symb.dat'];	name_sc = [prefix '_symb.dat'];
		fc = symbols.FillColor{1};			ec = symbols.EdgeColor{1};
		opt_G = '';			opt_W = '';
		if (~ischar(fc)),	opt_G = sprintf(' -G%d/%d/%d', round(fc * 255));	end
		if (ischar(ec) && strcmp(ec, 'auto'))			% WRONG. Should be line's 'Color' property
			opt_W = ' -W1p';
		elseif (~ischar(ec))
			opt_W = sprintf(' -W1p,%d/%d/%d', round(ec * 255));
		end

		if (ns > 1 && numel(symbols.Size) == 1)			% We have the same symbol repeated ns times
			fid = fopen(name,'wt');
			fprintf(fid,'%.5f\t%.5f\n',[symbols.x{:}; symbols.y{:}]);
			script{l} = ' ';                        	l=l+1;
			script{l} = [comm ' ---- Plot symbols'];    l=l+1;
			script{l} = ['psxy ' name_sc ' -S' symbols.Marker num2str(symbols.Size{1}) 'p' opt_G ...
					opt_W ellips ' -R -J -O -K >> ' pb 'ps' pf];    l=l+1;
			fclose(fid);
		elseif (ns == 1 && numel(symbols.Size) == 1)	% We have only one symbol
			script{l} = ' ';							l=l+1;
			script{l} = [comm ' ---- Plot symbol'];		l=l+1;
			script{l} = [sprintf('echo %.6f\t%.6f',symbols.x{1},symbols.y{1}) ' | ' ...
						'psxy -S' symbols.Marker num2str(symbols.Size{1}) 'p' opt_G ...
						opt_W ellips ' -R -J -O -K >> ' pb 'ps' pf];    l=l+1;        
		else								% We have ns different symbols
			m = zeros(ns,1);
			for (i = 1:ns)
				m(i) = size(symbols.x{i},2);
			end
			n = find(m ~= 1);
			if (~isempty(n))				% We have a mixed scenario. Individual as well as group symbols
				script = write_group_symb(prefix,prefix_ddir,comm,pb,pf,ellips,symbols,n,script);
				symbols.x(n) = [];			symbols.y(n) = [];  % Clear processed symbols
				symbols.FillColor(n) = [];	symbols.EdgeColor(n) = [];
				symbols.Size(n) = [];		symbols.Marker(n,:) = [];
				l = numel(script) + 1;
				ns = ns - numel(n);
			end
			clear m n;
			fid = fopen(name,'wt');
			for (i = 1:ns)
				fc = symbols.FillColor{i};			ec = symbols.EdgeColor{i};
				opt_G = '';			opt_W = '';
				if (~ischar(fc)),	opt_G = sprintf(' -G%d/%d/%d', round(fc * 255));	end
				if (ischar(ec) && strcmp(ec, 'auto'))			% WRONG. Should be line's 'Color' property
					opt_W = ' -W1p';
				elseif (~ischar(ec))
					opt_W = sprintf(' -W1p,%d/%d/%d', round(ec * 255));
				end
				fprintf(fid,'>%s\n',[opt_G opt_W]);
				fprintf(fid,'%.5f\t%.5f\t%.0f\t%s\n',symbols.x{i},symbols.y{i},symbols.Size{i},symbols.Marker(i,:));
			end
			script{l} = ' ';                        	l=l+1;
			script{l} = [comm ' ---- Plot symbols'];    l=l+1;
			script{l} = ['psxy ' name_sc ellips ' -S -R -J --MEASURE_UNIT=point -m -O -K >> ' pb 'ps' pf];    l=l+1;
			fclose(fid);
		end
		clear cor_fill cor_edge ns symbols haveSymbol name name_sc;
	end
% ------------------------------------------------------------------------------------------------

% ------------- Search for focal mecanisms ----------------------------
ALLpatchHand = findobj(get(handMir.axes1,'Child'),'Type','patch');
if (~isempty(ALLpatchHand))
	focHand = findobj(ALLpatchHand,'Tag','FocalMeca');
	if (~isempty(focHand))
		% First deal with the 'line anchors'
		focHandAnchor = findobj(ALLlineHand,'Tag','FocalMecaAnchor');   % Handles of the line anchors
		x = get(focHandAnchor,'XData');			y = get(focHandAnchor,'YData');
		if (iscell(x)),		x = cell2mat(x);	y = cell2mat(y);    end
		id_anch = find(diff(x,1,2));

		psmeca_line = cell(numel(focHand),1);
		for (k = 1:numel(focHand)),		psmeca_line{k} = getappdata(focHand(k),'psmeca_com');	end
		psmeca_line = cat(1,psmeca_line{:});    % This also get us rid of empty cell fields.
              
		n_cols = size(psmeca_line,2);
		if (n_cols == 10 || n_cols == 14),		with_label = 1;
		else									with_label = 0;
		end
		name = [prefix_ddir '_meca.dat'];   name_sc = [prefix '_meca.dat'];     opt_C = '';
		fid = fopen(name,'wt');
		if (n_cols == 9 || n_cols == 10)		% Aki & Richard convention
            % If beach-bals are not ploted at their origin update the ploting coords columns
            if (~isempty(id_anch))
				psmeca_line(:,8) = x(:,2);		psmeca_line(:,9) = y(:,2);     opt_C = ' -C';
            end
			opt_S = ['-Sa' getappdata(handMir.figure1,'MecaMag5') 'c'];
			format = '%.4f\t%.4f\t%.1f\t%.0f\t%.0f\t%.0f\t%.1f\t%.4f\t%.4f';
			for (k=1:size(psmeca_line,1))
				fprintf(fid,format,psmeca_line(k,1:9));
				if (with_label),	fprintf(fid,'\t%s\n',num2str(psmeca_line(k,10)));
				else				fprintf(fid,'\n');
				end
			end
        elseif (n_cols == 13 || n_cols == 14)	% CMT convention
            % If beach-bals are not ploted at their origin update the ploting coords columns
            if (~isempty(id_anch))
                psmeca_line(:,12) = x(:,2);		psmeca_line(:,13) = y(:,2);     opt_C = ' -C';
            end
            psmeca_line(:,11) = psmeca_line(:,11) + 7;		% psmeca uses Moment in Dyn-cm
            opt_S = ['-Sc' getappdata(handMir.figure1,'MecaMag5') 'c'];
            format = '%.4f\t%.4f\t%.1f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.2f\t%d\t%.4f\t%.4f';           
			for (k=1:size(psmeca_line,1))
                fprintf(fid,format,psmeca_line(k,1:13));
                if (with_label),	fprintf(fid,'\t%s\n',num2str(psmeca_line(k,14)));
                else				fprintf(fid,'\n');
                end
			end
		end
        fclose(fid);
    	script{l} = ' ';			l=l+1;
        script{l} = [comm ' ---- Plot Focal Mechanisms'];   l=l+1;
        script{l} = ['psmeca ' opt_S opt_C ' ' name_sc ellips ' -R -J -O -K >> ' pb 'ps' pf];    l=l+1;
        ALLpatchHand = setxor(ALLpatchHand, focHand);		% focHand is processed, so remove it from handles list
        ALLlineHand  = setxor(ALLlineHand, focHandAnchor);	%       iden
        clear focHand name name_sc psmeca_line with_label n_cols id_anch opt_S opt_C
	end
end
% -------------------------------------------------------------------------------------------------------

% ------------- Search for "telhas" ---------------------------------
if (~isempty(ALLpatchHand))
	TelhasHand = findobj(ALLpatchHand,'Tag','tapete');
	if (~isempty(TelhasHand))
        tmp = findobj(ALLpatchHand,'Tag','tapete_R');
        ALLpatchHand = setxor(ALLpatchHand, tmp);       % Remove the reverse "telhas" 
        n_tapetes = length(TelhasHand);
        for (i=1:n_tapetes)
            saved = get(TelhasHand(i),'UserData');
            name = [prefix_ddir sprintf('_telha_%d.dat',i)];
            name_sc = [prefix sprintf('_telha_%d.dat',i)];
            if (~isempty(saved))
                fid = fopen(name,'wt');
                fprintf(fid,'%.5f\t%.5f\n',saved.line');
                fclose(fid);
			    script{l} = ' ';              l=l+1;
                script{l} = [comm ' ---- Plot telhas. NOTE: THIS IS NOT A GMT PROGRAM'];   l=l+1;
			    script{l} = ['telha ' name_sc ' ' saved.opt_E ' ' saved.opt_I ' ',...
                    saved.opt_N ' ' saved.opt_T ' -Blixo.dat'];     l=l+1;
                script{l} = ['psxy lixo.dat ' ellips ' -R -J -m -L -O -K >> ' pb 'ps' pf];    l=l+1;
                %fclose(fid);
            end
        end
        ALLpatchHand = setxor(ALLpatchHand, TelhasHand);       % TelhasHand is processed, so remove it from handles list
        clear TelhasHand name name_sc n_tapetes tmp 
	end
end
% -------------------------------------------------------------------------------------------------------

% ------------------------------------- Search for countries ----------------------------
if (~isempty(ALLpatchHand))
	% First see about these still remaining patch transparency
	[ALLpatchHand, hAlfaPatch] = findTransparents(ALLpatchHand);
	if (isempty(hAlfaPatch)),		haveAlfa = 0;		end			% An extra test
	
    AtlasHand = findobj(ALLpatchHand,'Tag','Atlas');
    if (~isempty(AtlasHand))
        used_countries = 1;     need_path = 1;
        n_cts = length(AtlasHand);
        if (n_cts > 1)                  % We have multiple countries
            ct_names = cell(n_cts,1);   % To hold the country names
            for (k=1:n_cts)             % Loop over all countries found and store theyr names
                ct_names{k} = get(AtlasHand(k),'UserData');
            end
        else                            % We have only one country
            ct_names = {get(AtlasHand(k),'UserData')};
        end
        ct_names = unique(ct_names);    % Many countries have several polygons (e.g. islands).
        name = [prefix_ddir '_country_names.txt'];
        fid = fopen(name,'wt');
        fprintf(fid,'%s\n',ct_names{:});        fclose(fid);
		script{l} = ' ';				l=l+1;
        script{l} = [comm ' ---- Plot countries. NOTE: THIS IS NOT A GMT PROGRAM'];   l=l+1;
        ct_with_pato = getappdata(handMir.figure1,'AtlasResolution');
		script{l} = [cd filesep 'country_extract -P' name ' ' ct_with_pato ' -C | ',...
                'psxy ' ellips ' -R -J -W0.5p -m -O -K >> ' pb 'ps' pf];    l=l+1;
        ALLpatchHand = setxor(ALLpatchHand, AtlasHand);       % AtlasHand is processed, so remove it from handles list
        clear AtlasHand name n_cts ct_with_pato
    end
end
% -------------------------------------------------------------------------------------------------------

% ------------- Search for closed polygons ----------------------------
if (~isempty(ALLpatchHand))
    xx = get(ALLpatchHand,'XData');     yy = get(ALLpatchHand,'YData');
    n_patch = length(ALLpatchHand);
    LineStyle = get(ALLpatchHand,'LineStyle');
    LineWidth = get(ALLpatchHand,'LineWidth');
    if (iscell(LineWidth)),     LineWidth = cat(1,LineWidth{:});     end
    EdgeColor = get(ALLpatchHand,'EdgeColor');
    if (iscell(EdgeColor)),     EdgeColor = cat(1,EdgeColor{:});     end
    FillColor = get(ALLpatchHand,'FaceColor');
    if (iscell(FillColor))
        resp = strmatch('none',char(FillColor{:}));
        if (isempty(resp))
            FillColor = cat(1,FillColor{:});
        else
            for (i=1:length(resp))                  % Signal down that this is a non colored polygon
                FillColor{resp(i)} = [-1 -1 -1];    % FDS it worked. I wonder why FillColor{resp} = repmat([-1 -1 -1],length(resp),1); DOESN'T
            end
            FillColor = cat(1,FillColor{:});
        end
    else                % We have only one patch
        xx = num2cell(xx,1);   yy = num2cell(yy,1);   % Make it a cell for reducing the head-hakes
        resp = strmatch('none',FillColor);
        if (~isempty(resp))
            FillColor = [-1 -1 -1];                 % Signal down that this is a non colored polygon
        end
    end
    name = [prefix_ddir '_patch.dat'];    name_sc = [prefix '_patch.dat'];
	fid = fopen(name,'wt');
    for (i=1:n_patch)
        cor_edge = round(EdgeColor(i,1:3) * 255);
        cor_edge = [num2str(cor_edge(1)) '/' num2str(cor_edge(2)) '/' num2str(cor_edge(3))];
        cor_fill = round(FillColor(i,1:3) * 255);
        if (cor_fill(1) >= 0)       % Color filled polygon
            cor_fill = [num2str(cor_fill(1)) '/' num2str(cor_fill(2)) '/' num2str(cor_fill(3))];
            mlt_comm = ['> -G' cor_fill ' -W' num2str(LineWidth(i)) 'p,' cor_edge];
        else                        % No filling color
            mlt_comm = ['> -W' num2str(LineWidth(i)) 'p,' cor_edge];
        end
        
        if (any(isnan(xx{i})))      % If we have NaNs we need to split into segments
            [latcells,loncells] = polysplit(yy{i}(:),xx{i}(:));
            for (j=1:numel(loncells))
                fprintf(fid,'%s\n',mlt_comm);
                fprintf(fid,'%.5f\t%.5f\n',[loncells{j}(:)'; latcells{j}(:)']);
            end
        else
            fprintf(fid,'%s\n',mlt_comm);
            fprintf(fid,'%.5f\t%.5f\n',[xx{i}(:)'; yy{i}(:)']);
        end
    end
	fclose(fid);
	script{l} = ' ';              l=l+1;
    script{l} = [comm ' ---- Plot closed AND colored polygons'];   l=l+1;
	script{l} = ['psxy ' name_sc ellips ' -R -J --MEASURE_UNIT=point -m -O -K >> ' pb 'ps' pf];    l=l+1;
    clear ALLpatchHand name name_sc n_patch xx yy LineStyle LineWidth EdgeColor FillColor cor_edge resp
end

% ------------- Search for lines or polylines ----------------------------
	if (~isempty(ALLlineHand))      % OK, now the only left line handles must be, plines, mb-tracks, etc
		xx = get(ALLlineHand,'XData');     yy = get(ALLlineHand,'YData');
		if (~iscell(xx))            % We have only one line
			xx = num2cell(xx(:),1);   yy = num2cell(yy(:),1);
		end
		n_lin = length(xx);
		script{l} = ' ';                        l=l+1;
		script{l} = [comm ' ---- Plot lines'];  l=l+1;
		if (n_lin > 0)     % We have more than one line.         E SENAO?
			LineStyle = get(ALLlineHand,'LineStyle');
			[LineStyle,LineStyle_gmt] = lineStyle2num(LineStyle);
			LineWidth = get(ALLlineHand,'LineWidth');
			if (iscell(LineWidth)),     LineWidth = cat(1,LineWidth{:});    end
			LineColor = get(ALLlineHand,'Color');
			if (iscell(LineColor)),     LineColor = cat(1,LineColor{:});    end
			[b,m] = sortrows([LineWidth LineColor LineStyle]);
			m = m(end:-1:1);			% Revert order because I want thicker lines ploted first
			xx = xx(m);     yy = yy(m);
			LineWidth = LineWidth(m,:);     LineColor = LineColor(m,:);
			LineStyle = LineStyle(m);       LineStyle_gmt = LineStyle_gmt(m,:);
			[b,m] = unique([LineWidth LineColor LineStyle],'rows');   % reuse b,m
			m = m(end:-1:1);			% OK, now we have to put it back in ascending order        
			m = [0; m];					% use this first index to help file creation algo
			for (i = 1:length(m)-1)
				name = sprintf('%s_line_%d.dat', prefix_ddir, i);
				name_sc = sprintf('%s_line_%d.dat', prefix, i);
				fid = fopen(name,'wt');
				for j=m(i)+1:m(i+1)
					if (any(isnan(xx{j})))          % If we have NaNs we need to split into segments
						[latcells,loncells] = polysplit(yy{j}(:),xx{j}(:));
						for (k=1:numel(loncells))
							fprintf(fid,'>\n');
							fprintf(fid,'%.5f\t%.5f\n',[loncells{k}(:)'; latcells{k}(:)']);
						end
					else
						fprintf(fid,'>\n');
						fprintf(fid,'%.5f\t%.5f\n',[xx{j}(:) yy{j}(:)]');
					end
				end
				fclose(fid);
				cor = round(LineColor(j,:) * 255);
				cor = [num2str(cor(1)) '/' num2str(cor(2)) '/' num2str(cor(3))];
				script{l} = ['psxy ' name_sc ellips ' -R -J -W' num2str(LineWidth(j)) 'p,' ...
						cor LineStyle_gmt{j} ' --MEASURE_UNIT=point -m -O -K >> ' pb 'ps' pf];
				l=l+1;
			end
		end
		clear xx yy cor fid m name name_sc reps LineStyle LineWidth LineColor
	end

% ------------- Search for text strings ---------------------------------------------
if (~isempty(ALLtextHand))          % ALLtextHand was found above in the search for contours
	if (~isempty(ALLtextHand))      % We (still) have text fields
		pos = get(ALLtextHand,'Position');      font = get(ALLtextHand,'FontName');
		fsize = get(ALLtextHand,'FontSize');    fcolor = get(ALLtextHand,'Color');
		if (isnumeric(fcolor))
			fcolor = round(fcolor * 255);
			if (numel(fcolor) == 1)
				opt_G = {sprintf(' -G%d', fcolor)};
			else
				opt_G = {sprintf(' -G%d/%d/%d', fcolor(1:3))};
			end
		elseif (ischar(fcolor))     % Shit, we have to decode the color letter
			switch fcolor
				case 'w',       opt_G = {' -G255'};
				case 'k',       opt_G = {' -G0'};
				case 'y',       opt_G = {' -G255/255/0'};
				case 'c',       opt_G = {' -G0/255/255'};
				case 'r',       opt_G = {' -G255/0/0'};
				case 'g',       opt_G = {' -G0/255/0'};
				case 'b',       opt_G = {' -G0/0/255'};
				otherwise,      opt_G = {''};
			end
		elseif (iscell(fcolor))			% Double shit, we have to convert a Mx3 cell matrix into texts
            tmp = cell2mat(fcolor) * 255;
            opt_G = cell(size(tmp,1),1);
			for (m = 1:size(tmp,1))
				opt_G{m} = {sprintf(' -G%d/%d/%d', tmp(1:3))};
			end
		else
			opt_G = {''};
		end
        str = get(ALLtextHand,'String');      angle = get(ALLtextHand,'Rotation');
        if (~iscell(pos))				% Make them cells for author's mental sanity
            pos = num2cell(pos(:),1);	fsize = num2cell(fsize,1);		angle = num2cell(angle,1);
            str = {str};				%font = {font};
        end
        n_text = length(str);
		script{l} = ' ';        l=l+1;
        script{l} = [comm ' ---- Plot text strings'];   l=l+1;    
        for (i = 1:n_text)
			frmt = 'echo %.5f %.5f %d %.2f 4 LB %s | pstext %s %s  -R -J -O -K >> %sps%s';
			% Quick and dirty patch for when opt_G is a cell of cells and it than crash below on sprintf
			texto = opt_G{i};
			if (isa(texto,'cell')),		texto = texto{1};	end
			script{l} = sprintf(frmt, pos{i}(1), pos{i}(2), fsize{i}, angle{i}, str{i}(1,:), ellips, texto, pb, pf);
			l = l + 1;
			this_nLines = size(str{i},1);		% How many lines has this text element?
			if (this_nLines > 1)				% More than one. So try to estimate each line Pos from a simple calculus
				ext = get(ALLtextHand(i), 'Extent');
				for (k = 2:this_nLines)
					yPos = pos{i}(2) - (k - 1) * (ext(4) / this_nLines);
					script{l} = sprintf(frmt, pos{i}(1), yPos, fsize{i}, angle{i}, str{i}(k,:), ellips, texto, pb, pf);
					l = l + 1;
				end
			end
        end
	end
end

% ------------- Search for colorbar -------------------------------------------
	if (strcmp(get(handMir.PalAt,'Check'),'on') || strcmp(get(handMir.PalIn,'Check'),'on'))
		if (strcmp(get(handMir.PalAt,'Check'),'on')),	axHandle = get(handMir.PalAt,'UserData');
		else											axHandle = get(handMir.PalIn,'UserData');
		end

		axUnits = get(axHandle(1), 'Units');		set(axHandle(1), 'Units', 'pixels');
		posCB = get(axHandle(1),'pos');				set(axHandle(1), 'Units', axUnits);
		axUnits = get(handMir.axes1, 'Units');		set(handMir.axes1, 'Units', 'pixels');
		posAx = get(handMir.axes1,'pos');			set(handMir.axes1, 'Units', axUnits);

		mapW = str2double(get(handles.edit_mapWidth,'String'));
		mapH = str2double(get(handles.edit_mapHeight,'String'));
		cbH = posCB(4) / posAx(4) * mapH;       % Estimate the colorbar height like this
		marg = 0.3;     cbW = 0.5;    % Margin between Image and colorbar (in cm) and colorbar width
		unitC = handles.which_unit(1);

		if (handles.which_unit(1) == 'i')
			marg = marg / 2.54;			cbW = cbW / 2.54;
		end
		if (handles.which_unit(1) == 'p')
			marg = marg / 2.54 * 72;	cbW = cbW / 2.54 * 72;
		end
		YTick = get(axHandle(1),'YTick');		bInt = YTick(2) - YTick(1);		% To use in -B option
		opt_D = sprintf(' -D%.2f%c/%.2f%c/%.2f%c/%.2f%c',mapW+marg,unitC, cbH/2,unitC, cbH,unitC, cbW,unitC);
		script{l} = ' ';        l=l+1;
		script{l} = [comm ' ---- Plot colorbar ---'];   l=l+1;
		script{l} = ['psscale' opt_D ' -S -C' pb 'cpt' pf ' -B' num2str(bInt) ' -O -K >> ' pb 'ps' pf];
		script{saveBind} = [script{saveBind} 'WSNe'];       % Don't write West anotations
	end

% -----------------------------------------------------------------------------------------------------
% ----------------------------- See if we have to do a screen capture to 3 RGB grids-------------------
	if (~isempty(nameRGB) && ~haveAlfa)
        mirone('File_img2GMT_RGBgrids_CB', handMir, 'image', nameRGB)
	elseif (~isempty(nameRGB) && haveAlfa)
		% Here we'll hide everything except the patches with transparency
		ALLlineHand = findobj(get(handMir.axes1,'Child'),'Type','line');
		ALLpatchHand = findobj(get(handMir.axes1,'Child'),'Type','patch');
		ALLtextHand = findobj(get(handMir.axes1,'Child'),'Type','text');
		set(ALLlineHand, 'Vis', 'off');		set(ALLpatchHand, 'Vis', 'off');	set(ALLtextHand, 'Vis', 'off')
		set(hAlfaPatch, 'Vis', 'on')					% Only semi-transparent ones are visible now
		try
			refresh(handMir.figure1)		% F... Matlab OpenGL driver has more bugs than a dead rat
			if (isempty(ALLlineHand) && isempty(ALLpatchHand) && isempty(ALLtextHand))	% No need to SC because image is clean
	        	mirone('File_img2GMT_RGBgrids_CB', handMir, 'image', nameRGB)
			else
				mirone('File_img2GMT_RGBgrids_CB', handMir, 'fromWS', nameRGB)
			end
		end
		% Make everybody visible again
		set(ALLlineHand, 'Vis', 'on');		set(ALLpatchHand, 'Vis', 'on');	set(ALLtextHand, 'Vis', 'on')
	end

% -----------------------------------------------------------------------------------------------------
% -------------------------------------------- Write the script ---------------------------------------
	% First do some eventual cleaning
	if (~isempty(handMir.grdname) && ~used_grd),         script(id_grd) = [];        end;
	if (strncmp(computer,'PC',2) && (used_grd || used_countries) && need_path && ~strcmp(sc,'bat'))
		tmp = cell(7,1);
		tmp{1} = [comm 'If you see this message is because you choosed to generate a c-shell'];
		tmp{2} = [comm 'script in a windows running machine. Notice that I have no means to'];
		tmp{3} = [comm 'guess on what imullation schema (e.g. SFU, cygwin, etc..) you intend'];
		tmp{4} = [comm 'to run this script. The point is that they use different file names'];
		tmp{5} = [comm 'mapping. While cygwin accepts the c:\somewhere\somefile, SFU wants'];
		tmp{6} = [comm '/dev/fs/C/somewhere/somefile. So it''s your responsability to set'];
		if (used_grd && ~used_countries)
			tmp{7} = [comm 'the $grd variable with the correct path.'];
		elseif (~used_grd && used_countries)
			tmp{7} = [comm 'the paths correctly in the "country_select" command line.'];
		else			% Both cases
			tmp{7} = [comm 'the $grd variable with the correct path. And the same'];
			tmp{9} = [comm 'for the paths in the "country_select" command line.'];
		end
		tmp{end+1} = '';
		script = [script(1:4); tmp; script(5:end)];
		out_msg = 1;
	end
	
	if (strcmp(sc,'bat'))
		fid = fopen([prefix_ddir '_mir.' sc],'wt');
	else
		fid = fopen([prefix_ddir '_mir.' sc],'wb');		% This way scripts are directly executable
	end
	
	for i = 1:length(script)-1
		fprintf(fid,'%s\n',script{i});
	end
	if (strcmp(sc,'bat')),  cut = 11;
	else                    cut = 10;    end
	last = [script{i+1}(1:end-cut) ' >> ' pb 'ps' pf];    % Remove the last '-K'
	fprintf(fid,'%s\n',last);
	fclose(fid);

% ----------------------------------------------------------------------------------
function symbol = get_symbols(hand)
	xx = get(hand,'XData');     yy = get(hand,'YData');
	if (~iscell(xx))
		xx = num2cell(xx,1);   yy = num2cell(yy,1);   % Make it a cell for reducing the head-hakes
	end
	symbol.x = xx(:);       symbol.y = yy(:);
	symbol.Marker = get(hand,'Marker');
	zz = get(hand,'MarkerSize');
	if (~iscell(zz)),   symbol.Size = num2cell(zz,1);
	else				symbol.Size = zz;
	end
	zz = get(hand,'MarkerFaceColor');
	if (~iscell(zz)),	symbol.FillColor = num2cell(zz(:),1);
	else				symbol.FillColor = zz;
	end
	zz = get(hand,'MarkerEdgeColor');
	if (~iscell(zz)),	symbol.EdgeColor = num2cell(zz(:),1);
	else				symbol.EdgeColor = zz;
	end

	symbol.Marker = char(symbol.Marker);
	symbol.Marker = symbol.Marker(:,1);

	symbol.Marker(symbol.Marker == '^') = 't';
	symbol.Marker(symbol.Marker == '>') = 't';      % not in GMT
	symbol.Marker(symbol.Marker == '<') = 't';      % not in GMT
	symbol.Marker(symbol.Marker == 'v') = 'i';
	symbol.Marker(symbol.Marker == '.') = 'p';
	symbol.Marker(symbol.Marker == 'd') = 'd';
	symbol.Marker(symbol.Marker == 'o') = 'c';
	symbol.Marker(symbol.Marker == '+') = 'x';      % not in GMT
	symbol.Marker(symbol.Marker == 'x') = 'x';
	symbol.Marker(symbol.Marker == 's') = 's';
	symbol.Marker(symbol.Marker == '*') = 'a';
	symbol.Marker(symbol.Marker == 'p') = 'a';      % not in GMT
	symbol.Marker(symbol.Marker == 'h') = 'a';      % not in GMT

% ----------------------------------------------------------------------------------
function [LineStyle_num,LineStyle_gmt] = lineStyle2num(LineStyle)
	if (~iscell(LineStyle)),    LineStyle = {LineStyle};    end
	lt = {'-'; '--'; ':'; '-.'};
	LineStyle_num = strrep(LineStyle,lt{4},'4');
	LineStyle_num = strrep(LineStyle_num,lt{3},'3');
	LineStyle_num = strrep(LineStyle_num,lt{2},'2');
	LineStyle_num = strrep(LineStyle_num,lt{1},'1');
	tmp = LineStyle_num;
	LineStyle_num = str2num(cat(1,LineStyle_num{:}));
	% Convert to GMT linestyles
	tmp = strrep(tmp,'4',',.-');
	tmp = strrep(tmp,'3',',.');
	tmp = strrep(tmp,'2',',-');
	LineStyle_gmt = strrep(tmp,'1','');

% --------------------------------------------------------------------
function script = write_group_symb(prefix,prefix_ddir,comm,pb,pf,ellips,symbols,n,script)
% Write a group symbol to file, and uppdate the "script"
	l = numel(script) + 1;
	for (i = 1:numel(n))
		name = sprintf('%s_symb_%d.dat', prefix_ddir, i);
		name_sc = sprintf('%s_symb_%d.dat', prefix, i);
		fid = fopen(name,'wt');
		fc = symbols.FillColor{n(i)};		ec = symbols.EdgeColor{n(i)};
		if (ischar(fc)),	opt_G = '';
		else				opt_G = sprintf(' -G%d/%d/%d', round(fc * 255));
		end
		if (ischar(ec))
			if (strcmp(ec, 'none')),	opt_W = '';
			else						opt_W = ' -W1p';		% 'auto'. WRONG. Should be line's 'Color' property
			end
		else
			opt_W = sprintf(' -W1p,%d/%d/%d', round(ec * 255));
		end
		fprintf(fid,'%.5f\t%.5f\n',[symbols.x{n(i)}; symbols.y{n(i)}]);
		script{l} = ' ';					l=l+1;
		script{l} = [comm 'Plot symbols'];	l=l+1;
		script{l} = ['psxy ' name_sc ' -S' symbols.Marker(n(i)) num2str(symbols.Size{n(i)}) 'p' opt_G ...
                opt_W ellips ' -R -J -O -K >> ' pb 'ps' pf];    l=l+1;
		fclose(fid);
	end

% --------------------------------------------------------------------------------
function [ALLpatchHand, hAlfaPatch] = findTransparents(ALLpatchHand)
% Find patches which have a level of transparency > 0.05
	ind = false(1,numel(ALLpatchHand));
	for (k = 1:numel(ALLpatchHand))
		if (get(ALLpatchHand(k),'FaceAlpha') < 0.95)		% Patch has transparency
			ind(k) = true;
		end
	end
	hAlfaPatch = ALLpatchHand(ind);			% Split the transparent and non-transparent
	ALLpatchHand(ind) = [];

% --------------------------------------------------------------------------------
function [latcells,loncells] = polysplit(lat,lon)
%POLYSPLIT Extract segments of NaN-delimited polygon vectors to cell arrays
%
%   [LATCELLS,LONCELLS] = POLYSPLIT(LAT,LON) returns the NaN-delimited
%   segments of the vectors LAT and LON as N-by-1 cell arrays with one
%   polygon segment per cell.  LAT and LON must be the same size and have
%   identically-placed NaNs.  The polygon segments are column vectors if
%   LAT and LON are column vectors, and row vectors otherwise.

% Copyright 1996-2006 The MathWorks, Inc.
% $Revision: 1.4.4.5 $    $Date: 2006/05/24 03:35:26 $

% checkinput(lat,{'numeric'},{'real','vector'},mfilename,'LAT',1);
% checkinput(lon,{'numeric'},{'real','vector'},mfilename,'LON',2);
[lat, lon] = removeExtraNanSeparators(lat, lon);

% Find NaN locations.
indx = find(isnan(lat(:)));

% Simulate the trailing NaN if it's missing.
if ~isempty(lat) && ~isnan(lat(end))
    indx(end+1,1) = numel(lat) + 1;
end

%  Extract each segment into pre-allocated N-by-1 cell arrays, where N is
%  the number of polygon segments.  (Add a leading zero to the indx array
%  to make indexing work for the first segment.)
N = numel(indx);
latcells = cell(N,1);
loncells = cell(N,1);
indx = [0; indx];
for k = 1:N
	iStart = indx(k)   + 1;
	iEnd   = indx(k+1) - 1;
	latcells{k} = lat(iStart:iEnd);
	loncells{k} = lon(iStart:iEnd);
end

% --------------------------------------------------------------------------------
function [xdata, ydata, zdata] = removeExtraNanSeparators(xdata, ydata, zdata)
%removeExtraNanSeparators  Clean up NaN separators in polygons and lines
%
%   [XDATA, YDATA] = removeExtraNanSeparators(XDATA, YDATA) removes NaNs
%   from the vectors XDATA and YDATA, leaving only isolated NaN separators.
%   If present, one or more leading NaNs are removed entirely.  If present,
%   a single trailing NaN is preserved.  NaNs are removed, but never added,
%   so if the input lacks a trailing NaN, so will the output.  XDATA and
%   YDATA must match in size and have identical NaN locations.
%
%   [XDATA, YDATA, ZDATA] = removeExtraNanSeparators(XDATA, YDATA, ZDATA)
%   removes NaNs from the vectors XDATA, YDATA, and ZDATA, leaving only
%   isolated NaN separators and optionally, consistent with the input, a
%   single trailing NaN.
%
%   Examples
%   --------
%   xin = [NaN NaN 1:3 NaN 4:5 NaN NaN NaN 6:9 NaN NaN]
%   yin = xin;
%   [xout, yout] = removeExtraNanSeparators(xin, yin);
%   xout
%
%   xin = [NaN 1:3 NaN NaN 4:5 NaN NaN NaN 6:9]'
%   yin = xin;
%   zin = xin;
%   [xout, yout, zout] = removeExtraNanSeparators(xin, yin, zin);
%   xout

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2006/06/15 20:11:13 $

% if nargin < 3
%     if ~isequal(isnan(xdata), isnan(ydata))
%         eid = sprintf('%s:%s:inconsistentXY', getcomp, mfilename);
%         error(eid,'XDATA and YDATA mismatch in size or NaN locations.')
%     end
% else
%     if ~isequal(isnan(xdata), isnan(ydata), isnan(zdata))
%         eid = sprintf('%s:%s:inconsistentXYZ', getcomp, mfilename);
%         error(eid,'XDATA, YDATA (or ZDATA) mismatch in size or NaN locations.')
%     end
% end

p = find(isnan(xdata(:)'));     % Determing the positions of each NaN.

% Determine the position of each NaN that is not the final element in a sequence of contiguous NaNs.
q = p(diff(p) == 1);

% If there's a leading sequence of NaNs (a sequence starting with a NaN in
% position 1), determine the position of each NaN in this sequence.
if isempty(p),      r = [];
else                r = find((p - (1:numel(p))) == 0);
end

% Determine the position of each excess NaN.
if isempty(r),      s = q;
else                s = [r q(q > r(end))];
end

% Remove the excess NaNs.
xdata(s) = [];      ydata(s) = [];
if (nargin >= 3),   zdata(s) = [];  end

%-------------------------------------------------------------------------------------
function figure1_KeyPressFcn(hObject, eventdata)
	if isequal(get(hObject,'CurrentKey'),'escape')
		delete(hObject);
	end

% ---------------------- Creates and returns a handle to the GUI figure. 
function write_gmt_script_LayoutFcn(h1)

set(h1,...
'Color',get(0,'factoryUicontrolBackgroundColor'),...
'KeyPressFcn',@figure1_KeyPressFcn,...
'MenuBar','none',...
'Name','write_gmt_script',...
'NumberTitle','off',...
'Position',[520 340 561 460],...
'DoubleBuffer','on',...
'Resize','off',...
'HandleVisibility','Call',...
'Tag','figure1');

uicontrol('Parent',h1,'Position',[30 9 205 121],'Style','frame');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',@main_uiCB,...
'Position',[40 98 181 22],...
'String','A4 595 842',...
'Style','popupmenu',...
'Value',1,...
'Tag','popup_PaperSize');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[40 42 71 15],...
'String','Portrait',...
'Style','radiobutton',...
'Value',1,...
'Tag','radio_P');

axes('Parent',h1,...
'Units','pixels',...
'CameraPosition',[0.5 0.5 9.16025403784439],...
'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
'Color',get(0,'defaultaxesColor'),...
'ColorOrder',get(0,'defaultaxesColorOrder'),...
'Position',[30 169 281 281],...
'XColor',get(0,'defaultaxesXColor'),...
'YColor',get(0,'defaultaxesYColor'),...
'Tag','axes1');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[40 18 85 15],...
'String','Landscape',...
'Style','radiobutton',...
'Tag','radio_L');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[135 42 100 15],...
'String','Set map width',...
'Style','radiobutton',...
'Tooltip','Check this to force Map width = rectangle width',...
'Value',1,...
'Tag','radio_setWidth');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[135 18 105 15],...
'String','Set map height',...
'Style','radiobutton',...
'Tooltip','Check this to force Map height = rectangle height',...
'Tag','radio_setHeight');

uicontrol('Parent',h1, ...
'Call',@main_uiCB,...
'Position',[340 150 95 15],...
'String','[-180 180]', 'Style','radiobutton',...
'Tooltip','Plot longitudes in the [-180;180] range',...
'Value',1,...
'Tag','radio_180_180');

uicontrol('Parent',h1, ...
'Call',@main_uiCB,...
'Position',[340 130 95 15],...
'String','[0 360]', 'Style','radiobutton',...
'Tooltip','Plot longitudes in the [0;360] range',...
'Tag','radio_0_360');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[340 60 68 33],...
'String','Update', 'FontWeight','bold',...
'Tooltip','Update the rectangle size to allowed dimensions according to projection and side constraints',...
'Tag','push_uppdate');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',@main_uiCB,...
'Position',[480 89 61 21],...
'String','2.5',...
'Style','edit',...
'Tooltip','Plot X origin',...
'Tag','edit_X0');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',@main_uiCB,...
'Position',[480 59 61 21],...
'String','2.5',...
'Style','edit',...
'Tooltip','Plot Y origin',...
'Tag','edit_Y0');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',@main_uiCB,...
'Position',[480 149 60 21],...
'Style','edit',...
'Tooltip','Map width',...
'Tag','edit_mapWidth');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[400 367 95 21],...
'String','Map projection',...
'Tooltip','Select/Change the map projection',...
'Tag','push_mapProjections');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[40 75 40 15],...
'String','cm',...
'Style','radiobutton',...
'Tooltip','Show paper size in centimeters',...
'Value',1,...
'Tag','radio_cm');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[116 75 40 15],...
'String','in',...
'Style','radiobutton',...
'Tooltip','Show paper size in inches',...
'Tag','radio_in');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[179 75 40 15],...
'String','pt',...
'Style','radiobutton',...
'Tooltip','Show paper size in points',...
'Tag','radio_pt');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'FontSize',9,...
'FontWeight','bold',...
'Position',[460 8 82 21],...
'String','Write script',...
'Tag','push_OK');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',@main_uiCB,...
'Position',[480 119 60 21],...
'Style','edit',...
'Tooltip','Map height',...
'Tag','edit_mapHeight');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',@main_uiCB,...
'Position',[410 179 131 21],...
'Style','edit',...
'Tooltip','Aproximate map scale',...
'Tag','edit_scale');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',@main_uiCB,...
'Position',[330 240 191 22],...
'Style','popupmenu',...
'Tooltip','Save script and files in this directory',...
'Value',1,...
'Tag','popup_directory_list');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Position',[430 209 111 21],...
'Style','edit',...
'Tooltip','Script and files name prefix',...
'Tag','edit_prefix');

uicontrol('Parent',h1,'HorizontalAlignment','left','Position',[426 152 51 15],...
'String','Map width','Style','text');

uicontrol('Parent',h1,'HorizontalAlignment','left','Position',[426 122 53 15],...
'String','Map height','Style','text');

uicontrol('Parent',h1,'HorizontalAlignment','left','Position',[426 92 41 15],...
'String','X origin','Style','text');

uicontrol('Parent',h1,'HorizontalAlignment','left','Position',[426 62 41 15],...
'String','Y origin','Style','text');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'FontWeight','bold','Position',[520 241 21 21],...
'String','...',...
'Tag','push_change_dir');

uicontrol('Parent',h1,'Position',[120 9 3 51],'Style','frame','Tag','frame2');

uicontrol('Parent',h1,'HorizontalAlignment','left','Position',[369 212 58 15],...
'String','Name prefix','Style','text','Tag','text6');

uicontrol('Parent',h1,'HorizontalAlignment','left','Position',[331 182 76 15],...
'String','Map scale (apr)','Style','text','Tag','text8');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[260 95 66 34],...
'Style','togglebutton',...
'Tooltip','Call a window to draw a map scale bar',...
'SelectionHighlight','off',...
'Tag','toggle_Option_L');

uicontrol('Parent',h1,'Enable','inactive','HorizontalAlignment','left',...
'Position',[269 100 48 27],...
'String',{'    Map'; 'scale bar'},...
'Style','text',...
'Tag','text_MapScale');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[260 26 66 34],...
'Style','togglebutton',...
'Tooltip','Call a window to draw a Time Stamp',...
'SelectionHighlight','off',...
'Tag','toggle_Option_U');

uicontrol('Parent',h1,'Enable','inactive','HorizontalAlignment','left',...
'Position',[265 30 57 28],'String',{'Time Stamp'; '& signature' },...
'Style','text');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[265 30 66 15],...
'String','Remove',...
'Style','checkbox',...
'Tooltip','Remove the scale bar',...
'Tag','check_removeOptionL',...
'Vis','off');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[260 10 66 15],...
'String','Remove',...
'Style','checkbox',...
'Tooltip','Remove the Time Stamp',...
'Tag','check_removeOptionU',...
'Vis','off');

uicontrol('Parent',h1,...
'Call',@main_uiCB,...
'Position',[360 408 181 23],...
'String','Apply finer control to coast lines',...
'Tag','push_coastLines');

uicontrol('Parent',h1,...
'HorizontalAlignment','left',...
'Position',[340 281 201 71],...
'String','Nikles',...
'Style','text',...
'Tag','text_ProjDescription');

function main_uiCB(hObject, eventdata)
% This function is executed by the callback and than the handles is allways updated.
	feval([get(hObject,'Tag') '_CB'],hObject, guidata(hObject));
