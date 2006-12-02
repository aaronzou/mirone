function varargout = floodFill(varargin)
% M-File changed by desGUIDE 
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to floodFill_export (see VARARGIN) 
 
hObject = figure('Tag','figure1','Visible','off');
handles = guihandles(hObject);
guidata(hObject, handles);
floodFill_LayoutFcn(hObject,handles);
handles = guihandles(hObject);

% Import icons
load (['data' filesep 'mirone_icons.mat'],'lapis_ico','trincha_ico','pipeta_ico','balde_ico',...
    'circ_ico','rectang_ico','ellipse_ico');

h_toolbar = uitoolbar('parent',hObject, 'BusyAction','queue','HandleVisibility','on',...
   'Interruptible','on','Tag','FigureToolBar','Visible','on');
uipushtool('parent',h_toolbar,'Click',{@line_clickedcallback,'pencil'}, ...
   'cdata',lapis_ico,'TooltipString','Pencil');
uipushtool('parent',h_toolbar,'Click',{@line_clickedcallback,'paintbrush'}, ...
   'cdata',trincha_ico,'TooltipString','Paintbrush');
uipushtool('parent',h_toolbar,'Click',@pipeta_clickedcallback,'cdata',pipeta_ico,'TooltipString','Color Picker');
uipushtool('parent',h_toolbar,'Click',@flood_clickedcallback,'cdata',balde_ico,'TooltipString','Floodfill');
uipushtool('parent',h_toolbar,'Click',{@shape_clickedcallback,'circ'},'cdata',circ_ico,'TooltipString','Circle');
uipushtool('parent',h_toolbar,'Click',{@shape_clickedcallback,'rect'},'cdata',rectang_ico,'TooltipString','Rectangle');
uipushtool('parent',h_toolbar,'Click',{@shape_clickedcallback,'ellipse'},'cdata',ellipse_ico,'TooltipString','Ellipse');

if (~isempty(varargin))
    handles.hCallingFig = varargin{1};
else
    handles.hCallingFig = gcf;        % Useless with Mirone figures because they are hiden to gcf
end

% Try to position this figure glued to the right of calling figure
posThis = get(hObject,'Pos');
posParent = get(handles.hCallingFig,'Pos');
ecran = get(0,'ScreenSize');
xLL = posParent(1) + posParent(3) + 6;
xLR = xLL + posThis(3);
if (xLR > ecran(3))         % If figure is partially out, bring totally into screen
    xLL = ecran(3) - posThis(3);
end
yLL = (posParent(2) + posParent(4)/2) - posThis(4) / 2;
set(hObject,'Pos',[xLL yLL posThis(3:4)])

handles.hCallingAxes = get(handles.hCallingFig,'CurrentAxes');
handles.hImage = findobj(handles.hCallingFig,'Type','image');
img = get(handles.hImage,'CData');
handles.origFig = img;        % Make a copy of the original image
handles.imgSize = size(img);

handles.IAmAMirone = getappdata(handles.hCallingFig,'IAmAMirone');
if (~isempty(handles.IAmAMirone))
    handlesMir = guidata(handles.hCallingFig);
    handles.head = handlesMir.head;
    %handles.origFig = handlesMir.origFig;
    handles.DefLineThick = handlesMir.DefLineThick;
    handles.DefLineColor = handlesMir.DefLineColor;
    handles.image_type = handlesMir.image_type;
else
    handles.IAmAMirone = 0;
    % Build a GMT type header info
    handles.head = [get(handles.hCallingAxes,'xlim') get(handles.hCallingAxes,'ylim') 0 0 1];
    handles.head(8) = (handles.head(2)-handles.head(1)) / size(img,2);
    handles.head(9) = (handles.head(4)-handles.head(3)) / size(img,1);
    
    handles.DefLineThick = 1;
    handles.DefLineColor = [0 0 0];
end

% Initialize some vars
handles.connect = 4;
handles.tol = 20;
handles.randColor = 1;
handles.fillColor = [255 255 255];
handles.useDilation = 1;            % Dilate mask before using it in picking shapes
handles.colorSegment = 1;           % Default to do color segmentation
%handles.colorModel = 'YCrCb';       % When color segmentation, default to this color space
handles.colorModel = [];            % Do color segmentation in RGB
handles.minPts = 50;                % When digitizing, dont create polygs with less than this pts
handles.udCount = 1;                % Unique incremental identifier to set in UserData of polygons
handles.single_poly = 0;            % IF == 1 -> all detected polygons are drawn in a single multi-polygon
handles.bg_color = 0;               % Background color (or color number in cmap)
handles.lineWidth = 3;
handles.elemSquare = 1;

set(handles.listbox_lineWidth,'String',1:99,'Val',2)
set(handles.slider_tolerance,'Value',handles.tol)

%--------------- Give a Pro look (3D) to the frame boxes -------------------------
bgcolor = get(0,'DefaultUicontrolBackgroundColor');
framecolor = max(min(0.65*bgcolor,[1 1 1]),[0 0 0]);
h_f = findobj(hObject,'Style','Frame');
for i=1:length(h_f)
    frame_size = get(h_f(i),'Position');
    f_bgc = get(h_f(i),'BackgroundColor');
    usr_d = get(h_f(i),'UserData');
    if abs(f_bgc(1)-bgcolor(1)) > 0.01           % When the frame's background color is not the default's
        frame3D(hObject,frame_size,framecolor,f_bgc,usr_d)
    else
        frame3D(hObject,frame_size,framecolor,'',usr_d)
        delete(h_f(i))
    end
end

% Recopy the text fields on top of previously created frames (uistack is to damn slow)
h_t = [handles.text_Paint handles.text_DS];
for i=1:length(h_t)
    usr_d = get(h_t(i),'UserData');
    t_size = get(h_t(i),'Position');   t_str = get(h_t(i),'String');    fw = get(h_t(i),'FontWeight');
    bgc = get (h_t(i),'BackgroundColor');   fgc = get (h_t(i),'ForegroundColor');
    t_just = get(h_t(i),'HorizontalAlignment');     t_tag = get(h_t(i),'Tag');
    uicontrol('Parent',hObject, 'Style','text', 'Position',t_size,'String',t_str,'Tag',t_tag, ...
        'BackgroundColor',bgc,'ForegroundColor',fgc,'FontWeight',fw,...
        'UserData',usr_d,'HorizontalAlignment',t_just);
end
delete(h_t)
%------------------- END Pro look (3D) ----------------------------------------------------------

guidata(hObject, handles);
varargout{1} = hObject;
set(hObject,'Visible','on');

% --------------------------------------------------------------------
function line_clickedcallback(hObject, eventdata, opt)
    handles = guidata(hObject);     % get handles
    figure(handles.hCallingFig)
    
    state = uisuspend_j(handles.hCallingFig);        % Remember initial figure state
    if (strcmp(opt,'pencil'))
        set(handles.hCallingFig,'Pointer', 'custom','PointerShapeCData',getPointer('pencil'),'PointerShapeHotSpot',[14 2])
    else
        set(handles.hCallingFig,'Pointer', 'custom','PointerShapeCData',getPointer('brush'),'PointerShapeHotSpot',[14 2])
    end
    w = waitforbuttonpress;
    if (w == 0),    paintFirstButtonDown(handles,state,opt)       % A mouse click
    else            set(handles.hCallingFig,'Pointer', 'arrow');
    end

% -------------------
function paintFirstButtonDown(handles,state,opt)
    if (strcmp(opt,'pencil')),      lineThick = 1;
    else                            lineThick = handles.lineWidth;
    end
    lineType = 8;       % Default to 8 connectivity
    if (get(handles.checkbox_AA,'Value')),      lineType = 16;      end
    pt = get(handles.hCallingAxes, 'CurrentPoint');
    setappdata(handles.figure1,'prev_pt',pt(1,1:2))
    set(handles.hCallingFig,'WindowButtonMotionFcn',{@wbm_line,handles,lineThick,lineType},...
        'WindowButtonDownFcn',{@wbd_paint,handles.hCallingFig,state});
    if (~handles.elemSquare && lineThick > 1)       % Use a round element
        set(handles.hCallingFig,'WindowButtonMotionFcn',{@wbm_circ,handles,lineThick,lineType})
    end

% -------------------
function wbm_line(obj,eventdata,handles,lineThick,lineType)
    % Draw the line using a square element
    pt = get(handles.hCallingAxes, 'CurrentPoint');
    prev_pt = getappdata(handles.figure1,'prev_pt');
    setappdata(handles.figure1,'prev_pt',pt(1,1:2))
    [x,y] = getpixcoords(handles,[prev_pt(1) pt(1,1)],[prev_pt(2) pt(1,2)]);
    x = round(x);       y = round(y);
    if (~insideRect(handles,x(2),y(2))),      return;     end
    win_dx = abs(diff(x)) + 4;         win_dy = abs(diff(y)) + 4;
    
    % Notice that the (2) index denotes the current point
    win_left = max(x(2)-win_dx,1);      win_right = min(x(2)+win_dx,handles.imgSize(2));
    win_top  = max(y(2)-win_dy,1);      win_bot   = min(y(2)+win_dy,handles.imgSize(1));
    if (win_top > win_bot)  % Buble sort
        fds = win_top;        win_top = win_bot;        win_bot = fds;
    end
       
    r = win_top:win_bot;    c = win_left:win_right;
    img = get(handles.hImage,'CData');
    img_s = img(r,c,:);     % Extract a sub-image
    x = x - c(1);           % We need the PTs coords relative to the subimage
    y = y - r(1);
    cvlib_mex('line',img_s,[x(1) y(1)],[x(2) y(2)],handles.fillColor,lineThick,lineType)
    img(r,c,:) = img_s;     % Reimplant the painted sub-image
    set(handles.hImage,'CData',img);

% -------------------
function wbm_circ(obj,eventdata,handles,lineThick,lineType)
    % Draw the line using a circular element
    pt = get(handles.hCallingAxes, 'CurrentPoint');
    [x,y] = getpixcoords(handles,pt(1,1),pt(1,2));
    if (~insideRect(handles,x,y)),      return;     end
    x = round(x);       y = round(y);
    win_left = max(x-lineThick-1,1);      win_right = min(x+lineThick+1,handles.imgSize(2));
    win_top  = max(y-lineThick-1,1);      win_bot   = min(y+lineThick+1,handles.imgSize(1));
    if (win_top > win_bot)
        fds = win_top;        win_top = win_bot;        win_bot = fds;
    end

    r = win_top:win_bot;    c = win_left:win_right;
    img = get(handles.hImage,'CData');
    img_s = img(r,c,:);     % Extract a sub-image
    x = x - c(1);           y = y - r(1);      % We need the PTs coords relative to the subimage
    cvlib_mex('circle',img_s,[x y],lineThick,handles.fillColor,-1,lineType)
    img(r,c,:) = img_s;     % Reimplant the painted sub-image
    set(handles.hImage,'CData',img);

% -------------------
function wbd_paint(obj,eventdata,hCallFig,state)
    set(hCallFig,'WindowButtonMotionFcn','', 'WindowButtonDownFcn','', 'Pointer', 'arrow')
    uirestore_j(state);           % Restore the figure's initial state

% --------------------------------------------------------------------
function pipeta_clickedcallback(hObject, eventdata)
    % Pick one color from image and make it the default painting one
    handles = guidata(hObject);     % get handles
    figure(handles.hCallingFig)
    set(handles.hCallingFig,'Pointer', 'custom','PointerShapeCData',getPointer('pipeta'),'PointerShapeHotSpot',[15 1])
    w = waitforbuttonpress;
    if (w == 0)       % A mouse click
        pt = get(handles.hCallingAxes, 'CurrentPoint');
        [c,r] = getpixcoords(handles,pt(1,1),pt(1,2));
        c = round(c);       r = round(r);
        if (~insideRect(handles,c,r))
            set(handles.hCallingFig,'Pointer', 'arrow');            return;
        end
        img = get(handles.hImage,'CData');
        fillColor = double(img(r,c,:));
        handles.fillColor = reshape(fillColor,1,numel(fillColor));
        set(handles.toggle_currColor,'BackgroundColor',handles.fillColor/255)
        set(handles.hCallingFig,'Pointer', 'arrow');
        guidata(handles.figure1,handles)
    end
    
% -------------------------------------------------------------------------------------
function flood_clickedcallback(hObject, eventdata)
    handles = guidata(hObject);     % get handles
    figure(handles.hCallingFig)
    set(handles.hCallingFig,'Pointer', 'custom','PointerShapeCData',getPointer('bucket'),'PointerShapeHotSpot',[16 15])
    [params,but] = prepareParams(handles,getPointer('bucket'),[16 15]);
    if (isempty(params) || but ~= 1 || ~insideRect(handles,params.Point(1),params.Point(2)))
        set(handles.hCallingFig,'Pointer', 'arrow');        return;
    end
    while (but == 1)
        img = get(handles.hImage,'CData');
        if (ndims(img) == 2)            % Here we have to permanently change the image type to RGB
            img = ind2rgb8(img,get(handles.hCallingFig,'ColorMap'));
            handles.origFig = img;      % Update the copy of the original image
            guidata(handles.figure1,handles)
        end
        img = cvlib_mex('floodfill',img,params);
        set(handles.hImage,'CData', img); 
        [x,y,but] = ginput_pointer(1,getPointer('bucket'),[16 15]);  % Get next point
        [x,y] = getpixcoords(handles,x,y);
        params.Point = [x y];
    end
    set(handles.hCallingFig,'Pointer', 'arrow')

% --------------------------------------------------------------------
function shape_clickedcallback(hObject, eventdata, opt)
    handles = guidata(hObject);     % get handles
    state = uisuspend_j(handles.hCallingFig);        % Remember initial figure state
    set(handles.hCallingFig,'Pointer', 'crosshair')
    figure(handles.hCallingFig)
    
    w = waitforbuttonpress;
    if (w == 0),    ShapeFirstButtonDown(handles,state,opt)       % A mouse click
    else            set(handles.hCallingFig,'Pointer', 'arrow');
    end

% -------------------
function ShapeFirstButtonDown(handles,state,opt)
    lineType = 8;       % Default to 8 connectivity
    if (get(handles.checkbox_AA,'Value')),      lineType = 16;      end
    pt = get(handles.hCallingAxes, 'CurrentPoint');
    [x,y] = getpixcoords(handles,pt(1,1),pt(1,2));
    x = round(x);    y = round(y);
    if (~insideRect(handles,x,y)),  set(handles.hCallingFig,'Pointer', 'arrow');    return;     end
    img = get(handles.hImage,'CData');
    lineThick = handles.lineWidth;
    if (get(handles.checkbox_filled,'Value'))
        lineThick = -lineThick;
    end
    if (strcmp(opt,'circ'))
        set(handles.hCallingFig,'WindowButtonMotionFcn',{@wbm_circle,handles,[x y],img,lineThick,lineType})
    elseif (strcmp(opt,'rect'))
        set(handles.hCallingFig,'WindowButtonMotionFcn',{@wbm_rectangle,handles,[x y],img,lineThick,lineType})
    elseif (strcmp(opt,'ellipse'))
        set(handles.hCallingFig,'WindowButtonMotionFcn',{@wbm_ellipse,handles,[x y],img,lineThick,lineType})
    end
    set(handles.hCallingFig,'WindowButtonDownFcn',{@wbd_paint,handles.hCallingFig,state})
    
% -------------------
function wbm_circle(obj,eventdata,handles,first_pt,IMG,lineThick,lineType)
    % Draw a circle
    pt = get(handles.hCallingAxes, 'CurrentPoint');
    x = round( localAxes2pix(handles.imgSize(2),handles.head(1:2),pt(1,1)) );
    y = round( localAxes2pix(handles.imgSize(1),handles.head(3:4),pt(1,2)) );
    if (~insideRect(handles,x,y)),      return;     end
    dx = abs(x - first_pt(1));          dy = abs(y - first_pt(2));
    rad = round(sqrt(dx*dx + dy*dy));   dt = round(abs(lineThick)/2) + 2;

    win_left = max(first_pt(1) - rad - dt,1);     win_right = min(first_pt(1) + rad + dt,handles.imgSize(2));
    win_top = max(first_pt(2) - rad - dt,1);      win_bot = min(first_pt(2) + rad + dt,handles.imgSize(1));
    
    r = win_top:win_bot;    c = win_left:win_right;
    img_s = IMG(r,c,:);     % Extract a sub-image
    x = first_pt(1) - c(1);           y = first_pt(2) - r(1);      % We need the PTs coords relative to the subimage
    cvlib_mex('circle',img_s,[x y],rad,handles.fillColor,lineThick,lineType)
    IMG(r,c,:) = img_s;     % Reimplant the painted sub-image
    set(handles.hImage,'CData',IMG);
    
% -------------------
function wbm_ellipse(obj,eventdata,handles,first_pt,IMG,lineThick,lineType)
    % Draw an ellipse
    pt = get(handles.hCallingAxes, 'CurrentPoint');
    x = round( localAxes2pix(handles.imgSize(2),handles.head(1:2),pt(1,1)) );
    y = round( localAxes2pix(handles.imgSize(1),handles.head(3:4),pt(1,2)) );
    if (~insideRect(handles,x,y)),      return;     end
    dx = abs(x - first_pt(1));          dy = abs(y - first_pt(2));
    dt = round(abs(lineThick)/2) + 2;

    win_left = max(first_pt(1) - dx - dt,1);     win_right = min(first_pt(1) + dx + dt,handles.imgSize(2));
    win_top = max(first_pt(2) - dy - dt,1);      win_bot = min(first_pt(2) + dy + dt,handles.imgSize(1));
    
    r = win_top:win_bot;    c = win_left:win_right;
    img_s = IMG(r,c,:);     % Extract a sub-image
    x = first_pt(1) - c(1);           y = first_pt(2) - r(1);      % We need the PTs coords relative to the subimage
    box.center = [x y];
    box.size = [2*dx 2*dy];
    cvlib_mex('eBox',img_s,box,handles.fillColor,lineThick,lineType)
    IMG(r,c,:) = img_s;     % Reimplant the painted sub-image
    set(handles.hImage,'CData',IMG);
    
% -------------------
function wbm_rectangle(obj,eventdata,handles,first_pt,IMG,lineThick,lineType)
    % Draw a circle
    pt = get(handles.hCallingAxes, 'CurrentPoint');
    x = round( localAxes2pix(handles.imgSize(2),handles.head(1:2),pt(1,1)) );
    y = round( localAxes2pix(handles.imgSize(1),handles.head(3:4),pt(1,2)) );
    if (~insideRect(handles,x,y)),      return;     end
    dt = round(abs(lineThick)/2) + 2;
    win_dx = abs(x - first_pt(1)) + dt + 2;         win_dy = abs(y - first_pt(2)) + dt + 2;
    
    win_left = max(x-win_dx,1);      win_right = min(x+win_dx,handles.imgSize(2));
    win_top  = max(y-win_dy,1);      win_bot   = min(y+win_dy,handles.imgSize(1));
    if (win_top > win_bot)
        fds = win_top;        win_top = win_bot;        win_bot = fds;
    end
    
    r = win_top:win_bot;    c = win_left:win_right;
    img_s = IMG(r,c,:);     % Extract a sub-image
    x = x - c(1);                       y = y - r(1);      % We need the PTs coords relative to the subimage
    first_pt(1) = first_pt(1) - c(1);   first_pt(2) = first_pt(2) - r(1);
    cvlib_mex('rectangle',img_s,[first_pt(1) first_pt(2)],[x y],handles.fillColor,lineThick,lineType)
    IMG(r,c,:) = img_s;     % Reimplant the painted sub-image
    set(handles.hImage,'CData',IMG);

% -------------------------------------------------------------------------------------
function slider_tolerance_Callback(hObject, eventdata, handles)
    handles.tol = round(get(hObject,'Value'));
    set(handles.text_tol,'String',['Tolerance = ' num2str(handles.tol)])
    guidata(handles.figure1,handles)
        
% -------------------------------------------------------------------------------------
function [params,but] = prepareParams(handles, opt, opt2)
% Prepare the params structure that is to be transmited to cvlib_mex (gets also the point)
% OPT, if provided and contains a 16x16 array, is taken as a pointer
% OPT2, if provided, must be a 2 element vector with 'PointerShapeHotSpot'
% BUT returns which button has been pressed.
    if (nargin == 1),   opt = [];   opt2 = [];   end
    if (nargin == 2),   opt2 = [];  end
    if (~handles.randColor)        % That is, Cte color
        if (~isempty(handles.fillColor))
            params.FillColor = handles.fillColor;
        else
            errordlg('I don''t have yet a filling color. You must select one first.','Error')
            params = [];        return
        end
    end
    figure(handles.hCallingFig)         % Bring the figure containing image forward
    but = 1;                            % Initialize to a left click
    poin = 'crosshair';
    if (numel(opt) == 256),        poin = opt;    end
    [x,y,but]  = ginput_pointer(1,poin,opt2);
    [x,y] = getpixcoords(handles,x,y);
    params.Point = [x y];
    params.Tolerance = handles.tol;
    params.Connect = handles.connect;

% -------------------------------------------------------------------------------------
function [x,y] = getpixcoords(handles,x,y)
    % Convert x,y to pixel coordinates (they are not when the image has other coordinates)
    if (handles.head(7))                % Image is pixel registered
        X = [handles.head(1) handles.head(2)] + [handles.head(8) -handles.head(8)]/2;
        Y = [handles.head(3) handles.head(4)] + [handles.head(9) -handles.head(9)]/2;
    else                                % Image is grid registered
        X = [handles.head(1) handles.head(2)];
        Y = [handles.head(3) handles.head(4)];
    end
    x = localAxes2pix(handles.imgSize(2),X,x);
    y = localAxes2pix(handles.imgSize(1),Y,y);

% --------------------------------------------------------------------
function res = insideRect(handles,x,y)
    % Check if the point x,y in PIXELS is inside the rectangle RECT
    % RECT = [1 handles.imgSize(2) 1 handles.imgSize(1)]
    res = ( x >= 1 && x <= handles.imgSize(2) && y >= 1 && y <= handles.imgSize(1) );

% -------------------------------------------------------------------------------------
function radio_randColor_Callback(hObject, eventdata, handles)
    if (~get(hObject,'Value')),      set(hObject,'Value',1);   return;     end
    set(handles.radio_cteColor,'Value',0)
    handles.randColor = 1;
    set(findobj(handles.figure1,'Style','toggle'),'Enable','Inactive')
    set(handles.pushbutton_moreColors,'Enable','Inactive')
    set(handles.toggle_currColor,'BackgroundColor','w')
    guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
function radio_cteColor_Callback(hObject, eventdata, handles)
    if (~get(hObject,'Value')),      set(hObject,'Value',1);   return;     end
    set(handles.radio_randColor,'Value',0)
    handles.randColor = 0;
    set(findobj(handles.figure1,'Style','toggle'),'Enable','on');
    set(handles.pushbutton_moreColors,'Enable','on')
    guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
function radio_fourConn_Callback(hObject, eventdata, handles)
    if (~get(hObject,'Value')),      set(hObject,'Value',1);   return;     end
    set(handles.radio_eightConn,'Value',0)
    handles.connect = 4;
    guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
function radio_eightConn_Callback(hObject, eventdata, handles)
    if (~get(hObject,'Value')),      set(hObject,'Value',1);   return;     end
    set(handles.radio_fourConn,'Value',0)
    handles.connect = 8;
    guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
function toggle00_Callback(hObject, eventdata, handles)
    % All color toggle end up here
    toggleColors(hObject,handles)

% -------------------------------------------------------------------------------------
function toggleColors(hCurr,handles)
% hCurr is the handle of the current slected toggle color. Get its color
% and assign it to toggle_currColor.
    set(hCurr,'Value',1);               % Reset it to pressed state
    set(handles.toggle_currColor,'BackgroundColor',get(hCurr,'BackgroundColor'))
    handles.fillColor = round(get(hCurr,'BackgroundColor')*255);
    guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
function pushbutton_moreColors_Callback(hObject, eventdata, handles)
    c = uisetcolor;
    if (length(c) > 1)          % That is, if a color was selected
        handles.fillColor = round(c*255);
        set(handles.toggle_currColor,'BackgroundColor',c)
        guidata(handles.figure1,handles)
    end

% -------------------------------------------------------------------------------------
function pushbutton_pickSingle_Callback(hObject, eventdata, handles)
    [params,but] = prepareParams(handles);
    if (isempty(params) || but ~= 1),   return;     end
    img = get(handles.hImage,'CData');              % Get the image
    [dumb,mask] = cvlib_mex('floodfill',img,params);
    if (get(handles.checkbox_useDilation,'Value'))
        mask  = img_fun('bwmorph',mask,'dilate');
    end
    if (handles.colorSegment)
        if (ndims(img) == 3)
            mask = repmat(mask,[1 1 3]);
        end
        img(~mask) = handles.bg_color;
        if (handles.image_type == 2 || handles.image_type == 20)
            h = mirone(img);
            set(h,'ColorMap',get(handles.hCallingFig,'ColorMap'),'Name','Color segmentation')
        else
            tmp.X = handles.head(1:2);  tmp.Y = handles.head(3:4);  tmp.head = handles.head;
            tmp.name = 'Color segmentation';
            mirone(img,tmp);
        end
    else
        digitize(handles,mask)
    end

% -------------------------------------------------------------------------------------
function digitize(handles,img)
    % IMG is binary mask. Digitize its outer contours

    B = img_fun('bwboundaries',img,'noholes');
    
    % Remove short polygons, and reduce pts along rows & cols
    j = false(1,length(B));
	for k = 1:length(B)
		if (length(B{k}) < handles.minPts)
            j(k) = 1;
        else
            df = diff(B{k}(:,1));
            id = df == 0;
            id = id & [false; id(1:end-1)];
            if (any(id)),       B{k}(id,:) = [];   end
            df = diff(B{k}(:,2));
            id = df == 0;
            id = id & [false; id(1:end-1)];
            if (any(id)),       B{k}(id,:) = [];   end
        end
    end
    B(j) = [];
    
    x_inc = handles.head(8);    y_inc = handles.head(9);
    x_min = handles.head(1);    y_min = handles.head(3);
    if (handles.head(7))            % Work in grid registration
        x_min = x_min + x_inc/2;
        y_min = y_min + y_inc/2;
    end

    if (handles.single_poly)                    % Draw a single polygon
        % Add NaNs to the end of each polygon
        nElem = zeros(length(B)+1,1);
		for k = 1:length(B)
            B{k}(end+1,1:2) = [NaN NaN];
            nElem(k+1) = size(B{k},1);
        end
        soma = cumsum(nElem);
    
        x = zeros(soma(end),1);     y = x;
		for k = 1:length(B)
            y(soma(k)+1:soma(k+1)) = (B{k}(:,1)-1) * y_inc + y_min;
            x(soma(k)+1:soma(k+1)) = (B{k}(:,2)-1) * x_inc + x_min;
        end
			
        h_edge = line(x, y,'Linewidth',handles.DefLineThick,'Color',handles.DefLineColor, ...
                'Tag','shape_detected','Userdata',handles.udCount);
            
		multi_segs_str = cell(length(h_edge),1);    % Just create a set of empty info strings
		draw_funs(h_edge,'isochron',multi_segs_str);
        handles.udCount = handles.udCount + 1;
    else                                        % Draw separate polygons
		for k = 1:length(B)
            x = (B{k}(:,2)-1) * x_inc + x_min;
            y = (B{k}(:,1)-1) * y_inc + y_min;
            
            h_edge = line(x, y,'Linewidth',handles.DefLineThick,'Color',handles.DefLineColor, ...
                    'Tag','shape_detected');
            draw_funs(h_edge,'line_uicontext')      % Set lines's uicontextmenu
        end    
    end
    guidata(handles.figure1,handles)
    
% -------------------------------------------------------------------------------------
function pushbutton_pickMultiple_Callback(hObject, eventdata, handles)
    % I left the code that deals with processing in Lab & HSV color models but removed
    % those options from the GUI. This is for the case that I change my mind and decide
    % to reintroduce it. For the time beeing, RGB seams to work better.
    [params,but] = prepareParams(handles);
    if (isempty(params) || but ~= 1),   return;     end
    img = get(handles.hImage,'CData');              % Get the image
    nColors = 0;
    mask = false([size(img,1) size(img,2)]);        % Initialize the mask
    while (but == 1)
        nColors = nColors + 1;
        [dumb,mask(:,:,nColors)] = cvlib_mex('floodfill',img,params);
        [x,y,but] = ginput_pointer(1,'crosshair');  % Get next point
        [x,y] = getpixcoords(handles,x,y);
        params.Point = [x y];
    end
        
    if (~isempty(handles.colorModel))
        if (ndims(img) == 2)
            img = ind2rgb8(img,get(handles.hCallingFig,'ColorMap'));
        end
        img = cvlib_mex('color',img,['rgb2' handles.colorModel]);
    end
            
    if (isempty(handles.colorModel) && ndims(img) == 3)        % That is, RGB model
        a = img(:,:,1);
        b = img(:,:,2);
        c = img(:,:,3);
        cm = zeros(nColors, 6);
        for count = 1:nColors
            cm(count,1) = mean2(a(mask(:,:,count)));
            %cm(count,1) = a(round(params.Point(2)),round(params.Point(1)));
            cm(count,1:2) = [max(cm(count,1) - handles.tol, 0) min(cm(count,1) + handles.tol, 255)];
            cm(count,3) = mean2(b(mask(:,:,count)));
            %cm(count,3) = b(round(params.Point(2)),round(params.Point(1)));
            cm(count,3:4) = [max(cm(count,3) - handles.tol, 0) min(cm(count,3) + handles.tol, 255)];
            cm(count,5) = mean2(c(mask(:,:,count)));
            %cm(count,5) = c(round(params.Point(2)),round(params.Point(1)));
            cm(count,5:6) = [max(cm(count,5) - handles.tol, 0) min(cm(count,5) + handles.tol, 255)];
            tmp = (a >= cm(count,1) & a <= cm(count,2) & b >= cm(count,3) & b <= cm(count,4) & ...
                c >= cm(count,5) & c <= cm(count,6));
            tmp  = img_fun('bwmorph',tmp,'clean');      % Get rid of isolated pixels
            if (get(handles.checkbox_useDilation,'Value'))
                tmp  = img_fun('bwmorph',tmp,'dilate');
                %tmp  = cvlib_mex('dilate',tmp);
                %tmp  = cvlib_mex('morphologyex',tmp,'close');
            end
            if (handles.colorSegment)           % Do color segmentation. One figure for each color
                tmp = repmat(tmp,[1 1 3]);
                img(~tmp) = handles.bg_color;
                if (handles.IAmAMirone)
                    if (handles.image_type == 2 || handles.image_type == 20)
                        h = mirone(img);
                        set(h,'Name','Color segmentation')
                    else
                        tmp.X = handles.head(1:2);  tmp.Y = handles.head(3:4);  tmp.head = handles.head;
                        tmp.name = ['Color segmentation n� ' num2str(1)];
                        mirone(img,tmp);
                    end
                else
        	        figure; image(img);
                end
            else                                % Create contours from mask
                digitize(handles,tmp)
            end
        end
    elseif (isempty(handles.colorModel) && ndims(img) == 2)        % That is, indexed image & RGB model
        cm = zeros(nColors, 2);
        for count = 1:nColors
            cm(count,1) = mean2(img(mask(:,:,count)));
            %cm(count,1) = img(round(params.Point(2)),round(params.Point(1)));
            cm(count,1:2) = [max(cm(count,1) - handles.tol, 0) min(cm(count,1) + handles.tol, 255)];
            tmp = (img >= cm(count,1) & img <= cm(count,2));
            tmp  = img_fun('bwmorph',tmp,'clean');      % Get rid of isolated pixels
            if (get(handles.checkbox_useDilation,'Value'))
                tmp  = img_fun('bwmorph',tmp,'dilate');
            end
            if (handles.colorSegment)           % Do color segmentation. One figure for each color
                img(~tmp) = handles.bg_color;
                if (handles.IAmAMirone)
                    if (handles.image_type == 2 || handles.image_type == 20)
                        h = mirone(img);
                        set(h,'ColorMap',get(handles.hCallingFig,'ColorMap'),'Name','Color segmentation')
                    else
                        tmp.X = handles.head(1:2);  tmp.Y = handles.head(3:4);  tmp.head = handles.head;
                        tmp.name = ['Color segmentation n� ' num2str(1)];
                        tmp.cmap = get(handles.hCallingFig,'ColorMap');
                        mirone(img,tmp);
                    end
                else
        	        h = figure;     image(img);
                    set(h,'ColorMap',get(handles.hCallingFig,'ColorMap'),'Name','Color segmentation')
                end
            else                                % Create contours from mask
                digitize(handles,tmp)
            end
        end
    else                                        % Either YCrCb or Lab model were used
        a = img(:,:,2);
        b = img(:,:,3);
        cm = zeros(nColors, 4);
        for count = 1:nColors
            cm(count,1) = min(min(a(mask(:,:,count))));
            cm(count,2) = max(max(a(mask(:,:,count))));
            cm(count,3) = min(min(b(mask(:,:,count))));
            cm(count,4) = max(max(b(mask(:,:,count))));
            tmp = (a >= cm(count,1) & a <= cm(count,2) & b >= cm(count,3) & b <= cm(count,4));
            %tmp = bwareaopen(tmp,20,4);
            if (handles.colorSegment)           % Do color segmentation. One figure for each color
                tmp = repmat(tmp,[1 1 3]);
                img(~tmp) = handles.bg_color;
                if (handles.IAmAMirone)
                    if (handles.image_type == 2 || handles.image_type == 20)
                        mirone(img);
                    else
                        tmp.X = handles.head(1:2);  tmp.Y = handles.head(3:4);  tmp.head = handles.head;
                        tmp.name = ['Color segmentation n� ' num2str(1)];
                        mirone(img,tmp);
                    end
                else
        	        figure; image(img);
                end
            else                                % Create contours from mask
                digitize(handles,tmp)
            end
        end    
    end
    
% -------------------------------------------------------------------------------------
% function radio_YCrCb_Callback(hObject, eventdata, handles)
%     if (~get(hObject,'Value')),      set(hObject,'Value',1);   return;     end
%     set(handles.radio_Lab,'Value',0)
%     set(handles.radio_RGB,'Value',0)
%     handles.colorModel = 'YCrCb';
%     guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
% function radio_Lab_Callback(hObject, eventdata, handles)
%     if (~get(hObject,'Value')),      set(hObject,'Value',1);   return;     end
%     set(handles.radio_YCrCb,'Value',0)
%     set(handles.radio_RGB,'Value',0)
%     handles.colorModel = 'lab';
%     guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
% function radio_RGB_Callback(hObject, eventdata, handles)
%     % This the only one know (it seams to do better than the others)
%     if (~get(hObject,'Value')),      set(hObject,'Value',1);   return;     end
%     set(handles.radio_YCrCb,'Value',0)
%     set(handles.radio_Lab,'Value',0)
%     handles.colorModel = '';
%     guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
function radio_colorSegment_Callback(hObject, eventdata, handles)
    if (~get(hObject,'Value')),      set(hObject,'Value',1);   return;     end
    set(handles.radio_digitize,'Value',0)
    handles.colorSegment = 1;
    set(handles.edit_minPts,'Visible','off')
    set(handles.text_minPts,'Visible','off')
    guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
function radio_digitize_Callback(hObject, eventdata, handles)
    if (~get(hObject,'Value')),      set(hObject,'Value',1);   return;     end
    set(handles.radio_colorSegment,'Value',0)
    handles.colorSegment = 0;
    set(handles.edit_minPts,'Visible','on')
    set(handles.text_minPts,'Visible','on')
    guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
function edit_minPts_Callback(hObject, eventdata, handles)
    xx = round( str2double(get(hObject,'String')) );
    if (isnan(xx)),     set(hObject,'String','50');     return;     end
    handles.minPts = xx;
    guidata(handles.figure1,handles)

% -------------------------------------------------------------------------------------
function push_restoreImg_Callback(hObject, eventdata, handles)
    set(handles.hImage,'CData',handles.origFig)

% -------------------------------------------------------------------------------------
function pixelx = localAxes2pix(dim, x, axesx)
%   Convert axes coordinates to pixel coordinates.
%   PIXELX = AXES2PIX(DIM, X, AXESX) converts axes coordinates
%   (as returned by get(gca, 'CurrentPoint'), for example) into
%   pixel coordinates.  X should be the vector returned by
%   X = get(image_handle, 'XData') (or 'YData').  DIM is the
%   number of image columns for the x coordinate, or the number
%   of image rows for the y coordinate.

	xfirst = x(1);      xlast = x(max(size(x)));	
	if (dim == 1)
        pixelx = axesx - xfirst + 1;        return;
	end
	xslope = (dim - 1) / (xlast - xfirst);
	if ((xslope == 1) & (xfirst == 1))
        pixelx = axesx;
	else
        pixelx = xslope * (axesx - xfirst) + 1;
	end

% -------------------------------------------------------------------------------------
function y = mean2(x)
%MEAN2 Compute mean of matrix elements.
y = sum(x(:)) / numel(x);

% -------------------------------------------------------------------------------------
function checkbox_useDilation_Callback(hObject, eventdata, handles)
% It does nothing

% -------------------------------------------------------------------------------------
function listbox_lineWidth_Callback(hObject, eventdata, handles)
    handles.lineWidth = get(hObject,'Value');
    guidata(handles.figure1, handles);

% -------------------------------------------------------------------------------------
function radio_square_Callback(hObject, eventdata, handles)
    if (~get(hObject,'Value')),      set(hObject,'Value',1);   return;     end
    handles.elemSquare = 1;
    set(handles.radio_round,'Value',0)
    guidata(handles.figure1, handles);

% -------------------------------------------------------------------------------------
function radio_round_Callback(hObject, eventdata, handles)
    if (~get(hObject,'Value')),      set(hObject,'Value',1);   return;     end
    handles.elemSquare = 0;
    set(handles.radio_square,'Value',0)
    guidata(handles.figure1, handles);

% -------------------------------------------------------------------------------------------------------
function p = getPointer(opt)

if (strcmp(opt,'pipeta'))
	p = [...
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	1	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	1
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	1	1	1
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	NaN	1	1	1	1	1
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	1	1	1	1	1
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	1	1	1	1	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	1	1	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	1	1	1	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	1	1	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	1	NaN	NaN	1	1	1	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	1	NaN	1	1	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	1	NaN	1	1	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	1	NaN	1	1	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	1	1	1	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		1	1	1	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN];
        
elseif (strcmp(opt,'pencil'))
	p = [...
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	1	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	1	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	1	NaN	NaN	NaN	1	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	1	NaN	1	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	1	1	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	1	1	1	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	1	1	1	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	1	1	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN];
        
elseif (strcmp(opt,'brush'))
	p = [...
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	1	1
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	1	NaN	1	1	1	1	1
		NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	1	1	1	1	1	NaN
		NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	1	1	NaN	NaN
		NaN	NaN	NaN	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN
		1	1	1	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	1	NaN	NaN
		NaN	1	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN
		NaN	NaN	1	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN
		NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	1	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN];
elseif (strcmp(opt,'bucket'))
	p = [...
		NaN	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	1	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	1	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	NaN	1	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	NaN	1	NaN	NaN	1	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	NaN	1	NaN	NaN	NaN	1	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN
		NaN	NaN	1	NaN	NaN	NaN	1	NaN	1	NaN	1	NaN	NaN	NaN	NaN	NaN
		NaN	1	NaN	NaN	NaN	NaN	NaN	1	1	NaN	NaN	1	NaN	NaN	NaN	NaN
		NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	NaN	NaN
		NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	1	1	1	NaN
		NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	1	1	NaN
		NaN	NaN	NaN	NaN	1	NaN	NaN	NaN	1	NaN	NaN	NaN	NaN	1	1	NaN
		NaN	NaN	NaN	NaN	NaN	1	1	1	NaN	NaN	NaN	NaN	NaN	1	1	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	NaN
		NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	1	1	NaN];    
end

% --- Creates and returns a handle to the GUI figure. 
function floodFill_LayoutFcn(h1,handles);

set(h1,...
'Color',get(0,'factoryUicontrolBackgroundColor'),...
'MenuBar','none',...
'Name','Flood Fill',...
'NumberTitle','off',...
'Position',[520 390 185 366],...
'Resize','off',...
'HandleVisibility','callback',...
'Tag','figure1');

uicontrol('Parent',h1,'Position',[4 30 177 110],'Style','frame');
uicontrol('Parent',h1,'Position',[4 209 177 153],'Style','frame');

uicontrol('Parent',h1,'BackgroundColor',[1 1 1],...
'Callback',{@floodFill_uicallback,h1,'slider_tolerance_Callback'},...
'Max',255,...
'Position',[4 171 176 16],...
'Style','slider',...
'SliderStep',[0.00390625 0.1],...
'TooltipString','Color detection equal pixel color +/- tolerance',...
'Tag','slider_tolerance');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'pushbutton_pickSingle_Callback'},...
'Position',[12 105 160 23],...
'String','Pick single shape',...
'TooltipString','Pick up the body''s shape with the selected color',...
'Tag','pushbutton_pickSingle');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'radio_fourConn_Callback'},...
'Position',[12 277 70 15],...
'String','4 conn',...
'Style','radiobutton',...
'TooltipString','Floodfill with a connectivity of 4',...
'Value',1,...
'Tag','radio_fourConn');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'radio_eightConn_Callback'},...
'Position',[80 277 86 15],...
'String','8 connectivity',...
'Style','radiobutton',...
'TooltipString','Floodfill with a connectivity of 8',...
'Tag','radio_eightConn');

uicontrol('Parent',h1,'BackgroundColor',[1 0.501960784313725 0.501960784313725],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[13 315 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,'BackgroundColor',[1 0 0],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[29 315 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,'BackgroundColor',[0.501960784313725 0.250980392156863 0.250980392156863],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[45 315 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,'BackgroundColor',[0.250980392156863 0 0],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[61 315 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,'BackgroundColor',[1 1 0.501960784313725],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[77 315 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,...
'BackgroundColor',[1 0.501960784313725 0],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[93 315 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,...
'BackgroundColor',[0.501960784313725 0.501960784313725 0],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[109 315 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,...
'BackgroundColor',[0 1 0],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[125 315 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,...
'BackgroundColor',[0 0.501960784313725 0],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[13 299 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,...
'BackgroundColor',[0 0.501960784313725 0.501960784313725],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[29 299 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,...
'BackgroundColor',[0.501960784313725 0.501960784313725 0.501960784313725],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[45 299 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,...
'BackgroundColor',[0 0 1],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[61 299 15 15],...
'Style','togglebutton',...
'Value',1);

h20 = uicontrol('Parent',h1,...
'BackgroundColor',[0 1 1],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[77 299 15 15],...
'Style','togglebutton',...
'Value',1);

h21 = uicontrol('Parent',h1,...
'BackgroundColor',[1 0.501960784313725 0.752941176470588],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[93 299 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,...
'BackgroundColor',[0.250980392156863 0 0.501960784313725],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[109 299 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@floodFill_uicallback,h1,'toggle00_Callback'},...
'Enable','inactive',...
'Position',[125 299 15 15],...
'Style','togglebutton',...
'Value',1);

uicontrol('Parent',h1,...
'FontSize',9,...
'Position',[69 353 40 15],...
'String','Paint',...
'Style','text','Tag','text_Paint');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'radio_randColor_Callback'},...
'Position',[12 339 90 15],...
'String','Random colors',...
'Style','radiobutton',...
'TooltipString','Repainting will use a randomly selected color',...
'Value',1,...
'Tag','radio_randColor');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'radio_cteColor_Callback'},...
'Position',[115 339 61 15],...
'String','Cte color',...
'Style','radiobutton',...
'TooltipString','Repainting will use a selected color',...
'Tag','radio_cteColor');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'pushbutton_moreColors_Callback'},...
'Enable','inactive',...
'Position',[143 314 30 19],...
'String','More',...
'TooltipString','Chose other color',...
'Tag','pushbutton_moreColors');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Enable','inactive',...
'Position',[143 299 30 16],...
'Style','togglebutton',...
'TooltipString','Current selected color',...
'Value',1,...
'HandleVisibility','off',...
'Tag','toggle_currColor');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'pushbutton_pickMultiple_Callback'},...
'Position',[12 77 160 23],...
'String','Pick multiple shapes',...
'TooltipString','Find out all bounding polygons that share the selected color',...
'Tag','pushbutton_pickMultiple');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'radio_colorSegment_Callback'},...
'Position',[12 54 115 15],...
'String','Color segmentation',...
'Style','radiobutton',...
'TooltipString','Create a separate figure with shapes colored as you selected',...
'Value',1,...
'Tag','radio_colorSegment');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'radio_digitize_Callback'},...
'Position',[12 37 55 15],...
'String','Digitize',...
'Style','radiobutton',...
'TooltipString','Detect bounding polygon to the colored selected body',...
'Tag','radio_digitize');

uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@floodFill_uicallback,h1,'edit_minPts_Callback'},...
'Position',[140 35 33 20],...
'String','50',...
'Style','edit',...
'TooltipString','Shapes with less than this number of vertex won''t be ploted',...
'Tag','edit_minPts',...
'Visible','off');

uicontrol('Parent',h1,...
'Position',[118 38 20 15],...
'String','Min',...
'Style','text',...
'Tag','text_minPts',...
'Visible','off');

uicontrol('Parent',h1,...
'HorizontalAlignment','left',...
'Position',[48 187 90 14],'String','Tolerance = 20',...
'Style','text','Tag','text_tol');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'push_restoreImg_Callback'},...
'Position',[37 4 111 23],'String','Restore image',...
'Tag','push_restoreImg');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'checkbox_useDilation_Callback'},...
'Position',[4 152 80 15],'String','Use Dilation',...
'Style','checkbox',...
'TooltipString','Use dilation operation to find better limits between neighboring shapes',...
'Value',1,...
'Tag','checkbox_useDilation');

h37 = uicontrol('Parent',h1,...
'BackgroundColor',[1 1 1],...
'Callback',{@floodFill_uicallback,h1,'listbox_lineWidth_Callback'},...
'Position',[10 238 40 32],'String',{'LineThickness'},...
'Style','listbox',...
'TooltipString','Line thickness in pixels',...
'Value',1,...
'Tag','listbox_lineWidth');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'radio_square_Callback'},...
'Position',[80 255 95 15],'String','Square element',...
'Style','radiobutton',...
'TooltipString','Use square elements in line drawings',...
'Value',1,...
'Tag','radio_square');

uicontrol('Parent',h1,...
'Callback',{@floodFill_uicallback,h1,'radio_round_Callback'},...
'Position',[80 235 91 15],...
'String','Round element',...
'Style','radiobutton',...
'TooltipString','Use round elements in line drawings',...
'Tag','radio_round');

uicontrol('Parent',h1,'Position',[10 215 80 15],...
'String','Antialiasing','Style','checkbox',...
'TooltipString','Use anti aliasing in line drwaings',...
'Tag','checkbox_AA');

uicontrol('Parent',h1,'Position',[90 215 100 15],...
'String','Filled forms','Style','checkbox',...
'TooltipString','When drawing circles, ellipses or rectangles draw them filled',...
'Tag','checkbox_filled');

uicontrol('Parent',h1,'FontSize',9,...
'Position',[49 131 90 16],...
'String','Digit / Segment',...
'Style','text','Tag','text_DS');

function floodFill_uicallback(hObject, eventdata, h1, callback_name)
% This function is executed by the callback and than the handles is allways updated.
feval(callback_name,hObject,[],guidata(h1));
