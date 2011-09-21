function varargout = line_operations(varargin)
% Wraper figure to perform vectorial operations on line/patch objects

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
	
	if (isempty(varargin)),		return,		end
	if (~isfield(varargin{1}, 'head')),		return,		end		% Call from an empty fig
	
	floating = false;
 
	hMirFig = varargin{1}.figure1;
	hMirAxes = varargin{1}.axes1;

	if (~floating)
		hLineOP = getappdata(hMirFig, 'hLineOP');		% Get the uicontrol handles (if they already exist)
		if ( strcmp(get(varargin{1}.lineOP,'checked'), 'off') && isempty(hLineOP) )		% First time use
			old_unit = get(hMirAxes,'units');	set(hMirAxes,'units','pixels')
			pos = get(hMirAxes,'pos');			set(hMirAxes,'units',old_unit)
			hObject = figure('Tag','figure1','MenuBar','none','Visible','off');
			h = line_operations_LayoutFcn(hObject,hMirFig, pos,-2);
			handles = guihandles(hObject);
			handles.edit_cmd		= h(1);
			handles.push_pickLine	= h(2);
			handles.popup_cmds		= h(3);
			handles.push_apply		= h(4);
			handles.push_semaforo	= h(5);
			handles.figure1			= hObject;
			set(varargin{1}.lineOP,'checked', 'on')
			setappdata(hMirFig, 'hLineOP', [hObject h])			% Save for an eventual future use

		elseif ( strcmp(get(varargin{1}.lineOP,'checked'), 'off') && ~isempty(hLineOP) )	% Reuse
			handles.figure1			= hLineOP(1);
			handles.edit_cmd		= hLineOP(2);
			handles.push_pickLine	= hLineOP(3);
			handles.popup_cmds		= hLineOP(4);
			handles.push_apply		= hLineOP(5);
			handles.push_semaforo	= hLineOP(6);
			hObject = hLineOP(1);
			set(handles.push_pickLine,'Tooltip','Have 0 lines to play with')	% Restart clean because we didn't store
			set(handles.push_semaforo,'BackgroundColor',[1 0 0])				% any eventual picked line handles
			set(hLineOP(2:end), 'Vis', 'on')
			set(varargin{1}.lineOP,'checked', 'on')

		else				% Hide, clean and leave
			set(hLineOP, 'Vis', 'off')
			set(varargin{1}.lineOP,'checked', 'off')
			return
		end
	else
		hObject = figure('Tag','figure1','Visible','off');
		line_operations_LayoutFcn(hObject);
		handles = guihandles(hObject);
	end

	handles.hMirFig = hMirFig;
	handles.hMirAxes = hMirAxes;
	handles.lt = varargin{1}.DefLineThick;
	handles.lc = varargin{1}.DefLineColor;
	handles.geog = varargin{1}.geog;
	handles.head = varargin{1}.head;
	handles.path_tmp = varargin{1}.path_tmp;
	IamCompiled = varargin{1}.IamCompiled;

	if (floating)
		move2side(handles.hMirFig, hObject, 'bottom')
		set(hObject,'Visible','on');
	end

	handles.known_ops = {'buffer'; 'polysimplify'; 'bspline'; 'cspline'; 'bezier'; 'polyunion'; 'polyintersect'; ...
			'polyxor'; 'polyminus'; 'line2patch'; 'pline'; 'thicken'; 'toRidge'; 'stitch'; 'scale'; 'hand2Workspace'};
	handles.hLine = [];
	set(handles.popup_cmds,'Tooltip', 'Select one operation from this list')
	set(handles.popup_cmds,'String', {'Possible commands'; 'buffer DIST'; 'polysimplify TOL'; 'bspline'; ...
			'cspline N RES'; 'bezier N'; 'polyunion'; 'polyintersect'; 'polyxor'; 'polyminus'; 'line2patch'; ...
			'pline [x1 ..xn; y1 .. yn]'; 'thicken N'; 'toRidge 5'; 'stitch TOL'; 'scale to [-0.5 0.5]'; 'hand2Workspace'} )

	handles.ttips = cell(numel(handles.known_ops));
	handles.ttips{1} = 'Select one operation from this list';
	handles.ttips{2} = sprintf(['Compute buffer zones arround polylines.\n' ...
								'Replace DIST by the width of the buffer zone.\n\n' ...
								'Optionally you can append NPTS, DIR or GEOD options. Where:\n' ...
								'NPTS -> Number of points used to contruct the circles\n' ...
								'around each polygon vertex. If omitted, default is 13.\n' ...
								'DIR -> ''in'', ''out'' or ''both'' selects whether to plot\n' ...
								'inside, outside or both delineations of the buffer zone.\n' ...
								'GEOD -> ''geod'', or [A B|F] uses an ellipsoidal model.\n' ...
								'First of this cases uses WGS-84 Ellipsoid. Second form selects\n' ...
								'an ellipsoid with A = semi-major axis and B = semi-minor axis\n' ...
								'or B = ellipsoid Flatenning.']);
	handles.ttips{3} = sprintf(['Approximates polygonal curve with desired precision\n' ...
								'using the Douglas-Peucker algorithm.\n' ...
								'Replace TOL by the desired approximation accuracy.\n' ...
								'When data is in geogs, TOL is the tolerance in km.']);
	handles.ttips{4} = sprintf(['Smooth line with a B-form spline\n' ...
								'It will open a help control window to\n' ...
								'help with selection of nice parameters']);
	handles.ttips{5} = sprintf(['Smooth line with a cardinal spline.\n' ...
								'Replace N by the downsampling rate. For example a N of 10\n' ...
								'will take one every other 10 vertices of the polyline.\n' ...
								'The optional RES argument represents the number subdivisions\n' ...
								'between consecutive data points. As an example RES = 10 will\n' ...
								'split the downsampled interval in 10 sub-intervald, thus reseting\n' ...
								'the original number of point, excetp at the end of the line.\n' ...
								'If omited RES defaults to 10.']);
	handles.ttips{6} = sprintf(['Fit a Bezier curve to a polyline.\n' ...
								'Replace N by the number of nodes of the Bezier curve [default 100].']);
	handles.ttips{7} = 'Performs the boolean operation of Union to the selected polygons.';
	handles.ttips{8} = 'Performs the boolean operation of Intersection to the selected polygons.';
	handles.ttips{9} = 'Performs the boolean operation of exclusive OR to the selected polygons.';
	handles.ttips{10} = 'Performs the boolean operation of subtraction to the selected polygons.';
	handles.ttips{11} = 'Convert line objects into patch. Patches, for example, accept fill color.';
	handles.ttips{12} = sprintf(['Dray a polyline with vertices defined by coords [x1 xn; y1 yn].\n' ...
								'Note: you must use the brackets and semi-comma notation as above.\n' ...
								'Example vector: [1 1.5 3.1; 2 4 8.4]']);
	handles.ttips{13} = sprintf(['Thicken line object to a thickness corresponding to N grid cells.\n' ...
								'The interest of this comes when used trough the "Extract profile"\n' ...
								'option. Since the thickned line stored in its pocked N + 1 parallel\n' ...
								'lines, roughly separate by 1 grid cell size, the profile interpolation\n' ...
								'is carried on those N + 1 lines, which are averaged (stacked) in the end.']);
	handles.ttips{14} = sprintf(['Calculate a new line with vertex siting on top of nearby ridges.\n' ...
								'The parameter N is used to search for ridges only inside a sub-region\n' ...
								'2Nx2N centered on current vertex. Default is 5, but you can change it.']);
	handles.ttips{15} = sprintf(['Stitch in cascade the lines that are closer than TOL to selected line.\n' ...
								'Replace TOL by the desired maximum distance for lines still be stitched.\n' ...
								'If removed or left as the string "TOL" (no quotes) it defaults to Inf.']);
	handles.ttips{16} = 'Scale to the [-0.5 0.5] interval.';
	handles.ttips{17} = sprintf(['Send the selected object handles to the Matlab workspace.\n' ...
								'Use this if you want to gain access to all handle properties.']);

	if (IamCompiled),	handles.known_ops(end) = [];	handles.ttips(end) = [];	end		% regretably

	% Add this figure handle to the carra�as list
	plugedWin = getappdata(handles.hMirFig,'dependentFigs');
	plugedWin = [plugedWin hObject];
	setappdata(handles.hMirFig,'dependentFigs',plugedWin);

	guidata(hObject, handles);
	if (nargout),	varargout{1} = hObject;		end

% --------------------------------------------------------------------------------------------------
function push_pickLine_CB(hObject, handles)    
    set(handles.hMirFig,'pointer','crosshair')
    hLine = get_polygon(handles.hMirFig,'multi');        % Get the line handle
	if (numel(hLine) >= 1)
		handles.hLine = unique(hLine);
		set(handles.push_semaforo,'BackgroundColor',[0 1 0])
	else
		set(handles.push_semaforo,'BackgroundColor',[1 0 0])
		handles.hLine = [];
	end
	set(hObject,'Tooltip', ['Have ' sprintf('%d',numel(hLine)) ' lines to play with'])

    set(handles.hMirFig,'pointer','arrow')
	guidata(handles.figure1, handles);

% --------------------------------------------------------------------------------------------------
function popup_cmds_CB(hObject, handles)
	str = get(hObject,'String');	val = get(hObject,'Val');
	set(hObject, 'Tooltip', handles.ttips{val})
	if (val == 1)
		set(handles.edit_cmd,'String', '', 'Tooltip', '' )
	else
		set(handles.edit_cmd,'String', str{val}, 'Tooltip', handles.ttips{val} )
	end

% --------------------------------------------------------------------------------------------------
function push_apply_CB(hObject, handles)
	cmd = get(handles.edit_cmd,'String');
	if (isempty(cmd))
		errordlg('Fiu Fiu!! Apply WHAT????','ERROR'),	return
	end

	[t, r] = strtok(cmd);
	r = ddewhite(r);	% Remove leading spaces on 'r' that idiot strtok didn't care to do
	ind = find(strcmp(t, handles.known_ops));
	if (isempty(ind))
		% Here (will come) a function call which tries to adress the general command issue
		return
	end
	if ( isempty(handles.hLine) && ~strcmp(handles.known_ops{ind}, 'pline') && ~strcmp(handles.known_ops{ind},'scale') )
		errordlg('Fiu Fiu!! Apply WHERE????','ERROR'),	return
	end
	if ( ~strcmp(handles.known_ops{ind},'pline') && ~strcmp(handles.known_ops{ind},'scale') )
		handles.hLine = handles.hLine(ishandle(handles.hLine));
		if (isempty(handles.hLine))
			errordlg('Invalid handle. You probably killed the line(s)','ERROR'),	return
		end
	end
	
	switch handles.known_ops{ind}
		case 'buffer'
			[out, msg] = validate_args(handles.known_ops{ind}, r, handles.geog);
			if (~isempty(msg)),		errordlg(msg,'ERROR'),		return,		end

			direction = 'both';		npts = 13;		% Defaults (+ next line)
			geodetic = handles.geog;		% 1 uses spherical aproximation -- OR -- 0 do cartesian calculation
			dist = out.dist;
			if (out.dir)		direction = out.dir;	end
			if (out.npts)		npts = out.npts;		end
			if (out.ab)
				geodetic = out.ab;
			elseif (out.geod)
				geodetic = out.geod;
			end

			for (k = 1:numel(handles.hLine))
				x = get(handles.hLine(k), 'xdata');		y = get(handles.hLine(k), 'ydata');
 				[y, x] = buffer_j(y, x, dist, direction, npts, geodetic);
				if (isempty(x)),	return,		end
				ind = find(isnan(x));
				if (isempty(ind))			% One only, so no doubts
					h = patch('XData',x, 'YData',y, 'Parent',handles.hMirAxes, 'EdgeColor',handles.lc, ...
						'FaceColor','none', 'LineWidth',handles.lt, 'Tag','polybuffer');
					uistack_j(h,'bottom'),		draw_funs(h,'line_uicontext')
				else
					% Get the length of the segments by ascending order and plot them in that order.
					% Since the uistack will send the last ploted one to the bottom, that will be the larger polygon
					ind = [0 ind(:)' numel(x)];
					[s, i] = sort(diff(ind));		h = zeros(numel(i),1);
					for (m = 1:numel(i))
						h(m) = patch('XData',x(ind(i(m))+1:ind(i(m)+1)-1), 'YData',y(ind(i(m))+1:ind(i(m)+1)-1), 'Parent',handles.hMirAxes, ...
							 'EdgeColor',handles.lc, 'FaceColor','none', 'LineWidth',handles.lt, 'Tag','polybuffer');
					end
					% Do this after so that when it takes time (uistack may be slow) the user won't notice it
					for (m = 1:numel(i)),	uistack_j(h(m),'bottom'),		draw_funs(h(m),'line_uicontext'),		end
				end
			end

		case 'polysimplify'
			[tol, msg] = validate_args(handles.known_ops{ind}, r);
			if (~isempty(msg)),		errordlg(msg,'ERROR'),		return,		end
			for (k = 1:numel(handles.hLine))
				x = get(handles.hLine(k), 'xdata');		y = get(handles.hLine(k), 'ydata');
				if (handles.geog),		B = cvlib_mex('dp', [x(:) y(:)], tol, 'GEOG');
				else					B = cvlib_mex('dp', [x(:) y(:)], tol);
				end
				h = line('XData',B(:,1), 'YData',B(:,2), 'Parent',handles.hMirAxes, 'Color',handles.lc, 'LineWidth',handles.lt, 'Tag','polyline');
				draw_funs(h,'line_uicontext')
			end

		case 'bspline'
			x = get(handles.hLine(1), 'xdata');		y = get(handles.hLine(1), 'ydata');
			[pp,p] = spl_fun('csaps',x,y);			% This is just to get csaps's p estimate
			y = spl_fun('csaps',x,y,p,x);
			h = line('XData', x, 'YData', y, 'Parent',handles.hMirAxes, 'Color',handles.lc, 'LineWidth',handles.lt, 'Tag','polyline');
			draw_funs(h,'line_uicontext')
			smoothing_param(p, [x(1) x(2)-x(1) x(end)], handles.hMirFig, handles.hMirAxes, handles.hLine, h);

		case 'cspline'
			for (k = 1:numel(handles.hLine))
				x = get(handles.hLine(k), 'xdata');		y = get(handles.hLine(k), 'ydata');
				[N, msg] = validate_args(handles.known_ops{ind}, r, numel(x));
				if (~isempty(msg)),		errordlg(msg,'ERROR'),		continue,		end
				np = numel(x);			ind = (1:N(1):np);
				if (x(ind(end)) ~= x(end)),		ind = [ind np];		end		% We want also the last point
				if (numel(N) == 1),			[x,y] = spline_interp(x(ind),y(ind));				% With 10 pts per segment
				else						[x,y] = spline_interp(x(ind),y(ind),'n',N(2));		% With a resolution request
				end
				h = line('XData', x, 'YData', y, 'Parent',handles.hMirAxes, 'Color',handles.lc, 'LineWidth',handles.lt,'Tag','polyline');
				draw_funs(h,'line_uicontext')
			end

		case {'polyunion' 'polyintersect' 'polyxor' 'polyminus'}
			if		(handles.known_ops{ind}(5) == 'u'),		ID = 3;
			elseif	(handles.known_ops{ind}(5) == 'i'),		ID = 1;
			elseif	(handles.known_ops{ind}(5) == 'x'),		ID = 2;
			else											ID = 0;
			end
			[lixo, msg] = validate_args(handles.known_ops{ind}, numel(handles.hLine));
			if (~isempty(msg)),		errordlg(msg,'ERROR'),		return,		end
			P1.x = get(handles.hLine(1), 'xdata');			P1.y = get(handles.hLine(1), 'ydata');
			for (k = 2:numel(handles.hLine))
				P2.x = get(handles.hLine(k), 'xdata');		P2.y = get(handles.hLine(k), 'ydata');
				P1 = PolygonClip(P1, P2, ID);
			end
			for (k = 1:length(P1))
				h = patch('XData', P1(k).x, 'YData', P1(k).y, 'Parent',handles.hMirAxes, 'EdgeColor',handles.lc, ...
					'FaceColor','none', 'LineWidth',handles.lt, 'Tag','polyclip');
				draw_funs(h,'line_uicontext')
			end

		case 'line2patch'
			for (k = 1:numel(handles.hLine))
				if (~strcmp(get(handles.hLine(k),'type'), 'line')),	continue,	end
				x = get(handles.hLine(k), 'xdata');		y = get(handles.hLine(k), 'ydata');
				h = patch('XData',x, 'YData',y, 'Parent',handles.hMirAxes, 'EdgeColor',get(handles.hLine(k),'color'), ...
					'FaceColor','none', 'LineWidth',get(handles.hLine(k),'LineWidth'), 'Tag','line2patch');
				draw_funs(h,'line_uicontext')
				delete(handles.hLine(k))
			end

		case 'pline'
			[out, msg] = validate_args(handles.known_ops{ind}, r);
			if (~isempty(msg)),		errordlg(msg,'ERROR'),		return,		end
			try
				[X{1:out{3}}] = strread(out{1}, repmat('%f',1,out{3}));		% Parse the X coords
				[Y{1:out{3}}] = strread(out{2}, repmat('%f',1,out{3}));		% Parse the Y coords
				x = cat(1,X{:});			y = cat(1,Y{:});
				h = line('XData',x, 'YData',y, 'Parent',handles.hMirAxes, 'Color',handles.lc, 'LineWidth',handles.lt, 'Tag','polyline');
				draw_funs(h,'line_uicontext')
			catch
				errordlg(['Something screwd up. Error message is ' lasterr])
			end

		case 'thicken'
			[out, msg] = validate_args(handles.known_ops{ind}, r, handles.hMirAxes);
			if (~isempty(msg)),		errordlg(msg,'ERROR'),		return,		end
			N = out(1);		hscale = out(2);	vscale = out(3);
			x = get(handles.hLine(1), 'xdata');		y = get(handles.hLine(1), 'ydata');
			
			if (handles.geog)
				[dumb, az] = vdist(y(1:end-1),x(1:end-1), y(2:end),x(2:end));
				az = 90 - az;		% Make it trigonometric
				co = cos(az * pi / 180);	si = sin(az * pi / 180);
			else
				dx = diff(x);				dy = diff(y);
				% calculate the cosine and sine
				hy = (dx.^2 + dy.^2)^.5;
				co =  dx ./ hy;				si =  dy ./ hy;
			end

			thick = N * (handles.head(8) + handles.head(9)) / 2;		% desenrasque, mas foleiro
			% rotate a control line, "th" cells long, based on the slope of the line
% 			foo = [co -si; si  co] * [0	 0; thick/2 -thick/2];
			% Add rotated points to line vertices
			n_pts = numel(x);
			x = x(:);			y = y(:);		% We need them as column vectrs
			x_copy = x;			y_copy = y;
% 			x = [x; x(end:-1:1)];		y = [y; y(end:-1:1)];		% Wrap arround
% 			x(1:n_pts) = x(1:n_pts) + repmat(foo(1,1),n_pts,1);
% 			x(n_pts+1:end) = x(n_pts+1:end) + repmat(foo(1,2),n_pts,1);
% 			y(1:n_pts) = y(1:n_pts) + repmat(foo(2,1),n_pts,1);
% 			y(n_pts+1:end) = y(n_pts+1:end) + repmat(foo(2,2),n_pts,1);
% 			x(end+1) = x(1);			y(end+1) = y(1);			% Close line

			scale = (hscale + vscale) / 2;		% Approximation that works relatively well
 			set(handles.hLine(1), 'LineWidth', thick / scale, 'Tag', 'cellthick')
			refresh
			hui = findobj(get(handles.hLine(1),'UIContextMenu'),'Label', 'Extract profile');
			set(hui, 'Call', 'setappdata(gcf,''StackTrack'',gco); mirone(''ExtractProfile_CB'',guidata(gcbo))')
			try		rmappdata(handles.hMirFig,'TrackThisLine'),		end		% Clear it so that ExtractProfile_CB() in mirone.m knows the way

% 			h = line('XData',x', 'YData',y', 'Parent',handles.hMirAxes, 'Color','w', 'LineWidth',handles.lt, 'Tag','thickned');
% 			draw_funs(h,'line_uicontext')

			% Compute the N+1 lines that will be attached to this thickned line
			dl = thick / N;
			xL = zeros(n_pts, N+1);		yL = zeros(n_pts, N+1);
% 			co = [co co(end)];			si = [si si(end)];
% 			foo1 = zeros(n_pts, 1);		foo2 = zeros(n_pts, 1);
			for (k = 1:N+1)
				th = thick/2 - (k-1) * dl;
				foo = [co(1) -si(1); si(1) co(1)] * [0; th];
				xL(:,k) = x_copy + repmat(foo(1), n_pts, 1);		% One line per column
				yL(:,k) = y_copy + repmat(foo(2), n_pts, 1);
				
				% Tenho de voltar a remoer isto. O problema (em baixo) � que depois n�o vai ter
				% o mesmo n�mero de elementos quando interpolada no grid_profiler (para stakar)
% 				for (m = 1:n_pts)		% This loop has meaning only for polylines, as angles vray between segments
% 					foo = [co(m) -si(m); si(m) co(m)] * [0; th];
% 					foo1(m) = foo(1);	foo2(m) = foo(2);
% 				end
% 				xL(:,k) = x_copy + foo1;		% One line per column
% 				yL(:,k) = y_copy + foo2;
			end
			set(handles.hLine(1), 'UserData', {xL; yL; thick; [x_copy y_copy]; handles.geog; ...	% We'll next info if line is edited
					'MxN X and Y with M = number_vertex and N = number_lines; THICK = thickness in map units; Mx2 = original line; is geog?'})

		case 'hand2Workspace'
			assignin('base','lineHandles',handles.hLine);
			
		case 'toRidge'
			hanMir = guidata(handles.hMirFig);
			[out, msg] = validate_args(handles.known_ops{ind}, r, hanMir);
			if (~isempty(msg)),		errordlg(msg,'ERROR'),		return,		end
			N = out(1);
			[X,Y,Z,head] = load_grd(hanMir);
			if (isempty(Z))		return,		end
			x = get(handles.hLine(1), 'xdata');		y = get(handles.hLine(1), 'ydata');
			dx = N * head(8);			dy = N * head(9);
			f_name = [handles.path_tmp 'lixo.dat'];		% Temp file
			xR = x * NaN;				yR = y * NaN;
			hR = line('XData',xR, 'YData',yR, 'Parent',handles.hMirAxes,'Linewidth', ...
				get(handles.hLine(1),'Linewidth')+1, 'Color',(1 - get(handles.hLine(1),'Color')));
			draw_funs(hR,'line_uicontext')	% Set edition functions
			for (k = 1:numel(x))		% Loop over vertex to find its closest position on the Ridge
				xRec = [max(head(1), x(k)-dx) min(head(2), x(k)+dx)];
				yRec = [max(head(3), y(k)-dy) min(head(4), y(k)+dy)];
				rect = [xRec(1) xRec(1) xRec(2) xRec(2) xRec(1); yRec(1) yRec(2) yRec(2) yRec(1) yRec(1)];
				% Get a small grid arround the current point
				[X,Y,Z,hdr] = mirone('ImageCrop_CB', hanMir, rect, 'CropaGrid_pure');
				out = grdppa_m(Z, hdr);
				if ( ~all(isnan(out(1,:))) )
					double2ascii(f_name,out','%f\t%f');					% Save as file so we can use it mapproject
					pt = mapproject_m([x(k) y(k)], ['-L' f_name]);		% Project and get points along the line
				else
					pt = [0 0 Inf];		% Make it fall into the next 'else' case
				end
				if ( ~isinf(pt(3)) )
					xR(k) = pt(4);		yR(k) = pt(5);
				else
					xR(k) = x(k);		yR(k) = y(k);
				end
				set(hR, 'XData', xR, 'YData', yR)
			end
			clear mapproject_m			% Because of the memory leaks
			set(hanMir.figure1,'pointer','arrow')

		case 'stitch'
			tol = validate_args(handles.known_ops{ind}, r);

			hCurrLine = handles.hLine;
			hLines = findobj(handles.hMirAxes, 'Type', 'line');
			if (numel(hLines) == 1)				% Only one line in the whole plot. Insult and exit
				warndlg('There is only one line in Town. So stitch where?','Chico Clever'),		return
			end
			hLines = setxor(hLines, hCurrLine);
			nLines = numel(hLines);				doAguenta = false;	hAguenta = [];	x = [];		y = [];
			if (nLines > 100 )					% greater than 100?
				hAguenta = aguentabar(0,'title',['Stitching ' sprintf('%d', nLines) ' lines']);
				doAguenta = true;
			end
			for (k = 1:numel(hLines))
				[hLineClosest, endType, indOfFound] = find_closestline(hCurrLine, hLines, tol);
				if (isempty(hLineClosest))		% Either we found and finished or found nothing
					break
				end
				x1 = get(hCurrLine,'XData');	y1 = get(hCurrLine,'YData');
				x2 = get(hLineClosest,'XData');	y2 = get(hLineClosest,'YData');
				if (endType == 1)				% Lines grow in oposite directions from a "mid point"
					x = [x2(end:-1:1) x1];		y = [y2(end:-1:1) y1];
				elseif (endType == 2)			% Line 2 ends near the begining of line 1 
					x = [x2 x1];				y = [y2 y1];
				elseif (endType == 3)			% Line 1 ends near the begining of line 2
					x = [x1 x2];				y = [y1 y2];
				else							% Lines grow from the extremeties twards the "mid point"
					x = [x1 x2(end:-1:1)];		y = [y1 y2(end:-1:1)];
				end
				set(hCurrLine, 'XData',x, 'YData',y)
				delete(hLineClosest)			% It was assimilated, now delete old one.
				hLines(indOfFound) = [];		% Do not process the same line again.
				if (doAguenta && rem(k,10)),	hAguenta = aguentabar(k/nLines);		end
			end
			% Now search for repeated points along the stitched line (nothing uncommon)
			ind_x = (diff(x) ~= 0);		ind_y = (diff(y) ~= 0);
			unicos = (ind_x | ind_y);
			if (~isempty(x))					% Prevent case of an initial x = []
				unicos(end+1) = true;
				x = x(unicos);			y = y(unicos);
				set(hCurrLine, 'XData',x, 'YData',y)
			end

			% Files (imported with ogr) can have each line segment repeated which causes strange effects. 
			% This corrects one type of those effects, which is hard to describe with words.
			knees = zeros(2,1);			nKnees = 0;
			for (k = 1:numel(x)-2)		% Do it scalar because is equaly fast (or more) and waist no memory
				if ( (x(k) == x(k+2)) && (y(k) == y(k+2)) )	% Detect points where line returns along same path.
					nKnees = nKnees + 1;
					knees(nKnees) = k;	
				end
			end
			if (nKnees == 2)
				x = x(knees(1)+1:knees(2)+1);	y = y(knees(1)+1:knees(2)+1);
				set(hCurrLine, 'XData',x, 'YData',y)
			end

			% We still need to check if first and last pts are whithin TOL, case in which line is closed.
			if ( ~isempty(x) && (x(1) ~= x(end)) && (y(1) ~= y(end)) && (sqrt((x(1) - x(end))^2 + (y(1) - y(end))^2) <= tol) )
				x(end+1) = x(1);		y(end+1) = y(1);
				set(hCurrLine, 'XData',x, 'YData',y)
			end
			if (ishandle(hAguenta)),	delete(hAguenta),	end

			% Make it clear that it is neccessary to explicitly pick another line
			set(handles.push_semaforo,'BackgroundColor',[1 0 0])
			set(hObject,'Tooltip', 'Have 0 lines to play with')
			handles.hLine = [];		guidata(handles.figure1, handles)

		case 'bezier'
			n_nodes = validate_args(handles.known_ops{ind}, r);

			vt = linspace(0,1,n_nodes);			bez = zeros(numel(vt), 2);
			x = get(handles.hLine, 'XData');	y = get(handles.hLine, 'YData');
			xy = [x(:) y(:)];

			% Compute each point in the Bezier curve. From Jesus Lucio bezier_.m file in FEX
			np = 1;		n = numel(x) - 1;
			for t = vt
				som = [0 0];
				for (i = 0:n)			% Add the next point multiplied by the corresponding Bernstein polynomial
					som = som + xy(i+1, :) * local_nchoosek(n, i) * (t^i) * ((1 - t)^(n - i));  
				end
				bez(np, :) = som;
				np = np + 1;
			end
			h = line('XData', bez(:,1), 'YData', bez(:,2), 'Parent',handles.hMirAxes, 'Color','r', 'LineWidth',handles.lt,'Tag','polyline');
			draw_funs(h,'line_uicontext')

		case 'scale'

			hLines = findobj(handles.hMirAxes, 'Type', 'line');
			xMin = 1e50;	yMin = 1e50;	xMax = -xMin;	yMax = -yMin;
			for (k = 1:numel(hLines))
				x = get(hLines(k), 'XData');	y = get(hLines(k), 'YData');
				xMin = min([xMin min(x)]);		xMax = max([xMax max(x)]);
				yMin = min([yMin min(y)]);		yMax = max([yMax max(y)]);
			end
			h = mirone;		hNewMirHand = guidata(h);
			hNewMirHand = mirone('FileNewBgFrame_CB', hNewMirHand, [-0.5 0.5 -0.5 0.5 0 1], 'Scaled');
			scale_x = 1 / (xMax - xMin);	off_x = -0.5 - xMin;
			scale_y = 1 / (yMax - yMin);	off_y = -0.5 - yMin;
			if (scale_x < scale_y)
				scale = scale_x;			off_y = -(yMax - yMin) * scale / 2 - yMin;
			else
				scale = scale_y;			off_x = -(xMax - xMin) * scale / 2 - xMin;
			end

			% Now a second run to efectively scale the data
			for (k = 1:numel(hLines))
				x = get(hLines(k), 'XData') * scale + off_x;
				y = get(hLines(k), 'YData') * scale + off_y;
				h = line('XData',x, 'YData',y, 'Parent', hNewMirHand.axes1);
				draw_funs(h,'line_uicontext')
			end
	end

% -------------------------------------------------------------------------------------------------
function [hLineClosest, endType, indOfFound] = find_closestline(hMe, hLines, TOL)
% Find among the HLINES vector of line handles which one is closest the line with handle HME.
% TOL is the max distance that the two lines can be apart and still be considered close.
%	If not provided, defaults to Inf.
% HLINECLOSEST	Is the handle of the closest line or [] if any passes the TOL condition.
% ENDTYPE		Is a integer ranging between 1 and 4, or 0 if no closest line is found. Where
%				1	Lines grow in oposite directions from a "mid point"
%				2	Line 2 (HLINECLOSEST) ends near the begining of line 1 (HME)
%				3	Line 1 (HME) ends near the begining of line 2 (HLINECLOSEST)
%				4	Lines grow from the extremeties twards the "mid point"
% INDOFFOUND	Index of HLINECLOSEST in original HLINES vector. That index of closest line.

	if (nargin == 2),	TOL = inf;		end
	x1 = get(hMe,'XData');				y1 = get(hMe,'YData');

	hLineClosest = [];		endType = 0;	indOfFound = 0;
	minDist = TOL * TOL;	% We do the test with square distances to save calls to sqrt 

	for (k = 1:numel(hLines))
		x2 = get(hLines(k),'XData');		% These calls are horribly expensive, so ...
		dif_x2 = ([(x1(1) - x2(1)); (x1(1) - x2(end)); (x1(end) - x2(1)); (x1(end) - x2(end))]).^2;
		if (min(dif_x2) > minDist),		continue,	end		% we know enough to drop this line.
		y2 = get(hLines(k),'YData');
		if ( (x2(1) == x2(end)) && (y2(1) == y2(end)) )		% Ignore closed polygons
			continue
		end

		dif_y = [(y1(1) - y2(1)); (y1(1) - y2(end)); (y1(end) - y2(1)); (y1(end) - y2(end))];
		dist = sum([dif_x2 dif_y.^2], 2);	% Square of distances between the 4 extremities
		[mimi, I] = min(dist);
		if ( mimi <= minDist )
			indOfFound = k;
			endType = I;
			hLineClosest = hLines(k);
			if (mimi < 1e-8),	break,	end		% This is so small that we can assume to have found the closest
		end
	end

% --------------------------------------------------------------------------------------------
function res = local_nchoosek(n ,k)   % A faster stripped alternative of nchoosek(n, k)
	res = 1;
	if (k == 0),	return,		end
	if (n == 0),	res = 0;	return,	end
	n_k = n - k;
	for (i = 1:k)
		res = res * ((n_k + i)/i);
	end

% --------------------------------------------------------------------------------------------------
function [out, msg] = validate_args(qual, str, np)
% Check for errors on arguments to operation QUAL and return required args, or error
	msg = [];	out = [];
	switch qual
		case 'buffer'
			out.dir = false;	out.npts = false;		out.ab = false;		out.geod = false;
			[t, str] = strtok(str);
			if (strcmp(t, 'DIST'))
				msg = 'The argument "DIST" must be replaced by a numeric value representing the width of the buffer zone';	return
			end
			out.dist = abs( str2double(t) );
			if (isnan(out.dist)),		msg = 'BUFFER argument is nonsense';	return,		end

			% OPTIONS
			str = strrep(str,'''','');		% no ' ' around the char variables
			ind = strfind(str, 'in');
			if (~isempty(ind))
				out.dir = str(ind:ind+1);		str(ind:ind+1) = [];
			end
			ind = strfind(str, 'out');
			if (~isempty(ind))
				out.dir = str(ind:ind+2);		str(ind:ind+2) = [];
			end

			% Ok, here we are over with the 'in' or 'out' options. Proceed
			ind = strfind(str, 'geod');
			if (~isempty(ind))
				out.geod = true;		str(ind:ind+3) = [];		% WGS-84
			end

			% See if we have an ellipsoid
			ind1 = strfind(str,'[');
			if (~isempty(ind1) && numel(ind1) ~= 1),	msg = 'Wrong syntax. ''['' symbol must appear one and only one time';	return,	end
			ind2 = strfind(str,']');
			if (~isempty(ind1) && numel(ind2) ~= 1),	msg = 'Wrong syntax. '']'' symbol must appear one and only one time';	return,	end

			% test the geodetic option
			if (ind1)
				[t1, r] = strtok(str(ind1+1:ind2-1));	t2 = strtok(r);
				a = str2double(t1);		b = str2double(t2);		% b actually may be f (flatening)
				if (isnan(a) || isnan(b))
					msg = 'ellipsoid vector is screwed up. Please revise or pay more attention';	return
				end
				out.ab = [a b];
				str(ind1:ind2) = [];		% Remove it from the opt string
			end
			
			% We still may have the circle NPTS option 
			np = round(abs( str2double(strtok(str)) ));
			if (~isnan(np)),	out.npts = np;		end			

		case 'polysimplify'
			d = strtok(str);
			if (strcmp(d, 'TOL'))
				msg = 'The argument "TOL" must be replaced by a numeric value representing the tolerance';	return
			end
			out = abs( str2double(d) );
			if (isnan(out)),		msg = 'POLYSIMPLIFY argument is nonsense';		end

		case 'cspline'
			[N, r] = strtok(str);
			if (isempty(N))
				msg = 'Must provide N (decimation interval)';		return
			end
			out = round(abs( str2double(N) ));
			if (isnan(out))
				if (N(1) == 'N')
					msg = 'The argument "N" is no to be taken literaly. It must contain the decimation interval';
				else
					msg = 'cspline argument is nonsense';
				end
				return
			elseif (out > np)
				msg = 'N is larger than the number of polyline vertices. Smoothed line would desapear';
			end
			N = round(abs( str2double(strtok(r)) ));		% See if we have resolution request
			if (~isnan(N)),		out(2) = N;		end

		case 'bezier'
			if ( isempty(str) || strcmpi(str, 'N') )
				out = 100;
			else
				out = round(abs(str2double(str)));
			end

		case {'polyunion' 'polyintersect' 'polyxor' 'polyminus'}
			if (str < 2)		% str is in fact the number of handles
				msg = 'you want to make the union of a single line???. Wierd!';
			end

		case 'thicken'
			N = strtok(str);
			if (isempty(N)),	N = '10';		end		% Default value
			out = round(abs( str2double(N) ));
			if (isnan(out))
				if (N(1) == 'N')
					msg = 'The argument "N" is no to be taken literaly. It must contain the number of grid cell to thicken line';
				else
					msg = 'thicken argument is nonsense';
				end
				return
			end
			hMirAxes = np;
         	axLims = getappdata(hMirAxes,'ThisImageLims');
			% create a conversion from data to points for the current axis
			oldUnits = get(hMirAxes,'Units');		set(hMirAxes,'Units','points');
			Pos = get(hMirAxes,'Position');			set(hMirAxes,'Units',oldUnits);
			vscale = 1/Pos(4) * diff(axLims(1:2));	hscale = 1/Pos(3) * diff(axLims(3:4));
			%vscale = (vscale + hscale) / 2;			hscale = vscale;	% For not having a X|Y direction dependency
			DAR = get(hMirAxes, 'DataAspectRatio');
			if (DAR(1) == 1 && DAR(1) ~= DAR(2))	% To account for the "Scale geog images at mean lat" effect
				vscale = vscale * DAR(2);		hscale = hscale * DAR(1);
			end
			out = [out hscale vscale];

		case 'pline'
			ind1 = strfind(str,'[');
			if (numel(ind1) ~= 1),	msg = 'Wrong syntax. ''['' symbol must appear one and only one time';	return,	end
			ind2 = strfind(str,']');
			if (numel(ind2) ~= 1),	msg = 'Wrong syntax. '']'' symbol must appear one and only one time';	return,	end
			ind3 = strfind(str,';');
			if (numel(ind3) ~= 1),	msg = 'Wrong syntax. '';'' symbol must appear one and only one time';	return,	end
			[t, r] = strtok(str(ind1+1:ind3-1));	% Count the number of X coords
			if (isempty(t)),		msg = 'There are no X pts inside the brackets. You fill clever?';		return,	end 
			n = 1;
			while (~isempty(r))
				[t, r] = strtok(r);		n = n + 1;
			end
			out = {str(ind1+1:ind3-1); str(ind3+1:ind2-1); n};

		case 'toRidge'
			if (~np.validGrid)
				msg = 'This operation is only possible with grids. Not images';		return
			end
			N = strtok(str);
			if (isempty(N)),	N = '5';		end		% Default value
			out = round(abs( str2double(N) ));
			if (isnan(out))
				if (N(1) == 'N')
					msg = 'The argument "N" is no to be taken literaly. It must contain the number of grid cell arround vertex';
				else
					msg = 'the N argument is nonsense';
				end
			end

		case 'stitch'
			if ( isempty(str) || strcmpi(str, 'TOL') )
				out = Inf;
			else
				out = abs(str2double(str));
			end
	end

% --------------------------------------------------------------------------------------------------
% --- Creates and returns a handle to the GUI figure. 
function h = line_operations_LayoutFcn(h1, hMirFig, axPos, y_off)
	if (nargin == 4)
		ofset = [axPos(1) y_off 0 0];
		h2 = hMirFig;
		floating = false;
	else
		ofset = [0 0 0 0];
		h2 = h1;
		floating = true;
	end
	
set(h1, 'Position',[520 729 470 48],...
'Color',get(0,'factoryUicontrolBackgroundColor'),...
'Name','Line operations',...
'NumberTitle','off',...
'Resize','off',...
'HandleVisibility','Call',...
'Tag','figure1');

W = 465;	xOff = 3;
if (~floating)
	Wf = min(axPos(3),W+60);		% Frame width
	xOff = (axPos(3) - Wf) / 2;
	h = zeros(1,6);
	h(6) = uicontrol('Parent',h2, 'Position',[xOff 2 Wf axPos(2)] + ofset,'Style', 'frame');
	xOff = xOff + (Wf - W) / 2;		% X offset for the buttons so they are centered in the frame
end

h(1) = uicontrol('Parent',h2, 'Position',[xOff 2 W 24] + ofset,...
'BackgroundColor',[1 1 1],...
'HorizontalAlignment','left',...
'Style','edit',...
'Tag','edit_cmd');

h(2) = uicontrol('Parent',h2, 'Position',[xOff 26 91 21] + ofset,...
'Call',{@lop_CB, h1},...
'FontName','Helvetica', 'FontSize',9,...
'String','Get line(s)',...
'TooltipString','Have 0 lines to play with',...
'Tag','push_pickLine');

h(3) = uicontrol('Parent',h2, 'Position',[140+xOff 26 201 21] + ofset,...
'BackgroundColor',[1 1 1],...
'Call',{@lop_CB, h1},...
'FontName','Helvetica',...
'Style','popupmenu',...
'TooltipString','See list of possible operations and slect template if wished',...
'Value',1,...
'Tag','popup_cmds');

h(4) = uicontrol('Parent',h2, 'Position',[375+xOff 26 91 21] + ofset,...
'Call',{@lop_CB, h1},...
'FontName','Helvetica', 'FontSize',9,...
'String','Apply',...
'Tag','push_apply');

h(5) = uicontrol('Parent',h2, 'Position',[101+xOff 30 14 14] + ofset,...
'BackgroundColor',[1 0 0],...
'Enable','inactive',...
'FontName','Helvetica', 'FontSize',9,...
'TooltipString','Color informs if we have line(s) to work with.',...
'Tag','push_semaforo');

function lop_CB(hObject, eventdata, h1)
% This function is executed by the Call and than the handles is allways updated.
	feval([get(hObject,'Tag') '_CB'],hObject, guidata(h1));
