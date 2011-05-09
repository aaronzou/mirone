function varargout = bg_region(varargin)
% Helper window to select a map region
%
% It accepts inputs in dd:mm or dd:mm:ss format

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
 
hObject = figure('Visible','off');
bg_region_LayoutFcn(hObject);
handles = guihandles(hObject);
move2side(hObject,'center');
 
handles.command = cell(15,1);

if ~isempty(varargin) && strcmp(varargin{1},'empty')
	handles.x_min = [];                     handles.x_max = [];
	handles.y_min = [];                     handles.y_max = [];
	handles.command{3} = [];                handles.command{5} = [];
	handles.command{7} = [];                handles.command{9} = [];
	set(handles.edit_Xmin,'String','');     set(handles.edit_Xmax,'String','');
	set(handles.edit_Ymin,'String','');     set(handles.edit_Ymax,'String','');
	set(handles.figure1,'Name','Limits')
elseif ~isempty(varargin) && strcmp(varargin{1},'with_limits')
	tmp = varargin{2};
	handles.x_min = tmp(1);                 handles.x_max = tmp(2);
	handles.y_min = tmp(3);                 handles.y_max = tmp(4);
	handles.command{3} = num2str(tmp(1));   handles.command{5} = num2str(tmp(2));
	handles.command{7} = num2str(tmp(3));   handles.command{9} = num2str(tmp(4));
	set(handles.edit_Xmin,'String',num2str(tmp(1)));   set(handles.edit_Xmax,'String',num2str(tmp(2)));
	set(handles.edit_Ymin,'String',num2str(tmp(3)));   set(handles.edit_Ymax,'String',num2str(tmp(4)));
	set(handles.figure1,'Name','Limits')
	if ((tmp(2) - tmp(1)) > 360 || (tmp(4) - tmp(3)) > 180)  % See if limits rule out "geog"
		set(handles.checkbox_IsGeog,'Value',0)
	end
else
	handles.x_min = -180;                   handles.x_max = 180;
	handles.y_min = -90;                    handles.y_max = 90;
	handles.command{3} = '-180';            handles.command{5} = '180';
	handles.command{7} = '-90';             handles.command{9} = '90';
end
% Choose default command line output for bg_region_export
handles.output = hObject;
guidata(hObject, handles);

set(hObject,'Visible','on');
% UIWAIT makes bg_region_export wait for user response (see UIRESUME)
uiwait(handles.figure1);

handles = guidata(hObject);
varargout{1} = handles.output;
delete(handles.figure1);

% --------------------------------------------------------------------------------------------------
function edit_Xmin_CB(hObject, handles)
xx = get(hObject,'String');     val = test_dms(xx);
if ~isempty(val)            % when dd:mm or dd:mm:ss was given
    x_min = 0;
    if str2double(val{1}) > 0
        for i = 1:length(val),  x_min = x_min + str2double(val{i}) / (60^(i-1));    end
    else
        for i = 1:length(val),  x_min = x_min - abs(str2double(val{i})) / (60^(i-1));   end
    end
    handles.x_min = x_min;
    if ~isempty(handles.x_max) && x_min >= handles.x_max
        errordlg('West Longitude >= East Longitude ','Error in Longitude limits')
        handles.command{3} = '';
        set(hObject,'String','');   guidata(hObject, handles);  return
    else
        handles.command{3} = xx;    % Save entered string
        guidata(hObject, handles);
    end
    % Guess if we are probably dealing with geog coordinates
    if ~isempty(get(handles.edit_Xmax,'String')) && (handles.x_max - x_min) <= 360
        set(handles.checkbox_IsGeog,'Value',1)
    else
        set(handles.checkbox_IsGeog,'Value',0)
    end
else                % box is empty
    handles.command{3} = '';
    set(hObject,'String','');   guidata(hObject, handles);
end

% --------------------------------------------------------------------------------------------------
function edit_Xmax_CB(hObject, handles)
xx = get(hObject,'String');     val = test_dms(xx);
if ~isempty(val)            % when dd:mm or dd:mm:ss was given
    x_max = 0;
    if str2double(val{1}) > 0
        for i = 1:length(val),  x_max = x_max + str2double(val{i}) / (60^(i-1));    end
    else
        for i = 1:length(val),  x_max = x_max - abs(str2double(val{i})) / (60^(i-1));   end
    end
    handles.x_max = x_max;
    if ~isempty(handles.x_min) && x_max <= handles.x_min
        errordlg('East Longitude <= West Longitude','Error in Longitude limits')
        handles.command{5} = '';
        set(hObject,'String','');   guidata(hObject, handles);  return
    else
        handles.command{5} = xx;    % Save entered string
        guidata(hObject, handles);
    end
    % Guess if we are probably dealing with geog coordinates
    if ~isempty(get(handles.edit_Xmin,'String')) && (x_max - handles.x_min) <= 360
        set(handles.checkbox_IsGeog,'Value',1)
    else
        set(handles.checkbox_IsGeog,'Value',0)
    end
else                % box is empty
    handles.command{5} = '';
    set(hObject,'String','');   guidata(hObject, handles);
end

% --------------------------------------------------------------------------------------------------
function edit_Ymin_CB(hObject, handles)
xx = get(hObject,'String');     val = test_dms(xx);
if ~isempty(val)            % when dd:mm or dd:mm:ss was given
    y_min = 0;
    if str2double(val{1}) > 0
        for i = 1:length(val),  y_min = y_min + str2double(val{i}) / (60^(i-1));    end
    else
        for i = 1:length(val),  y_min = y_min - abs(str2double(val{i})) / (60^(i-1));   end
    end
    handles.y_min = y_min;
    if ~isempty(handles.y_max) && y_min >= handles.y_max
        errordlg('South Latitude >= North Latitude','Error in Latitude limits')
        handles.command{7} = '';
        set(hObject,'String','');   guidata(hObject, handles);  return
    else
        handles.command{7} = xx;    % Save entered string
        guidata(hObject, handles);
    end
    % Guess if we are probably dealing with geog coordinates
    if ~isempty(get(handles.edit_Ymax,'String')) && (handles.y_max - y_min) <= 180
        set(handles.checkbox_IsGeog,'Value',1)
    else
        set(handles.checkbox_IsGeog,'Value',0)
    end
else                % box is empty
    handles.command{7} = '';
    set(hObject,'String','');   guidata(hObject, handles);
end

% --------------------------------------------------------------------------------------------------
function edit_Ymax_CB(hObject, handles)
xx = get(hObject,'String');     val = test_dms(xx);
if ~isempty(val)            % when dd:mm or dd:mm:ss was given
    y_max = 0;
    if str2double(val{1}) > 0
        for i = 1:length(val),   y_max = y_max + str2double(val{i}) / (60^(i-1));    end
    else
        for i = 1:length(val),   y_max = y_max - abs(str2double(val{i})) / (60^(i-1));   end
    end
    handles.y_max = y_max;
    if ~isempty(handles.y_min) && y_max <= handles.y_min
        errordlg('North Latitude <= South Latitude','Error in Latitude limits')
        handles.command{9} = '';
        set(hObject,'String','');   guidata(hObject, handles);  return
    else
        handles.command{9} = xx;    % Save entered string
        guidata(hObject, handles);
    end
    % Guess if we are probably dealing with geog coordinates
    if ~isempty(get(handles.edit_Ymin,'String')) && (y_max - handles.y_min) <= 180
        set(handles.checkbox_IsGeog,'Value',1)
    else
        set(handles.checkbox_IsGeog,'Value',0)
    end
else                % box is empty
    handles.command{9} = '';
    set(hObject,'String','');   guidata(hObject, handles);
end

% --------------------------------------------------------------------------------------------------
function error = VerifyCommand(handles)
% ERROR TESTING
	error = 0;
	if isempty(handles.command{3})
		errordlg('Lon Min box is empty','Error');
		error = error + 1;    
	end
	if isempty(handles.command{5})
		errordlg('Lon Max box is empty','Error');
		error = error + 1;    
	end
	if isempty(handles.command{7})
		errordlg('Lat Min box is empty','Error');
		error = error + 1;    
	end
	if isempty(handles.command{9})
		errordlg('Lat Max box is empty','Error');
		error = error + 1;    
	end

% --------------------------------------------------------------------------------------------------
function push_OK_CB(hObject, handles)
	nError = VerifyCommand(handles);
	if nError == 0
		is_geog = get(handles.checkbox_IsGeog,'Value');
		handles.output = [handles.x_min handles.x_max handles.y_min handles.y_max is_geog];
		guidata(hObject,handles);
		uiresume(handles.figure1);
	end

% --------------------------------------------------------------------------------------------------
function push_Cancel_CB(hObject, handles)
	handles.output = [];        % User gave up, return nothing
	guidata(hObject, handles);  uiresume(handles.figure1);

% --------------------------------------------------------------------------------------------------
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata)
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

% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata)
	handles = guidata(hObject);
	if isequal(get(hObject,'CurrentKey'),'escape')
		handles.output = [];    % User said no by hitting escape
		guidata(hObject, handles);    uiresume(handles.figure1);
	end

% --- Creates and returns a handle to the GUI figure. 
function bg_region_LayoutFcn(h1)
set(h1,...
'CloseRequestFcn',@figure1_CloseRequestFcn,...
'Color',get(0,'factoryUicontrolBackgroundColor'),...
'KeyPressFcn',@figure1_KeyPressFcn,...
'MenuBar','none',...
'Name','bg_region',...
'NumberTitle','off',...
'Pos',[520 659 258 141],...
'Resize','off',...
'Tag','figure1');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',@bg_region_uiCB,...
'FontSize',10,...
'Pos',[123 113 79 26],...
'String','90',...
'Style','edit',...
'Tooltip','Enter nothern map limit',...
'Tag','edit_Ymax');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',@bg_region_uiCB,...
'CData',[],...
'FontSize',10,...
'Pos',[79 78 79 26],...
'String','-180',...
'Style','edit',...
'Tooltip','Enter western map limit',...
'Tag','edit_Xmin');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',@bg_region_uiCB,...
'FontSize',10,...
'Pos',[168 78 79 26],...
'String','180',...
'Style','edit',...
'Tooltip','Enter eastern map limit',...
'Tag','edit_Xmax');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Call',@bg_region_uiCB,...
'FontSize',10,...
'Pos',[124 43 79 26],...
'String','-90',...
'Style','edit',...
'Tooltip','Enter southern map limit',...
'Tag','edit_Ymin');

uicontrol('Parent',h1,...
'Call',@bg_region_uiCB,...
'Pos',[185 8 66 21],...
'String','OK',...
'Tag','push_OK');

uicontrol('Parent',h1,...
'Call',@bg_region_uiCB,...
'Pos',[110 8 66 21],...
'String','Cancel',...
'Tag','push_Cancel');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Enable','off',...
'FontSize',10,...
'Pos',[25 104 22 22],...
'String','N',...
'Style','edit');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Enable','off',...
'FontSize',10,...
'Pos',[9 80 24 22],...
'String','W',...
'Style','edit');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Enable','off',...
'FontSize',10,...
'Pos',[39 80 24 22],...
'String','E',...
'Style','edit');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Enable','off',...
'FontSize',10,...
'Pos',[25 57 22 22],...
'String','S',...
'Style','edit');

uicontrol('Parent',h1,...
'Pos',[10 32 110 15],...
'String','Is Geographic?',...
'Style','checkbox',...
'Value',1,...
'Tooltip','Check if limits are in geographic coordinates',...
'Tag','checkbox_IsGeog');

function bg_region_uiCB(hObject, eventdata)
% This function is executed by the callback and than the handles is allways updated.
	feval([get(hObject,'Tag') '_CB'],hObject, guidata(hObject));