function listbox_message(text,ind,opt);
% Display a text file in a listbox
% TEXT is the text to add to the lisbox fields
% IND is the number on the lisbox fields (equivalent to the 'Value' propertie)
% OPT = 'add' OR = 'rep' OR = 'del' OR = 'ins'. Where
%   'add' adds a new field at the end of list
%   'rep' replaces field number 'ind' by 'text'
%   'del' deletes field number 'ind'
%   'ins' inserts a new field at position 'ind'

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

nargs = nargin;
if (nargs == 0 | nargs > 3)
    error('Wrong number of arguments.');
end
if (nargs == 1)
    ind = 1;    opt = 'add';
elseif (nargs == 2)
    opt = 'rep';
end

h_oldF = findobj('Tag','FigIsocAges');

if (isempty(h_oldF))        % First time call. Create figure
	hf = figure('menubar','none','Tag','FigIsocAges','numbertitle','off','Name','Ages',...
        'resizefcn',@resize_callback);
	h2 = addSaveButton(hf,'SAVE');
	
	tbpos = getTBPos(hf);
	h_list = uicontrol(hf,'style','listbox','position',tbpos,'BackgroundColor',[1 1 1],...
        'tag','textbox','string',{text});
	
	handles = guihandles(hf);
    handles.h_list = h_list;
	guidata(hf,handles);
else
    handles = guidata(h_oldF);
    str = get(handles.h_list,'String');
    if (any(strcmp(opt,{'rep' 'add'}))) % Replace entry number 'ind'
        str{ind} = text;
    elseif (strcmp(opt,'del'))          % Delete the entry number 'ind'
        str(ind) = [];
    else                                % New field inserted at position 'ind'
        tmp = cell(length(str)+1,1);
        tmp(1:ind-1) = str(1:ind-1);
        tmp(ind) = {text};
        tmp(ind+1:length(str)+1) = str(ind:end);
        str = tmp;
    end
	set(handles.h_list,'string',str);
end

%------------------------------------
function resize_callback(obj,eventdata)
handles = guidata(obj);
tbpos = getTBPos(handles.FigIsocAges);
bpos = getSavePos(handles.FigIsocAges);
set(handles.savebutton,'position',bpos);
set(handles.textbox,'position',tbpos);

%------------------------------------
function tbpos = getTBPos(hf)
margins = [10 10 10 50]; % left, right, top, bottom
pos = get(hf,'position');
tbpos = [margins(1) margins(4) pos(3)-margins(1)-margins(2) pos(4)-margins(3)-margins(4)];
tbpos(tbpos < 1) = 1;

%----------------------------------
function h = addSaveButton(hf,btext)
bpos = getSavePos(hf);
h = uicontrol(hf,'style','pushbutton','position',bpos,'string',btext,'tag','savebutton');
set(h,'callback',@savebutton_callback);

%-----------------------------------
function h = savebutton_callback(obj,eventdata)
handles = guidata(obj);
str = get(handles.h_list,'String');
ages = sort(str2double(str));
str1 = {'*.dat;*.DAT', 'Data file (*.dat,*.DAT)';'*.*', 'All Files (*.*)'};
[FileName,PathName] = uiputfile(str1,'Select output file name');
if isequal(FileName,0);     return;     end
double2ascii([PathName FileName],ages,'%.3f');

%------------------------------------
function tbpos = getSavePos(hf)
bsize = [60,30];
badjustpos = [0,25];
pos = get(hf,'position');
tbpos = [pos(3)/2-bsize(1)/2+badjustpos(1) -bsize(2)/2+badjustpos(2) bsize(1) bsize(2)];
tbpos = round(tbpos);
tbpos(tbpos < 1) = 1;
