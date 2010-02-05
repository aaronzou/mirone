function move2side(hFigStatic, hFigMov, opt)
% Put a smaller figure right to the side of a reference (standing) figure
%
% Try to position figure "hFigMov" glued to the right, left or bottom of "hFigStatic" figure
% OPT is an optional char string with 'left', 'right' or 'bottom' (if not provided, defaults to 'right')
% that selects at which side to position the moving figure.
%
%	EXAMPLE:
%		load clown
%		imagesc(X);		hS = gcf;	set(hS,'colormap',map)
%		hL = warndlg('I am a clown');
%		hR = warndlg('I am a clown');
%		move2side(hS, hL, 'left')
%		move2side(hS, hR)
%
%   AUTHOR
%		Joaquim Luis (jluis@ualg.pt)    13-Sep-2007
%		University of Algarve
	
	n_args = nargin;
	if (n_args < 2)
		error('move2side: need at least two inputs')
	elseif (n_args == 2)
		if (isa(hFigMov,'char'))
			opt = hFigMov;
			hFigMov = hFigStatic;
			hFigStatic = false;
		else
			opt = 'right';
		end
	elseif (n_args == 3 && ~ischar(opt))
		error('move2side: third argument must be a character string')
	end

	if ( ~(ishandle(hFigMov) && strcmp(get(hFigMov,'Type'), 'figure')) )
		error('move2side: first argument must be a valid figure handle')
	end
	if (hFigStatic && ~(ishandle(hFigStatic) && strcmp(get(hFigStatic,'Type'), 'figure')) )
		error('move2side: second argument must be a valid figure handle')
	end

	% get the screen size
	ecran = get(0,'ScreenSize');
	
	% save original figures units and temp set them to pixels
	if (hFigStatic),	FigStaticUnit = get(hFigStatic,'Units');	set(hFigStatic,'Units','Pixels'),	end
	FigMovUnit = get(hFigMov,'Units');		set(hFigMov,'Units','Pixels')
	
	% Get figures dimensions
	posFigMov = get(hFigMov,'Pos');
	outPosFigMov = get(hFigMov,'outerposition');
	if (hFigStatic)
		posFigStatic = get(hFigStatic,'Pos');
	else
		if (lower(opt(1)) == 'r')
			posFigStatic = [ecran(3) ecran(2:4)];
		else
			posFigStatic = [-1 0 ecran(3:4)];
		end
	end
	
	refine_yLL = true;				% For the horizontal cases
	if (lower(opt(1)) == 'r')		% Put moving figure on the RIGHT side of reference figure
		xLL = posFigStatic(1) + posFigStatic(3) + 6;	% + 6 is empiric
		xLR = xLL + posFigMov(3);
		if (xLR > ecran(3))         % If figure is partially out, bring it totally into screen
			xLL = ecran(3) - posFigMov(3);
		end
	elseif (lower(opt(1)) == 'l')	% Put moving figure on the LEFT side of reference figure
		xLL = posFigStatic(1) - posFigMov(3) - 6;		% + 6 is empiric
		if (xLL < 0)				% If figure is partially out, bring it totally into screen
			xLL = 4;				% 4 is nicier than 0
		end
	else							% Put moving figure on the BOTOM side of reference figure
		xLL = posFigStatic(1) + posFigStatic(3)/2  - posFigMov(3)/2;	% More or less centered
		yLL = posFigStatic(2) - posFigMov(4) - 28;		% But this can leak trough the screen bottom ...
		movegui(hFigMov, 'south')
		posFigMov = get(hFigMov,'Pos');
		yLL = max(yLL, posFigMov(2)+30);		% Take the highest of the two estimations. 30 is for bottom bar
		refine_yLL = false;
	end

	if (refine_yLL),	yLL = (posFigStatic(2) + posFigStatic(4)/2+12) - (posFigMov(4) / 2 - 22);	end
	if ( (yLL + outPosFigMov(4) + 5) > ecran(4) )		% Figure is partially out from top (5 is au-pif)
		yLL = ecran(4) - outPosFigMov(4) + 4;
	end
	set(hFigMov,'Pos',[xLL yLL posFigMov(3:4)])
	
	% Reset original figures units
	if (hFigStatic),	set(hFigStatic,'Units',FigStaticUnit),		end
	set(hFigMov,'Units',FigMovUnit)
