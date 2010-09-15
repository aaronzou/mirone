function info_m(comm)
% INFO(COMM) prints the stdout output of the COMM gmt command
%
if isunix           % UNIX
    unix([comm ' > text_stdout']);
elseif ispc         % Windows
    dos([comm ' > text_stdout']);
else
    errordlg('Unknown platform.','Error');  return
end

fid = fopen('text_stdout', 'r');
if fid < 0
    errordlg(['Can''t open file:  ' 'text_stdout'],'Error');    return
end

% When reporting info from grdinfo it's better remove the grid's name because it takes alot of space
strip_1 = 0;
t = strtok(comm);
if strcmp(t,'grdinfo'),    strip_1 = 1;     end

nl = 1;
while ~feof(fid)
    if strip_1
        [t,r] = strtok(fgetl(fid));
        w{nl,1} = r;
    else
        w{nl,1} = fgetl(fid);
    end
    nl = nl + 1;
end
fclose(fid);
delete text_stdout;
w = w';
msgbox(w,'Info');
%dmsgfun('create',w);