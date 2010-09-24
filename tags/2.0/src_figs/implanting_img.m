function varargout = implanting_img(varargin)
% M-File changed by desGUIDE 

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
implanting_img_LayoutFcn(hObject);
handles = guihandles(hObject);
move2side(hObject,'center');

set(hObject,'Name','Transplant Image')
handles.IPcmap = [];        % Initialize implanting image colormap to empty
handles.output = [];
handles.resizeIP = 1;
handles.resizeBG = 0;

% Load background image
axes(handles.axes_bg)
handles.bg_img = get(varargin{1},'CData');      handles.h_BGimg = varargin{1};
[m,n,k] = size(handles.bg_img);    handles.BGsize = [m n k];

% Compute background image aspect ratio and set axes_ip 'PlotBoxAspectRatio' to it
bg_aspect = m / n;
image(varargin{3},varargin{4},handles.bg_img);  axis xy;    axis off
set(handles.axes_bg,'PlotBoxAspectRatio',[1 bg_aspect 1])

handles.rect_x = get(varargin{2},'XData');   handles.rect_y = get(varargin{2},'YData');
% The xlim & ylim respect the background image
handles.xlim   = varargin{3};                handles.ylim = varargin{4};

% Draw the croping rectangle
line('XData',handles.rect_x,'YData',handles.rect_y, 'Color','w','LineWidth',.5,'Tag','CropRect')

% Load the Coffeeright logo as the default Implanting image
axes(handles.axes_ip)
handles.IPimg = imread(['data' filesep 'cafe_logo113x100.png']);      handles.IPcmap = [];
[m,n,k] = size(handles.IPimg);    handles.IPsize = [m n k];

% Compute implanting image aspect ratio and set axes_ip 'PlotBoxAspectRatio' to it
ip_aspect = m / n;
% Resize ip_axes_aspect to ip_aspect, but with the constraint that it's not over ??
image(handles.IPimg);   axis off;
set(handles.axes_ip,'PlotBoxAspectRatio',[1 ip_aspect 1])

% Get rectangle limits and transform them into row-col limits
x(1) = handles.rect_x(1);     x(2) = handles.rect_x(2);     x(3) = handles.rect_x(3);
y(1) = handles.rect_y(1);     y(2) = handles.rect_y(2);
r_c = cropimg(handles.xlim, handles.ylim, handles.bg_img, ...
    [x(1) y(1) (x(3)-x(2)) (y(2)-y(1))], 'out');
handles.r_c = r_c;

%Now we have to find out the final enlarged background image size (in case it is wanted)
scale_y = m / (r_c(2) - r_c(1) + 1);
scale_x = n / (r_c(4) - r_c(3) + 1);
handles.BGsize(1) = round(scale_y * double(handles.BGsize(1)));
handles.BGsize(2) = round(scale_x * double(handles.BGsize(2)));

% Set those to 'off' until they need to be made visible
set(handles.h_txtBgImgSize,'Visible','off')
set(handles.h_BGsize,'Visible','off')
set(handles.h_BGsize,'String',[num2str(handles.BGsize(1)) ' x ' num2str(handles.BGsize(2))])

% Choose default command line output for implanting_img_export
handles.output = hObject;
guidata(hObject, handles);

set(hObject,'Visible','on');
% UIWAIT makes implanting_img_export wait for user response (see UIRESUME)
uiwait(handles.figure1);

handles = guidata(hObject);
varargout{1} = handles.output;
delete(handles.figure1);

% ---------------------------------------------------------------------------------------
function pushbutton_loadInplantImg_CB(hObject, handles)
handles.home_dir = cd;		% Only to be able to call put_or_get_file
handles.last_dir = cd;		handles.work_dir = cd;

[FileName,PathName] = put_or_get_file(handles,{ ...
    '*.bmp', 'Windows Bitmap (*.bmp)'; ...
    '*.jpg', 'JPEG image (*.jpg)'; ...
    '*.pcx', 'Windows Paintbrush (*.pcx)'; ...
    '*.png', 'Portable Network Graphics(*.png)'; ...
    '*.ras', 'SUN rasterfile (*.ras)'; ...
    '*.tif', 'Tagged Image File (*.tif)'; ...
    '*.gif', 'GIF image (*.gif)'; ...
    '*.xwd', 'X Windows Dump (*.xwd)'; ...
    '*.*', 'All Files (*.*)'}, ...
    'Select Image to Transplant','get');
if isequal(FileName,0)		return,		end
[I,handles.IPcmap] = imread([PathName FileName]);
handles.IPimg = I;          [m,n,k] = size(I);  handles.IPsize = [m n k];
axes(handles.axes_ip);      image(I);           axis off;

% Compute implanting image aspect ratio and set axes 'PlotBoxAspectRatio' to it
ip_aspect = m / n;
set(handles.axes_ip,'PlotBoxAspectRatio',[1 ip_aspect 1])

% Get rectangle limits and transform them into row-col limits
x(1) = handles.rect_x(1);     x(2) = handles.rect_x(2);     x(3) = handles.rect_x(3);
y(1) = handles.rect_y(1);     y(2) = handles.rect_y(2);
r_c = cropimg(handles.xlim, handles.ylim, get(handles.h_BGimg,'CData'), ...
    [x(1) y(1) (x(3)-x(2)) (y(2)-y(1))], 'out');
handles.r_c = r_c;

% Find out if implanting rectangle requires enlarging or shrinking the implanting image
%new_IPheight = r_c(2)-r_c(1)+1;     new_IPwidth = r_c(4)-r_c(3)+1;
% if (new_IPheight > m | new_IPwidth > n)         % enlange the implanting image
    set(handles.radiobutton_resizeIPimg,'Value',1)
    set(handles.radiobutton_resizeBGimgSize,'Value',0)
    set(handles.h_txtBgImgSize,'Visible','off')
    set(handles.h_BGsize,'Visible','off')
% else                                             % enlarge the background image (NOT WORKING)
%     set(handles.radiobutton_resizeIPimg,'Value',0)
%     set(handles.radiobutton_resizeBGimgSize,'Value',1)
%     % Now we have to find out the final enlarged background image size
%     scale_y = m / new_IPheight;
%     scale_x = n / new_IPwidth;
%     new_BGheight = round(scale_y * handles.BGsize(1));
%     new_BGwidth  = round(scale_x * handles.BGsize(2));
%     set(handles.h_txtBgImgSize,'Visible','on')
%     set(handles.h_BGsize,'String',[num2str(new_BGheight) ' x ' num2str(new_BGwidth)],'Visible','on')
%     % Update extended background image size
%     handles.BGsize(1) = new_BGheight;   handles.BGsize(2) = new_BGwidth;
% end
guidata(hObject, handles);

% ---------------------------------------------------------------------------------------
function radiobutton_resizeIPimg_CB(hObject, handles)
set(hObject,'Value',1);                         set(handles.radiobutton_resizeBGimgSize,'Value',0)
set(handles.h_txtBgImgSize,'Visible','off');    set(handles.h_BGsize,'Visible','off')
handles.resizeIP = 1;    handles.resizeBG = 0;  guidata(hObject, handles);

% ---------------------------------------------------------------------------------------
function radiobutton_resizeBGimgSize_CB(hObject, handles)
set(hObject,'Value',1);                         set(handles.radiobutton_resizeIPimg,'Value',0)
set(handles.h_BGsize,'String',[num2str(handles.BGsize(1)) ' x ' num2str((handles.BGsize(2)))])
set(handles.h_txtBgImgSize,'Visible','on');     set(handles.h_BGsize,'Visible','on')
handles.resizeIP = 0;    handles.resizeBG = 1;  guidata(hObject, handles);

% ---------------------------------------------------------------------------------------
function pushbutton_InplantThisImg_CB(hObject, handles)
if (get(handles.radiobutton_resizeBGimgSize,'Value'))
    warndlg('Sorry, this is not yet working','Warning')
    set(handles.radiobutton_resizeBGimgSize,'Value',0)
    set(handles.radiobutton_resizeIPimg,'Value',1)
    set(handles.h_txtBgImgSize,'Visible','off');    set(handles.h_BGsize,'Visible','off')
    return
end
out.ip_img = handles.IPimg;
out.ip_cmap = handles.IPcmap;
out.resizeIP = handles.resizeIP;
out.resizeBG = handles.resizeBG;
out.bg_size_updated = handles.BGsize;
out.r_c = handles.r_c;
handles.output = out;
guidata(hObject,handles)
uiresume(handles.figure1);

% ---------------------------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata)
handles = guidata(hObject);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    handles.output = [];          % User gave up, return nothing
    guidata(hObject, handles);    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    handles.output = [];          % User gave up, return nothing
    guidata(hObject, handles);    uiresume(handles.figure1);
end

% ---------------------------------------------------------------------------------------
function figure1_KeyPressFcn(hObject, eventdata)
% Check for "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
	handles = guidata(hObject);
    handles.output = [];          % User said no by hitting escape
    guidata(hObject, handles);    uiresume(handles.figure1);
end

% --- Creates and returns a handle to the GUI figure. 
function implanting_img_LayoutFcn(h1)

set(h1,'PaperUnits',get(0,'defaultfigurePaperUnits'),...
'CloseRequestFcn',@figure1_CloseRequestFcn,...
'Color',get(0,'factoryUicontrolBackgroundColor'),...
'KeyPressFcn',@figure1_KeyPressFcn,...
'MenuBar','none',...
'Name','implanting_img',...
'NumberTitle','off',...
'Position',[520 497 400 303],...
'RendererMode','manual',...
'Resize','off',...
'Tag','figure1');

axes('Parent',h1,'Units','pixels',...
'CameraPosition',[0.5 0.5 9.16025403784439],...
'Color',get(0,'defaultaxesColor'),...
'ColorOrder',get(0,'defaultaxesColorOrder'),...
'Position',[10 85 211 211],...
'Tag','axes_bg');

axes('Parent',h1,'Units','pixels',...
'CameraPosition',[0.5 0.5 9.16025403784439],...
'Color',get(0,'defaultaxesColor'),...
'ColorOrder',get(0,'defaultaxesColorOrder'),...
'Position',[280 135 111 111],...
'Tag','axes_ip');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'pushbutton_InplantThisImg_CB'},...
'Position',[280 110 111 23],...
'String','Implant this image',...
'Tag','pushbutton_InplantThisImg');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'radiobutton_resizeIPimg_CB'},...
'FontSize',9,...
'Position',[10 60 316 16],...
'String','Resize implanting image to background image density',...
'Style','radiobutton',...
'Value',1,...
'Tag','radiobutton_resizeIPimg');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'radiobutton_resizeBGimgSize_CB'},...
'FontSize',9,...
'Position',[10 40 316 16],...
'String','Resize background image to implanting image density',...
'Style','radiobutton',...
'Tag','radiobutton_resizeBGimgSize');

uicontrol('Parent',h1,'FontSize',9,...
'HorizontalAlignment','left',...
'Position',[10 10 197 16],...
'String','New background image size will be:',...
'Style','text',...
'Tag','h_txtBgImgSize');

uicontrol('Parent',h1,'FontSize',9,...
'HorizontalAlignment','left',...
'Position',[214 11 101 15],...
'String','Size',...
'Style','text',...
'Tag','h_BGsize');

uicontrol('Parent',h1,...
'Call',{@main_uiCB,h1,'pushbutton_loadInplantImg_CB'},...
'Position',[280 87 111 23],...
'String','Load Image to implant',...
'Tag','pushbutton_loadInplantImg');

function main_uiCB(hObject, eventdata, h1, callback_name)
% This function is executed by the callback and than the handles is allways updated.
	feval(callback_name,hObject,guidata(h1));
