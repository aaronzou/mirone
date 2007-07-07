function [xy_prj, msg, opt_R] = geog2projected_pts(handles,xy,lims,pad)
    % project a 2 column array in geogs to the projection currently stored in 'ProjWKT' or 'ProjGMT'
    %
    % XY , a [lon lat] 2 column array.
    % LIMS, if present & not empty,  must be a [x_min x_max y_min y_max] OR [x_min x_max y_min y_max whatever] vector. 
    %       Normally, the image four corners coords.
    %   The second case (a 5 elements vec) is used to select Inverse projection (e.g to Geogs)
    %   when the reprojection is done with GDAL.
    %   LIMS contents are realy only used when PAD is not zero 
    %
    % PAD is a scalar with its value in projected coords. It is used as a 'skirt' boundary buffer
    % Note: to remove pts outside the LIMS rectangle one have to provide a PAD ~= 0
    %
    % In case we have both a 'ProjGMT' & 'ProjWKT' the later prevails since
    % it is supposed to correctly describe the data projection.
    % If none proj string is found, XY_PRJ = XY since nothing was done
    %
    % On output OPT_R is a -R GMT option string which will be a crude estimation
    % in case of a mapproject conversion (that story of -Rg). We need this OPT_R to
    % use in calls to shoredump_m.
    % In case of 'projGMT' if OPT_R is asked than XY_PRJ == []
    %
    % A further note on HANDLES. While one normally just send in the Mirone handles, that doesn't always
    % work or is not practical when calling this fun from outside Mirone. In those cases, like for example
    % the earthquakes() GUI, is enough that this handles is a structure with just handles.figure1 &
    % handles.axes1 which are the handles of the Figure and its Axes

    msg = '';       xy_prj = [];    opt_R = [];

    n_arg = nargin;
    if (n_arg < 2)
        msg = 'geog2projected_pts: Bad usage. Need at least 2 arguments in';
        return
    elseif (n_arg < 3)
        lims = [];      pad = 0;
    elseif (n_arg < 4)
        pad = 0;
    end

    if (~isempty(lims) && numel(lims) < 4)
        msg = 'geog2projected_pts: ERROR, "lims" vector must have 4 or 5 elements';
        return
    end
    
    % Fish eventual proj strings
    projGMT = getappdata(handles.figure1,'ProjGMT');
    projWKT = getappdata(handles.axes1,'ProjWKT');
    proj4 = getappdata(handles.axes1,'Proj4');

    jump_call = false;
    if (~isempty(projWKT) || ~isempty(proj4))
        % In case we have both 'projWKT' takes precedence because it came from file metadata
        if (~isempty(projWKT)),     theProj = projWKT;
        else                        theProj = ogrproj(proj4);
        end
        if (isempty(lims) || numel(lims) == 4)      % Projection is from geogs to projWKT
            projStruc.DstProjWKT = theProj;
            if (handles.geog)                       % It would be a geog-to-geog proj. Useless 
                jump_call = true;
            end
        else                                        % Inverse projection
            projStruc.SrcProjWKT = theProj;
        end
        if (~jump_call)
            if (size(xy,2) > 3)     % If we have more than 3 columns send only the first 3
                xy_prj = ogrproj(xy(:,1:3)+0, projStruc);
                xy_prj = [xy_prj xy(:,4:end)];      % And rebuild
            else
                xy_prj = ogrproj(xy+0, projStruc);
            end
        else
            xy_prj = xy;
            msg = '0';          % Signal that nothing has been done and output = input
        end
        if (~isempty(lims) && pad ~= 0)
        	% Get rid of data that are outside the map limits
            lims = lims + [-pad pad -pad pad];      % Extend limits by PAD value
            ind = (xy_prj(:,1) < lims(1) | xy_prj(:,1) > lims(2));
	        xy_prj(ind,:) = [];
	        ind = (xy_prj(:,2) < lims(3) | xy_prj(:,2) > lims(4));
	        xy_prj(ind,:) = [];
        end
        if (nargout == 3)
            x_min = min(xy_prj(:,1));        x_max = max(xy_prj(:,1));
            y_min = min(xy_prj(:,2));        y_max = max(xy_prj(:,2));
            opt_R = ['-R' sprintf('%f',x_min) '/' sprintf('%f',x_max) '/' sprintf('%f',y_min) '/' sprintf('%f',y_max)];
        end
    elseif (~isempty(projGMT))
        if (isempty(lims))          % We need LIMS here
            lims = [get(handles.axes1,'Xlim') get(handles.axes1,'Ylim')];
        end
        out = mapproject_m([lims(1) lims(3); lims(2) lims(4)],'-R-180/180/0/80','-I','-F',projGMT{:});    % Convert lims back to geogs
        x_min = min(out(:,1));        x_max = max(out(:,1));
        y_min = min(out(:,2));        y_max = max(out(:,2));
      	opt_R = ['-R' sprintf('%f',x_min) '/' sprintf('%f',x_max) '/' sprintf('%f',y_min) '/' sprintf('%f',y_max)];
        if (nargout == 3)
            return              % We are only interested on opt_R
        end
        opt_I = ' ';
        if (numel(lims) == 5),      opt_I = ' -I';      end         % Inverse projection
        xy_prj = mapproject_m(xy, opt_R, opt_I, '-F', projGMT{:});
        if (~isempty(lims) && pad ~= 0)
        	% Get rid of data that are outside the map limits
            lims = lims + [-pad pad -pad pad];      % Extend limits by PAD value
            ind = (xy_prj(:,1) < lims(1) | xy_prj(:,1) > lims(2));
	        xy_prj(ind,:) = [];
	        ind = (xy_prj(:,2) < lims(3) | xy_prj(:,2) > lims(4));
	        xy_prj(ind,:) = [];
        end
    else
        xy_prj = xy;
        msg = '0';          % Signal that nothing has been done and output = input
        if (nargout == 3)   % Input in geogs, we need opt_R for shoredump_m (presumably)
            opt_R = ['-R' sprintf('%f/%f/%f/%f',lims(1),lims(2),lims(3),lims(4))];
        end
        return
    end
	