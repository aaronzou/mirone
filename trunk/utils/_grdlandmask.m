function [mask, head, X, Y] = _grdlandmask(varargin)
% Temporary function to easy up transition from GMT4 to GMT5.2

% $Id$

	global gmt_ver
	
	if (gmt_ver == 4)
		if (nargout == 1)
			mask = grdlandmask_m(varargin{:});
		elseif (nargout == 4)
			[mask, head, X, Y] = grdlandmask_m(varargin{:});
		else
			error('Wrong number of output args')
		end
	else
		cmd = 'grdlandmask';
		for (k = 1:numel(varargin))
			cmd = sprintf('%s %s', cmd, varargin{k});
		end
		gmtmex('create')
		mask = gmtmex(cmd);
		gmtmex('destroy')
		if (nargout == 4)
			head = mask.hdr;	X = mask.x;		Y = mask.y;
		end
		mask = mask.z;
	end
