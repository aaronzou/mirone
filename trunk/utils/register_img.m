function register_img(handles,h,GCPs)
% HANDLES should be a guidata(hFig) but if it's not (that is, if it's empty) the fig and
% axes handles are fished from H
% H is the handle of a line or patch object
% GCPs is a Mx4 matrix with the source and target GCP coordinates (normally given by GDAL)

if (nargin < 2)
    errordlg('REGISTER_IMG: wrong number of arguments (must be at least two)','ERROR')
    return
end
if ( ~ishandle(h) || ~(strcmp(get(h,'Type'),'line') || strcmp(get(h,'Type'),'patch')) )
    errordlg('REGISTER_IMG: Second argument must be a handle to a line or patch object','ERROR')
    return
end
if (isempty(handles))
    handles.axes1 = get(h,'Parent');
    handles.figure1 = get(handles.axes1,'Parent');
end

hImg = findobj(handles.axes1,'Type','image');
if (isempty(hImg))
    errordlg('REGISTER_IMG: No image in this axes. So what do you want to register?','ERROR')
    return
end

% Make the warping tooltips
trfToolTips{1} = sprintf(['Use this transformation when shapes\n'...
        'in the input image exhibit shearing.\n'...
        'Straight lines remain straight,\n'...
        'and parallel lines remain parallel,\n'...
        'but rectangles become parallelograms.']);
trfToolTips{2} = sprintf(['Use this transformation when shapes\n'...
        'in the input image are unchanged,\n'...
        'but the image is distorted by some\n'...
        'combination of translation, rotation,\n'...
        'and scaling. Straight lines remain straight,\n'...
        'and parallel lines are still parallel.']);
trfToolTips{3} = sprintf(['Use this transformation when the scene\n'...
        'appears tilted. Straight lines remain\n'...
        'straight, but parallel lines converge\n'...
        'toward vanishing points that might or\n'...
        'might not fall within the image.']);
trfToolTips{4} = sprintf(['Use this transformation when objects\n'...
        'in the image are curved. The higher the\n'...
        'order of the polynomial, the better the\n'...
        'fit, but the result can contain more\n'...
        'curves than the base image.']);
trfToolTips{5} = trfToolTips{4};
trfToolTips{6} = trfToolTips{4};
trfToolTips{7} = sprintf(['Use this transformation when parts of\n'...
        'the image appear distorted differently.']);
trfToolTips{8} = sprintf(['Use this transformation (local weighted mean),\n'...
        'when the distortion varies locally and\n'...
        'piecewise linear is not sufficient.']);
handles.trfToolTips = trfToolTips;              % Since handles is not saved this field exists only here

ui_edit_polygon(h)    % Set edition functions
cmenuHand = uicontextmenu;
set(h, 'UIContextMenu', cmenuHand);

if (nargin == 2),   label = 'Set reference Points';
else                label = 'Show GCPs';
end
uimenu(cmenuHand, 'Label', label, 'Callback', {@regOptions,handles,'set'});
uimenu(cmenuHand, 'Label', 'Show GCPs residuals', 'Callback', {@regOptions,handles,'residue'});
uimenu(cmenuHand, 'Label', 'Register Image', 'Callback', {@regOptions,handles,'reg'});
uimenu(cmenuHand, 'Label', 'Change registration method', 'Callback', {@regOptions,handles,'change'});
uimenu(cmenuHand, 'Label', 'Delete GCPs', 'Callback', 'delete(gco)','Separator','on');
uimenu(cmenuHand, 'Label', 'Show GCP numbers', 'Callback', {@showGCPnumbers,handles},'Tag','GCPlab');
uimenu(cmenuHand, 'Label', 'Hide connecting line', 'Callback', 'set(gco,''LineStyle'',''none'')');
uimenu(cmenuHand, 'Label', 'Show connecting line', 'Callback', 'set(gco,''LineStyle'','':'')');

setappdata(handles.figure1,'RegistMethod',{'affine' 'bilinear'})     % Default tranfs type & interp method

if (nargin == 3)
	setappdata(handles.figure1,'GCPregImage',GCPs)
	if (size(GCPs,1) > 10)      % This is likely a mutch better choice
		setappdata(handles.figure1,'RegistMethod',{'polynomial (6 pts)' 'bilinear'})
	end
end

% ----------------------------------------------------------------------------------
function regOptions(obj,event,handles,opt)

hImg = findobj(handles.axes1,'Type','image');
h = findobj(handles.axes1,'Tag','GCPpolyline');     % Fish them because they might have been edited
x = get(h,'XData');     y = get(h,'YData');

try             % I'm fed up with so many possible errors
	switch opt
        case 'set'

            gcpInMem = getappdata(handles.figure1,'GCPregImage');
            if (~isempty(gcpInMem))             % We have them in memory so show them
			    gcps = tableGUI('array',gcpInMem,'RowNumbers','y','ColNames',{'Slave Points - X','Slave Points - Y',...
                        'Master Points - X','Master Points - Y'},'ColWidth',100,'FigName','GCP Table');
            else
                gcps = tableGUI('array',[num2cell([x(:) y(:)]) cell(numel(x),2)],'RowNumbers','y','ColNames',...
                    {'Unreg Points - X','Unreg Points - Y', 'Reg Points - X','Reg Points - Y'},...
                    'ColWidth',100,'FigName','Control Points Table');
            end
            if isempty(gcps),    return;  end     % User gave up
            base = str2double(gcps(:,3:4));
            if ( any(isnan(base)) )
                errordlg('Incomplete table of Control Points','Error')
                return                              % User gave up
            end
            input_x = axes2pix(size(get(hImg,'CData'),2),get(hImg,'XData'),x);
            input_y = axes2pix(size(get(hImg,'CData'),1),get(hImg,'YData'),y);
            input = [input_x(:) input_y(:)];
            setappdata(handles.figure1,'GCPregImage',[input base])
            
        case 'change'           % Change registration &/| interpolation method
            fig_RegMethod(handles);
            
        case 'residue'
            input_base = getappdata(handles.figure1,'GCPregImage');
            if (isempty(input_base))
                errordlg('You need to set first all pairs of Image-Reference Points.','ERROR'); return
            end
            if ( any(isnan(input_base(:,3:4))) )
                errordlg('Incomplete table of Control Points. Use the ''Set reference Points'' option first.','ERROR')
                return
            end
            
            RegistMethod = getappdata(handles.figure1,'RegistMethod');
            trfType      = RegistMethod{1};
            type         = checkTransform(trfType,numel(x));    % Test that n pts and tranfs type are compatible
            if (isempty(type)),     return;    end              % Error message already issued
            
			if (strncmp(type{1},'Poly',4))	% From referenced coords to pixels
				% Polynomial transformations are not ivertible, so here we do it the other way around
				trf = transform_fun('cp2tform',input_base(:,3:4),input_base(:,1:2),type{:});			
				[x,y] = transform_fun('tforminv',trf,input_base(:,3),input_base(:,4));
			else			% From pixels to referenced coords
				trf = transform_fun('cp2tform',input_base(:,1:2),input_base(:,3:4),type{:});			
				[x,y] = transform_fun('tformfwd',trf,input_base(:,1),input_base(:,2));
			end
			set(handles.figure1,'Pointer','watch')
            
			if (handles.geog)
                residue = vdist(input_base(:,4),input_base(:,3), y, x);
                str_res = 'Residue (m)';
			else
				residue = input_base(:,3:4) - [x y];
				residue = sqrt(residue(:,1).^2 + residue(:,2).^2);
				str_res = 'Residue (?)';
			end
			gcp = [x y input_base(:,3:4) residue];
			tableGUI('array',gcp,'RowNumbers','y','ColNames',{'Slave Points - X','Slave Points - Y',...
                    'Master Points - X','Master Points - Y',str_res},'ColWidth',100,'FigName','GCP Table','modal','');
            set(handles.figure1,'Pointer','arrow')
                    
        case 'reg'          % Register image
            input_base = getappdata(handles.figure1,'GCPregImage');
            if (isempty(input_base))
                errordlg('You need to set first all pairs of Image-Reference Points.','ERROR'); return
            end
            base = input_base(:,3:4);
            if ( any(isnan(base)) )
                errordlg('Incomplete table of Control Points. Use the ''Set reference Points'' option first.','ERROR')
                return
            end
            set(handles.figure1,'Pointer','watch')
            do_register(handles,input_base(:,1:2),base)
            set(handles.figure1,'Pointer','arrow')
	end
catch
    errordlg(lasterr,'Error')
    set(handles.figure1,'Pointer','arrow')
end

% ----------------------------------------------------------------------------------
function do_register(handles,input,base)

h_img = findobj(handles.axes1,'Type','image');
x = input(:,1);     y = input(:,2);

RegistMethod = getappdata(handles.figure1,'RegistMethod');
trfType     = RegistMethod{1};
interpola   = RegistMethod{2};
type = checkTransform(trfType,numel(x));    % Test that n pts and tranfs type are compatible
if (isempty(type)),     return;    end      % Error message already issued
img         = get(h_img,'CData');

trf = transform_fun('cp2tform',input,base,type{:});
[img,new_xlim,new_ylim] = transform_fun('imtransform',img,trf,interpola,'size',size(img));
%[img,new_xlim,new_ylim] = transform_fun('imtransform',img,trf,'XData',[1 size(img,2)],'YData',[1 size(img,1)]);


tmp.head(1:7) = [new_xlim new_ylim 0 255 1];
tmp.head(8) = diff(new_xlim) / (size(img,2) - 1);
tmp.head(9) = diff(new_ylim) / (size(img,1) - 1);
tmp.X = new_xlim;
tmp.Y = new_ylim;
tmp.name = 'Rigestered Image';
if (ndims(img) == 2)
    tmp.cmap = get(handles.figure1,'ColorMap');
end
mirone(img,tmp);

% ---------------------------------------------------------------------------
function type = checkTransform(type,n_cps)
% Check that the number of points is enough for the selected transform

switch type
    case 'affine',              transf = 1;
    case 'linear conformal',    transf = 2;
    case 'projective',          transf = 3;
    case 'polynomial (6 pts)',  transf = 4;
    case 'polynomial (10 pts)', transf = 5;
    case 'polynomial (16 pts)', transf = 6;
    case 'piecewise linear',    transf = 7;
    case 'lwm',                 transf = 8;
end

msg = '';
if (transf == 1 && n_cps < 3)
    msg = 'Minimum Control points for affine transform is 3.';
elseif (transf == 2 && n_cps < 2)
    msg = 'Minimum Control points for Linear conformal transform is 2.';
elseif (transf == 3 && n_cps < 4)
    msg = 'Minimum Control points for projective transform is 4.';
elseif (transf == 4 && n_cps < 6)
    msg = 'Minimum Control points for polynomial order 2 transform is 6.';
elseif (transf == 5 && n_cps < 6)
    msg = 'Minimum Control points for polynomial order 3 transform is 10.';
elseif (transf == 6 && n_cps < 6)
    msg = 'Minimum Control points for polynomial order 2 transform is 16.';
elseif (transf == 7 && n_cps < 4)
    msg = 'Minimum Control points for piecewise linear transform is 4.';
elseif (transf == 8 && n_cps < 6)
    msg = 'Minimum Control points for Locolal weightd mean transform is 6.';
end

if (strncmp(type,'poly',4))
    % 'Polynomial (6 pts)', 'Polynomial (10 pts)'; 'Polynomial (16 pts)'
    polPts = str2double(type(13:14));      % See above why
    switch polPts
        case 6,     type = {'polynomial' 2};
        case 10,    type = {'polynomial' 3};
        case 16,    type = {'polynomial' 4};
    end
else
    type = {type};
end

if (~isempty(msg))
    errordlg([msg ' Either select more CPs or choose another trasform type'],'Error');
    type = [];
end

% -----------------------------------------------------------------------------------------
function fig_RegMethod(handles)
% Ctreate or bring to front a small figure with two popups containing the registration options

hFig = handles.figure1;
h_old = findobj(0,'Type','figure','Tag','fig_RegMethod');

if (isempty(h_old))
    ecran = get(0,'ScreenSize');
	h = figure('MenuBar','none', 'Name','Registration Method', 'NumberTitle','off','Resize','off',...
 	'Position',[ecran(3)/2 ecran(4)/2 270 23], 'Tag','RegistMethod', 'Visible','off');
		
	% ---------------- Create the popups
    str1 = {'Affine'; 'Linear conformal'; 'Projective'; 'Polynomial (6 pts)';...
            'Polynomial (10 pts)'; 'Polynomial (16 pts)'; 'Piecewise linear'; 'Loc weighted mean'};
	hTrf = uicontrol('Units','Pixels','TooltipString','Type of transformation',...
        'String', str1, 'Pos',[10 2 130 22],'Style','popupmenu', 'BackgroundColor','w','Tag','Trf');
    set(hTrf,'Callback',{@cb_trf,hFig,hTrf})
	
    str2 = {'bilinear'; 'bicubic'; 'nearest';};
	hInterp = uicontrol('Units','Pixels','TooltipString','Specifies the form of interpolation to use.',...
        'String',str2, 'BackgroundColor','w', 'Pos',[160 2 90 22],'Style','popupmenu','Tag','Interp');
    set(hInterp,'Callback',{@cb_interp,hFig,hInterp})
    
    % Start with the last selected value
    RegistMethod = getappdata(hFig,'RegistMethod');
	idW = strmatch(RegistMethod{1},lower(str1));
    if (isempty(idW)),   idW = 8;     end     % Last one is 'lwm' but its text is 'Loc weighted mean'
    set(hTrf,'Value',idW)
	id = strmatch(RegistMethod{2},str2);
    set(hInterp,'Value',id)
    
    set(hTrf,'TooltipString',handles.trfToolTips{idW})  % Set the tooltip for the selected method
    setappdata(hFig,'trfToolTips',handles.trfToolTips)  % Save it in appdata so that it's accessible in the callback
    
	set(h,'Visible','on')
else
    figure(h_old)
end

%-----------------------------------------------------------------------------------
function cb_trf(obj,event,hFig,h)
	% Transform type popup callback
	transf = get(h,'Value');
	switch transf
		case 1,     type = 'affine';
		case 2,     type = 'linear conformal';
		case 3,     type = 'projective';
		case 4,     type = 'polynomial (6 pts)';
		case 5,     type = 'polynomial (10 pts)';
		case 6,     type = 'polynomial (16 pts)';
		case 7,     type = 'piecewise linear';
		case 8,     type = 'lwm';
	end
	RegistMethod = getappdata(hFig,'RegistMethod');
	setappdata(hFig,'RegistMethod',{type RegistMethod{2}})
	trfToolTips = getappdata(hFig,'trfToolTips');
	set(h,'TooltipString',trfToolTips{transf})   % Set the tooltip for the selected method

%-----------------------------------------------------------------------------------
function cb_interp(obj,event,hFig,h)
	% Interpolation method popup callback
	interpola = get(h,'String');
	interpola = interpola{get(h,'Value')};
	RegistMethod = getappdata(hFig,'RegistMethod');
	setappdata(hFig,'RegistMethod',{RegistMethod{1} interpola})

%-----------------------------------------------------------------------------------
function showGCPnumbers(obj,event,handles)
% Plot/desplot the GCPs numbers

if (strcmp(get(obj,'Label'),'Show GCP numbers'))
    
    hPts = findobj(handles.axes1,'Tag','GCPpolyline');     % Fish them because they might have been edited
	xSlaves = get(hPts,'Xdata');        ySlaves = get(hPts,'Ydata');
	
	% Estimate the text position shift in order that it doesn't fall over the symbols
    dpis = get(0,'ScreenPixelsPerInch') ;   % screen DPI
    symb_size = 7 / 72 * 2.54;              % Symbol size in cm (circles size is 7 points)
	n_texts = numel(xSlaves);
    
	axUnit = get(handles.axes1,'Units');	set(handles.axes1,'Units','pixels')
	pos = get(handles.axes1,'Position');    ylim = get(handles.axes1,'Ylim');
	set(handles.axes1,'Units',axUnit)
    escala = diff(ylim)/(pos(4)*2.54/dpis); % Image units / cm
    dy = symb_size * escala;
    
	for i = 1:n_texts
        text(xSlaves(i),ySlaves(i)+dy,0,num2str(i),'Fontsize',8,'Parent',handles.axes1,'Tag','GCPnumbers');
	end
    
    % Change the uimenus label to "Hide"
    hS = get(hPts,'uicontextmenu');
    set(findobj(hS,'Tag','GCPlab'),'Label','Hide GCP numbers')
else
    delete(findobj(handles.axes1,'Type','text','Tag','GCPnumbers'))
	hPts = findobj(handles.axes1,'Type','line','Tag','GCPpolyline');
    
    % Change the uimenus labels to "Hide"
    hS = get(hPts,'uicontextmenu');
    set(findobj(hS,'Tag','GCPlab'),'Label','Show GCP numbers')
end
