function varargout = draw_scale(varargin)
% M-File changed by desGUIDE 
% varargin   command line arguments to draw_scale (see VARARGIN)

%	Copyright (c) 2004-2006 by J. Luis
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
handles = guihandles(hObject);
guidata(hObject, handles);
draw_scale_LayoutFcn(hObject,handles);
handles = guihandles(hObject);
 
handles.command = cell(20,1);
handles.command{5} = ['-L'];

% Reposition the window on screen
movegui(hObject,'northwest')

% Choose default command line output for draw_scale_export
handles.output = hObject;
guidata(hObject, handles);

set(hObject,'Visible','on');
% UIWAIT makes draw_scale_export wait for user response (see UIRESUME)
uiwait(handles.figure1);

handles = guidata(hObject);
out = draw_scale_OutputFcn(hObject, [], handles);
varargout{1} = out;

% --- Outputs from this function are returned to the command line.
function varargout = draw_scale_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
delete(handles.figure1);

function mutual_exclude(off)
set(off,'Value',0)

function clear_editBox(clean)
% Just clean what might be inside an edit box
set(clean, 'String', '')

function edit_XposLongitude_Callback(hObject, eventdata, handles)
xx = get(hObject,'String');
if isempty(handles.command{6}) & (str2double(xx) > 360 | str2double(xx) < -180)
    errordlg('Don''t push your luck. Enter longitude in the range (-180,180) or 0-360','Error')
    set(hObject, 'String', '');    handles.command{8} = [''];
    return
end
handles.command{8} = [xx];
handles.command{9} = ['/'];     handles.command{11} = ['/'];    handles.command{13} = ['/'];
set(handles.edit_ShowCommand, 'String', [handles.command{5:end}]);
guidata(hObject, handles);

function edit_YposLatitude_Callback(hObject, eventdata, handles)
xx = get(hObject,'String');
if isempty(handles.command{6}) & (str2double(xx) > 90 | str2double(xx) < -90)
    errordlg('Don''t push your luck. Enter latitude in the range (-90,90)','Error')
    set(hObject, 'String', '');    handles.command{10} = [''];
    return
end
handles.command{10} = [xx];
handles.command{9} = ['/'];     handles.command{11} = ['/'];    handles.command{13} = ['/'];
set(handles.edit_ShowCommand, 'String', [handles.command{5:end}]);
guidata(hObject, handles);

function edit_LatitudeOfScale_Callback(hObject, eventdata, handles)
xx = get(hObject,'String');
if (str2double(xx) > 90 | str2double(xx) < -90)
    errordlg('Either you are experimenting or a little ignorant about Earth coordinate systems','Error')
    set(hObject, 'String', '');    handles.command{12} = [''];
    return
end
handles.command{12} = [xx];
handles.command{9} = ['/'];     handles.command{11} = ['/'];    handles.command{13} = ['/'];
set(handles.edit_ShowCommand, 'String', [handles.command{5:end}]);
guidata(hObject, handles);

function edit_LengthOfScale_Callback(hObject, eventdata, handles)
xx = get(hObject,'String');     handles.command{14} = [xx];
handles.command{9} = ['/'];     handles.command{11} = ['/'];    handles.command{13} = ['/'];
set(handles.edit_ShowCommand, 'String', [handles.command{5:end}]);
guidata(hObject, handles);

function checkbox_Fancy_Callback(hObject, eventdata, handles)
if get(hObject,'Value')     handles.command{7} = ['f'];
else handles.command{7} = [''];    end
set(handles.edit_ShowCommand, 'String', [handles.command{5:end}]);
guidata(hObject, handles);

function popup_ScaleUnities_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');     str = get(hObject, 'String');
switch str{val};
    case 'miles'
        handles.command{15} = ['m'];
    case 'nautical miles'
        handles.command{15} = ['n'];
    otherwise
        handles.command{15} = [''];
end
set(handles.edit_ShowCommand, 'String', [handles.command{5:end}]);
guidata(hObject, handles);

function radiobutton_GeogUnities_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    mutual_exclude(handles.radiobutton_PaperUnities)
    handles.command{6} = [''];
end
set(handles.edit_ShowCommand, 'String', [handles.command{5:end}]);
guidata(hObject, handles);

function radiobutton_PaperUnities_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    mutual_exclude(handles.radiobutton_GeogUnities)
    handles.command{6} = ['x'];
end
set(handles.edit_ShowCommand, 'String', [handles.command{5:end}]);
guidata(hObject, handles);

function radiobutton_decimal_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    mutual_exclude([handles.radiobutton_DegMin,handles.radiobutton_DegMinSec])
end

function radiobutton_DegMin_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    mutual_exclude([handles.radiobutton_decimal,handles.radiobutton_DegMinSec])
end

function radiobutton_DegMinSec_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    mutual_exclude([handles.radiobutton_decimal,handles.radiobutton_DegMin])
end

function edit_ShowCommand_Callback(hObject, eventdata, handles)
% Nothing to do. Just echo the GMT command.

function pushbutton_Cancel_Callback(hObject, eventdata, handles)
handles.output = '';        % User gave up, return nothing
guidata(hObject, handles);
uiresume(handles.figure1);

function pushbutton_OK_Callback(hObject, eventdata, handles)
xx = get(handles.edit_ShowCommand, 'String');
if findstr(xx,'//') | findstr(xx,'///')
    errordlg('You didn''t fill all mandatory fields','Error')
    return
end
if isempty(handles.command{6}) & (str2double(handles.command{8}) > 360 | str2double(handles.command{8}) < -180)
    errordlg('You probably played arround with your mouse and left an inconsistent value for the longitude Scale Bar position','Error')
    set(handles.edit_XposLongitude, 'String', '');    handles.command{8} = [''];
    set(handles.edit_ShowCommand, 'String', [handles.command{5:end}]);
    return
end
if isempty(handles.command{6}) & (str2double(handles.command{10}) < -90 | str2double(handles.command{10}) > 90)
    errordlg('You probably played arround with your mouse and left an inconsistent value for the Latitude Scale Bar position','Error')
    set(handles.edit_XposLatitude, 'String', '');    handles.command{10} = [''];
    set(handles.edit_ShowCommand, 'String', [handles.command{5:end}]);
    return
end
handles.output = get(handles.edit_ShowCommand, 'String');
guidata(hObject,handles);
uiresume(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    handles.output = '';        % User gave up, return nothing
    guidata(hObject, handles);
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    handles.output = '';        % User gave up, return nothing
    guidata(hObject, handles);
    delete(handles.figure1);
end

% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% Check for "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    handles.output = '';    % User said no by hitting escape
    guidata(hObject, handles);
    uiresume(handles.figure1);
end   


% --- Creates and returns a handle to the GUI figure. 
function draw_scale_LayoutFcn(h1,handles);

set(h1,...
'PaperUnits','centimeters',...
'CloseRequestFcn',{@figure1_CloseRequestFcn,handles},...
'Color',get(0,'factoryUicontrolBackgroundColor'),...
'KeyPressFcn',{@figure1_KeyPressFcn,handles},...
'MenuBar','none',...
'Name','draw_scale',...
'NumberTitle','off',...
'Position',[265.768111202607 190.120079430433 280 264],...
'RendererMode','manual',...
'Resize','off',...
'Tag','figure1',...
'UserData',[]);

setappdata(h1, 'GUIDEOptions',struct(...
'active_h', [], ...
'taginfo', struct(...
'figure', 2, ...
'edit', 8, ...
'radiobutton', 8, ...
'checkbox', 2, ...
'popupmenu', 2, ...
'pushbutton', 3, ...
'text', 6), ...
'override', 0, ...
'release', 13, ...
'resize', 'none', ...
'accessibility', 'callback', ...
'mfile', 1, ...
'callbacks', 1, ...
'singleton', 1, ...
'syscolorfig', 1, ...
'lastSavedFile', 'D:\m_gmt\draw_scale.m', ...
'blocking', 0));

h2 = uicontrol(...
'Parent',h1,...
'Callback',{@draw_scale_uicallback,h1,'radiobutton_decimal_Callback'},...
'Enable','off',...
'Position',[31 238 62 15],...
'String','decimal',...
'Style','radiobutton',...
'TooltipString','Enter geographical coordinates in dd.xx format',...
'Value',1,...
'Tag','radiobutton_decimal');

h3 = uicontrol(...
'Parent',h1,...
'Callback',{@draw_scale_uicallback,h1,'radiobutton_DegMin_Callback'},...
'Enable','off',...
'Position',[109 238 66 15],...
'String','dd:mm.xx',...
'Style','radiobutton',...
'TooltipString','Enter geographical coordinates in dd:mm.xx format',...
'Tag','radiobutton_DegMin');


h4 = uicontrol(...
'Parent',h1,...
'Callback',{@draw_scale_uicallback,h1,'radiobutton_DegMinSec_Callback'},...
'Enable','off',...
'Position',[192 238 79 15],...
'String','dd:mm:ss.xx',...
'Style','radiobutton',...
'TooltipString','Enter geographical coordinates in dd:mm:ss.xx format',...
'Tag','radiobutton_DegMinSec');

h5 = uicontrol(...
'Parent',h1,...
'Callback',{@draw_scale_uicallback,h1,'radiobutton_GeogUnities_Callback'},...
'Position',[109 217 79 15],...
'String','Geog unities',...
'Style','radiobutton',...
'TooltipString','Scale position is given in geographical coordinates',...
'Value',1,...
'Tag','radiobutton_GeogUnities');


h6 = uicontrol(...
'Parent',h1,...
'Callback',{@draw_scale_uicallback,h1,'radiobutton_PaperUnities_Callback'},...
'Position',[192 217 79 15],...
'String','Paper unities',...
'Style','radiobutton',...
'TooltipString','Scale position is given in paper coordinates',...
'Tag','radiobutton_PaperUnities');


h7 = uicontrol(...
'Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@draw_scale_uicallback,h1,'edit_XposLongitude_Callback'},...
'HorizontalAlignment','left',...
'Position',[110 191 161 21],...
'Style','edit',...
'Tag','edit_XposLongitude');


h8 = uicontrol(...
'Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@draw_scale_uicallback,h1,'edit_YposLatitude_Callback'},...
'HorizontalAlignment','left',...
'Position',[110 165 161 21],...
'Style','edit',...
'Tag','edit_YposLatitude');


h9 = uicontrol(...
'Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@draw_scale_uicallback,h1,'edit_LatitudeOfScale_Callback'},...
'HorizontalAlignment','left',...
'Position',[110 139 161 21],...
'Style','edit',...
'Tag','edit_LatitudeOfScale');


h10 = uicontrol(...
'Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@draw_scale_uicallback,h1,'edit_LengthOfScale_Callback'},...
'HorizontalAlignment','left',...
'Position',[110 113 161 21],...
'Style','edit',...
'TooltipString','e.g. 50, means a bar whose unprojected length is 50 km ',...
'Tag','edit_LengthOfScale');


h11 = uicontrol(...
'Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@draw_scale_uicallback,h1,'popup_ScaleUnities_Callback'},...
'Position',[110 86 111 22],...
'String',{  'kilometers'; 'miles'; 'nautical miles' },...
'Style','popupmenu',...
'TooltipString','Select Scale unities',...
'Value',1,...
'Tag','popup_ScaleUnities');


h12 = uicontrol(...
'Parent',h1,...
'Callback',{@draw_scale_uicallback,h1,'checkbox_Fancy_Callback'},...
'Position',[110 64 81 15],...
'String','Fancy Scale',...
'Style','checkbox',...
'TooltipString','Draw scale using fancy style',...
'Tag','checkbox_Fancy');


h13 = uicontrol(...
'Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@draw_scale_uicallback,h1,'edit_ShowCommand_Callback'},...
'HorizontalAlignment','left',...
'Position',[10 33 261 20.8],...
'Style','edit',...
'TooltipString','Display corresponding GMT command',...
'Tag','edit_ShowCommand');


h14 = uicontrol(...
'Parent',h1,...
'Callback',{@draw_scale_uicallback,h1,'pushbutton_OK_Callback'},...
'Position',[205 7 66 23],...
'String','OK',...
'Tag','pushbutton_OK');


h15 = uicontrol(...
'Parent',h1,...
'Callback',{@draw_scale_uicallback,h1,'pushbutton_Cancel_Callback'},...
'Position',[132 7 66 23],...
'String','Cancel',...
'Tag','pushbutton_Cancel');


h16 = uicontrol(...
'Parent',h1,...
'Enable','inactive',...
'HorizontalAlignment','left',...
'Position',[10 194 97 17],...
'String','Bar Scale X position',...
'Style','text',...
'Tag','text1');


h17 = uicontrol(...
'Parent',h1,...
'Enable','inactive',...
'HorizontalAlignment','left',...
'Position',[10 167 98 15],...
'String','Bar Scale Y position',...
'Style','text',...
'Tag','text2');

h18 = uicontrol(...
'Parent',h1,...
'Enable','inactive',...
'HorizontalAlignment','left',...
'Position',[10 143 91 15],...
'String','Scale at this Lat',...
'Style','text',...
'Tag','text3');

h19 = uicontrol(...
'Parent',h1,...
'Enable','inactive',...
'HorizontalAlignment','left',...
'Position',[10 116 91 15],...
'String','Bar Scale length',...
'Style','text',...
'Tag','text4');

h20 = uicontrol(...
'Parent',h1,...
'Enable','inactive',...
'HorizontalAlignment','left',...
'Position',[10 89 71 15],...
'String','Scale unities',...
'Style','text',...
'Tag','text5');

function draw_scale_uicallback(hObject, eventdata, h1, callback_name)
% This function is executed by the callback and than the handles is allways updated.
feval(callback_name,hObject,[],guidata(h1));
