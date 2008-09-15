function [numeric_data,date,headerlines,str_col,out] = text_read(varargin)
% This function is another attempt (as compared to guess_file function) to build a funtion
% that guesses as much as I can from a generic file. It is crude right now, but if it proves
% usefull, it should be merged with guess_file
%
% A = TEXT_READ(FILENAME) loads data from FILENAME into A.
%
% TEXT_READ(FILENAME, D) loads data from FILENAME using D as the column
% separator (if text).  Use '\t' for tab.
%
% NUMERIC_DATA  The numeric data in file
% DATE          If a column in file is of string type assume that it's a date string and convert it to dec years
%               However, if multisegment file is indicated in input it will contain the multiseg char
%               This implyies that files with a date string cannot be multiseg
% HEADERLINES   Number of header lines in file
% STR_COL       If a column in file is of string type, return that column number
%               In case nargout == 4, it contains the header text lines
% OUT           A structure with NUMERIC_DATA, Header text and ... I think its idiot and gives nothing new
% This function uses some sub-functions of IMPORTDATA
% Coffeeright Joaquim Luis

filename = varargin{1};     hlines = NaN;

if (nargin > 1),    requestedDelimiter = varargin{2};
else                requestedDelimiter = NaN;       end

if (nargin > 2),    requestedHeaderLines = varargin{3};
else                requestedHeaderLines = NaN;     end

if (nargin > 3),    requestedMultiSeg = varargin{4};
else                requestedMultiSeg = NaN;     end

if ~ischar(filename)                 % get filename
	errordlg('Filename must be a string.','Error');
	numeric_data = [];  date = [];  headerlines = 0;    str_col = [];   out = [];
	return
end

if isempty(filename)                % do some validation
	errordlg('Filename must not be empty.','Error');
	numeric_data = [];  date = [];  headerlines = 0;    str_col = [];   out = [];
	return
end

if ~isequal(exist(filename,'file'), 2)     % make sure file exists
	errordlg('File not found.','Error');
	numeric_data = [];  date = [];  headerlines = 0;    str_col = [];   out = [];
	return
end

% ----------------------------- open the file
fid = fopen(filename);
if fid == (-1)
	errordlg(['Could not open file ', filename ,'.'],'Error');
	numeric_data = [];  date = [];  headerlines = 0;    str_col = [];   out = [];
	return
end
string = char(fread(fid)');
%string=fread(fid,'*char').';
fclose(fid);

if isempty(string)                  % Check that file is not empty
	errordlg('Empty file.','Error');
	numeric_data = [];  date = [];  headerlines = 0;    str_col = [];   out = [];
	return
end

% get the delimiter for the file
if isnan(requestedDelimiter)
	str = string(1:min(length(string),4096));       % Limit the variable size used to guess the delimiter
	delimiter = guessdelim(str);    clear str;
	if (numel(delimiter) > 1)		% Found more than one likely delimiter, where second is ' ' or '\t'
		string = strrep(string, delimiter(2), delimiter(1));	% Replace occurences of second delimiter by first
		delimiter = delimiter(1);
	end
else
	delimiter = sprintf(requestedDelimiter);
end

% tenta o caso dos multi-segments
if ~isnan(requestedMultiSeg)
	p = find(string == requestedMultiSeg);
	if (~isempty(p))
		p(end+1) = length(string)+1;    vv = [];
		for k = 1:length(p)-1;
			T = string(p(k):p(k+1)-1);
			h = min(find(T==10));		% 10 = end of line
            vv = [vv p(k):p(k)+h];
		end
		if (vv(end) > numel(string)),	vv(end) = numel(string);	end		% As when one have a ">" in the last line
		clear p vv T h;
	else
		requestedMultiSeg = NaN;		% It was a false request
	end
end

try
	[out.data, out.textdata, headerlines] = stringparse(string, delimiter, hlines);
	out = LocalRowColShuffle(out);      clear string;
catch
	errordlg('Unknown error while parsing the file.','Error');
	numeric_data = [];  date = [];  headerlines = 0;    str_col = [];   out = [];
	return
end

if (~isnan(requestedHeaderLines))   % Force to beleave in the requested number of HeaderLines
	out.headers = out.textdata(1:headerlines);          % Return also the headers
	out.textdata = out.textdata(requestedHeaderLines+1:end,:);
	headerlines = 0;        % Jump the guessed number of headers
end

% If a column in file is of string type assume that it's a date string and convert it to dec years
% But first rip out the eventual headerlines from the array.
if (isempty(out.data) && ~isempty(out.textdata))      % We have only text
	% How shell we find the number of eventual headerlines? This is a tough case.
	% Basicly we'll count the number of delimeters and assume that headers and line data
	% have a different number of delimeters. This creteria may faill in many cases e.g.
	% more headers than line data; headers with the same number of delims as data, etc ...
	rows = size(out.textdata,1);
	n_test = min(rows,50);          % Do not test more than 50 lines
	numDelims = zeros(1,n_test);
	for (i=1:n_test)
		numDelims(i) = length(find(out.textdata{i} == delimiter));
	end    
	med = median(numDelims);
	tmp = find(numDelims ~= med);
	headerlines = length(tmp);
end

if (~isnan(requestedHeaderLines) && headerlines > 0)     % Very likely the # of requestedHeaderLines was wrong
	warndlg('I have strong reasons to beleave that the number of header lines provided was false. Expect errors.','Wrning')
end

if (headerlines)
	out.headers = out.textdata(1:headerlines);          % Return also the headers
	out.textdata = out.textdata(headerlines+1:end,:);
else
	out.headers = [];
end

[numeric_data,date,str_col] = col_str2dec(out,delimiter);

if (nargout == 4 && isempty(str_col))
	str_col = out.headers;
end

if ~isnan(requestedMultiSeg)
	fid = fopen(filename);
	c = fread(fid,inf,'*char');
	s = strread(c,'%s','delimiter','\n');     clear c;
	fclose(fid);
	ix = strmatch(requestedMultiSeg,s);
	% ... descriptors
	date = s(ix);
	ix = [ix;size(s,1)+1];    ib = ix(1:end-1)+1;    ie = ix(2:end)-1;
	ind = ((ib - ie) > 0);					% Find consecutive lines that start by the multi-seg character
	ib(ind) = [];		ie(ind) = [];		% And remove the n-1 first (if they exist, certainly) 
	% Because strread neads as many nargout as n_col, I do the following
	numeric_data = cell(numel(ib),1);		% Reuse this var
	for i=1:numel(ib)
        sv = [char(s(ib(i):ie(i))) repmat(char(10),ie(i)-ib(i)+1,1)];
        numeric_data{i} = strread(sv.');
	end
end

%-------------------------------------------------------------------------------------------------------
function out = LocalRowColShuffle(in)
	out = in;
	if isempty(in) || ~isfield(in, 'data') || ~isfield(in,'textdata') || isempty(in.data) || isempty(in.textdata)
		return
	end
	[dm, dn] = size(in.data);
	[tm, tn] = size(in.textdata);
	if (tn == 1 && tm == dm)     % use as row headers
		out.rowheaders = in.textdata(:,end);
	elseif (tn == dn)           % use last row as col headers
		out.colheaders = in.textdata(end,:);
	end

%-------------------------------------------------------------------------------------------------------
function delim = guessdelim(str)
%GUESSDELIM Take stab at default delim for this string.
%   Copyright 1984-2002 The MathWorks, Inc. 

if isempty(str),    delim = '';    return;  end     % return if str is empty
%numLines = length(find(str == sprintf('\n')));      % count num lines

% NOTE: THIS PROCEDURE IS NOT COMPLETELY ISENT OF RISK
% A problem raises when we have nearly as many header lines as data lines.
% In such cases the guessed delimeter will likely be ' ' which is may be deadly wrong
% So I'll remove from STR all chunks between eventual '#' or '>' and the next '\n'
% so that these header lines are not taken into account in delimiter guessing
ind = strfind(str,'#');
if (~isempty(ind))
	nHead = numel(ind);
	indN = strfind(str,sprintf('\n'));
	inds = sort([indN ind]);
	newind = zeros(1,nHead);
	for (k=1:nHead),        newind(k) = find(inds == ind(k));    end
	res = [];
	for (k=1:nHead),        res = [res inds(newind(k)):inds(newind(k)+1)];    end
	str(res)=[];
end

% Now do the same with the '>'
ind = strfind(str,'>');
if (~isempty(ind))
	% Note that this will be nearly useless if header lines have more than one '>'
	nHead = numel(ind);     % number of probable header lines that contain a '>' char
	indN = strfind(str,sprintf('\n'));      % get position of new lines chars
	inds = sort([indN ind]);
	newind = zeros(1,nHead);
	for (k=1:nHead),        newind(k) = find(inds == ind(k));    end
	res = [];
	for (k=1:nHead),        res = [res inds(newind(k)):inds(newind(k)+1)];    end
	str(res)=[];        % Removes chunks between a '>' and a newline
end

numLines = numel(strfind(str,sprintf('\n')));      % count remaining num of lines

% set of column delimiters to try - ordered by quality as delim
delims = {sprintf('\t'), ',', ';', ':', '|', ' '};

% remove any delims which don't appear at all
% need to rethink based on headers and footers which are plain text
goodDelims = {};
numDelims = zeros(1, numel(delims));
for i = 1:numel(delims)
    numDelims(i) = numel(strfind(str,delims{i}));
    if (numDelims(i) ~= 0)        % this could be a delim
        goodDelims{end+1} = delims{i};
    end
end

% if no delims were found, return empty string
if isempty(goodDelims),    delim = '';    return;   end

% if the num delims is greater or equal to num lines, this will be the default (so return)
nDelimsFound = sum(numDelims > 0);
if (nDelimsFound == 1 || nDelimsFound > 2)		% Found one or (???) multiple delimiters
	[maxNdelims,ind] = max(numDelims);			% Get the greater number of delimiters
	if (maxNdelims > numLines)
		delim = delims{ind};
		return
	end
elseif (nDelimsFound == 2)			% Two delimiters found. 
	% If second delimiter is ' ' or '\t' replace their occurences by first delimiter
	[so,ii] = sort(numDelims);
	second_delim = delims{ii(end-1)};
	if ( strcmp(second_delim, ' ') || strcmp(second_delim, sprintf('\t')) )
		delim = [delims{ii(end)} delims{ii(end-1)}];
		return
	end
end

% no delimiter was a clear win from above, choose the first in the delimiter list
delim = goodDelims{1};

%-------------------------------------------------------------------------------------------------------
function [numericData, textData, numHeaderRows] = stringparse(string, delimiter, headerLines)
%STRINGPARSE Helper function for importdata.
% Copyright 1984-2002 The MathWorks, Inc.

numericData = [];
textData = {};
numHeaderRows = 0;

% gracefully handle empty
if ( isempty(string) || all(isspace(string)) ),    return;   end

% validate delimiter 
if nargin == 1
    delimiter = guessdelim(string);
else    % handle \t
    delimiter = sprintf(delimiter);
    if (numel(delimiter) > 1)
        error('Multi character delimiters not supported.')
    end
end

if (nargin < 3),    headerLines = NaN;      end

% use what user asked for header lines if specified
[numDataCols, numHeaderRows, numHeaderCols, numHeaderChars] = analyze(string, delimiter, headerLines);

% fetch header lines and look for a line of column headers
headerLine = {};
headerData = {};
origHeaderData = headerData;
useAsCells = 1;

if numHeaderRows
    firstLineOffset = numHeaderRows - 1;
    headerData = strread(string,'%[^\n]',firstLineOffset,'delimiter',delimiter);
    origHeaderData = headerData;
    
    if numDataCols
        headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols + numDataCols - 1)];
    else
        headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols)];
    end
    
    headerLine = strread(string,'%[^\n]',1,'headerlines',firstLineOffset,'delimiter',delimiter);
    origHeaderLine = headerLine;
    useAsCells = 0;
    
    if ~isempty(delimiter) && ~isempty(headerLine) && ~isempty(strfind(deblank(headerLine{:}), delimiter))
        cellLine = split(headerLine{:}, delimiter);
        if length(cellLine) == numHeaderCols + numDataCols
            headerLine = cellLine;
            useAsCells = 1;
        end
    end
    
    if (~useAsCells)
        if numDataCols
            headerLine = [origHeaderLine, cell(1, numHeaderCols + numDataCols - 1)];
        else
            headerLine = [origHeaderLine, cell(1, numHeaderCols)];
        end
    end
end

if isempty(delimiter)
    formatString = [repmat('%s', 1, numHeaderCols) repmat('%n', 1, numDataCols)];
else
    formatString = [repmat(['%[^' delimiter ']'], 1, numHeaderCols) repmat('%n', 1, numDataCols)];
end

textCellData = {};
numericCellData = {};

% call strread with format string
% (if we got here, there must be at least one good chunk on the 1st line in the file)
if numHeaderCols && numDataCols
    [textCellData{1:numHeaderCols}, numericCellData{1:numDataCols}] = ...
        strread(string,formatString,1,'delimiter',delimiter,'headerlines',numHeaderRows);
elseif numDataCols
    [numericCellData{1:numDataCols}] = ...
        strread(string,formatString,1,'delimiter',delimiter,'headerlines',numHeaderRows);
end

% now try again for the whole shootin' match
try
    if numHeaderCols && numDataCols
        [textCellData{1:numHeaderCols}, numericCellData{1:numDataCols}] = ...
            strread(string,formatString,'delimiter',delimiter,'headerlines',numHeaderRows);
    elseif numDataCols
        [numericCellData{1:numDataCols}] = ...
            strread(string,formatString,'delimiter',delimiter,'headerlines',numHeaderRows);
    end
    wasError = 0;
catch
    wasError = 1;
end

% setup some default answers if we're not able to do the full read below
if numHeaderCols
    numRows = length(textCellData{1});
else
    numRows = 0;
end

if (numDataCols && ~numRows && ~isempty(numericCellData{1}))
    numRows = length(numericCellData{1});
end

if (nargout > 1)
    for i = 1:numHeaderCols
        textData(:,i) = textCellData{i};
    end
end

for (i = 1:numDataCols)
    numericData(:,i) = numericCellData{i};
    if (nargout > 1), textData(:,i+numHeaderCols) = cell(numRows, 1); end
end

if (nargout > 1)
    if ~isempty(headerLine)
        textData = [headerLine; textData];
    end
    
    if ~isempty(headerData)
        textData = [headerData; textData];
    end    
end

% if the first pass failed to read the whole shootin' match, try again using the character offset
if wasError && numHeaderChars
    % rebuild format string
    formatString = ['%' num2str(numHeaderChars) 'c' repmat('%n', 1, numDataCols)];
    textCharData = '';
    try
        [textCharData, numericCellData{1:numDataCols}] = ...
            strread(string,formatString,'delimiter',delimiter,'headerlines',numHeaderRows,'returnonerror',1);
        numHeaderCols = 1;
        if ~isempty(numericCellData)
            numRows = length(numericCellData{1});
        else
            numRows = length(textCharData);
        end
    end        
    
    numericData = [];
    
    if numDataCols
        headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols + numDataCols - 1)];
    else
        headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols)];
    end
    
    if ~useAsCells
        if numDataCols
            headerLine = [origHeaderLine, cell(1, numHeaderCols + numDataCols - 1)];
        else
            headerLine = [origHeaderLine, cell(1, numHeaderCols)];
        end
    end
    
    for (i = 1:numDataCols)
        numericData(:,i) = numericCellData{i};
    end
    
    if (nargout > 1 && ~isempty(textCharData))
        textCellData = cellstr(textCharData);
        if ~isempty(headerLine)
            textData = [headerLine;
                textCellData(1:numRows), cell(numRows, numHeaderCols + numDataCols - 1)];
        else
            textData = [textCellData(1:numRows), cell(numRows, numHeaderCols + numDataCols - 1)];
        end
        
        if ~isempty(headerData)
            textData = [headerData; textData];
        end
    end
end

if (nargout > 1 && ~isempty(textData))    % trim trailing empty rows from textData
    i = 1;
    while i <= size(textData,1)
        if all(cellfun('isempty',textData(i,:)))
            break;
        end
        i = i + 1;
    end
    if i <= size(textData,1)
        textData = textData(1:i-1,:);
    end
    
    % trim trailing empty cols from textData
    i = 1;
    while (i <= size(textData,2))
        if all(cellfun('isempty',textData(:,i)))
            break;
        end
        i = i + 1;
    end
    if (i <= size(textData,2))
        textData = textData(:,1:i-1);
    end
end

%-------------------------------------------------------------------------------------------------------
function [numColumns, numHeaderRows, numHeaderCols, numHeaderChars] = analyze(string, delimiter, header)
%ANALYZE count columns, header rows and header columns

numColumns = 0;         numHeaderRows = 0;
numHeaderCols = 0;      numHeaderChars = 0;

if (~isnan(header)),    numHeaderRows = header;     end

thisLine = strread(string,'%[^\n]',1,'headerlines',numHeaderRows,'delimiter',delimiter);
if isempty(thisLine),    return;    end
thisLine = thisLine{:};

% When 'thisLine' has blanks at the end this would cause a wrong estimation of numColumns below
thisLine = deblank(thisLine);

[isvalid, numHeaderCols, numHeaderChars] = isvaliddata(thisLine, delimiter);

if (~isvalid)
    numHeaderRows = numHeaderRows + 1;
    thisLine = strread(string,'%[^\n]',1,'headerlines',numHeaderRows,'delimiter',delimiter);
    if isempty(thisLine),   return;    end
    thisLine = thisLine{:};
    
    [isvalid, numHeaderCols, numHeaderChars] = isvaliddata(thisLine, delimiter);
    if (~isvalid)
        newLines = strfind(string,sprintf('\n'));
        if (isempty(newLines))  % must be a MAC
            newLines = strfind(string,char(13));
            if (isempty(newLines)) % do not know what to do with this...
                return
            end
        end
        % deal with the case where the file is not terminated with a \n
        if (newLines(end) ~= length(string))
            newLines(end + 1) = length(string);
        end
        numLines = length(newLines);
        newLines(end+1) = length(string) + 1;
        
        while (~isvalid )
            if(numHeaderRows == numLines),  break;      end
            
            % stop now if the user specified a number of header lines
            if (~isnan(header) && numHeaderRows == header)
                break;
            end
            numHeaderRows = numHeaderRows + 1;
            
            thisLine = string((newLines(numHeaderRows)+1):(newLines(numHeaderRows+1)-1));
            if (isempty(thisLine)), break;      end
            [isvalid, numHeaderCols, numHeaderChars] = isvaliddata(thisLine, delimiter);
        end
    end
end

% Thie check could happen earlier
if (~isnan(header) && numHeaderRows >= header)
    numHeaderRows = header;
end

if (isvalid)    % determine num columns
    delimiterIndexes = strfind(thisLine, delimiter);
    if (all(delimiter == ' ') && length(delimiterIndexes) > 1)
        delimiterIndexes = delimiterIndexes([true diff(delimiterIndexes) ~= 1]);
    end
    
    % format string should have 1 more specifier than there are delimiters
    numColumns = length(delimiterIndexes) + 1;
    if (numHeaderCols > 0)  % add one to numColumns because the two set of columns share a delimiter
        numColumns = numColumns - numHeaderCols;
    end    
end

%-------------------------------------------------------------------------------------------------------
function [status, numHeaderCols, numHeaderChars] = isvaliddata(string, delimiter)
% ISVALIDDATA delimiters and all numbers or e or + or . or -
% what about single columns???

numHeaderCols  = 0;     numHeaderChars = 0;

if isempty(delimiter)    % with no delimiter, the line must be all numbers, +, . or -
    status = isdata(string);
elseif isempty(strfind(string, delimiter))
    % a delimiter must occur on each line of data (or there is no delimiter...)
    status = 0;
else    % if there is data at the end of the line, it's legit
    cellstring = {fliplr(strtok(fliplr(deblank(string)), delimiter))};
    flag = isdata(cellstring);
    status = 0;
    if flag
        cellstring = split(string, delimiter);
        flags = isdata(cellstring);
        % num leading zeros in flags is num header cols
        numHeaderCols = max(find(flags == 0));
        if (isempty(numHeaderCols))
            numHeaderCols = 0;
        end
        % use contents of 1st data data cell to find num leading chars
        numHeaderChars = strfind(string, cellstring{numHeaderCols + 1}) - 1;
        status = 1;
    end
end

%-------------------------------------------------------------------------------------------------------
function status = isdata(cellstring)
%ISDATA true if string can be shoved into a number

if (~isa(cellstring,'cell'))
    cellstring = cellstr(cellstring);
end

status = logical([]);
for (i = 1:length(cellstring) - 1)
    [a,b,c] = sscanf(cellstring{i}, '%g');
    status(i) = isempty(c);
end

if (~isempty(cellstring{end}))      % ignore empty last field
    [a,b,c] = sscanf(cellstring{end}, '%g');
    status(length(cellstring)) = isempty(c);
end

%-------------------------------------------------------------------------------------------------------
function cellOut = split(string, delimiter)
%SPLIT rip string apart using strtok
cellOut = strread(string,'%s','delimiter',delimiter)';

%-------------------------------------------------------------------------------------------------------
function [numeric_data,date,str_col] = col_str2dec(in1,delimiter)
% This function doesn't do anything (and returns emptys) if the in1 var doesn't
% have a string column. Otherwise NUMERIC_DATA contains the original numeric columns,
% DATE contains the string date converted to decimal years and STR_COL is the string column number

numeric_data = [];  date = [];  str_col = [];
if (isstruct(in1) && ~isempty(in1.textdata))     % We have at least one string column in file (the last column)
    if (iscell(in1.textdata))   % I think that's allways the case, but...
        % When the string is in the last column, we still want to know if the previous are numeric
        % In that case in1.textdata will containt only one column per line
        cellstring = strread(in1.textdata{1},'%s','delimiter',delimiter)';
        try
            flags = isdata(cellstring(1:length(cellstring)-1));
            n_good = max(find(flags ~= 0));
        catch   % Error occurs when in1.textdata has more than 1 column and the n_good condition is not necessary
            n_good = 0;
        end
        if (n_good)             % Yes, there are valid data cols before the string col
            tmp = [];   m = size(in1.textdata,1);
            for (i=1:m)
                tmp = [tmp; strread(in1.textdata{i},'%s','delimiter',delimiter)'];
            end
            numeric_data = reshape(str2num(cat(1,tmp{:,1:n_good})),m,n_good);
            clear tmp;
            str_col = n_good+1;  % Keep trace on the string column number
        else
            [m,n] = size(in1.textdata);
            numeric_data = reshape(str2num(cat(1,in1.textdata{:,1:n-1})),m,n-1);    % Fds this was tough
            in1.textdata(:,1:end-1) = [];     % retain only the data string in this variable
            str_col = n;            % Keep trace on the string column number
        end
        if (~isempty(in1.data))     % cat the eventual data after the string column
            numeric_data = [numeric_data in1.data];
        end
    else        % Shit, what shell I do?
        errordlg('Case not forseen in "col_str2dec".','Error')
        numeric_data = [];  date = [];  str_col = [];   return;
    end
elseif (isstruct(in1) && isempty(in1.textdata) && ~isempty(in1.data))     % Date string not found but found valid data 
    numeric_data = in1.data;    date = [];  str_col = [];   return;
end

dateform = [];
if (~isempty(str_col))
    % Now we have to decode the data column (a string) and convert it to dec years
    % Accepted formats are (or any of the "/" ":" "-" separators):
    % dd-mmm-yyyy, mmm-dd-yyyy, yyyy-mmm-dd, yyyy-dd-mmm
    % dd-mm-yyyy,  mm-dd-yyyy,  yyyy-mm-dd,  yyyy-dd-mm
    % Because -mm-dd is almost impossible to guess from -dd-mm, ambiguous cases are treated as -mm-dd
    delim_dash = strfind(in1.textdata{1},'-');
    delim_slash = strfind(in1.textdata{1},'/');
    delim_colon = strfind(in1.textdata{1},':');
    if (~isempty(delim_dash) && size(delim_dash,2) == 2 && diff(delim_dash) <= 4) % > 4 are due to a - in other cols
        delim = 1;      delim_sep = '-';
    elseif (~isempty(delim_slash) && size(delim_slash,2) == 2)
        delim = 2;      delim_sep = '/';
    elseif (~isempty(delim_colon) && size(delim_colon,2) >= 2)
        delim = 3;      delim_sep = ':';
    else
        warndlg('Unknown date format','Warning');
        date = [];  str_col = [];   return;
    end
    
    switch delim
        case 1      % '-' is the delimiter
            d1 = in1.textdata{1}(1:delim_dash(1)-1);
            d2 = in1.textdata{1}(delim_dash(1)+1:delim_dash(2)-1);
            d3 = in1.textdata{1}(delim_dash(2)+1:end);
        case 2      % '/' is the delimiter
            d1 = in1.textdata{1}(1:delim_slash(1)-1);
            d2 = in1.textdata{1}(delim_slash(1)+1:delim_slash(2)-1);
            d3 = in1.textdata{1}(delim_slash(2)+1:end);
        case 3      % ':' is the delimiter
            d1 = in1.textdata{1}(1:delim_colon(1)-1);
            d2 = in1.textdata{1}(delim_colon(1)+1:delim_colon(2)-1);
            d3 = in1.textdata{1}(delim_colon(2)+1:end);
    end
    yr_pos = find([length(d1) length(d2) length(d3)] == 4);
    
    if (yr_pos == 3)        % We are in the cases of '??-???-yyyy' or '???-??-yyyy'
        year = d3;
        mon_pos = find([length(d1) length(d2)] == 3);
        if (mon_pos ~= 0)   % We have a month in the mmm type, but in what position?
            if (mon_pos == 1)
                month = d1;   day = d2;     dateform = ['mmm' delim_sep 'dd' delim_sep 'yyyy'];
            else
                month = d2;   day = d1;     dateform = ['dd' delim_sep 'mmm' delim_sep 'yyyy'];
            end
        else                % We have a month in the mm type (shit)
            dateform = ['mm' delim_sep 'dd' delim_sep 'yyyy'];
        end
    elseif (yr_pos == 1)    % We are in the cases of 'yyyy-??-???' or 'yyyy-???-??'
        year = d1;
        mon_pos = find([length(d2) length(d3)] == 3);
        if (mon_pos ~= 0)   % We have a month in the mmm type, but in what position?
            if (mon_pos == 2)
                month = d2;   day = d3;     dateform = ['yyyy' delim_sep 'mmm' delim_sep 'dd'];
            else
                month = d3;   day = d2;     dateform = ['yyyy' delim_sep 'dd' delim_sep 'mmm'];
            end
        else                % We have a month in the mm type (shit)
            dateform = ['yyyy' delim_sep 'mm' delim_sep 'dd'];
        end
    end
    % Move in1.textdata to the tmp variable
    tmp = char(in1.textdata);       in1.textdata = [];
else
    date = [];  str_col = [];   return;
end

switch dateform         % Convert the date from its string form to decimal years
    case 'dd-mmm-yyyy'
        tmp1 = tmp(:,1:delim_dash(1)-1);
        tmp2 = lower(tmp(:,delim_dash(1)+1:delim_dash(2)-1));
        tmp3 = tmp(:,delim_dash(2)+1:end);
        mon = monstr2monnum(tmp2);      year = str2num(tmp3);   day = str2num(tmp1);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
    case 'mmm-dd-yyyy'
        tmp1 = lower(tmp(:,1:delim_dash(1)-1));
        tmp2 = tmp(:,delim_dash(1)+1:delim_dash(2)-1);
        tmp3 = tmp(:,delim_dash(2)+1:end);
        mon = monstr2monnum(tmp1);      year = str2num(tmp3);   day = str2num(tmp2);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
        %date = year + (datenummx(year,mon,day) - datenummx(year,1,1))/365;
    case 'dd-mm-yyyy'
        tmp1 = tmp(:,1:delim_dash(1)-1);
        tmp2 = tmp(:,delim_dash(1)+1:delim_dash(2)-1);
        tmp3 = tmp(:,delim_dash(2)+1:end);
        mon = str2num(tmp2);      year = str2num(tmp3);   day = str2num(tmp1);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
    case 'mm-dd-yyyy'
        tmp1 = tmp(:,1:delim_dash(1)-1);
        tmp2 = tmp(:,delim_dash(1)+1:delim_dash(2)-1);
        tmp3 = tmp(:,delim_dash(2)+1:end);
        mon = str2num(tmp1);      year = str2num(tmp3);   day = str2num(tmp2);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
        
    case 'dd/mmm/yyyy'
        tmp1 = tmp(:,1:delim_slash(1)-1);
        tmp2 = lower(tmp(:,delim_slash(1)+1:delim_slash(2)-1));
        tmp3 = tmp(:,delim_slash(2)+1:end);
        mon = monstr2monnum(tmp2);      year = str2num(tmp3);   day = str2num(tmp1);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
    case 'mmm/dd/yyyy'
        tmp1 = lower(tmp(:,1:delim_slash(1)-1));
        tmp2 = tmp(:,delim_slash(1)+1:delim_slash(2)-1);
        tmp3 = tmp(:,delim_slash(2)+1:end);
        mon = monstr2monnum(tmp1);      year = str2num(tmp3);   day = str2num(tmp2);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
    case 'dd/mm/yyyy'
        tmp1 = tmp(:,1:delim_slash(1)-1);
        tmp2 = tmp(:,delim_slash(1)+1:delim_slash(2)-1);
        tmp3 = tmp(:,delim_slash(2)+1:end);
        mon = str2num(tmp2);      year = str2num(tmp3);   day = str2num(tmp1);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
    case 'mm/dd/yyyy'
        tmp1 = tmp(:,1:delim_slash(1)-1);
        tmp2 = tmp(:,delim_slash(1)+1:delim_slash(2)-1);
        tmp3 = tmp(:,delim_slash(2)+1:end);
        mon = str2num(tmp1);      year = str2num(tmp3);   day = str2num(tmp2);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
        
    case 'dd:mmm:yyyy'
        tmp1 = tmp(:,1:delim_colon(1)-1);
        tmp2 = lower(tmp(:,delim_colon(1)+1:delim_colon(2)-1));
        tmp3 = tmp(:,delim_colon(2)+1:end);
        mon = monstr2monnum(tmp2);      year = str2num(tmp3);   day = str2num(tmp1);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
    case 'mmm:dd:yyyy'
        tmp1 = lower(tmp(:,1:delim_colon(1)-1));
        tmp2 = tmp(:,delim_colon(1)+1:delim_colon(2)-1);
        tmp3 = tmp(:,delim_colon(2)+1:end);
        mon = monstr2monnum(tmp1);      year = str2num(tmp3);   day = str2num(tmp2);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
    case 'dd:mm:yyyy'
        tmp1 = tmp(:,1:delim_colon(1)-1);
        tmp2 = tmp(:,delim_colon(1)+1:delim_colon(2)-1);
        tmp3 = tmp(:,delim_colon(2)+1:end);
        mon = str2num(tmp2);      year = str2num(tmp3);   day = str2num(tmp1);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
    case 'mm:dd:yyyy'
        tmp1 = tmp(:,1:delim_colon(1)-1);
        tmp2 = tmp(:,delim_colon(1)+1:delim_colon(2)-1);
        tmp3 = tmp(:,delim_colon(2)+1:end);
        mon = str2num(tmp1);      year = str2num(tmp3);   day = str2num(tmp2);
        clear tmp1 tmp2 tmp3 tmp;
        date = dec_year(year,mon,day);
end

if (isempty(date))      % There was an error in the file's string date column, but we don't know
    str_col = [];       % where. So we leave silently (an error message would be more appropriate)
end

% ------------------------
function mon = monstr2monnum(monstr)
M = ['jan'; 'feb'; 'mar'; 'apr'; 'may'; 'jun'; 'jul'; 'aug'; 'sep'; 'oct'; 'nov'; 'dec'];
m = size(monstr,1);
mon = zeros(m,1);
for i=1:m
    mon(i) = find(all((M == monstr(ones(12,1),1:3))'));
end
