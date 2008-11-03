function  datasets_funs(opt,varargin)
% This contains the Mirone's 'Datasets' funtions

switch opt(1:3)
	case 'Coa'
		CoastLines(varargin{:})
	case 'Pol'
		PoliticalBound(varargin{:})
	case 'Riv'
		Rivers(varargin{:})
	case 'Pla'
		DatasetsPlateBound_PB_All(varargin{:})
	case 'ODP'
		DatasetsODP_DSDP(varargin{:})
	case 'Hot'
		DatasetsHotspots(varargin{:})
	case 'Vol'
		DatasetsVolcanoes(varargin{:})
	case 'Tid'
		DatasetsTides(varargin{:})
	case 'Iso'
		DatasetsIsochrons(varargin{:})
	case 'Cit'
		DatasetsCities(varargin{:})
	case 'sca'
		scaledSymbols(varargin{:})
	case 'GTi'
		GTilesMap(varargin{:})
end

% --------------------------------------------------------------------
function DatasetsHotspots(handles)
% Read hotspot.dat which has 4 columns (lon lat name age)
	if (aux_funs('msg_dlg',5,handles));     return;      end    % Test no_file || unknown proj
	fid = fopen([handles.path_data 'hotspots.dat'],'r');
	tline = fgetl(fid);             % Jump the header line
	todos = fread(fid,'*char');     fclose(fid);
	[hot.x hot.y hot.name hot.age] = strread(todos,'%f %f %s %f');     % Note: hot.name is a cell array of chars
	clear todos;
    [tmp, msg] = geog2projected_pts(handles,[hot.x hot.y]);     % If map in geogs, tmp is just a copy of input
    if (~strncmp(msg,'0',1))        % Coords were projected
		hot.x = tmp(:,1);        hot.y = tmp(:,2);
    end

	% Get rid of Fogspots that are outside the map limits
	[x,y,indx,indy] = aux_funs('in_map_region',handles,hot.x,hot.y,0,[]);
	hot.name(indx) = [];   hot.age(indx) = [];
	hot.name(indy) = [];   hot.age(indy) = [];
	n_hot = length(x);    h_hotspot = zeros(1,n_hot);
	for (i = 1:n_hot)
		h_hotspot(i) = line(x(i),y(i),'Marker','p','MarkerFaceColor','r',...
			'MarkerEdgeColor','k','MarkerSize',10,'Tag','hotspot','Userdata',i);
	end
	draw_funs(h_hotspot,'hotspot',hot)

% --------------------------------------------------------------------
function DatasetsVolcanoes(handles)
% Read volcanoes.dat which has 6 columns (lat lon name ...)
	if (aux_funs('msg_dlg',5,handles));     return;      end    % Test no_file || unknown proj
	fid = fopen([handles.path_data 'volcanoes.dat'],'r');
	todos = fread(fid,'*char');
	[volc.y volc.x volc.name region volc.desc volc.dating] = strread(todos,'%f %f %s %s %s %s');
	fclose(fid);    clear region todos
    [tmp, msg] = geog2projected_pts(handles,[volc.x volc.y]);     % If map in geogs, tmp is just a copy of input
    if (~strncmp(msg,'0',1))        % Coords were projected
		volc.x = tmp(:,1);        volc.y = tmp(:,2);
    end
	
	% Get rid of Volcanoes that are outside the map limits
	[x,y,indx,indy] = aux_funs('in_map_region',handles,volc.x,volc.y,0,[]);
	volc.name(indx) = [];       volc.desc(indx) = [];       volc.dating(indx) = [];
	volc.name(indy) = [];       volc.desc(indy) = [];       volc.dating(indy) = [];
	n_volc = length(x);    h_volc = zeros(1,n_volc);
	for (i = 1:n_volc)
		h_volc(i) = line(x(i),y(i),'Marker','^','MarkerFaceColor','y',...
			'MarkerEdgeColor','k','MarkerSize',8,'Tag','volcano','Userdata',i);
	end
	draw_funs(h_volc,'volcano',volc)

% --------------------------------------------------------------------
function DatasetsTides(handles)
	if (aux_funs('msg_dlg',5,handles));     return;      end    % Test no_file || unknown proj
	load([handles.path_data 't_xtide.mat']);
	[tmp, msg] = geog2projected_pts(handles,[xharm.longitude xharm.latitude]);     % If map in geogs, tmp is just a copy of input
	if (~strncmp(msg,'0',1))        % Coords were projected
		xharm.longitude = tmp(:,1);        xharm.latitude = tmp(:,2);
    end
	% Get rid of Tide stations that are outside the map limits
	[x,y] = aux_funs('in_map_region',handles,xharm.longitude,xharm.latitude,0,[]);
	h_tides = line(x,y,'Marker','^','MarkerFaceColor','y','MarkerEdgeColor','k','MarkerSize',6,...
		'LineStyle','none','Tag','TideStation');
	draw_funs(h_tides,'TideStation',[])

% --------------------------------------------------------------------
function DatasetsIsochrons(handles, opt)
% Read multisegment isochrons.dat which has 3 columns (lat lon id)
% OR read a generic ascii file that can be, or not, a multiseg file
% Multi-segs files accept -G, -W & -S GMT type options.
% If first line in file is of the form '>U_N_I_K', plot a single line NaN separated

if (nargin == 2 && isempty(opt))            % Read a ascii multi-segment with info file
	[FileName,PathName] = put_or_get_file(handles, ...
		{'*.dat;*.DAT', 'Data files (*.dat,*.DAT)';'*.*', 'All Files (*.*)'},'Select File','get');
	if isequal(FileName,0),		return,		end
	tag = 'Unnamed';		fname = [PathName FileName];
elseif (nargin == 2)		% Read a ascii multi-segment file of which we already know the name (drag N'drop)
	tag = 'DragNdroped';	fname = opt;
else
	tag = 'isochron';		fname = [handles.path_data 'isochrons.dat'];
end

%	EXAMPLE CODE OF HOW TO CREATE A TEMPLATE FOR UICTX WHEN THESE ARE TOO MANY
% 	cmenuHand = get(h, 'UIContextMenu');
% 	setappdata(handles.figure1, 'cmenuHand', cmenuHand)
% 	cmenuHand = uicontextmenu('Parent',handles.figure1);
% 	set(h, 'UIContextMenu', cmenuHand);
% 	%uimenu(cmenuHand, 'Label', 'Set all UIcontexts', 'Call', {@resetUIctx,h,handles.axes1});
% 	uimenu(cmenuHand, 'Label', 'Set all UIcontexts', 'Call', 'hand=guidata(gco); set(gco, ''UIContextMenu'', getappdata(hand.axes1, ''cmenuHand''))' );
% 
% function resetUIctx(obj,evt,h,hAxes)
% 	cmenuHand = getappdata(hAxes, 'cmenuHand');
% 	set(h, 'UIContextMenu', cmenuHand)
		

%set(handles.figure1,'pointer','watch')
[bin,n_column,multi_seg,n_headers] = guess_file(fname);
if (n_column == 1 && multi_seg == 0)        % Take it as a file names list
    fid = fopen(fname);
    c = char(fread(fid))';      fclose(fid);
    names = strread(c,'%s','delimiter','\n');   clear c fid;
else
    names = {fname};
end

tol = 0.5;
do_project = false;         % We'll estimate below if this holds true

if (handles.no_file)		% Start empty but below we'll find the true data region
    XMin = 1e50;			XMax = -1e50;    YMin = 1e50;            YMax = -1e50;
    geog = 1;				% Not important. It will be confirmed later
    if (nargin == 1)		% We know it's geog (Global Isochrons)
		xx = [-180 180];    yy = [-90 90];
		if (handles.geog == 2),		xx = [0 360];	end
		region = [xx yy];
    else                    % We need to compute the file extents.
		for (k=1:length(names))
            fname = names{k};
            j = strfind(fname,filesep);
            if (isempty(j)),    fname = [PathName fname];   end         % It was just the filename. Need to add path as well 
            [numeric_data,multi_segs_str] = text_read(fname,NaN,NaN,'>');
			if (~isa(numeric_data,'cell'))			% File was not multi-segment.
				numeric_data = {numeric_data};
			end
            for i=1:length(numeric_data)
				tmpx = numeric_data{i}(:,1);	tmpy = numeric_data{i}(:,2);
				XMin = min(XMin,min(tmpx));		XMax = max(XMax,max(tmpx));
				YMin = min(YMin,min(tmpy));		YMax = max(YMax,max(tmpy));
            end
		end
        xx = [XMin XMax];           yy = [YMin YMax];
        region = [xx yy];           % 1 stands for geog but that will be confirmed later
    end
	mirone('FileNewBgFrame_CB', handles, [region geog])   % Create a background
else							% Reading over an established region
	XYlim = getappdata(handles.axes1,'ThisImageLims');
	xx = XYlim(1:2);			yy = XYlim(3:4);
	if (handles.is_projected && (nargin == 1 || handles.defCoordsIn > 0) )
		do_project = true;
	end
	XMin = XYlim(1);			XMax = XYlim(2);		% In case we need this names below for line trimming
end

for (k = 1:numel(names))
    fname = names{k};
    j = strfind(fname,filesep);
    if (isempty(j)),    fname = [PathName fname];   end			% It was just the filename. Need to add path as well 
    [numeric_data,multi_segs_str] = text_read(fname,NaN,NaN,'>');
	if (~isa(numeric_data,'cell'))			% File was not multi-segment. Now pretend it was but with no info
		numeric_data = {numeric_data};
		multi_segs_str = {'> No info provided'};
	end
	n_isoc = 0;     n_segments = length(numeric_data);
	h_isoc = ones(n_segments,1)*NaN;							% This is the maximum we can have
	n_clear = false(n_segments,1);

	% Test if conversion into a single, NaN separated, line its wanted 
	if (strncmp(multi_segs_str{1}, '>U_N_I_K', 8))
		for (i = 1:n_segments-1)
			numeric_data{i} = [numeric_data{i}(:,1:2); nan nan];
		end
		numeric_data{1} = cat(1,numeric_data{:});
		% Rip the U_N_I_K identifier
		if (numel(multi_segs_str{1}) > 8)			% We may have line type specifications
			multi_segs_str{1} = ['> ' multi_segs_str{1}(9:end)];
		else
			multi_segs_str{1} = '> ';
		end
		n_segments = 1;				% Pretend we have only one segment
	end
	
	for (i = 1:n_segments)
        if (do_project)         % We need to project
            numeric_data{i} = geog2projected_pts(handles,numeric_data{i});
        end
        difes = [numeric_data{i}(1,1)-numeric_data{i}(end,1) numeric_data{i}(1,2)-numeric_data{i}(end,2)];
        if (any(abs(difes) > 1e-4))
            is_closed = false;
            % Not a closed polygon, so get rid of points that are outside the map limits
            [tmpx,tmpy] = aux_funs('in_map_region',handles,numeric_data{i}(:,1),numeric_data{i}(:,2),tol,[xx yy]);
        else
            tmpx = numeric_data{i}(:,1);       tmpy = numeric_data{i}(:,2);
            is_closed = true;
        end
        if (isempty(tmpx)),     n_clear(i) = 1;     continue,	end     % Store indexes for clearing vanished segments info

        if (handles.no_file)        % We need to compute the data extent in order to set the correct axes limits
            XMin = min(XMin,min(tmpx));     XMax = max(XMax,max(tmpx));
            YMin = min(YMin,min(tmpy));     YMax = max(YMax,max(tmpy));
        end
        
        [thick, cor, multi_segs_str{i}] = parseW(multi_segs_str{i}(min(2,numel(multi_segs_str{i})):end)); % First time, we can chop the '>' char
        if (isempty(thick)),    thick = handles.DefLineThick;   end     % IF not provided, use default
        if (isempty(cor)),      cor = handles.DefLineColor;     end     %           "
        
        if (~is_closed)         % Line plottings
			% See if we need to wrap arround the earth roundness discontinuity. Using 0.5 degrees from border. 
			if (handles.geog == 1 && ~do_project && (XMin < -179.5 || XMax > 179.5) )
				[tmpy, tmpx] = map_funs('trimwrap', tmpy, tmpx, [-90 90], [XMin XMax],'wrap');
			elseif (handles.geog == 2 && ~do_project && (XMin < 0.5 || XMax > 359.5) )
				[tmpy, tmpx] = map_funs('trimwrap', tmpy, tmpx, [-90 90], [XMin XMax],'wrap');
			end
            n_isoc = n_isoc + 1;
            h_isoc(i) = line('XData',tmpx,'YData',tmpy,'Parent',handles.axes1,'Linewidth',thick,...
                'Color',cor,'Tag',tag,'Userdata',n_isoc);
            setappdata(h_isoc(i),'LineInfo',multi_segs_str{i})  % To work with the sessions and will likely replace old mechansim
        else
			[Fcor str2] = parseG(multi_segs_str{i});
			if (isempty(Fcor)),      Fcor = 'none';   end
			hPat = patch('XData',tmpx,'YData',tmpy,'Parent',handles.axes1,'Linewidth',thick,'EdgeColor',cor,'FaceColor',Fcor);
			draw_funs(hPat,'line_uicontext')
			n_clear(i) = 1;     % Must delete this header info because it only applyies to lines, not patches
        end
	end
	multi_segs_str(n_clear) = [];       % Clear the unused info

	ind = isnan(h_isoc);    h_isoc(ind) = [];      % Clear unused rows in h_isoc (due to over-dimensioning)
	if (~isempty(h_isoc)),  draw_funs(h_isoc,'isochron',multi_segs_str);    end
end
set(handles.figure1,'pointer','arrow')

if (handles.no_file)        % We have a kind of inf Lims. Adjust for current values
	region = [XMin XMax YMin YMax];
	set(handles.axes1,'XLim',[XMin XMax],'YLim',[YMin YMax])
	setappdata(handles.axes1,'ThisImageLims',region)
	handles = guidata(handles.figure1);			% Tricky, but we need the new version, which was changed in show_image
	handles.geog = aux_funs('guessGeog',region);
	guidata(handles.figure1,handles)
end

% --------------------------------------------------------------------
function [cor, str2] = parseG(str)
% Parse the STR string in search of color. If not found or error COR = [].
% STR2 is the STR string less the -Gr/g/b part
	cor = [];   str2 = str;
	ind = strfind(str,'-G');
	if (isempty(ind)),      return;     end     % No -G option
	try									% There are so many ways to have it wrong that I won't bother testing
		[strG, rem] = strtok(str(ind:end));
		str2 = [str(1:ind(1)-1) rem];   % Remove the -G<str> from STR

		strG(1:2) = [];					% Remove the '-G' part from strG
		% OK, now 'strG' must contain the color in the r/g/b form
		ind = strfind(strG,'/');
		if (isempty(ind))           % E.G. -G100 form
			cor = eval(['[' strG ']']);
			cor = [cor cor cor] / 255;
		else
			% This the relevant part in num2str. I think it is enough here
			cor = [eval(['[' strG(1:ind(1)-1) ']']) eval(['[' strG(ind(1)+1:ind(2)-1) ']']) eval(['[' strG(ind(2)+1:end) ']'])];
			cor = cor / 255;
		end
		if (any(isnan(cor))),   cor = [];   end
	end

% --------------------------------------------------------------------
function [thick, cor, str2] = parseW(str)
% Parse the STR string in search for a -Wpen. Valid options are -W1,38/130/255 -W3 or -W100/255/255
% If not found or error THICK = [] &/or COR = [].
% STR2 is the STR string less the -W[thick,][r/g/b] part
    thick = [];     cor = [];   str2 = str;
    ind = strfind(str,'-W');
    if (isempty(ind)),      return;     end     % No -W option
    try                                 % There are so many ways to have it wrong that I won't bother testing
        [strW, rem] = strtok(str(ind:end));
        str2 = [str(1:ind(1)-1) rem];   % Remove the -W<str> from STR
        
        strW(1:2) = [];                 % Remove the '-W' part from strW
        % OK, now 'strW' must contain the pen in the thick,r/g/b form
        ind = strfind(strW,',');
        if (~isempty(ind))          % First thing before the comma must be the line thickness
            thick = eval(['[' strW(1:ind(1)-1) ']']);
            strW = strW(ind(1)+1:end);  % Remove the line thickness part
        else                        % OK, no comma. So we have either a thickness XOR a color
            ind = strfind(strW,'/');
            if (isempty(ind))       % No color. Take it as a thickness
                thick = eval(['[' strW ']']);
            else                    % A color
                cor = [eval(['[' strW(1:ind(1)-1) ']']) eval(['[' strW(ind(1)+1:ind(2)-1) ']']) eval(['[' strW(ind(2)+1:end) ']'])];
                cor = cor / 255;
                if (any(isnan(cor))),   cor = [];   end
                % We are done here. RETURN
                return
            end
        end
        % Come here when -Wt,r/g/b and '-Wt,' have already been riped
        ind = strfind(strW,'/');
        if (~isempty(ind))
            % This the relevant part in num2str. I think it is enough here
            cor = [eval(['[' strW(1:ind(1)-1) ']']) eval(['[' strW(ind(1)+1:ind(2)-1) ']']) eval(['[' strW(ind(2)+1:end) ']'])];
            cor = cor / 255;
        end
        % Notice that we cannot have -W100 represent a color because it would have been interpret above as a line thickness
        if (any(isnan(cor))),   cor = [];   end
    end
    
% --------------------------------------------------------------------
function DatasetsPlateBound_PB_All(handles)
% Read and plot the modified (by me) Peter Bird's Plate Boundaries (nice shit they are)
	if (aux_funs('msg_dlg',5,handles)),		return,		end    % Test no_file || unknown proj
	set(handles.figure1,'pointer','watch')
	load([handles.path_data 'PB_boundaries.mat'])

	% ------------------
	% Get rid of boundary segments that are outside the map limits
	xx = get(handles.axes1,'Xlim');      yy = get(handles.axes1,'Ylim');
	tol = 0.5;
    if (handles.is_projected),      tol = 1e4;      end     % Maybe still too small
    lims = [xx yy];
	% ------------------ OTF class
	n = length(OTF);    k = false(n,1);
	for i = 1:n
        if (handles.is_projected)      
			tmp = geog2projected_pts(handles,[OTF(i).x_otf; OTF(i).y_otf]', lims);
			OTF(i).x_otf = tmp(:,1)';        OTF(i).y_otf = tmp(:,2)';            
        end
		[OTF(i).x_otf, OTF(i).y_otf] = aux_funs('in_map_region', handles, OTF(i).x_otf, OTF(i).y_otf, tol, lims);
		if (handles.geog == 2 && ~handles.is_projected && (lims(1) < 0.2 || lims(2) > 359.8) )
			[OTF(i).y_otf, OTF(i).x_otf] = map_funs('trimwrap', OTF(i).y_otf, OTF(i).x_otf, [-90 90], [lims(1) lims(2)],'wrap');
		end
		if (isempty(OTF(i).x_otf) || isempty(OTF(i).y_otf)),	k(i) = true;	end
	end
	OTF(k) = [];
	% ------------------ OSR class
	n = length(OSR);    k = false(n,1);
	for i = 1:n
        if (handles.is_projected)      
            tmp = geog2projected_pts(handles,[OSR(i).x_osr; OSR(i).y_osr]', lims);
            OSR(i).x_osr = tmp(:,1)';        OSR(i).y_osr = tmp(:,2)';            
        end
		[OSR(i).x_osr, OSR(i).y_osr] = aux_funs('in_map_region', handles, OSR(i).x_osr, OSR(i).y_osr, tol, lims);
		if (handles.geog == 2 && ~handles.is_projected && (lims(1) < 0.2 || lims(2) > 359.8) )
			[OSR(i).y_osr, OSR(i).x_osr] = map_funs('trimwrap', OSR(i).y_osr, OSR(i).x_osr, [-90 90], [lims(1) lims(2)],'wrap');
		end
		if (isempty(OSR(i).x_osr) || isempty(OSR(i).y_osr)),	k(i) = true;	end
	end
	
	OSR(k) = [];
	% ------------------ CRB class
	n = length(CRB);    k = false(n,1);
	for i = 1:n
        if (handles.is_projected)      
            [tmp, msg] = geog2projected_pts(handles,[CRB(i).x_crb; CRB(i).y_crb]', lims);
            CRB(i).x_crb = tmp(:,1)';        CRB(i).y_crb = tmp(:,2)';            
        end
		[CRB(i).x_crb, CRB(i).y_crb] = aux_funs('in_map_region', handles, CRB(i).x_crb, CRB(i).y_crb, tol, lims);
		if (isempty(CRB(i).x_crb) || isempty(CRB(i).y_crb)),	k(i) = true;	end
	end
	CRB(k) = [];
	% ------------------ CTF class
	n = length(CTF);    k = false(n,1);
	for i = 1:n
        if (handles.is_projected)      
            tmp = geog2projected_pts(handles,[CTF(i).x_ctf; CTF(i).y_ctf]', lims);
            CTF(i).x_ctf = tmp(:,1)';        CTF(i).y_ctf = tmp(:,2)';            
        end
		[CTF(i).x_ctf, CTF(i).y_ctf] = aux_funs('in_map_region', handles, CTF(i).x_ctf, CTF(i).y_ctf, tol, lims);
		if (isempty(CTF(i).x_ctf) || isempty(CTF(i).y_ctf)),	k(i) = true;	end
	end
	CTF(k) = [];
	% ------------------ CCB class
	n = length(CCB);    k = false(n,1);
	for i = 1:n
        if (handles.is_projected)      
            tmp = geog2projected_pts(handles,[CCB(i).x_ccb; CCB(i).y_ccb]', lims);
            CCB(i).x_ccb = tmp(:,1)';        CCB(i).y_ccb = tmp(:,2)';            
        end
		[CCB(i).x_ccb, CCB(i).y_ccb] = aux_funs('in_map_region', handles, CCB(i).x_ccb, CCB(i).y_ccb, tol, lims);
		if (handles.geog == 2 && ~handles.is_projected && (lims(1) < 0.2 || lims(2) > 359.8) )
			[CCB(i).y_ccb, CCB(i).x_ccb] = map_funs('trimwrap', CCB(i).y_ccb, CCB(i).x_ccb, [-90 90], [lims(1) lims(2)],'wrap');
		end
		if (isempty(CCB(i).x_ccb) || isempty(CCB(i).y_ccb)),	k(i) = true;	end
	end
	CCB(k) = [];
	% ------------------ OCB class
	n = length(OCB);    k = false(n,1);
	for i = 1:n
        if (handles.is_projected)      
            tmp = geog2projected_pts(handles,[OCB(i).x_ocb; OCB(i).y_ocb]', lims);
            OCB(i).x_ocb = tmp(:,1)';        OCB(i).y_ocb = tmp(:,2)';            
        end
		[OCB(i).x_ocb, OCB(i).y_ocb] = aux_funs('in_map_region', handles, OCB(i).x_ocb, OCB(i).y_ocb, tol, lims);
		if (isempty(OCB(i).x_ocb) || isempty(OCB(i).y_ocb)),	k(i) = true;	end
	end
	OCB(k) = [];
	% ------------------ SUB class
	n = length(SUB);    k = false(n,1);
	for i = 1:n
        if (handles.is_projected)      
            tmp = geog2projected_pts(handles,[SUB(i).x_sub; SUB(i).y_sub]', lims);
            SUB(i).x_sub = tmp(:,1)';        SUB(i).y_sub = tmp(:,2)';            
        end
		[SUB(i).x_sub, SUB(i).y_sub] = aux_funs('in_map_region', handles, SUB(i).x_sub, SUB(i).y_sub, tol, lims);
		if (isempty(SUB(i).x_sub) || isempty(SUB(i).y_sub)),	k(i) = true;	end
	end
	SUB(k) = [];

% ------------------ Finally do the ploting ------------------------------------
	% Plot the OSR class
	n = length(OSR);    h_PB_All_OSR = zeros(n,1);
	for i = 1:n
        line(OSR(i).x_osr,OSR(i).y_osr,'Linewidth',3,'Color','k','Tag','PB_All','Userdata',i);
        h_PB_All_OSR(i) = line(OSR(i).x_osr,OSR(i).y_osr,'Linewidth',2,'Color','r','Tag','PB_All','Userdata',i);
	end
	% Plot the OTF class
	n = length(OTF);    h_PB_All_OTF = zeros(n,1);
	for i = 1:n
        line(OTF(i).x_otf,OTF(i).y_otf,'Linewidth',3,'Color','k','Tag','PB_All','Userdata',i);
        h_PB_All_OTF(i) = line(OTF(i).x_otf,OTF(i).y_otf,'Linewidth',2,'Color','g','Tag','PB_All','Userdata',i);
	end
	% Plot the CRB class
	n = length(CRB);    h_PB_All_CRB = zeros(n,1);
	for i = 1:n
        line(CRB(i).x_crb,CRB(i).y_crb,'Linewidth',3,'Color','k','Tag','PB_All','Userdata',i);
        h_PB_All_CRB(i) = line(CRB(i).x_crb,CRB(i).y_crb,'Linewidth',2,'Color','b','Tag','PB_All','Userdata',i);
	end
	% Plot the CTF class
	n = length(CTF);    h_PB_All_CTF = zeros(n,1);
	for i = 1:n
        line(CTF(i).x_ctf,CTF(i).y_ctf,'Linewidth',3,'Color','k','Tag','PB_All','Userdata',i);
        h_PB_All_CTF(i) = line(CTF(i).x_ctf,CTF(i).y_ctf,'Linewidth',2,'Color','y','Tag','PB_All','Userdata',i);
	end
	% Plot the CCB class
	n = length(CCB);    h_PB_All_CCB = zeros(n,1);
	for i = 1:n
        line(CCB(i).x_ccb,CCB(i).y_ccb,'Linewidth',3,'Color','k','Tag','PB_All','Userdata',i);
        h_PB_All_CCB(i) = line(CCB(i).x_ccb,CCB(i).y_ccb,'Linewidth',2,'Color','m','Tag','PB_All','Userdata',i);
	end
	% Plot the OCB class
	n = length(OCB);    h_PB_All_OCB = zeros(n,1);
	for i = 1:n
        line(OCB(i).x_ocb,OCB(i).y_ocb,'Linewidth',3,'Color','k','Tag','PB_All','Userdata',i);
        h_PB_All_OCB(i) = line(OCB(i).x_ocb,OCB(i).y_ocb,'Linewidth',2,'Color','c','Tag','PB_All','Userdata',i);
	end
	% Plot the SUB class
	n = length(SUB);    h_PB_All_SUB = zeros(n,1);
	for i = 1:n
        line(SUB(i).x_sub,SUB(i).y_sub,'Linewidth',3,'Color','k','Tag','PB_All','Userdata',i);
        h_PB_All_SUB(i) = line(SUB(i).x_sub,SUB(i).y_sub,'Linewidth',2,'Color','c','Tag','PB_All','Userdata',i);
	end

	% Join all line handles into a single variable
	h.OSR = h_PB_All_OSR;    h.OTF = h_PB_All_OTF;    h.CRB = h_PB_All_CRB;    h.CTF = h_PB_All_CTF;
	h.CCB = h_PB_All_CCB;    h.OCB = h_PB_All_OCB;    h.SUB = h_PB_All_SUB;
	% Join all data into a single variable
	data.OSR = OSR;    data.OTF = OTF;    data.CRB = CRB;    data.CTF = CTF;
	data.CCB = CCB;    data.OCB = OCB;    data.SUB = SUB;
	draw_funs(h,'PlateBoundPB',data);
    set(handles.figure1,'pointer','arrow')

% --------------------------------------------------------------------
function CoastLines(handles, res)
	if (aux_funs('msg_dlg',5,handles));     return;      end    % Test no_file || unknown proj
	set(handles.figure1,'pointer','watch')
	
	lon = get(handles.axes1,'Xlim');      lat = get(handles.axes1,'Ylim');
    [dumb, msg, opt_R] = geog2projected_pts(handles,[lon(:) lat(:)],[lon lat 0]);   % Get -R for use in shoredump
    if (isempty(opt_R)),    return;    end      % It should never happen, but ...
	
	switch res
        case 'c',        opt_res = '-Dc';        pad = 2.0;
        case 'l',        opt_res = '-Dl';        pad = 0.5;
        case 'i',        opt_res = '-Di';        pad = 0.1;
        case 'h',        opt_res = '-Dh';        pad = 0.03;
        case 'f',        opt_res = '-Df';        pad = 0.005;
	end
	coast = shoredump(opt_R,opt_res,'-A1/1/1');
	if (isempty(coast)),	return,		end

	[coast, msg] = geog2projected_pts(handles,coast',[lon lat],0);
    if (numel(msg) > 2)
    	set(handles.figure1,'pointer','arrow')
        errordlg(msg,'ERROR');
        return
    end
	coast = coast';
    
    if (strncmp(msg,'0',1))     % They are in geogs so we know how to ...
		% Get rid of data that are outside the map limits
		lon = lon - [pad -pad];     lat = lat - [pad -pad];
		indx = (coast(1,:) < lon(1) | coast(1,:) > lon(2));
		coast(:,indx) = [];
		indx = (coast(2,:) < lat(1) | coast(2,:) > lat(2));
		coast(:,indx) = [];
    end
    coast = single(coast);      % If we do this before the test, single(NaN) screw up. Goog job TMW 
	
	if (~all(isnan(coast(:))))
		h = line('XData',coast(1,:),'YData',coast(2,:),'Parent',handles.axes1,'Linewidth',handles.DefLineThick,...
            'Color',handles.DefLineColor,'Tag','CoastLineNetCDF','UserData',opt_res(3));
		draw_funs(h,'CoastLineUictx')    % Set line's uicontextmenu
	end
	set(handles.figure1,'pointer','arrow')

% --------------------------------------------------------------------
function PoliticalBound(handles, type, res)
	% TYPE is: '1' -> National Boundaries
	%          '2' -> State Boundaries
	%          '3' -> Marine Boundaries
	%          'a' -> All Boundaries
	% RES is:  'c' or 'l' or 'i' or 'h' or 'f' (gmt database resolution)
	if (aux_funs('msg_dlg',5,handles)),		return,		end    % Test no_file || unknown proj
	
	set(handles.figure1,'pointer','watch')
	lon = get(handles.axes1,'Xlim');      lat = get(handles.axes1,'Ylim');
    [dumb, msg, opt_R] = geog2projected_pts(handles,[lon(:) lat(:)],[lon lat 0]);   % Get -R for use in shoredump
	
	switch type
        case '1',        opt_N = '-N1';
        case '2',        opt_N = '-N2';
        case '3',        opt_N = '-N3';
        case 'a',        opt_N = '-Na';
	end
	
	switch res
        case 'c',        opt_res = '-Dc';        pad = 2;
        case 'l',        opt_res = '-Dl';        pad = 0.5;
        case 'i',        opt_res = '-Di';        pad = 0.1;
        case 'h',        opt_res = '-Dh';        pad = 0.05;
        case 'f',        opt_res = '-Df';        pad = 0.01;
	end
	boundaries = shoredump(opt_R,opt_N,opt_res);
	if (isempty(boundaries)),	return,		end

    [boundaries, msg] = geog2projected_pts(handles,boundaries',[lon lat],0);
    if (numel(msg) > 2)
    	set(handles.figure1,'pointer','arrow')
        errordlg(msg,'ERROR');
        return
    end
    boundaries = boundaries';
	
    if (strncmp(msg,'0',1))     % They are in geogs so we know how to ...
		% Get rid of data that are outside the map limits
		lon = lon - [pad -pad];     lat = lat - [pad -pad];
		indx = (boundaries(1,:) < lon(1) | boundaries(1,:) > lon(2));
		boundaries(:,indx) = [];
		indx = (boundaries(2,:) < lat(1) | boundaries(2,:) > lat(2));
		boundaries(:,indx) = [];
    end
    boundaries = single(boundaries);      % If we do this before the test, single(NaN) screw up. Goog job TMW 
	
	if (~all(isnan(boundaries(:))))
		h = line('XData',boundaries(1,:),'YData',boundaries(2,:),'Parent',handles.axes1,'Linewidth',handles.DefLineThick,...
            'Color',handles.DefLineColor,'Tag','PoliticalBoundaries', 'UserData',[opt_res(3) opt_N(3)]);
		draw_funs(h,'CoastLineUictx')    % Set line's uicontextmenu
	end
	set(handles.figure1,'pointer','arrow')

% --------------------------------------------------------------------
function Rivers(handles, type, res)
	% TYPE is: '1' -> Permanent major rivers;           '2' -> Additional major rivers
	%          '3' -> Additional rivers                 '4' -> Minor rivers
	%          '5' -> Intermittent rivers - major       '6' -> Intermittent rivers - additional
	%          '7' -> Intermittent rivers - minor       '8' -> Major canals
	%          '9' -> Minor canals
	%          'a' -> All rivers and canals (1-10)      'r' -> All permanent rivers (1-4)
	%          'i' -> All intermittent rivers (5-7)
	% RES is:  'c' or 'l' or 'i' or 'h' or 'f' (gmt database resolution)
	if (aux_funs('msg_dlg',5,handles));     return;      end    % Test no_file || unknown proj
	
	set(handles.figure1,'pointer','watch')
	lon = get(handles.axes1,'Xlim');      lat = get(handles.axes1,'Ylim');
    [dumb, msg, opt_R] = geog2projected_pts(handles,[lon(:) lat(:)],[lon lat 0]);   % Get -R for use in shoredump
	
	switch type
        case '1',        opt_I = '-I1';         case '2',        opt_I = '-I2';
        case '3',        opt_I = '-I3';
        case '5',        opt_I = '-I5';         case '6',        opt_I = '-I6';
        case '7',        opt_I = '-I7';
        case 'a',        opt_I = '-Ia';
        case 'r',        opt_I = '-Ir';         case 'i',        opt_I = '-Ii';
	end
	
	switch res
        case 'c',        opt_res = '-Dc';        pad = 2;
        case 'l',        opt_res = '-Dl';        pad = 0.5;
        case 'i',        opt_res = '-Di';        pad = 0.1;
        case 'h',        opt_res = '-Dh';        pad = 0.05;
        case 'f',        opt_res = '-Df';        pad = 0.01;
	end
	rivers = shoredump(opt_R,opt_I,opt_res);
	if (isempty(rivers)),	return,		end

    [rivers, msg] = geog2projected_pts(handles,rivers',[lon lat],0);
    if (numel(msg) > 2)
    	set(handles.figure1,'pointer','arrow')
        errordlg(msg,'ERROR');        return
    end
    rivers = rivers';
    
    if (strncmp(msg,'0',1))     % They are in geogs so we know to to ...
		% Get rid of data that are outside the map limits
		lon = lon - [pad -pad];     lat = lat - [pad -pad];
		indx = (rivers(1,:) < lon(1) | rivers(1,:) > lon(2));
		rivers(:,indx) = [];
		indx = (rivers(2,:) < lat(1) | rivers(2,:) > lat(2));
		rivers(:,indx) = [];
    end
    rivers = single(rivers);      % If we do this before the test, single(NaN) screw up. Goog job TMW 
	
	if (~all(isnan(rivers(:))))
		h = line('XData',rivers(1,:),'YData',rivers(2,:),'Parent',handles.axes1,'Linewidth',handles.DefLineThick,...
            'Color',handles.DefLineColor,'Tag','Rivers', 'UserData',[opt_res(3) opt_I(3:end)]);
		draw_funs(h,'CoastLineUictx')    % Set line's uicontextmenu
	end
	set(handles.figure1,'pointer','arrow')

% --------------------------------------------------------------------
function DatasetsCities(handles,opt)
	if (aux_funs('msg_dlg',5,handles));     return;      end    % Test no_file || unknown proj
	if strcmp(opt,'major')
        fid = fopen([handles.path_data 'wcity_major.dat'],'r');
        tag = 'City_major';
	elseif strcmp(opt,'other')
        fid = fopen([handles.path_data 'wcity.dat'],'r');
        tag = 'City_other';
	end
	todos = fread(fid,'*char');     fclose(fid);
	[city.x city.y city.name] = strread(todos,'%f %f %s');      % Note: city.name is a cell array of chars
    [tmp, msg] = geog2projected_pts(handles,[city.x city.y]);   % If map in geogs, tmp is just a copy of input
    if (~strncmp(msg,'0',1))        % Coords were projected
        city.x = tmp(:,1);      city.y = tmp(:,2);
    end

    % Get rid of Cities that are outside the map limits
	[x,y,indx,indy] = aux_funs('in_map_region',handles,city.x,city.y,0,[]);
	city.name(indx) = [];       city.name(indy) = [];
	n_city = length(x);
	
	if (n_city == 0),   return;     end     % No cities inside area. Return.
	h_city = line(x,y,'LineStyle','none','Marker','o','MarkerFaceColor','k',...
        'MarkerEdgeColor','w','MarkerSize',6,'Tag',tag);
	draw_funs(h_city,'DrawSymbol')                  % Set symbol's uicontextmenu
	
	% Estimate the text position shift in order that it doesn't fall over the city symbol 
	pos = get(handles.figure1,'Position');
	x_lim = get(handles.axes1,'xlim');
	z1 = 7 / pos(3);
	dx = z1 * (x_lim(2) - x_lim(1));
	
	city.name = strrep(city.name,'_',' ');          % Replace '_' by ' '
	textHand = zeros(1,n_city);
	for i = 1:n_city                                % Plot the City names
        textHand(i) = text(x(i)+dx,y(i),0,city.name{i},'Tag',tag);
        draw_funs(textHand(i),'DrawText')           % Set text's uicontextmenu
	end

% --------------------------------------------------------------------
function DatasetsODP_DSDP(handles,opt)
	if (aux_funs('msg_dlg',5,handles));     return;      end    % Test no_file || unknown proj
	set(handles.figure1,'pointer','watch')
	fid = fopen([handles.path_data 'DSDP_ODP.dat'],'r');
	todos = fread(fid,'*char');
	[ODP.x ODP.y zz ODP.leg ODP.site ODP.z ODP.penetration] = strread(todos,'%f %f %s %s %s %s %s');
	fclose(fid);    clear todos zz
    [tmp, msg] = geog2projected_pts(handles,[ODP.x ODP.y]);   % If map in geogs, tmp is just a copy of input
    if (~strncmp(msg,'0',1))        % Coords were projected
        ODP.x = tmp(:,1);      ODP.y = tmp(:,2);
    end

	% Get rid of Sites that are outside the map limits
	[ODP.x,ODP.y,indx,indy] = aux_funs('in_map_region',handles,ODP.x,ODP.y,0,[]);
	ODP.leg(indx) = [];     ODP.site(indx) = [];    ODP.z(indx) = [];   ODP.penetration(indx) = [];
	ODP.leg(indy) = [];     ODP.site(indy) = [];    ODP.z(indy) = [];   ODP.penetration(indy) = [];
	
	% If there no sites left, return
	if isempty(ODP.x)
        set(handles.figure1,'pointer','arrow');
        msgbox('Warning: There are no sites inside this area.','Warning');    return;
	end
	
	% Find where in file is the separation of DSDP from ODP legs
	ind = find(str2double(ODP.leg) >= 100);
	if ~isempty(ind),   ind = ind(1);   end
	if (strcmp(opt,'ODP'))      % If only ODP sites were asked remove DSDP from data structure
        ODP.x(1:ind-1) = [];    ODP.y(1:ind-1) = [];    ODP.z(1:ind-1) = [];
        ODP.leg(1:ind-1) = [];  ODP.site(1:ind-1) = []; ODP.penetration(1:ind-1) = [];
	elseif (strcmp(opt,'DSDP'))
        ODP.x(ind:end) = [];    ODP.y(ind:end) = [];    ODP.z(ind:end) = [];
        ODP.leg(ind:end) = [];  ODP.site(ind:end) = []; ODP.penetration(ind:end) = [];
	end

	n_sites = length(ODP.x);    h_sites = zeros(n_sites,1);
	if (strcmp(opt,'DSDP'))
        if (n_sites == 0)           % If there are no sites, give a warning and exit
            set(handles.figure1,'pointer','arrow');
            msgbox('Warning: There are no DSDP sites inside this area.','Warning');    return;
        end
        for i = 1:n_sites
            h_sites(i) = line('XData',ODP.x(i),'YData',ODP.y(i),'Parent',handles.axes1,'Marker','o','MarkerFaceColor','g',...
                'MarkerEdgeColor','k','MarkerSize',8,'Tag','DSDP','Userdata',i);
        end
        draw_funs(h_sites,'ODP',ODP)
	elseif (strcmp(opt,'ODP'))
        if (n_sites == 0)           % If there are no sites, give a warning and exit
            set(handles.figure1,'pointer','arrow');
            msgbox('Warning: There are no ODP sites inside this area.','Warning');    return;
        end
        for i = 1:n_sites
            h_sites(i) = line('XData',ODP.x(i),'YData',ODP.y(i),'Parent',handles.axes1,'Marker','o','MarkerFaceColor','r',...
                'MarkerEdgeColor','k','MarkerSize',8,'Tag','ODP','Userdata',i);
        end
        draw_funs(h_sites,'ODP',ODP)
	else
        h_sites = zeros(length(1:ind-1),1);
        for i = 1:ind-1
            h_sites(i) = line('XData',ODP.x(i),'YData',ODP.y(i),'Parent',handles.axes1,'Marker','o','MarkerFaceColor','g',...
                'MarkerEdgeColor','k','MarkerSize',8,'Tag','DSDP','Userdata',i);
        end
        draw_funs(h_sites,'ODP',ODP)
        h_sites = zeros(length(ind:n_sites),1);
        for (i = 1:length(ind:n_sites))
            j = i + ind - 1;
            h_sites(i) = line('XData',ODP.x(j),'YData',ODP.y(j),'Parent',handles.axes1,'Marker','o','MarkerFaceColor','r',...
                'MarkerEdgeColor','k','MarkerSize',8,'Tag','ODP','Userdata',j);
        end
        draw_funs(h_sites,'ODP',ODP)
	end
	set(handles.figure1,'pointer','arrow')

% --------------------------------------------------------------------
function scaledSymbols(handles, fname)
% Read and parse a file wich should be multi-seg with "> -S.. -W.. -G.." controling
% symbol parametrs. If file is not multi-seg, returns before doing anything
% In that case control will be passed to the scatter_plot() function

[bin,n_column,multi_seg,n_headers] = guess_file(fname);
if (n_column == 1 && multi_seg == 0)        % Take it as a file names list
    fid = fopen(fname);
    c = fread(fid,'*char')';      fclose(fid);
    names = strread(c,'%s','delimiter','\n');   clear c fid;
else
    names = {fname};
end

% Signal Mirone Fig if it is to call the scatter_plot window (in wich case it returns here) or not
setappdata(handles.figure1,'callScatterWin',false)
if (n_column > 1 && multi_seg == 0)     % Since no multi-segs control will be given (in Mirone) to scatter_plot figure
    setappdata(handles.figure1,'callScatterWin',n_column)   % Return when no multi-segs and cols > 1
    return
end

tol = 0.5;
do_project = false;     % We'll estimate below if this holds true

if (handles.no_file)        % Start empty but below we'll find the true data region
    XMin = 1e50;            XMax = -1e50;    YMin = 1e50;            YMax = -1e50;
    geog = 1;               % Not important. It will be confirmed later
	for (k=1:length(names))
        fname = names{k};
        %j = strfind(fname,filesep);
        %if (isempty(j)),    fname = [PathName fname];   end         % It was just the filename. Need to add path as well
        % No caso acima tenho que testar se o fiche existe
        [numeric_data,multi_segs_str] = text_read(fname,NaN,n_headers,'>');
        for i=1:length(numeric_data)
            tmpx = numeric_data{i}(:,1);    tmpy = numeric_data{i}(:,2);
            XMin = min(XMin,min(tmpx));     XMax = max(XMax,max(tmpx));
            YMin = min(YMin,min(tmpy));     YMax = max(YMax,max(tmpy));
        end
	end
    xx = [XMin XMax];           yy = [YMin YMax];
    region = [xx yy];           % 1 stands for geog but that will be confirmed later
    mirone('FileNewBgFrame_CB', handles, [region geog])   % Create a background
else                        % Reading over an established region
    XYlim = getappdata(handles.axes1,'ThisImageLims');
    xx = XYlim(1:2);            yy = XYlim(3:4);
    if (handles.is_projected && handles.defCoordsIn > 0)
        do_project = true;
    end
end

for (k=1:length(names))
    fname = names{k};
%     j = strfind(fname,filesep);
%     if (isempty(j)),    fname = [PathName fname];   end         % It was just the filename. Need to add path as well 
    % No caso acima tenho que testar se o fiche existe
    [numeric_data,multi_segs_str] = text_read(fname,NaN,n_headers,'>');
	n_segments = length(numeric_data);
	n_clear = false(n_segments,1);
	for i=1:n_segments
        if (do_project)         % We need to project
            numeric_data{i} = geog2projected_pts(handles,numeric_data{i});
        end
        % Get rid of points that are outside the map limits
        [tmpx,tmpy,indx,indy] = aux_funs('in_map_region',handles,numeric_data{i}(:,1),numeric_data{i}(:,2),tol,[xx yy]);
        if (isempty(tmpx)),     n_clear(i) = 1;     continue;   end     % Store indexes for clearing vanished segments info

        if (handles.no_file)        % We need to compute the data extent in order to set the correct axes limits
            XMin = min(XMin,min(tmpx));     XMax = max(XMax,max(tmpx));
            YMin = min(YMin,min(tmpy));     YMax = max(YMax,max(tmpy));
        end
        
        if (i == 1)
            [thick, corW, multi_segs_str{i}] = parseW(multi_segs_str{i});   % Search EdgeColor and thickness
            if (isempty(thick)),    thick = 0.5;    end     % IF not provided, use default
            if (isempty(corW)),     corW = 'k';     end     %           "
            [corFill, multi_segs_str{i}] = parseG(multi_segs_str{i});       % Search Fill color
            [symbol, dim, multi_segs_str{i}] = parseS(multi_segs_str{i});   % Search Symbols
            tag = parseT(multi_segs_str{i});                % See if we have a tag
        else
            found = parseIqual(multi_segs_str{i});      % First see if symbol is the same
            if (~found)                                 % No, it isn't. So get the new one
                [thick, corW, multi_segs_str{i}] = parseW(multi_segs_str{i});
                if (isempty(thick)),    thick = 0.5;    end
                if (isempty(corW)),     corW = 'k';     end
                [corFill, multi_segs_str{i}] = parseG(multi_segs_str{i});
                [symbol, dim, multi_segs_str{i}] = parseS(multi_segs_str{i});
                tag = parseT(multi_segs_str{i});        % See if we have a tag
            end
        end
        
        h = zeros(1,numel(tmpx));
        if (size(numeric_data{i},2) > 2)        % We have a 3rd column with Z
            z = numeric_data{i}(:,3);
            z(indx) = [];       z(indy) = [];
            for kk=1:numel(tmpx)
                h(kk) = line('XData',tmpx,'YData',tmpy,'ZData',z,'Parent',handles.axes1,'LineWidth',thick,'Tag',tag,...
                    'Marker',symbol,'Color',corW,'MarkerFaceColor',corFill,'MarkerSize',dim,'LineStyle','none');
            end
        else
            for kk=1:numel(tmpx)
                h(kk) = line('XData',tmpx,'YData',tmpy,'Parent',handles.axes1,'LineWidth',thick,'Tag',tag,...
                    'Marker',symbol,'Color',corW,'MarkerFaceColor',corFill,'MarkerSize',dim,'LineStyle','none');
            end
        end
        setUIs(h)
	end
end

if (handles.no_file)        % We have a kind of inf Lims. Adjust for current values
	region = [XMin XMax YMin YMax];
	set(handles.figure1,'XLim',[XMin XMax],'YLim',[YMin YMax])
	setappdata(handles.axes1,'ThisImageLims',region)
	handles = guidata(handles.figure1);			% Tricky, but we need the new version, which was changed in show_image
	handles.geog = aux_funs('guessGeog',region);
	guidata(handles.figure1,handles)
end

% --------------------------------------------------------------------
function GTilesMap(handles)
% Read a 'tilesMapping.mat' file with mid point positions of google images tiles - UNDER CONSTRUCTION

	if (~handles.no_file && ~handles.geog)
		errordlg('Your background image is not in geographics.','Error'),	return
	end
	str1 = {'*.mat;*.MAT', 'Data files (*.mat,*.MAT)'};
	[FileName,PathName] = put_or_get_file(handles,str1,'Select tilesMapping file','get');
	if isequal(FileName,0),		return,		end

	data = load([PathName FileName]);
	% Test that this is a good tilesMapping file
	if ( ~isfield(data, 'region') && ~isfield(data, 'tiles_midpt') )
		errordlg('Invalid "tilesMapping" type file','ERROR'),	return
	end

	% If we have no background region, create one
	if (handles.no_file),   mirone('FileNewBgFrame_CB',handles, [data.region 1]);   end
	
	h = line('XData',data.tiles_midpt(:,1),'YData',data.tiles_midpt(:,2), 'linestyle','none', ...
		'marker','.', 'markersize', get(handles.figure1,'defaultlinemarkersize'), ...
		'Color',handles.DefLineColor, 'Parent',handles.axes1, 'Tag','GTiles');
	draw_funs(h,'line_uicontext')       % Set lines's uicontextmenu
	setappdata(h,'cacheDir',PathName)	% Save files tiles location (they are at same place as the mat file)

% 	% Recicle useless uicontexts into some interesting new ones
% 	cmenuHand = get(h, 'UIContextMenu');
% 	delete(findobj(cmenuHand,'Label','Copy'));
% 	h1 = findobj(cmenuHand,'Label','Line length(s)');
% 	h2 = findobj(cmenuHand,'Label','Line azimuth(s)');
% 	h3 = findobj(cmenuHand,'Label','Point interpolation');
% 	delete(findobj(cmenuHand,'Label','Extract profile'));
% 	set(h1, 'Label','Load this tiles', 'Callback',{@loadTiles,h, data.zoomL},'Sep', 'on')
% 	set(h2, 'Label','Load all region tiles', 'Callback',{@loadTiles,[[get(handles.axes1,'XLim') get(handles.axes1,'YLim')]], data.zoomL})
% 	set(h3, 'Label','Load in rectangle tiles',  'Callback',{@loadTiles,h, data.zoomL})

% % -----------------------------------------------------------------------------------------
% function loadTiles(obj,event,h, zoomL)
% 	if (ishandle(h))
% 		cacheDir = getappdata(h,'cacheDir');
% 	elseif (numel(h) == 4)
% 		[img, hdr] = imagoogle('tile2img',h(1:2), h(3:4), zoomL);
% 	end

% ------------------------------------------------------------------------------------
function setUIs(handles,h)
	cmenuHand = uicontextmenu;
	for k=1:numel(h)
		set(h(k), 'UIContextMenu', cmenuHand);
		uimenu(cmenuHand, 'Label', 'Delete this', 'Callback', {@del_line,h});
		uimenu(cmenuHand, 'Label', 'Delete all', 'Callback', {@del_all,handles,h});
		ui_edit_polygon(h(k))
	end

% -----------------------------------------------------------------------------------------
function del_all(obj,eventdata,handles,h)
% Delete all objects that share the same tag of h
	tag = get(h,'Tag');
	hAll = findobj(handles.axes1,'Tag',tag);
	del_line(obj,eventdata,hAll)
    
% -----------------------------------------------------------------------------------------
function del_line(obj,eventdata,h)
% Delete symbols but before check if they are in edit mode
    for (k=1:numel(h))
		if (~isempty(getappdata(h(k),'polygon_data')))
            s = getappdata(h(k),'polygon_data');
            if strcmpi(s.controls,'on')         % Object is in edit mode, so this
                ui_edit_polygon(h(k))           % call will force out of edit mode
            end
		end
		delete(h(k));
    end

% --------------------------------------------------------------------
function [symbol, dim, str2] = parseS(str)
% Parse the STR string in search for -S[symb][size]. Valid options are -Sc10, -Sa or -S (defaults to o 10 pt)
% If not found or error, DIM = [].
% STR2 is the STR string less the -S[symb][size] part
    symbol = 'o';   dim = 10;   str2 = str;
    ind = strfind(str,'-S');
    if (isempty(ind)),      return;     end     % No -S option
    try                                 % There are so many ways to have it wrong that I won't bother testing
        [strS, rem] = strtok(str(ind:end));
        str2 = [str(1:ind(1)-1) rem];   % Remove the -S<str> from STR
        
        if (numel(strS) > 2)            % Get the symbol
            symbs = '+o*xsd^v><ph';
            ind = strfind(symbs,strS(3));
            if (~isempty(ind)),     symbol = symbs(ind);    end
        end
        if (numel(strS) > 3)            % Get size
            dim = str2double(strS(4:end));
            if (isnan(dim)),    dim = 10;   end
        end
    end

% --------------------------------------------------------------------
function found = parseIqual(str)
% Parse the STR string in search for a '-=' option. If found it means the symbol
% will be of exactly the same type as previously determined. So this cannot
% be used on a first '>' comment line.
    found = false;
    ind = strfind(str,'-=');
    if (~isempty(ind)),      found = true;     end

% --------------------------------------------------------------------
function [tag,str2] = parseT(str)
% Parse the STR string in search for '-T<tag>'. If not found uses default 'scatter_symbs' tag
% STR2 is the STR string less the -T<tag> part
    tag = 'scatter_symbs';   str2 = str;
    ind = strfind(str,'-T');
    if (isempty(ind)),      return;     end     % No -T option
    try                                 % There are so many ways to have it wrong that I won't bother testing
        [strT, rem] = strtok(str(ind:end));
        str2 = [str(1:ind(1)-1) rem];   % Remove the -T<tag> from STR
        tag = strT(3:end);
    end
    