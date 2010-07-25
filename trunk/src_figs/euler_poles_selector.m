function varargout = euler_poles_selector(varargin)
% command line arguments to euler_poles_selector
%
% Changes:
%       16-Oct-2004 Replaced APKIM2000 by DEOS2K model. However, APKIM2000 functions
%                   where left in the code for the case they will be needed in future

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

	hObject = figure('Tag','figure1','Visible','off');
	euler_poles_selector_LayoutFcn(hObject);
	handles = guihandles(hObject);
	move2side(hObject,'right')

	if (isempty(varargin)),
		home_dir = pwd;
	else
		home_dir = varargin{1};
	end

	handles.path_data = [home_dir filesep 'data' filesep];
	handles.first_NNR = 1;
	handles.first_PB = 1;
	handles.first_AKIM2000 = 1;
	handles.first_DEOS2K = 1;
	handles.first_REVEL = 1;
	handles.absolute_motion = 0;        % when == 1, it signals an absolute motion model
	handles.abs2rel = 0;                % when == 1, flags that an absolute model was turned relative
	handles.abb_mov = [];
	handles.abb_fix = [];

    set(handles.checkbox_Abs2Rel,'Visible','off')

	% Read the Nuvel-1A poles file as they are the default
	fid = fopen([handles.path_data 'Nuvel1A_poles.dat'],'r');
	[abbrev name lat lon omega] = strread(fread(fid,'*char'),'%s %s %f %f %f');
	fclose(fid);

	% Save the poles parameters in the handles structure
	handles.Nuvel1A_abbrev = abbrev;
	handles.Nuvel1A_name = name;
	handles.Nuvel1A_lat = lat;
	handles.Nuvel1A_lon = lon;
	handles.Nuvel1A_omega = omega;

	% Fill the popupmenus with the Plate's names
	set(handles.popup_FixedPlate,'String',name)
	set(handles.popup_MovingPlate,'String',name)

	setappdata(hObject,'current_model','Nuvel1A')

	% Choose default command line output for euler_poles_selector_export
	handles.output = hObject;
	guidata(hObject, handles);

	set(hObject,'Visible','on');
	% UIWAIT makes euler_poles_selector_export wait for user response (see UIRESUME)
	uiwait(handles.figure1);

	handles = guidata(hObject);
	varargout{1} = handles.output;
	delete(handles.figure1);

%--------------------------------------------------------------------------------------------------
function popup_FixedPlate_CB(hObject, handles)
D2R = pi/180;
ind_fix = get(hObject,'Value');
ind_mov = get(handles.popup_MovingPlate,'Value');
model = getappdata(gcf,'current_model');
switch model
    case 'Nuvel1A'
        lat2 = handles.Nuvel1A_lat(ind_mov);        lon2 = handles.Nuvel1A_lon(ind_mov);
        omega2 = handles.Nuvel1A_omega(ind_mov);    handles.abb_mov = handles.Nuvel1A_abbrev{ind_mov};
    case 'NNR'
        lat2 = handles.Nuvel1A_NNR_lat(ind_mov);     lon2 = handles.Nuvel1A_NNR_lon(ind_mov);
        omega2 = handles.Nuvel1A_NNR_omega(ind_mov); handles.abb_mov = handles.Nuvel1A_NNR_abbrev{ind_mov};
    case 'PB'
        lat2 = handles.PB_lat(ind_mov);             lon2 = handles.PB_lon(ind_mov);
        omega2 = handles.PB_omega(ind_mov);         handles.abb_mov = handles.PB_abbrev{ind_mov};
    case 'AKIM2000'
        lat2 = handles.AKIM2000_lat(ind_mov);       lon2 = handles.AKIM2000_lon(ind_mov);
        omega2 = handles.AKIM2000_omega(ind_mov);   handles.abb_mov = handles.AKIM2000_abbrev{ind_mov};
    case 'REVEL'
        lat2 = handles.REVEL_lat(ind_mov);          lon2 = handles.REVEL_lon(ind_mov);
        omega2 = handles.REVEL_omega(ind_mov);      handles.abb_mov = handles.REVEL_abbrev{ind_mov};
    case 'DEOS2K'
        lat2 = handles.DEOS2K_lat(ind_mov);         lon2 = handles.DEOS2K_lon(ind_mov);
        omega2 = handles.DEOS2K_omega(ind_mov);     handles.abb_mov = handles.DEOS2K_abbrev{ind_mov};
end

if ~(handles.absolute_motion)       % That is, if relative motion
    switch model
        case 'Nuvel1A'
            lat1 = handles.Nuvel1A_lat(ind_fix);        lon1 = handles.Nuvel1A_lon(ind_fix);
            omega1 = handles.Nuvel1A_omega(ind_fix);    handles.abb_fix = handles.Nuvel1A_abbrev{ind_fix};
        case 'NNR'
            lat1 = handles.Nuvel1A_NNR_lat(ind_fix);     lon1 = handles.Nuvel1A_NNR_lon(ind_fix);
            omega1 = handles.Nuvel1A_NNR_omega(ind_fix); handles.abb_fix = handles.Nuvel1A_NNR_abbrev{ind_fix};
        case 'PB'
            lat1 = handles.PB_lat(ind_fix);             lon1 = handles.PB_lon(ind_fix);
            omega1 = handles.PB_omega(ind_fix);         handles.abb_fix = handles.PB_abbrev{ind_fix};
        case 'AKIM2000'
            lat1 = handles.AKIM2000_lat(ind_fix);       lon1 = handles.AKIM2000_lon(ind_fix);
            omega1 = handles.AKIM2000_omega(ind_fix);   handles.abb_fix = handles.AKIM2000_abbrev{ind_fix};       
        case 'REVEL'
            lat1 = handles.REVEL_lat(ind_fix);          lon1 = handles.REVEL_lon(ind_fix);
            omega1 = handles.REVEL_omega(ind_fix);      handles.abb_fix = handles.REVEL_abbrev{ind_fix};
        case 'DEOS2K'
            lat1 = handles.DEOS2K_lat(ind_fix);         lon1 = handles.DEOS2K_lon(ind_fix);
            omega1 = handles.DEOS2K_omega(ind_fix);     handles.abb_fix = handles.DEOS2K_abbrev{ind_fix};       
    end
    [lon,lat,omega] = calculate_pole(lon1,lat1,omega1,lon2,lat2,omega2);
else                                % Absolute motion
    lon = lon2;     lat = lat2;     omega = omega2;
    handles.abb_fix = 'absolute';
end

if (omega == 0)     % This works as a test for when the same plate is selected as Fixed and Moving
    set(handles.edit_PoleLon,'String','')
    set(handles.edit_PoleLat,'String','')
    set(handles.edit_PoleRate,'String','')
    return
end

set(handles.edit_PoleLon,'String',num2str(lon/D2R,'%3.2f'))
set(handles.edit_PoleLat,'String',num2str(lat/D2R,'%2.2f'))
set(handles.edit_PoleRate,'String',num2str(omega,'%1.4f'))

guidata(hObject, handles);

%--------------------------------------------------------------------------------------------------
function popup_MovingPlate_CB(hObject, handles)
D2R = pi/180;
ind_mov = get(hObject,'Value');
ind_fix = get(handles.popup_FixedPlate,'Value');
model = getappdata(gcf,'current_model');
switch model
    case 'Nuvel1A'
        lat2 = handles.Nuvel1A_lat(ind_mov);        lon2 = handles.Nuvel1A_lon(ind_mov);
        omega2 = handles.Nuvel1A_omega(ind_mov);    handles.abb_mov = handles.Nuvel1A_abbrev{ind_mov};
    case 'NNR'
        lat2 = handles.Nuvel1A_NNR_lat(ind_mov);     lon2 = handles.Nuvel1A_NNR_lon(ind_mov);
        omega2 = handles.Nuvel1A_NNR_omega(ind_mov); handles.abb_mov = handles.Nuvel1A_NNR_abbrev{ind_mov};
    case 'PB'
        lat2 = handles.PB_lat(ind_mov);             lon2 = handles.PB_lon(ind_mov);
        omega2 = handles.PB_omega(ind_mov);         handles.abb_mov = handles.PB_abbrev{ind_mov};
    case 'AKIM2000'
        lat2 = handles.AKIM2000_lat(ind_mov);       lon2 = handles.AKIM2000_lon(ind_mov);
        omega2 = handles.AKIM2000_omega(ind_mov);   handles.abb_mov = handles.AKIM2000_abbrev{ind_mov};        
    case 'REVEL'
        lat2 = handles.REVEL_lat(ind_mov);          lon2 = handles.REVEL_lon(ind_mov);
        omega2 = handles.REVEL_omega(ind_mov);      handles.abb_mov = handles.REVEL_abbrev{ind_mov};
    case 'DEOS2K'
        lat2 = handles.DEOS2K_lat(ind_mov);         lon2 = handles.DEOS2K_lon(ind_mov);
        omega2 = handles.DEOS2K_omega(ind_mov);     handles.abb_mov = handles.DEOS2K_abbrev{ind_mov};        
end

if ~(handles.absolute_motion)       % That is, if relative motion
    switch model
        case 'Nuvel1A'
            lat1 = handles.Nuvel1A_lat(ind_fix);        lon1 = handles.Nuvel1A_lon(ind_fix);
            omega1 = handles.Nuvel1A_omega(ind_fix);    handles.abb_fix = handles.Nuvel1A_abbrev{ind_fix};
        case 'NNR'
            lat1 = handles.Nuvel1A_NNR_lat(ind_fix);     lon1 = handles.Nuvel1A_NNR_lon(ind_fix);
            omega1 = handles.Nuvel1A_NNR_omega(ind_fix); handles.abb_fix = handles.Nuvel1A_NNR_abbrev{ind_fix};
        case 'PB'
            lat1 = handles.PB_lat(ind_fix);             lon1 = handles.PB_lon(ind_fix);
            omega1 = handles.PB_omega(ind_fix);         handles.abb_fix = handles.PB_abbrev{ind_fix};
        case 'AKIM2000'
            lat1 = handles.AKIM2000_lat(ind_fix);       lon1 = handles.AKIM2000_lon(ind_fix);
            omega1 = handles.AKIM2000_omega(ind_fix);   handles.abb_fix = handles.AKIM2000_abbrev{ind_fix};        
        case 'REVEL'
            lat1 = handles.REVEL_lat(ind_fix);          lon1 = handles.REVEL_lon(ind_fix);
            omega1 = handles.REVEL_omega(ind_fix);      handles.abb_fix = handles.REVEL_abbrev{ind_fix};
        case 'DEOS2K'
            lat1 = handles.DEOS2K_lat(ind_fix);         lon1 = handles.DEOS2K_lon(ind_fix);
            omega1 = handles.DEOS2K_omega(ind_fix);     handles.abb_fix = handles.DEOS2K_abbrev{ind_fix};        
    end
    [lon,lat,omega] = calculate_pole(lon1,lat1,omega1,lon2,lat2,omega2);
    lon = lon/D2R;     lat = lat/D2R;
else                                % Absolute motion
    lon = lon2;     lat = lat2;     omega = omega2;
    handles.abb_fix = 'absolute';
end

if (omega == 0)     % This works as a test for when the same plate is selected as Fixed and Moving
    set(handles.edit_PoleLon,'String','')
    set(handles.edit_PoleLat,'String','')
    set(handles.edit_PoleRate,'String','')
    return
end

set(handles.edit_PoleLon,'String',num2str(lon,'%3.2f'))
set(handles.edit_PoleLat,'String',num2str(lat,'%2.2f'))
set(handles.edit_PoleRate,'String',num2str(omega,'%1.4f'))

guidata(hObject, handles);

%--------------------------------------------------------------------------------------------------
function radiobutton_Nuvel1A_CB(hObject, handles)
	if ~get(hObject,'Value')
        set(hObject,'Value',1);    return
	end

	set(handles.radiobutton_Nuvel1A_NNR,'Value',0)
	set(handles.radiobutton_PBird,'Value',0)
	set(handles.radiobutton_DEOS2K,'Value',0)
	set(handles.radiobutton_REVEL,'Value',0)
	set(handles.checkbox_Abs2Rel,'Visible','off')

	set(handles.popup_FixedPlate,'Enable','on')
	handles.absolute_motion = 0;            % The Nuvel1A is a relative motion model

	% Fill the popupmenus with the Plate's names
	set(handles.popup_FixedPlate,'Value',1)
	set(handles.popup_MovingPlate,'Value',1)
	set(handles.popup_FixedPlate,'String',handles.Nuvel1A_name)
	set(handles.popup_MovingPlate,'String',handles.Nuvel1A_name)

	% Clear the pole edit boxes fields
	set(handles.edit_PoleLon,'String','')
	set(handles.edit_PoleLat,'String','')
	set(handles.edit_PoleRate,'String','')

	% Flag in appdata which model is currently loaded
	setappdata(gcf,'current_model','Nuvel1A')
	guidata(hObject, handles);

%--------------------------------------------------------------------------------------------------
function radiobutton_Nuvel1A_NNR_CB(hObject, handles)
	if ~get(hObject,'Value')
        set(hObject,'Value',1);    return
	end

	D2R = pi/180;
	set(handles.radiobutton_Nuvel1A,'Value',0)
	set(handles.radiobutton_PBird,'Value',0)
	set(handles.radiobutton_DEOS2K,'Value',0)
	set(handles.radiobutton_REVEL,'Value',0)
	set(handles.checkbox_Abs2Rel,'Visible','on')

	if (handles.first_NNR)      % Load and read poles deffinition
        fid = fopen([handles.path_data 'Nuvel1A_NNR_poles.dat'],'r');
        [abbrev name lat lon omega] = strread(fread(fid,'*char'),'%s %s %f %f %f');
        fclose(fid);
        % Save the poles parameters in the handles structure
        handles.Nuvel1A_NNR_abbrev = abbrev;
        handles.Nuvel1A_NNR_name = name;
        handles.Nuvel1A_NNR_lat = lat;
        handles.Nuvel1A_NNR_lon = lon;
        handles.Nuvel1A_NNR_omega = omega;
        handles.first_NNR = 0;
	end

	% Fill the Moving plate popupmenu with the plate's names (we have to this in every case)
	set(handles.popup_MovingPlate,'Value',1)
	set(handles.popup_MovingPlate,'String',handles.Nuvel1A_NNR_name)

	if (handles.abs2rel)                        % We are in "relativized absolute" motion mode
        set(handles.popup_FixedPlate,'Value',1)
        set(handles.popup_FixedPlate,'String',handles.Nuvel1A_NNR_name)
        set(handles.popup_FixedPlate,'Enable','on')
        lon1 = handles.Nuvel1A_NNR_lon(1);      lat1 = handles.Nuvel1A_NNR_lat(1);
        omega1 = handles.Nuvel1A_NNR_omega(1);
        ind = get(handles.popup_MovingPlate,'Value');
        lon2 = handles.Nuvel1A_NNR_lon(ind);    lat2 = handles.Nuvel1A_NNR_lat(ind);
        omega2 = handles.Nuvel1A_NNR_omega(ind);
        [lon,lat,omega] = calculate_pole(lon1,lat1,omega1,lon2,lat2,omega2);
        lon = lon/D2R;     lat = lat/D2R;
        handles.abb_mov = handles.Nuvel1A_NNR_abbrev{ind};
        handles.abb_fix = 'relativezed';
	else                                        % On the original absolute motion mode
        handles.absolute_motion = 1;
        set(handles.popup_FixedPlate,'Enable','off')
        lon = handles.Nuvel1A_NNR_lon(1);       lat = handles.Nuvel1A_NNR_lat(1);
        omega = handles.Nuvel1A_NNR_omega(1);
        handles.abb_mov = handles.Nuvel1A_NNR_abbrev{1};
        handles.abb_fix = 'absolute';
	end

	% Actualize the pole edit boxes fields and plot the pole
	if (omega ~= 0)         % That is, if the pole exists
        set(handles.edit_PoleLon,'String',num2str(lon,'%3.2f'))
        set(handles.edit_PoleLat,'String',num2str(lat,'%2.2f'))
        set(handles.edit_PoleRate,'String',num2str(omega,'%1.4f'))
	else
        set(handles.edit_PoleLon,'String','')
        set(handles.edit_PoleLat,'String','')
        set(handles.edit_PoleRate,'String','')
	end

	% Flag in appdata which model is currently loaded
	setappdata(gcf,'current_model','NNR')
	guidata(hObject, handles);

%--------------------------------------------------------------------------------------------------
function radiobutton_PBird_CB(hObject, handles)
	if ~get(hObject,'Value')
        set(hObject,'Value',1);    return
	end

	set(handles.radiobutton_Nuvel1A,'Value',0)
	set(handles.radiobutton_Nuvel1A_NNR,'Value',0)
	set(handles.radiobutton_DEOS2K,'Value',0)
	set(handles.radiobutton_REVEL,'Value',0)
	set(handles.checkbox_Abs2Rel,'Visible','off')

	set(handles.popup_FixedPlate,'Enable','on')
	handles.absolute_motion = 0;            % The PB is a relative motion model

	if (handles.first_PB)      % Load and read poles deffinition
        fid = fopen([handles.path_data 'PB_poles.dat'],'r');
        [abbrev name lat lon omega] = strread(fread(fid,'*char'),'%s %s %f %f %f');
        fclose(fid);
        % Save the poles parameters in the handles structure
        handles.PB_abbrev = abbrev;
        handles.PB_name = name;
        handles.PB_lat = lat;
        handles.PB_lon = lon;
        handles.PB_omega = omega;
        handles.first_PB = 0;
        guidata(hObject, handles);
	end

	% Fill the popupmenus with the Plate's names
	set(handles.popup_FixedPlate,'Value',1)
	set(handles.popup_MovingPlate,'Value',1)
	set(handles.popup_FixedPlate,'String',handles.PB_name)
	set(handles.popup_MovingPlate,'String',handles.PB_name)

	% Clear the pole edit boxes fields
	set(handles.edit_PoleLon,'String','')
	set(handles.edit_PoleLat,'String','')
	set(handles.edit_PoleRate,'String','')

	% Flag in appdata which model is currently loaded
	setappdata(gcf,'current_model','PB')

%--------------------------------------------------------------------------------------------------
function radiobutton_AKIM2000_CB(hObject, handles)
	if ~get(hObject,'Value')
        set(hObject,'Value',1);    return
	end

	D2R = pi/180;
	set(handles.radiobutton_Nuvel1A,'Value',0)
	set(handles.radiobutton_Nuvel1A_NNR,'Value',0)
	set(handles.radiobutton_PBird,'Value',0)
	set(handles.radiobutton_REVEL,'Value',0)
	set(handles.checkbox_Abs2Rel,'Visible','on')

	if (handles.first_AKIM2000)      % Load and read poles deffinition
        fid = fopen([handles.path_data 'AKIM2000_poles.dat'],'r');
        [abbrev name lat lon omega] = strread(fread(fid,'*char'),'%s %s %f %f %f');
        fclose(fid);
        % Save the poles parameters in the handles structure
        handles.AKIM2000_abbrev = abbrev;
        handles.AKIM2000_name = name;
        handles.AKIM2000_lat = lat;
        handles.AKIM2000_lon = lon;
        handles.AKIM2000_omega = omega;
        handles.first_AKIM2000 = 0;
	end

	% Fill the Moving plate popupmenu with the plate's names (we have to this in every case)
	set(handles.popup_MovingPlate,'Value',1)
	set(handles.popup_MovingPlate,'String',handles.AKIM2000_name)

	if (handles.abs2rel)                        % We are in "relativized absolute" motion mode
        set(handles.popup_FixedPlate,'Value',1)
        set(handles.popup_FixedPlate,'String',handles.AKIM2000_name)
        set(handles.popup_FixedPlate,'Enable','on')
        lon1 = handles.AKIM2000_lon(1);      lat1 = handles.AKIM2000_lat(1);
        omega1 = handles.AKIM2000_omega(1);
        ind = get(handles.popup_MovingPlate,'Value');
        lon2 = handles.AKIM2000_lon(ind);    lat2 = handles.AKIM2000_lat(ind);
        omega2 = handles.AKIM2000_omega(ind);
        [lon,lat,omega] = calculate_pole(lon1,lat1,omega1,lon2,lat2,omega2);
        lon = lon/D2R;     lat = lat/D2R;
        handles.abb_mov = handles.AKIM2000_abbrev{ind};
        handles.abb_fix = 'relativezed';
	else                                        % On the original absolute motion mode
        handles.absolute_motion = 1;
        set(handles.popup_FixedPlate,'Enable','off')
        lon = handles.AKIM2000_lon(1);       lat = handles.AKIM2000_lat(1);
        omega = handles.AKIM2000_omega(1);
        handles.abb_mov = handles.AKIM2000_abbrev{1};
        handles.abb_fix = 'absolute';
	end

	% Actualize the pole edit boxes fields and plot the pole
	if (omega ~= 0)         % That is, if the pole exists
        set(handles.edit_PoleLon,'String',num2str(lon,'%3.2f'))
        set(handles.edit_PoleLat,'String',num2str(lat,'%2.2f'))
        set(handles.edit_PoleRate,'String',num2str(omega,'%1.4f'))
	else
        set(handles.edit_PoleLon,'String','')
        set(handles.edit_PoleLat,'String','')
        set(handles.edit_PoleRate,'String','')
	end

	% Flag in appdata which model is currently loaded
	setappdata(gcf,'current_model','AKIM2000')
	guidata(hObject, handles);

%--------------------------------------------------------------------------------------------------
function radiobutton_REVEL_CB(hObject, handles)
	if ~get(hObject,'Value')
        set(hObject,'Value',1);    return
	end

	D2R = pi/180;
	set(handles.radiobutton_Nuvel1A,'Value',0)
	set(handles.radiobutton_Nuvel1A_NNR,'Value',0)
	set(handles.radiobutton_PBird,'Value',0)
	set(handles.radiobutton_DEOS2K,'Value',0)
	set(handles.checkbox_Abs2Rel,'Visible','on')

	if (handles.first_REVEL)      % Load and read poles deffinition
        fid = fopen([handles.path_data 'REVEL_poles.dat'],'r');
        [abbrev name lat lon omega] = strread(fread(fid,'*char'),'%s %s %f %f %f');
        fclose(fid);
        % Save the poles parameters in the handles structure
        handles.REVEL_abbrev = abbrev;
        handles.REVEL_name = name;
        handles.REVEL_lat = lat;
        handles.REVEL_lon = lon;
        handles.REVEL_omega = omega;
        handles.first_REVEL = 0;
	end

	% Fill the Moving plate popupmenu with the plate's names (we have to this in every case)
	set(handles.popup_MovingPlate,'Value',1)
	set(handles.popup_MovingPlate,'String',handles.REVEL_name)

	if (handles.abs2rel)                        % We are in "relativized absolute" motion mode
        set(handles.popup_FixedPlate,'Value',1)
        set(handles.popup_FixedPlate,'String',handles.REVEL_name)
        set(handles.popup_FixedPlate,'Enable','on')
        lon1 = handles.REVEL_lon(1);      lat1 = handles.REVEL_lat(1);
        omega1 = handles.REVEL_omega(1);
        ind = get(handles.popup_MovingPlate,'Value');
        lon2 = handles.REVEL_lon(ind);    lat2 = handles.REVEL_lat(ind);
        omega2 = handles.REVEL_omega(ind);
        [lon,lat,omega] = calculate_pole(lon1,lat1,omega1,lon2,lat2,omega2);
        lon = lon/D2R;     lat = lat/D2R;
        handles.abb_mov = handles.REVEL_abbrev{ind};
        handles.abb_fix = 'relativezed';
	else                                        % On the original absolute motion mode
        handles.absolute_motion = 1;
        set(handles.popup_FixedPlate,'Enable','off')
        lon = handles.REVEL_lon(1);       lat = handles.REVEL_lat(1);
        omega = handles.REVEL_omega(1);
        handles.abb_mov = handles.REVEL_abbrev{1};
        handles.abb_fix = 'absolute';
	end

	% Actualize the pole edit boxes fields and plot the pole
	if (omega ~= 0)         % That is, if the pole exists
        set(handles.edit_PoleLon,'String',num2str(lon,'%3.2f'))
        set(handles.edit_PoleLat,'String',num2str(lat,'%2.2f'))
        set(handles.edit_PoleRate,'String',num2str(omega,'%1.4f'))
	else
        set(handles.edit_PoleLon,'String','')
        set(handles.edit_PoleLat,'String','')
        set(handles.edit_PoleRate,'String','')
	end

	% Flag in appdata which model is currently loaded
	setappdata(gcf,'current_model','REVEL')
	guidata(hObject, handles);

%--------------------------------------------------------------------------------------------------
function radiobutton_DEOS2K_CB(hObject, handles)
	if ~get(hObject,'Value')
        set(hObject,'Value',1);    return
	end

	D2R = pi/180;
	set(handles.radiobutton_Nuvel1A,'Value',0)
	set(handles.radiobutton_Nuvel1A_NNR,'Value',0)
	set(handles.radiobutton_PBird,'Value',0)
	set(handles.radiobutton_REVEL,'Value',0)
	set(handles.checkbox_Abs2Rel,'Visible','on')

	if (handles.first_DEOS2K)      % Load and read poles deffinition
        fid = fopen([handles.path_data 'DEOS2K_poles.dat'],'r');
        [abbrev name lat lon omega] = strread(fread(fid,'*char'),'%s %s %f %f %f');
        fclose(fid);
        % Save the poles parameters in the handles structure
        handles.DEOS2K_abbrev = abbrev;
        handles.DEOS2K_name = name;
        handles.DEOS2K_lat = lat;
        handles.DEOS2K_lon = lon;
        handles.DEOS2K_omega = omega;
        handles.first_DEOS2K = 0;
	end

	% Fill the Moving plate popupmenu with the plate's names (we have to this in every case)
	set(handles.popup_MovingPlate,'Value',1)
	set(handles.popup_MovingPlate,'String',handles.DEOS2K_name)

	if (handles.abs2rel)                        % We are in "relativized absolute" motion mode
        set(handles.popup_FixedPlate,'Value',1)
        set(handles.popup_FixedPlate,'String',handles.DEOS2K_name)
        set(handles.popup_FixedPlate,'Enable','on')
        lon1 = handles.DEOS2K_lon(1);      lat1 = handles.DEOS2K_lat(1);
        omega1 = handles.DEOS2K_omega(1);
        ind = get(handles.popup_MovingPlate,'Value');
        lon2 = handles.DEOS2K_lon(ind);    lat2 = handles.DEOS2K_lat(ind);
        omega2 = handles.DEOS2K_omega(ind);
        [lon,lat,omega] = calculate_pole(lon1,lat1,omega1,lon2,lat2,omega2);
        lon = lon/D2R;     lat = lat/D2R;
        handles.abb_mov = handles.DEOS2K_abbrev{ind};
        handles.abb_fix = 'relativezed';
	else                                        % On the original absolute motion mode
        handles.absolute_motion = 1;
        set(handles.popup_FixedPlate,'Enable','off')
        lon = handles.DEOS2K_lon(1);       lat = handles.DEOS2K_lat(1);
        omega = handles.DEOS2K_omega(1);
        handles.abb_mov = handles.DEOS2K_abbrev{1};
        handles.abb_fix = 'absolute';
	end

	% Actualize the pole edit boxes fields and plot the pole
	if (omega ~= 0)         % That is, if the pole exists
        set(handles.edit_PoleLon,'String',num2str(lon,'%3.2f'))
        set(handles.edit_PoleLat,'String',num2str(lat,'%2.2f'))
        set(handles.edit_PoleRate,'String',num2str(omega,'%1.4f'))
	else
        set(handles.edit_PoleLon,'String','')
        set(handles.edit_PoleLat,'String','')
        set(handles.edit_PoleRate,'String','')
	end

	% Flag in appdata which model is currently loaded
	setappdata(gcf,'current_model','DEOS2K')
	guidata(hObject, handles);

%--------------------------------------------------------------------------------------------------
function push_OK_CB(hObject, handles, opt)

	lon = str2double(get(handles.edit_PoleLon,'String'));
	lat = str2double(get(handles.edit_PoleLat,'String'));
	omega = str2double(get(handles.edit_PoleRate,'String'));
	
	if (isempty(lon) || isempty(lat) || isempty(omega))  % I any of these is empty insult
        errordlg('OK what? And if you select something meaningful first?','Error')
        return
	else            % Valid choice, so fill also the plate(s) abbreviation string
        plates = [handles.abb_fix '-' handles.abb_mov];
	end
	
	model = getappdata(gcf,'current_model');
	out.lon = lon;      out.lat = lat;      out.omega = omega;      out.plates = plates;    out.model = model;
	handles.output = out;
	guidata(hObject,handles);
	uiresume(handles.figure1);

%--------------------------------------------------------------------------------------------------
function [plon,plat,omega] = calculate_pole(lon1,lat1,omega1,lon2,lat2,omega2)
	% To calculate the relative motion, we have first to calculate relative Euler
	% pole. This is because the pole list is relative to the Pacific plate. So, anyother
	% plate combination that does not include the Pacific plate, has to be computed.
	%
	% In the following let aWb denote the rotation of the (moving) plate b relative to the (fixed) plate a 
	% Given that all poles are relative to the Pacific plate (p), the closing circuit implies:
	% pWa + aWb + bWp = 0
	% and the desired pole (aWb) is then equal to
	% aWb = -pWa - bWp = aWp + pWb
	% Note that from the poles list we know pWa (= -aWp) and pWb. So:
	% aWb = -pWa + pWb

	D2R = pi/180;
	if (lon1 == lon2 && lat1 == lat2)     % The two poles are equal
        plon = 0;   plat = 0;   omega = 0;
        return
	end

	pWa_x = omega1 * cos(lat1*D2R) * cos(lon1*D2R);
	pWa_y = omega1 * cos(lat1*D2R) * sin(lon1*D2R);
	pWa_z = omega1 * sin(lat1*D2R);

	pWb_x = omega2 * cos(lat2*D2R) * cos(lon2*D2R);
	pWb_y = omega2 * cos(lat2*D2R) * sin(lon2*D2R);
	pWb_z = omega2 * sin(lat2*D2R);

	aWb_x = -pWa_x + pWb_x;
	aWb_y = -pWa_y + pWb_y;
	aWb_z = -pWa_z + pWb_z;

	% Convert cartesian pole coordinates back to spherical coordinates
	plat = atan(aWb_z/sqrt(aWb_x*aWb_x + aWb_y*aWb_y));
	plon = atan2(aWb_y,aWb_x);
	omega = sqrt(aWb_x*aWb_x + aWb_y*aWb_y + aWb_z*aWb_z);

%--------------------------------------------------------------------------------------------------
function push_Help_CB(hObject, handles)
message = {'This window allows you to select (or enter) a Euler pole for a relative (or absolute) plate motion.'
    'The Nuvel1A and P. Bird are relative motion models. When you select two'
    'different plates from the popupmenus the relative motion Euler pole is'
    'computed. On the other hand Nuvel1A NNR, DEOS2K and REVEL are absolute'
    'motion plate models. So what you get is directly Euler Pole corresponding'
    'to the selected plate.'
    ' '
    'However, the "Relativize" checkbox appears when any of the absolute models'
    'is active. When checked, the absolute model is used to compute relative'
    'motion poles from the selected plate pairs.'
    ' '
    'Note: you can also enter pole parameters for a pole of your choice.'};
helpdlg(message,'Help on Euler Poles');


%--------------------------------------------------------------------------------------------------
function push_Cancel_CB(hObject, handles)
	handles.output = [];        % User gave up, return nothing
	guidata(hObject, handles);  uiresume(handles.figure1);

%--------------------------------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, evt)
	handles = guidata(hObject);
	if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        handles.output = [];        % User gave up, return nothing
        guidata(hObject, handles);    uiresume(handles.figure1);
	else
        % The GUI is no longer waiting, just close it
        handles.output = [];        % User gave up, return nothing
        guidata(hObject, handles);    delete(handles.figure1);
	end

%--------------------------------------------------------------------------------------------------
function figure1_KeyPressFcn(hObject, evt)
	handles = guidata(hObject);
	if isequal(get(hObject,'CurrentKey'),'escape')
        handles.output = [];    % User said no by hitting escape
        guidata(hObject, handles);    uiresume(handles.figure1);
	end

%--------------------------------------------------------------------------------------------------
function checkbox_Abs2Rel_CB(hObject, handles)
% Use absolute models to compute relative relative motions
if ~get(hObject,'Value')        % If we turn back to absolute motion
    handles.abs2rel = 0;
    handles.absolute_motion = 1;
    set(handles.popup_FixedPlate,'Enable','off')
    set(handles.edit_PoleLon,'String','')
    set(handles.edit_PoleLat,'String','')
    set(handles.edit_PoleRate,'String','')
    guidata(hObject, handles);
    return
end

D2R = pi/180;
model = getappdata(gcf,'current_model');

% Fill the fixed plate popupmenus with the current model plate names
switch model
    case 'NNR'
        set(handles.popup_FixedPlate,'String',handles.Nuvel1A_NNR_name)
    case 'AKIM2000'
        set(handles.popup_FixedPlate,'String',handles.AKIM2000_name)
    case 'REVEL'
        set(handles.popup_FixedPlate,'String',handles.REVEL_name)
    case 'DEOS2K'
        set(handles.popup_FixedPlate,'String',handles.DEOS2K_name)
end
set(handles.popup_FixedPlate,'Value',1)

ind_mov = get(handles.popup_MovingPlate,'Value');
ind_fix = get(handles.popup_FixedPlate,'Value');
handles.abs2rel = 1;                % Flag that an absolute model was turned relative
handles.absolute_motion = 0;
set(handles.popup_FixedPlate,'Enable','on')
guidata(hObject, handles);

switch model
    case 'NNR'
        lat2 = handles.Nuvel1A_NNR_lat(ind_mov);     lon2 = handles.Nuvel1A_NNR_lon(ind_mov);
        omega2 = handles.Nuvel1A_NNR_omega(ind_mov); handles.abb_mov = handles.Nuvel1A_NNR_abbrev{ind_mov};
    case 'AKIM2000'
        lat2 = handles.AKIM2000_lat(ind_mov);       lon2 = handles.AKIM2000_lon(ind_mov);
        omega2 = handles.AKIM2000_omega(ind_mov);   handles.abb_mov = handles.AKIM2000_abbrev{ind_mov};        
    case 'REVEL'
        lat2 = handles.REVEL_lat(ind_mov);          lon2 = handles.REVEL_lon(ind_mov);
        omega2 = handles.REVEL_omega(ind_mov);      handles.abb_mov = handles.REVEL_abbrev{ind_mov};
    case 'DEOS2K'
        lat2 = handles.DEOS2K_lat(ind_mov);         lon2 = handles.DEOS2K_lon(ind_mov);
        omega2 = handles.DEOS2K_omega(ind_mov);     handles.abb_mov = handles.DEOS2K_abbrev{ind_mov};        
end

switch model
    case 'NNR'
        lat1 = handles.Nuvel1A_NNR_lat(ind_fix);     lon1 = handles.Nuvel1A_NNR_lon(ind_fix);
        omega1 = handles.Nuvel1A_NNR_omega(ind_fix); handles.abb_fix = handles.Nuvel1A_NNR_abbrev{ind_fix};
    case 'AKIM2000'
        lat1 = handles.AKIM2000_lat(ind_fix);       lon1 = handles.AKIM2000_lon(ind_fix);
        omega1 = handles.AKIM2000_omega(ind_fix);   handles.abb_fix = handles.AKIM2000_abbrev{ind_fix};        
    case 'REVEL'
        lat1 = handles.REVEL_lat(ind_fix);          lon1 = handles.REVEL_lon(ind_fix);
        omega1 = handles.REVEL_omega(ind_fix);      handles.abb_fix = handles.REVEL_abbrev{ind_fix};
    case 'DEOS2K'
        lat1 = handles.DEOS2K_lat(ind_fix);         lon1 = handles.DEOS2K_lon(ind_fix);
        omega1 = handles.DEOS2K_omega(ind_fix);     handles.abb_fix = handles.DEOS2K_abbrev{ind_fix};        
end
[lon,lat,omega] = calculate_pole(lon1,lat1,omega1,lon2,lat2,omega2);
lon = lon/D2R;     lat = lat/D2R;

if (omega == 0)     % This works as a test for when the same plate is selected as Fixed and Moving
    set(handles.edit_PoleLon,'String','')
    set(handles.edit_PoleLat,'String','')
    set(handles.edit_PoleRate,'String','')
    return
end

set(handles.edit_PoleLon,'String',num2str(lon,'%3.2f'))
set(handles.edit_PoleLat,'String',num2str(lat,'%2.2f'))
set(handles.edit_PoleRate,'String',num2str(omega,'%1.4f'))

% --- Creates and returns a handle to the GUI figure. 
function euler_poles_selector_LayoutFcn(h1)
set(h1,...
'PaperUnits','centimeters',...
'CloseRequestFcn',@figure1_CloseRequestFcn,...
'Color',get(0,'factoryUicontrolBackgroundColor'),...
'KeyPressFcn',@figure1_KeyPressFcn,...
'MenuBar','none',...
'Name','Euler Poles',...
'NumberTitle','off',...
'Position',[520 559 282 241],...
'Resize','off',...
'Tag','figure1');

uicontrol('Parent',h1,'Position',[100 153 101 81], 'Style','frame');
uicontrol('Parent',h1,'Position',[10 153 81 81],'Style','frame');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',{@main_uiCB,h1,'popup_FixedPlate_CB'},...
'Position',[10 107 121 22],...
'Style','popupmenu',...
'Value',1,...
'Tag','popup_FixedPlate');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',{@main_uiCB,h1,'popup_MovingPlate_CB'},...
'Position',[150 107 121 22],...
'Style','popupmenu',...
'Value',1,...
'Tag','popup_MovingPlate');

uicontrol('Parent',h1,...
'Position',[10 129 52 15],...
'String','Fixed Plate',...
'Style','text');

uicontrol('Parent',h1,...
'HorizontalAlignment','left',...
'Position',[151 130 71 15],...
'String','Moving Plate',...
'Style','text');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'radiobutton_Nuvel1A_CB'},...
'Position',[14 203 71 15],...
'String','Nuvel-1A',...
'Style','radiobutton',...
'Value',1,...
'Tag','radiobutton_Nuvel1A');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'push_OK_CB'},...
'FontSize',9,...
'Position',[120 11 66 23],...
'String','OK',...
'Tag','push_OK');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'radiobutton_PBird_CB'},...
'Position',[14 176 71 15],...
'String','P. Bird',...
'Style','radiobutton',...
'Tag','radiobutton_PBird');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Position',[10 53 71 21],...
'Style','edit',...
'Tag','edit_PoleLon');

uicontrol('Parent',h1,...
'Position',[10 75 72 15],...
'String','Pole Longitude',...
'Style','text',...
'Tag','text5');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Position',[100 53 71 21],...
'Style','edit',...
'Tag','edit_PoleLat');

uicontrol('Parent',h1,...
'Position',[100 75 72 15],...
'String','Pole Latitude',...
'Style','text',...
'Tag','text6');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Position',[200 53 71 21],...
'Style','edit',...
'Tag','edit_PoleRate');

uicontrol('Parent',h1,...
'Position',[200 75 72 15],...
'String','Rate (deg/Ma)',...
'Style','text',...
'Tag','text7');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'radiobutton_Nuvel1A_NNR_CB'},...
'Position',[108 206 87 15],...
'String','Nuvel-1A NNR',...
'Style','radiobutton',...
'Tag','radiobutton_Nuvel1A_NNR');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'radiobutton_DEOS2K_CB'},...
'Position',[108 186 87 15],...
'String','DEOS2K',...
'Style','radiobutton',...
'Tag','radiobutton_DEOS2K');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'radiobutton_REVEL_CB'},...
'Position',[108 167 87 15],...
'String','REVEL',...
'Style','radiobutton',...
'Tag','radiobutton_REVEL');

uicontrol('Parent',h1,...
'Position',[20 225 51 15],...
'String','Relative',...
'Style','text');

uicontrol('Parent',h1,...
'Position',[115 225 51 15],...
'String','Absolute',...
'Style','text');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'push_Help_CB'},...
'FontSize',9,...
'FontWeight','demi',...
'ForegroundColor',[0 0 1],...
'Position',[30 11 66 23],...
'String','Help',...
'Tag','push_Help');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'push_Cancel_CB'},...
'FontSize',9,...
'Position',[206 11 66 23],...
'String','Cancel',...
'Tag','push_Cancel');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'checkbox_Abs2Rel_CB'},...
'Position',[210 156 64 15],...
'String','Relativize',...
'Style','checkbox',...
'TooltipString','Compute relative motion from asolute model',...
'Tag','checkbox_Abs2Rel');

function main_uiCB(hObject, eventdata, h1, callback_name)
% This function is executed by the callback and than the handles is allways updated.
	feval(callback_name,hObject,guidata(h1));
