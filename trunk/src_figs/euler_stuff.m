function varargout = euler_stuff(varargin)
% varargin   command line arguments to euler_stuff (see VARARGIN) 

%	Copyright (c) 2004-2010 by J. Luis
%
%	This program is free software; you can redistribute it and/or modify
%	it under the terms of the GNU General Public License as published by
%	the Free Software Foundation; version 2 of the License.
%
%	This program is distributed in the hope that it will be useful,
%	but WITHOUT ANY WARRANTY; without even the implied warranty of
%	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%	GNU General Public License for more details.
%
%	Contact info: w3.ualg.pt/~jluis/mirone
% --------------------------------------------------------------------

	if (isempty(varargin))
		errordlg('EULER_STUFF: wrong number of input arguments.','Error'),	return
	end

	hObject = figure('Tag','figure1','Visible','off');
	euler_stuff_LayoutFcn(hObject);
	handles = guihandles(hObject);
	move2side(hObject,'left');

	handles.h_line_orig = [];
	handles.hLineSelected = [];
	handles.p_lon = [];
	handles.p_lat = [];
	handles.p_omega = [];
	handles.edit_pole1Lon = [];
	handles.edit_pole1Lat = [];
	handles.edit_pole1Ang = [];
	handles.edit_pole2Lon = [];
	handles.edit_pole2Lat = [];
	handles.edit_pole2Ang = [];
	handles.ages = [];
	handles.do_interp = 0;          % Used to decide which 'compute' function to use
	handles.finite_poles = [];      % Used to store a collection of finite poles (issued by choosebox)

	handles.hCallingFig = varargin{1};
	handles.mironeAxes = get(varargin{1},'CurrentAxes');
	if (length(varargin) == 2)          % Called with the line handle in argument
		c = get(varargin{2},'Color');
		t = get(varargin{2},'LineWidth');
		h = copyobj(varargin{2},handles.mironeAxes);
		rmappdata(h,'polygon_data')     % Remove the parent's ui_edit_polygon appdata
		ui_edit_polygon(h)              % And set a new one
		set(h,'LineWidth',t+1,'Color',1-c)
		uistack_j(h,'bottom')
		handles.h_line_orig = h;
		handles.hLineSelected = varargin{2};
		set(handles.text_activeLine,'String','GOT A LINE TO WORK WITH','ForegroundColor',[0 0.8 0])
	end

	% Get the Mirone handles. We need it here
	handlesMir = guidata(handles.hCallingFig);
	handles.geog = handlesMir.geog;
	if (handlesMir.no_file)
		errordlg('You didn''t even load a file. What are you expecting then?','Error')
		delete(hObject);    return
	end
	if (~handles.geog)
		errordlg('This tool works only with geographical type data','Error')
		delete(hObject);    return
	end

	plugedWin = getappdata(handles.hCallingFig,'dependentFigs');
	plugedWin = [plugedWin hObject];		% Add this figure handle to the carra?as list
	setappdata(handles.hCallingFig,'dependentFigs',plugedWin);

	handles.path_data = handlesMir.path_data;
	handles.path_continent = [handlesMir.home_dir filesep 'continents' filesep];
	handles.geog = handlesMir.geog;
	handles.last_dir = handlesMir.last_dir;
	handles.work_dir = handlesMir.work_dir;
	handles.home_dir = handlesMir.home_dir;

% This is the tag that all tab push buttons share.  If you have multiple
% sets of tab push buttons, each group should have unique tag.
group_name = 'tab_group';

% This is a list of the UserData values used to link tab push buttons and
% the components on their linked panels.  To add a new tab panel to the group
%  Add the button using GUIDE
%  Assign the Tag based on the group name - in this case tab_group
%  Give the UserData a unique name - e.g. another_tab_panel
%  Add components to GUIDE for the new panel
%  Give the new components the same UserData as teh tab button
%  Add the new UserData name to the below cell array
panel_names = {'DoRotations','AddPoles','InterpPoles'};

% tabpanelfcn('makegroups',...) adds new fields to the handles structure,
% one for each panel name and another called 'group_name_all'.  These fields
% are used by the tabpanefcn when tab_group_handler is called.
handles = tabpanelfcn('make_groups',group_name, panel_names, handles, 1);

guidata(hObject, handles);
set(hObject,'Visible','on');
if (nargout),	varargout{1} = hObject;		end

% -------------------------------------------------------------------------------------
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over tab_group.
function tab_group_ButtonDownFcn(hObject, handles)
% Call the tab_group_handler.  This updates visiblity of components as needed to
% hide the components from the previous tab and show components on this tab.
% This also updates the last_tab field in the handles structure to keep track
% of which panel was hidden.
handles = tabpanelfcn('tab_group_handler',hObject, handles, get(hObject, 'Tag'));
% Since this tab uses mostly existing uis, just make the visible here
if (strcmp(get(hObject,'UserData'),'InterpPoles'))
	set(handles.h_Stg_txt,'Visible','on','String','Finite rotation poles file')
	set(handles.edit_polesFile,'Visible','on')
	set(handles.push_readPolesFile,'Visible','on')
	set(handles.txt_AgeF,'Visible','on')
	set(handles.edit_agesFile,'Visible','on')
	set(handles.push_ReadAgesFile,'Visible','on')
	set(handles.listbox_ages,'Visible','on')
	set(handles.push_polesList,'Visible','on')
	set(handles.push_compute,'Visible','on')
	handles.do_interp = 1;			% Redirect the 'compute' function
else
	handles.do_interp = 0;
	set(handles.h_Stg_txt,'String','Stage poles file')
end
guidata(hObject, handles);

% -------------------------------------------------------------------------------------
function edit_polesFile_CB(hObject, handles)
	fname = get(hObject,'String');
	if isempty(fname),		return;    end
	% Let the push_readPolesFile_CB do all the work
	push_readPolesFile_CB(hObject,guidata(gcbo),fname)

% -------------------------------------------------------------------------------------
function push_readPolesFile_CB(hObject, handles, opt)
% Get poles file name
	if (nargin == 3),	fname = opt;
	else				opt = [];
	end

	if (isempty(opt))           % Otherwise we already know fname from the 4th input argument
		str1 = {'*.stg;*.dat;*.DAT', 'Data files (*.stg,*.dat,*.DAT)';'*.*', 'All Files (*.*)'};
		[FileName,PathName] = put_or_get_file(handles,str1,'Select poles file','get');
		if isequal(FileName,0),		return,		end
		fname = [PathName FileName];
	end
	set(handles.edit_polesFile,'String',fname)

% -------------------------------------------------------------------------------------
function edit_agesFile_CB(hObject, handles)
	fname = get(hObject,'String');
	if isempty(fname),	return;    end
	id = strfind(fname,':');
	if (~isempty(id))
		handles.ages = eval(fname);
		set(handles.listbox_ages,'String',mat2cell(handles.ages',length(handles.ages),1))
		guidata(hObject, handles);
	else				% Let the push_ReadAgesFile_CB do all the work
		push_ReadAgesFile_CB(hObject,guidata(gcbo),fname)
	end

% -------------------------------------------------------------------------------------
function push_ReadAgesFile_CB(hObject, handles, opt)
% Read a file with ages where to compute the rotations
if (nargin == 3),	fname = opt;
else				opt = [];
end

if (isempty(opt))           % Otherwise we already know fname from the 4th input argument
	str1 = {'*.dat;*.DAT', 'Data files (*.dat,*.DAT)';'*.*', 'All Files (*.*)'};
	[FileName,PathName] = put_or_get_file(handles,str1,'Select ages file','get');
	if isequal(FileName,0),		return;    end
	fname = [PathName,FileName];
end

hFig = gcf;
[bin,n_column,multi_seg,n_headers] = guess_file(fname);
% If msgbox exist we have to move it from behind the main window. So get it's handle
hMsgFig = gcf;
if (hFig ~= hMsgFig)        uistack(hMsgFig,'top');   end   % If msgbox exists, bring it forward
% If error in reading file
if isempty(bin) && isempty(n_column) && isempty(multi_seg) && isempty(n_headers)
    errordlg(['Error reading file ' fname],'Error');    return
end
if (multi_seg ~= 0)   % multisegments are not spported
    errordlg('Multisegment files are not supported here.','Error');   return
end
if (bin == 0)   % ASCII
    fid = fopen(fname);
    todos = fread(fid,'*char');
    if (n_column == 1)
        handles.ages = strread(todos,'%f');
        handles.age_label = '';
    elseif (n_column == 2)
        [handles.ages handles.age_label] = strread(todos,'%f %s');
    else
        errordlg('Ages file can only have one OR two columns (IF 2 column: first column contains chron name)','Error')
        return
    end
    fclose(fid);
else        % BINARY
    errordlg('Sorry, binary files is not yet suported','Error');   return
end

if (~isempty(handles.age_label))    % We have labeled ages
    s1 = num2str(handles.ages);
    str = cell(size(handles.ages,1),1);
    for (k=1:size(handles.ages,1))
        str{k} = [handles.age_label{k} '    ' s1(k,1:end)];
    end
else
    str = {num2str(handles.ages)};
end
set(handles.listbox_ages,'String',str)

set(handles.edit_agesFile,'String',fname)
guidata(hObject, handles);

% -------------------------------------------------------------------------------------
function push_compute_CB(hObject, handles)

	if (handles.do_interp == 1)     % Compute interpolated poles instead
		cumpute_interp(handles),	return
	end

	if (isempty(handles.h_line_orig))
		errordlg('Will you be so kind to let me know what line/point should I rotate?','Unknown target')
		return
	end

	if (get(handles.check_singleRotation,'Value'))
		% Do the rotation using the pole parameters entered in the GUI and return
		if (isempty(handles.p_lon) || isempty(handles.p_lat) || isempty(handles.p_omega))
			return
		end
		do_geocentric = true;
		if (get(handles.check_geodetic, 'Val'))		do_geocentric = false;		end
		for (i=1:numel(handles.h_line_orig))
			lon = get(handles.h_line_orig(i),'XData');
			lat = get(handles.h_line_orig(i),'YData');
			if (do_geocentric)
				[rlon,rlat] = rot_euler(lon,lat,handles.p_lon,handles.p_lat,handles.p_omega, -1);
			else							% Use geodetic lats
				[rlon,rlat] = rot_euler(lon,lat,handles.p_lon,handles.p_lat,handles.p_omega);
			end
			if (handles.geog == 2)
				ind = (rlon < 0);
				rlon(ind) = rlon(ind) + 360;
			end
			if (length(rlon) == 1)			% Single point rotation
				smb = get(handles.hLineSelected(i),'Marker');
				smb_fc = get(handles.hLineSelected(i),'MarkerFaceColor');
				smb_ec = get(handles.hLineSelected(i),'MarkerEdgeColor');
				smb_s = get(handles.hLineSelected(i),'MarkerSize');
				smb_t = get(handles.hLineSelected(i),'Linewidth');
				set(handles.h_line_orig(i),'XData',rlon,'YData',rlat,'Marker',smb,'MarkerFaceColor',smb_fc,...
					'MarkerEdgeColor',smb_ec,'MarkerSize',smb_s,'Linewidth',smb_t,'Tag','Rotated Line','Userdata',1);
			else
				lt = get(handles.hLineSelected(i),'LineWidth');
				lc = get(handles.hLineSelected(i),'Color');
				set(handles.h_line_orig(i),'XData',rlon,'YData',rlat,'Linewidth',lt,'Color',lc,'Tag','Rotated Line','Userdata',1);
			end
			line_info = {['Ang = ' num2str(handles.p_omega)]};
			draw_funs(handles.h_line_orig(i),'isochron',line_info)
		end
		figure(handles.hCallingFig)		% Bring the Mirone figure forward
		handles.h_line_orig = [];       handles.hLineSelected = [];
		guidata(handles.figure1,handles)
		set(handles.text_activeLine,'String','NO ACTIVE LINE','ForegroundColor',[1 0 0])
		return
	end

	if (isempty(handles.ages))
		errordlg('I need to know the ages at which to compute the rotations','Error');    return
	end

	poles_name = get(handles.edit_polesFile,'String');
	if (isempty(poles_name))
		errordlg('No stage poles provided','Error');    return
	end

	figure(handles.hCallingFig)		% Bring the Mirone figure forward
	opt_E = ['-E' poles_name];
	opt_I = ' ';
	if (get(handles.check_revertRot,'Value'))
		opt_I = '-I';
	end

	for (i=1:numel(handles.h_line_orig))
		x = get(handles.h_line_orig(i),'XData');       y = get(handles.h_line_orig(i),'YData');
		linha = [x(:) y(:)];
		[out,n_data,n_seg,n_flow] = telha_m(linha, handles.ages, '-P', opt_E, opt_I);
		lt = get(handles.hLineSelected(i),'LineWidth');
		lc = get(handles.hLineSelected(i),'Color');
		if (length(linha) == 2)     % Only one point. Flow line mode
			aa = isnan(out(:,1));
			out = out(~aa,1:2);
			h_line = line('XData',out(:,1),'YData',out(:,2),'Linewidth',lt,'Color',lc,'Tag','Flow Line','Userdata',1);
			stg = get(handles.edit_polesFile,'String');
			[PATH,FNAME,EXT] = fileparts(stg);
			line_info = {['Stage file: ' FNAME EXT]};
		else
			h_line = zeros(n_flow,1);
			for (k=1:n_flow)              % For each time increment
				[x,y] = get_time_slice(out,n_data,n_seg,k);
				h_line(k) = line('XData',x,'YData',y,'Linewidth',lt,'Color',lc,'Tag','Rotated Line','Userdata',k);
			end
			line_info = get(handles.listbox_ages,'String');
		end
		draw_funs(h_line,'isochron',line_info)
	end

	set(handles.text_activeLine,'String','NO ACTIVE LINE','ForegroundColor',[1 0 0])
	delete(handles.h_line_orig)
	handles.h_line_orig = [];       handles.hLineSelected = [];
	guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
function cumpute_interp(handles)
% Compute interpolated poles.
% This function is far from optimized, but it's not supposed to be applyied to long series either

	if (isempty(handles.ages))
		errordlg('I need to know the ages at which to interpolate the poles','Error');    return
	end

	if ( strcmp(get(handles.edit_polesFile,'String'),'In memory poles') )
		poles = handles.finite_poles;
	else
		poles_name = get(handles.edit_polesFile,'String');
		if (isempty(poles_name))
			errordlg('No poles file provided','Error');    return
		end
		poles = read_poles(poles_name);
		if (isempty(poles))      return;     end         % Bad poles file
	end

	if (size(poles,2) ~= 4)
		errordlg('The poles matrix MUST have 4 columns.','Error');    return
	end
	poles = sortrows(poles,4);			% To make sure they go from youngest to oldest

	ages = handles.ages;
	n_ages = length(ages);
	pol = zeros(n_ages,4);
	n_new_finite = 0;
	id = find(ages <= poles(1,4));		% Find ages <= first pole (different case)
	if (~isempty(id))
		n_new_finite = length(id);		% Count number of interpolations of the first finite pole
		for (i = 1:n_new_finite)
			pol(i,:) = [poles(1,1:2) poles(1,3)*ages(i)/poles(1,4) ages(i)];
		end
		clear id;
	end

	id = (ages > poles(end,4));			% Find ages > last pole (they cannot be computed - no extrapolation)
	if (~isempty(id))
		ages(id) = [];					% This will only apply if we have extrapolation ages
		pol(id,:) = [];
		n_ages = length(ages);
	end

	for (i = n_new_finite+1:n_ages)
		id = find(ages(i) > poles(:,4));
		id = id(end);                   % We can only have one value and it's the last one that counts
		if (~isempty(id))
			%t0 = poles(id,4);        t1 = poles(id+1,4);
			stg = finite2stages([poles(id,:); poles(id+1,:)], 1, 0);    % Compute the stage pole between t0 & t1
			frac = (poles(id+1,4) - ages(i)) / (poles(id+1,4) - poles(id,4));
			[pol(i,1) pol(i,2) pol(i,3)] = add_poles(poles(id+1,1),poles(id+1,2),poles(id+1,3),stg(1,1),stg(1,2), frac*stg(1,5));
			pol(i,4) = ages(i);                 % Give it its age
		else
			errordlg(['Error: age = ' num2str(ages(i)) ' does not fit inside poles ages interval'],'Error')
			return
		end
	end

	% Now the interpolated poles are on the antipodes (don't know why), so revert that
	pol(n_new_finite+1:end,2:3) = -pol(n_new_finite+1:end,2:3);     % Change latitude & angle sign
	pol(n_new_finite+1:end,1) = pol(n_new_finite+1:end,1) + 180;
	id = pol(:,1) > 360;
	pol(id,1) = pol(id,1) - 360;

	[FileName,PathName] = put_or_get_file(handles, ...
		{'*.dat;*.stg', 'Data file (*.dat,*.stg)';'*.*', 'All Files (*.*)'},'Interp poles file','put','.dat');
	if isequal(FileName,0),		return,		end

	% Open and write to ASCII file
	if (ispc)			fid = fopen([PathName FileName],'wt');
	elseif (isunix)		fid = fopen([PathName FileName],'w');
	else				errordlg('Unknown platform.','Error');
	end
	fprintf(fid,'#longitude\tlatitude\tangle(deg)\tage(Ma)\n');
	fprintf(fid,'%9.5f\t%9.5f\t%7.4f\t%8.4f\n', pol');
	fclose(fid);

% --------------------------------------------------------------------
function [x,y] = get_time_slice(data,n_data,n_seg,n,first)
	i1 = (n-1)*(n_data + n_seg) + 2;
	i2 = i1 + n_data - 1 + n_seg - 1;
	x = data(i1:i2,1);    y = data(i1:i2,2);

% --------------------------------------------------------------------
function push_callMagBarCode_CB(hObject, handles)
	magbarcode([handles.path_data 'Cande_Kent_95.dat'])

% --------------------------------------------------------------------
function edit_poleLon_CB(hObject, handles)
	xx = str2double(get(hObject,'String'));
	if (isnan(xx))
		set(hObject,'String','')
		handles.p_lon = [];
	else
		handles.p_lon = xx;
	end
	guidata(hObject,handles)

% --------------------------------------------------------------------
function edit_poleLat_CB(hObject, handles)
	xx = str2double(get(hObject,'String'));
	if (isnan(xx))
		set(hObject,'String','')
		handles.p_lat = [];
	else
		handles.p_lat = xx;
	end
	guidata(hObject,handles)

% --------------------------------------------------------------------
function edit_poleAngle_CB(hObject, handles)
	xx = str2double(get(hObject,'String'));
	if (isnan(xx))
		set(hObject,'String','')
		handles.p_omega = [];
	else
		handles.p_omega = xx;
	end
	guidata(hObject,handles)

% --------------------------------------------------------------------
function check_singleRotation_CB(hObject, handles)
	if (get(hObject,'Value'))
		set(handles.edit_poleLon,'Enable','on')
		set(handles.edit_poleLat,'Enable','on')
		set(handles.edit_poleAngle,'Enable','on')
	else
		set(handles.edit_poleLon,'Enable','off')
		set(handles.edit_poleLat,'Enable','off')
		set(handles.edit_poleAngle,'Enable','off')
	end

% --------------------------------------------------------------------
function push_polesList_CB(hObject, handles)
fid = fopen([handles.path_continent 'lista_polos.dat'],'rt');
c = fread(fid,'*char').';
fclose(fid);
s = strread(c,'%s','delimiter','\n');

multiple_str = 'multiple_finite';
if (handles.do_interp)      multiple_val = 1;
else                        multiple_val = 0;
end

[s,v] = choosebox('Name','One Euler list',...
                    'PromptString','List of poles:',...
                    'SelectString','Selected poles:',...
                    'ListSize',[380 300],...
                    multiple_str,multiple_val,...
                    'ListString',s);

if (v == 1)         % Finite pole (one only)
    handles.p_lon = s(1);
    handles.p_lat = s(2);
    handles.p_omega = s(3);
    set(handles.edit_poleLon, 'String', num2str(s(1)))
    set(handles.edit_poleLat, 'String', num2str(s(2)))
    set(handles.edit_poleAngle, 'String', num2str(s(3)))
    guidata(hObject,handles)
elseif (v == 2)     % Stage poles
    set(handles.edit_polesFile,'String',s)
elseif (v == 3)     % Multiple finite poles (with ages)
    set(handles.edit_polesFile,'String','In memory poles')
    handles.finite_poles = s;
    guidata(hObject,handles)
end

% -----------------------------------------------------------------------------------
function tab_group_CB(hObject, handles)

% -----------------------------------------------------------------------------------
function push_pickLine_CB(hObject, handles)
    % Test if we have potential target lines and their type
    h_mir_lines = findobj(handles.hCallingFig,'Type','line');     % Fish all objects of type line in Mirone figure
    if (isempty(h_mir_lines))                                       % We don't have any lines
        str = ['If you hited this button on purpose, than you deserve the following insult.',...
                'You #!|"*!%!?~^)--$&.',... 
                'THERE ARE NO LINES IN THAT FIGURE.'];
        errordlg(str,'Chico Clever');     return;
    end
    
    set(handles.hCallingFig,'pointer','crosshair')
    h_line = get_polygon(handles.hCallingFig,'multi');        % Get the line handle
	if (numel(h_line) > 1)
		h_line = unique(h_line);
	end
    tf = ismember(h_line,handles.hLineSelected);        % Check that the line was not already selected
    if (tf)     % Repeated line
        set(handles.hCallingFig,'pointer','arrow');   figure(handles.figure1);   return;
    end
    for (k = 1:numel(h_line))
        c = get(h_line(k),'Color');
        t = get(h_line(k),'LineWidth');
        h = copyobj(h_line(k),handles.mironeAxes);
        rmappdata(h,'polygon_data')     % Remove the parent's ui_edit_polygon appdata
        ui_edit_polygon(h)              % And set a new one
        set(h,'LineWidth',t+2,'Color',1-c)
        uistack_j(h,'bottom')
        handles.h_line_orig = [handles.h_line_orig; h];
        % Make a copy of the selected handles to be used in props recovering
        handles.hLineSelected = [handles.hLineSelected; h_line(k)];
    end
    set(handles.hCallingFig,'pointer','arrow')
    figure(handles.figure1)                 % Bring this figure to front again

	nl = numel(handles.h_line_orig);
	if (nl)
        set(handles.text_activeLine,'String',['GOT ' num2str(nl) ' LINE(S) TO WORK WITH'],'ForegroundColor',[0 0.8 0])
	else
        set(handles.text_activeLine,'String','NO ACTIVE LINE','ForegroundColor',[1 0 0])
	end
	guidata(hObject, handles);

% -----------------------------------------------------------------------------------
function push_rectSelect_CB(hObject, handles)
    % Test if we have potential target lines and their type
    h_mir_lines = findobj(handles.hCallingFig,'Type','line');     % Fish all objects of type line in Mirone figure
    if (isempty(h_mir_lines)),      return;     end                 % We don't have any lines
    figure(handles.hCallingFig)
    [p1,p2,hl] = rubberbandbox;
    delete(hl)
    figure(handles.figure1)         % Bring this figure fowrward again
    h = zeros(numel(h_mir_lines),1);
    hc = h;
    for (i=1:numel(h_mir_lines))    % Loop over lines to find out which cross the rectangle
        x = get(h_mir_lines(i),'XData');
        y = get(h_mir_lines(i),'YData');
        if ( any( (x >= p1(1) & x <= p2(1)) & (y >= p1(2) & y <= p2(2)) ) )
            tf = ismember(h_mir_lines(i),handles.hLineSelected);    % Check that the line was not already selected
            if (tf),    continue;     end                           % Repeated line
            c = get(h_mir_lines(i),'Color');
            t = get(h_mir_lines(i),'LineWidth');
            h(i) = copyobj(h_mir_lines(i),handles.mironeAxes);
            rmappdata(h(i),'polygon_data')     % Remove the parent's ui_edit_polygon appdata
            ui_edit_polygon(h(i))              % And set a new one
            set(h(i),'LineWidth',t+2,'Color',1-c)
            uistack_j(h(i),'bottom')
            hc(i) = h_mir_lines(i);         % Make a copy of the selected handles to be used in props recovering
        end
    end
    h(h == 0) = [];     hc(hc == 0) = [];
    if (~isempty(h))
        handles.h_line_orig = [handles.h_line_orig; h];        % This is a bad name
        handles.hLineSelected = [handles.hLineSelected; hc];
        guidata(handles.figure1,handles)
    end
    set(handles.text_activeLine,'String',['GOT ' num2str(numel(h)) ' LINE(S) TO WORK WITH'],'ForegroundColor',[0 0.8 0])

% -----------------------------------------------------------------------------------
function edit_pole1Lon_CB(hObject, handles)
	handles.edit_pole1Lon = str2double(get(hObject,'String'));
	if (isnan(handles.edit_pole1Lon))   set(hObject,'String','');   return;     end
	guidata(hObject, handles);
	if (~got_them_all(handles))     return;     end     % Not yet all parameters of the 2 poles
	[lon_s,lat_s,ang_s] = add_poles(handles.edit_pole1Lon,handles.edit_pole1Lat,handles.edit_pole1Ang,...
		handles.edit_pole2Lon,handles.edit_pole2Lat,handles.edit_pole2Ang);
	set(handles.edit_pole3Lon,'String',num2str(lon_s,'%.4f'))
	set(handles.edit_pole3Lat,'String',num2str(lat_s,'%.4f'))
	set(handles.edit_pole3Ang,'String',num2str(ang_s,'%.4f'))

% -----------------------------------------------------------------------------------
function edit_pole1Lat_CB(hObject, handles)
	handles.edit_pole1Lat = str2double(get(hObject,'String'));
	if (isnan(handles.edit_pole1Lat))   set(hObject,'String','');   return;     end
	guidata(hObject, handles);
	if (~got_them_all(handles))     return;     end     % Not yet all parameters of the 2 poles
	[lon_s,lat_s,ang_s] = add_poles(handles.edit_pole1Lon,handles.edit_pole1Lat,handles.edit_pole1Ang,...
		handles.edit_pole2Lon,handles.edit_pole2Lat,handles.edit_pole2Ang);
	set(handles.edit_pole3Lon,'String',num2str(lon_s,'%.4f'))
	set(handles.edit_pole3Lat,'String',num2str(lat_s,'%.4f'))
	set(handles.edit_pole3Ang,'String',num2str(ang_s,'%.4f'))

% -----------------------------------------------------------------------------------
function edit_pole1Ang_CB(hObject, handles)
	handles.edit_pole1Ang = str2double(get(hObject,'String'));
	if (isnan(handles.edit_pole1Ang))   set(hObject,'String','');   return;     end
	guidata(hObject, handles);
	if (~got_them_all(handles))     return;     end     % Not yet all parameters of the 2 poles
	[lon_s,lat_s,ang_s] = add_poles(handles.edit_pole1Lon,handles.edit_pole1Lat,handles.edit_pole1Ang,...
		handles.edit_pole2Lon,handles.edit_pole2Lat,handles.edit_pole2Ang);
	set(handles.edit_pole3Lon,'String',num2str(lon_s,'%.4f'))
	set(handles.edit_pole3Lat,'String',num2str(lat_s,'%.4f'))
	set(handles.edit_pole3Ang,'String',num2str(ang_s,'%.4f'))

% -----------------------------------------------------------------------------------
function edit_pole2Lon_CB(hObject, handles)
	handles.edit_pole2Lon = str2double(get(hObject,'String'));
	if (isnan(handles.edit_pole2Lon))   set(hObject,'String','');   return;     end
	guidata(hObject, handles);
	if (~got_them_all(handles)),	return;     end     % Not yet all parameters of the 2 poles
	[lon_s,lat_s,ang_s] = add_poles(handles.edit_pole1Lon,handles.edit_pole1Lat,handles.edit_pole1Ang,...
		handles.edit_pole2Lon,handles.edit_pole2Lat,handles.edit_pole2Ang);
	set(handles.edit_pole3Lon,'String',num2str(lon_s,'%.4f'))
	set(handles.edit_pole3Lat,'String',num2str(lat_s,'%.4f'))
	set(handles.edit_pole3Ang,'String',num2str(ang_s,'%.4f'))

% -----------------------------------------------------------------------------------
function edit_pole2Lat_CB(hObject, handles)
	handles.edit_pole2Lat = str2double(get(hObject,'String'));
	if (isnan(handles.edit_pole2Lat)),	set(hObject,'String','');   return;     end
	guidata(hObject, handles);
	if (~got_them_all(handles)),	return;     end     % Not yet all parameters of the 2 poles
	[lon_s,lat_s,ang_s] = add_poles(handles.edit_pole1Lon,handles.edit_pole1Lat,handles.edit_pole1Ang,...
		handles.edit_pole2Lon,handles.edit_pole2Lat,handles.edit_pole2Ang);
	set(handles.edit_pole3Lon,'String',num2str(lon_s,'%.4f'))
	set(handles.edit_pole3Lat,'String',num2str(lat_s,'%.4f'))
	set(handles.edit_pole3Ang,'String',num2str(ang_s,'%.4f'))

% -----------------------------------------------------------------------------------
function edit_pole2Ang_CB(hObject, handles)
	handles.edit_pole2Ang = str2double(get(hObject,'String'));
	if (isnan(handles.edit_pole2Ang)),	set(hObject,'String','');   return;     end
	guidata(hObject, handles);
	if (~got_them_all(handles)),	return;     end     % Not yet all parameters of the 2 poles
	[lon_s,lat_s,ang_s] = add_poles(handles.edit_pole1Lon,handles.edit_pole1Lat,handles.edit_pole1Ang,...
		handles.edit_pole2Lon,handles.edit_pole2Lat,handles.edit_pole2Ang);
	set(handles.edit_pole3Lon,'String',num2str(lon_s,'%.4f'))
	set(handles.edit_pole3Lat,'String',num2str(lat_s,'%.4f'))
	set(handles.edit_pole3Ang,'String',num2str(ang_s,'%.4f'))

% -----------------------------------------------------------------------------------
function yeap = got_them_all(handles)
% Check if we have all the 6 parameters (2 poles x 3 params each)
% If at least one of them is empty returns YEAP = 0;

	yeap = 1;
	if ( isempty(handles.edit_pole1Lon) || isempty(handles.edit_pole1Lat) || isempty(handles.edit_pole1Ang) || ...
			isempty(handles.edit_pole2Lon) || isempty(handles.edit_pole2Lat) || isempty(handles.edit_pole2Ang) )
		yeap = 0;
	end

% -----------------------------------------------------------------------------------------
function poles = read_poles(poles_file)
% Read a poles file (with ages also) and store it in a cell array

	fid = fopen(poles_file,'r');
	c = fread(fid,'*char').';
	fclose(fid);
	s = strread(c,'%s','delimiter','\n');
	ix = strmatch('#',s);

	hdr = s(ix);
	n_hdr = length(hdr);
	n_poles = length(s)-n_hdr;
	poles = zeros(n_poles,4);
	try
		for (i = 1:n_poles)
			tmp = sscanf(s{i+n_hdr}','%f',4);
			poles(i,1:4) = tmp';
		end
	catch
		errordlg(['The file ' poles_file 'is not a properly formated Stage poles file.'],'Error');
		poles = [];
	end

% -----------------------------------------------------------------------------------
function stages = finite2stages(lon, lat, omega, t_start, half, side)
% Convert finite rotations to backwards stage rotations for backtracking
% LON, LAT, OMEGA & T_START are the finite rotation Euler pole parameters and age of pole
% Alternatively LON may be a Mx4 matrix with columns LON, LAT, OMEGA & T_START
% STAGES is a Mx5 matrix of stage pole (Euler) with the following format:
% lon(deg)  lat(deg)  tstart(Ma)  tstop(Ma)  ccw-angle(deg)
% stage records go from oldest to youngest rotation
%
% HALF = 1|2 If == 1 full angles are returned (good for plate reconstructions).
%            Else (== 2) compute half angles (good for flow lines in a single plate)
%
% NOTE: the notation is the finite pole is b_ROT_a - Where B is the fixed plate
% The signal of HALF is used to compute b_STAGE_a (default) or a_STAGE_b (if HALF < 0)
%
% SIDE = 1  -> poles in the northern hemisphere
% SIDE = -1 -> poles in the southern hemisphere
% SIDE = 0  -> report positive rotation angles
%
% Translated from C code of libspotter (Paul Wessel - GMT)
% Joaquim Luis 21-4-2005

n_args = nargin;
if (~(n_args == 1 || n_args == 3 || n_args == 6))
	error('Wrong number of arguments')
elseif (n_args == 1 || n_args == 3)
    if (n_args == 3),       half = lat;     side = omega;
    else                    half = 2;       side = 1;    % Default to half angles & North hemisphere poles
    end
    t_start = lon(:,4);     omega = lon(:,3);
    lat = lon(:,2);         lon = lon(:,1);
end

t_old = 0;
R_young = eye(3);
elon = zeros(1,length(lon));    elat = elon;    ew = elon;  t_stop = elon;
for i = 1:length(lon)
	R_old = make_rot_matrix (lon(i), lat(i), omega(i)/ abs(half));     % Get rotation matrix from pole and angle
    if (half > 0)                                           % the stages come in the reference b_STAGE_a
        R_stage = R_old * R_young;                          % This is R_stage = R_old * R_young^t
        R_stage = R_stage';
    else                                                    % the stages come in the reference a_STAGE_b
        R_stage = R_young * R_old;                          % This is R_stage = R_young^t * R_old
    end
	[elon(i) elat(i) ew(i)] = matrix_to_pole(R_stage,side); % Get rotation parameters from matrix
	if (elon(i) > 180), elon(i) = elon(i) - 360;     end    % Adjust lon
    R_young = R_old';                                       % Sets R_young = transpose (R_old) for next round
	t_stop(i) = t_old;
	t_old = t_start(i);
end

% Flip order since stages go from oldest to youngest
stages = flipud([elon(:) elat(:) t_start(:) t_stop(:) ew(:)]);

% --------------------------------------------------------
function R = make_rot_matrix (lonp, latp, w)
% lonp, latp	Euler pole in degrees
% w		angular rotation in degrees
% R		the rotation matrix

D2R = pi / 180;
[E0,E1,E2] = sph2cart(lonp*D2R,latp*D2R,1);

sin_w = sin(w * D2R);
cos_w = cos(w * D2R);
c = 1 - cos_w;

E_x = E0 * sin_w;
E_y = E1 * sin_w;
E_z = E2 * sin_w;
E_12c = E0 * E1 * c;
E_13c = E0 * E2 * c;
E_23c = E1 * E2 * c;

R(1,1) = E0 * E0 * c + cos_w;
R(1,2) = E_12c - E_z;
R(1,3) = E_13c + E_y;

R(2,1) = E_12c + E_z;
R(2,2) = E1 * E1 * c + cos_w;
R(2,3) = E_23c - E_x;

R(3,1) = E_13c - E_y;
R(3,2) = E_23c + E_x;
R(3,3) = E2 * E2 * c + cos_w;

% --------------------------------------------------------
function [plon,plat,w] = matrix_to_pole (T,side)
D2R = pi / 180;
R2D = 1 / D2R;
T13_m_T31 = T(1,3) - T(3,1);
T32_m_T23 = T(3,2) - T(2,3);
T21_m_T12 = T(2,1) - T(1,2);
H = T32_m_T23 * T32_m_T23 + T13_m_T31 * T13_m_T31;
L = sqrt (H + T21_m_T12 * T21_m_T12);
H = sqrt (H);
tr = T(1,1) + T(2,2) + T(3,3);

plon = atan2(T13_m_T31, T32_m_T23) * R2D;
%if (plon < 0)     plon = plon + 360;  end
plat = atan2(T21_m_T12, H) * R2D;
w = atan2(L, (tr - 1)) * R2D;

if ((side == 1 && plat < 0) || (side == -1 && plat > 0))
	plat = -plat;
	plon = plon + 180;
	if (plon > 360),    plon = plon - 360;  end
	w = -w;
end

% -----------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata)
	handles = guidata(hObject);
	try		delete(handles.h_line_orig),	end
	delete(findobj(handles.mironeAxes,'type','line','Tag','StarMarkers'))
	delete(handles.figure1);

% -----------------------------------------------------------------------------------
function figure1_KeyPressFcn(hObject, eventdata)
	handles = guidata(hObject);
	if isequal(get(hObject,'CurrentKey'),'escape')
		delete(handles.h_line_orig)
		delete(findobj(handles.mironeAxes,'type','line','Tag','StarMarkers'))
		delete(handles.figure1);
	end

% --- Creates and returns a handle to the GUI figure. 
function euler_stuff_LayoutFcn(h1)

set(h1,'PaperUnits',get(0,'defaultfigurePaperUnits'),...
'Color',get(0,'factoryUicontrolBackgroundColor'),...
'KeyPressFcn',@figure1_KeyPressFcn,...
'CloseRequestFcn',@figure1_CloseRequestFcn,...
'MenuBar','none',...
'Name','Euler stuff',...
'NumberTitle','off',...
'Position',[520 464 472 336],...
'Resize','off',...
'Tag','figure1');

uicontrol('Parent',h1, 'Position',[102 310 91 21],...
'Callback',{@euler_stuff_uiCB,h1,'tab_group_CB'},...
'Enable','inactive',...
'String','Add poles',...
'ButtonDownFcn',{@euler_stuff_uiCB,h1,'tab_group_ButtonDownFcn'},...
'Tag','tab_group',...
'UserData','AddPoles');

uicontrol('Parent',h1, 'Position',[10 310 91 21],...
'Callback',{@euler_stuff_uiCB,h1,'tab_group_CB'},...
'Enable','inactive',...
'String','Do Rotations',...
'ButtonDownFcn',{@euler_stuff_uiCB,h1,'tab_group_ButtonDownFcn'},...
'Tag','tab_group',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[194 310 100 21],...
'Callback',{@euler_stuff_uiCB,h1,'tab_group_CB'},...
'Enable','inactive',...
'String','Interpolate poles',...
'ButtonDownFcn',{@euler_stuff_uiCB,h1,'tab_group_ButtonDownFcn'},...
'Tag','tab_group',...
'UserData','InterpPoles');

uicontrol('Parent',h1, 'Position',[10 11 451 301],...
'Enable','inactive',...
'Tag','push_tab_bg');

uicontrol('Parent',h1, 'Position',[20 226 211 21],...
'BackgroundColor',[1 1 1],...
'Callback',{@euler_stuff_uiCB,h1,'edit_polesFile_CB'},...
'HorizontalAlignment','left',...
'Style','edit',...
'Tag','edit_polesFile',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[230 226 21 21],...
'Callback',{@euler_stuff_uiCB,h1,'push_readPolesFile_CB'},...
'FontSize',10,...
'FontWeight','bold',...
'String','...',...
'Tag','push_readPolesFile',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[20 145 211 21],...
'BackgroundColor',[1 1 1],...
'Callback',{@euler_stuff_uiCB,h1,'edit_agesFile_CB'},...
'HorizontalAlignment','left',...
'Style','edit',...
'Tag','edit_agesFile',...
'ToolTipString','Enter either a filename with ages OR a ML command like: [1:5:30]',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[230 145 21 21],...
'Callback',{@euler_stuff_uiCB,h1,'push_ReadAgesFile_CB'},...
'FontSize',10,...
'FontWeight','bold',...
'String','...',...
'Tag','push_ReadAgesFile',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[20 167 51 15],...
'String','Age file',...
'Style','text',...
'Tag','txt_AgeF',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[20 250 131 15],...
'String','Stage poles file',...
'Style','text',...
'Tag','h_Stg_txt',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[20 25 211 101],...
'BackgroundColor',[1 1 1],...
'Style','listbox',...
'Value',1,...
'Tag','listbox_ages',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[385 27 66 21],...
'Callback',{@euler_stuff_uiCB,h1,'push_compute_CB'},...
'String','Compute',...
'Tag','push_compute',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[20 204 160 15],...
'String','Revert sense of rotation',...
'Style','checkbox',...
'TooltipString','Revert the sense of rotation defined by the stages poles',...
'Tag','check_revertRot',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[20 187 96 15],...
'String','Geodetic Lats',...
'Tooltip',sprintf('Do rotations with geodetic latitudes (default is geocentric)\nWarnig: MUST BE CHECKED BEFORE PICK LINE'),...
'Style','checkbox',...
'Tag','check_geodetic',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[280 109 131 21],...
'Callback',{@euler_stuff_uiCB,h1,'push_callMagBarCode_CB'},...
'String','Magnetic Bar Code',...
'TooltipString','Open the magnetic bar code window',...
'Tag','push_callMagBarCode',...
'UserData','DoRotations');

uicontrol('Parent',h1,'BackgroundColor',[1 1 1],...
'Callback',{@euler_stuff_uiCB,h1,'edit_poleLon_CB'},...
'Enable','off',...
'Position',[280 226 51 21],...
'Style','edit',...
'TooltipString','Longitude of the Euler pole',...
'Tag','edit_poleLon',...
'UserData','DoRotations');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@euler_stuff_uiCB,h1,'edit_poleLat_CB'},...
'Enable','off',...
'Position',[340 226 51 21],...
'Style','edit',...
'TooltipString','Latitude of the Euler pole',...
'Tag','edit_poleLat',...
'UserData','DoRotations');

uicontrol('Parent',h1,'BackgroundColor',[1 1 1],...
'Callback',{@euler_stuff_uiCB,h1,'edit_poleAngle_CB'},...
'Enable','off',...
'Position',[400 226 51 21],...
'Style','edit',...
'TooltipString','Angle of rotation',...
'Tag','edit_poleAngle',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[286 251 41 15],...
'String','Lon',...
'Style','text',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[344 251 41 15],...
'String','Lat',...
'Style','text',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[404 251 41 15],...
'String','Angle',...
'Style','text',...
'UserData','DoRotations');

uicontrol('Parent',h1, 'Position',[280 204 110 15],...
'Callback',{@euler_stuff_uiCB,h1,'check_singleRotation_CB'},...
'String','Use this Pole',...
'Style','checkbox',...
'Tag','check_singleRotation',...
'UserData','DoRotations');

uicontrol('Parent',h1,...
'Callback',{@euler_stuff_uiCB,h1,'push_polesList_CB'},...
'Position',[280 159 131 21],...
'String','Poles selector',...
'Tag','push_polesList',...
'UserData','DoRotations');

uicontrol('Parent',h1,...
'Callback',{@euler_stuff_uiCB,h1,'push_pickLine_CB'},...
'Position',[20 279 161 21],...
'String','Pick line from Figure',...
'TooltipString','Allows you to mouse select one line from a Mirone figure',...
'Tag','togglebutton_pickLine',...
'UserData','DoRotations');

r=zeros(19,19,3)*NaN;   % Make a crude rectangle icon
r(4:17,3,1:3) = 0;      r(4:17,19,1:3) = 0;     % Verical lines
r(4,3:19,1:3) = 0;      r(17,3:19,1:3) = 0;
uicontrol('Parent',h1,...
'Callback',{@euler_stuff_uiCB,h1,'push_rectSelect_CB'},...
'Position',[190 279 25 21],...
'CData',r,...
'TooltipString','Select objects inside a rectangular region',...
'Tag','push_rectSelect',...
'UserData','DoRotations');

uicontrol('Parent',h1,...
'FontSize',10,...
'FontWeight','Bold',...
'Position',[220 283 235 16],...
'String','NO ACTIVE LINE',...
'ForegroundColor',[1 0 0],...
'Style','text',...
'Tag','text_activeLine',...
'UserData','DoRotations');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@euler_stuff_uiCB,h1,'edit_pole1Lon_CB'},...
'Position',[50 208 51 21],...
'Style','edit',...
'TooltipString','Longitude of the first Euler pole',...
'Tag','edit_pole1Lon',...
'UserData','AddPoles');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@euler_stuff_uiCB,h1,'edit_pole1Lat_CB'},...
'Position',[110 208 51 21],...
'Style','edit',...
'TooltipString','Latitude of the first Euler pole',...
'Tag','edit_pole1Lat',...
'UserData','AddPoles');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@euler_stuff_uiCB,h1,'edit_pole1Ang_CB'},...
'Position',[170 208 51 21],...
'Style','edit',...
'TooltipString','Angle of rotation of first pole',...
'Tag','edit_pole1Ang',...
'UserData','AddPoles');

uicontrol('Parent',h1, 'Position',[56 233 41 15],...
'String','Lon',...
'Style','text',...
'UserData','AddPoles');

uicontrol('Parent',h1, 'Position',[114 233 41 15],...
'String','Lat',...
'Style','text',...
'UserData','AddPoles');

uicontrol('Parent',h1, 'Position',[174 233 41 15],...
'String','Angle',...
'Style','text',...
'UserData','AddPoles');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@euler_stuff_uiCB,h1,'edit_pole2Lon_CB'},...
'Position',[260 209 51 21],...
'Style','edit',...
'TooltipString','Longitude of the second Euler pole',...
'Tag','edit_pole2Lon',...
'UserData','AddPoles');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@euler_stuff_uiCB,h1,'edit_pole2Lat_CB'},...
'Position',[320 209 51 21],...
'Style','edit',...
'TooltipString','Latitude of the second Euler pole',...
'Tag','edit_pole2Lat',...
'UserData','AddPoles');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@euler_stuff_uiCB,h1,'edit_pole2Ang_CB'},...
'Position',[380 209 51 21],...
'Style','edit',...
'TooltipString','Angle of rotation of the second pole',...
'Tag','edit_pole2Ang',...
'UserData','AddPoles');

uicontrol('Parent',h1, 'Position',[266 234 41 15],...
'String','Lon','Style','text',...
'UserData','AddPoles');

uicontrol('Parent',h1, 'Position',[324 234 41 15],...
'String','Lat',...
'Style','text',...
'UserData','AddPoles');

uicontrol('Parent',h1, 'Position',[384 234 41 15],...
'String','Angle',...
'Style','text',...
'UserData','AddPoles');

uicontrol('Parent',h1,...
'FontSize',10,...
'Position',[60 262 151 17],...
'String','First pole',...
'Style','text',...
'UserData','AddPoles');

uicontrol('Parent',h1,...
'FontSize',10,...
'Position',[263 262 151 17],...
'String','Second pole',...
'Style','text',...
'UserData','AddPoles');

uicontrol('Parent',h1,...
'FontSize',10,...
'Position',[195 176 101 16],...
'String','Result',...
'Style','text',...
'UserData','AddPoles');

uicontrol('Parent',h1,'BackgroundColor',[1 1 1],...
'Position',[123 121 71 21],...
'Style','edit',...
'TooltipString','Longitude of the resulting Euler pole',...
'Tag','edit_pole3Lon',...
'UserData','AddPoles');

uicontrol('Parent',h1,'BackgroundColor',[1 1 1],...
'Position',[209 121 71 21],...
'Style','edit',...
'TooltipString','Latitude of the resulting Euler pole',...
'Tag','edit_pole3Lat',...
'UserData','AddPoles');

uicontrol('Parent',h1,'BackgroundColor',[1 1 1],...
'Position',[295 121 71 21],...
'Style','edit',...
'TooltipString','Angle of rotation',...
'Tag','edit_pole3Ang',...
'UserData','AddPoles');

uicontrol('Parent',h1, 'Position',[149 146 41 15],...
'String','Lon',...
'Style','text',...
'UserData','AddPoles');

uicontrol('Parent',h1, 'Position',[224 146 41 15],...
'String','Lat',...
'Style','text',...
'UserData','AddPoles');

uicontrol('Parent',h1, 'Position',[299 146 41 15],...
'String','Angle',...
'Style','text',...
'UserData','AddPoles');

function euler_stuff_uiCB(hObject, eventdata, h1, callback_name)
% This function is executed by the callback and than the handles is allways updated.
	feval(callback_name,hObject,guidata(h1));
