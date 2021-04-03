function varargout = segmentation_ui(varargin)
% segmentation_ui(images,categories)
%
% GUI for semi-automatic image segmentation.
%  images is a list of images that shall be processed.
%    You can use loaddir or loadstrings to conveniently create this list.
%  categories is a hierarchical list of categories (labels)
%    that are presented for labeling the segments.
%    You may want to create a text file listing them and use
%    loadstrings to load it.
%
%  A typical call looks like this:
%
%  segmentation_ui( loaddir('C:\img','*.jpg'), loadstrings('categ.txt') );
%
% The GUI doesn't have a return values. Segmentation results are
% stored as files named  <original image name>.seg.gif,
% segmentation labels in <original image name>.label.mat.
%
% For further documentation please see the readme file.

%| Copyright 2007 Steffen Gauglitz
%| University of California at Santa Barbara, Vision Research Lab
%| contact: Prof. Manjunath, manj@ece.ucsb.edu

%| Modification/redistribution granted only for the purposes
%| of teaching, non-commercial research or study.

%| If you use this application we would appreciate it if you cite:
%| Elisa Drelie Gelasca, Joriz De Guzman, Steffen Gauglitz, Pratim Ghosh,
%| JieJun Xu, Amir M. Rahimi, Emily Moxley, Zhiqiang Bi, B. S. Manjunath:
%| "CORTINA: Searching a 10 Million+ Images Database",
%| submitted to the 33rd International Conference on Very Large Data Bases
%| (VLDB), September 23-28 2007, University of Vienna, Austria.


% Begin initialization code < DO NOT EDIT >
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segmentation_ui_OpeningFcn, ...
                   'gui_OutputFcn',  @segmentation_ui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code < DO NOT EDIT >

% --- Executes just before segmentation_ui is made visible.
function segmentation_ui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.images     = varargin{1}; % first  parameter: images
handles.categories = varargin{2}; % second parameter: categories
handles.colormap = randomcolormap();
handles.oldsegm = 0;
handles.output = hObject; % Choose default command line output for segmentation_ui
guidata(hObject, handles); % Update handles structure

initialize_image(hObject,1);

% --- Outputs from this function are returned to the command line.
function varargout = segmentation_ui_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)

d = guidata(gcbo);
d.oldsegm      = d.segmentation;
d.segmentation = load_presegmentation(d.images{d.i},1);
x=size(d.image,2);
y=size(d.image,1);
d.selstatus    = zeros(y,x,'uint8');
d.refinelevel  = ones (y,x,'uint8');
d.labels = struct([]);
guidata(gcbo,d);

showimage(d);

% --- Executes on button press in undo.
function undo_Callback(hObject, eventdata, handles)

d = guidata(gcbo);
if numel(d.oldsegm)>1
 d.segmentation=d.oldsegm;
 d.oldsegm=0;
end
if numel(d.oldrefine)>1
 d.refinement=d.oldrefine;
 d.oldrefine=0;
end
guidata(gcbo,d);

showimage(d);

% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)

answer=questdlg('save before going to next image?','save?');
if strcmp(answer,'Cancel'), return, end
if strcmp(answer,'Yes'), save_Callback(handles.save,[],handles); end

d = guidata(gcbo);

i = d.i + 1;
if( i > length(d.images) )
  msgbox('End of list reached! You may close the application.', ...
                'End of list','none','modal');
  
            %% delete all the segmentation !!rely on the fact the user did
            %% NOT name his/her files with *.segpre*.ppm & name them "name" . "ext"!!
            
   for i=1:length(d.images)
     file = d.images{i};
     delete([ file '.segpre*.ppm']);
   end
  
  return
end

initialize_image(gcbo,i);

% ---

function showimage(d)

if get(d.showsegmborders,'Value')==1
  temp=visualize_segm2(d.image,d.segmentation);
else
  temp=d.image;
end

sel=(d.selstatus==1);

%temp(sel) = .3.*temp(sel)+.7.*256.*d.red(sel);
temp(sel) = .0.*temp(sel)+1.0.*0.*d.red(sel); % IK
axes(d.img);
h=imshow(temp);
set(h,'ButtonDownFcn',@img_ButtonDownFcn);
set(d.nsegm,'String',['now ',num2str( countsegments(d.segmentation) ),' segment(s)']);

% --- Executes on button press in showsegmborders.
function showsegmborders_Callback(hObject, eventdata, handles)

d = guidata(gcbo);
showimage(d);

% --- Executes on mouse press over axes background.
function img_ButtonDownFcn(hObject, eventdata, handles)

d=guidata(gcbo);
pt = get(d.img, 'CurrentPoint');
x = int32(pt(1,1)); y = int32(pt(1,2));

clickedtoken=d.segmentation(y,x);
oldstatus   =d.selstatus(y,x);
newstatus   =1-oldstatus;

d.selstatus(d.segmentation == clickedtoken) = newstatus;
guidata(hObject,d);

showimage(d);

% --- Executes on button press in prev.
function prev_Callback(hObject, eventdata, handles)

answer=questdlg('save before going to previous image?','save?');
if strcmp(answer,'Cancel'), return, end
if strcmp(answer,'Yes'), save_Callback(handles.save,[],handles); end

d = guidata(gcbo);

i = d.i - 1;
if( i < 1 )
  msgbox('Start of list reached!','Start of list','none','modal');
  return
end

initialize_image(gcbo,i);

% --- 

function precompute_segmentations(filename)

if exist([filename '.segpre1.ppm'],'file') && ...
   exist([filename '.segpre2.ppm'],'file') && ...
   exist([filename '.segpre3.ppm'],'file') && ...
   exist([filename '.segpre4.ppm'],'file') && ...
   exist([filename '.segpre5.ppm'],'file'), return;
end

%%% IK %%%
%{
img = im2double(imread(filename));
[pathstr, fname, ext] = fileparts(filename);
ppmimgpath = [pathstr '\temp.ppm'];
imwrite(img, [pathstr '/temp.ppm']);
delete([ filename '.segpre*.ppm']);
myOS=computer;
s=0;
switch(myOS)
  case {'PCWIN','PCWIN64'}
    exe='felzenszwalb';
    s=s || system(['start ' exe ' 0.5 100 2000 temp.ppm ' filename '.segpre1.ppm']);
    s=s || system(['start ' exe ' 0.5 100  500 temp.ppm ' filename '.segpre2.ppm']);
    s=s || system(['start ' exe ' 0.5 100  150 temp.ppm ' filename '.segpre3.ppm']);
    s=s || system(['start ' exe ' 0.5 100   50 temp.ppm ' filename '.segpre4.ppm']);
    s=s || system(['start ' exe ' 0.5 100   10 temp.ppm ' filename '.segpre5.ppm']);
  case {'GLNX86','GLNXA64'}
    exe='felzenszwalb';
    s=s || system([exe ' 0.5 100 2000 temp.ppm ' filename '.segpre1.ppm &']);
    s=s || system([exe ' 0.5 100  500 temp.ppm ' filename '.segpre2.ppm &']);
    s=s || system([exe ' 0.5 100  150 temp.ppm ' filename '.segpre3.ppm &']);
    s=s || system([exe ' 0.5 100   50 temp.ppm ' filename '.segpre4.ppm &']);
    s=s || system([exe ' 0.5 100   10 temp.ppm ' filename '.segpre5.ppm &']);
  otherwise
    error('segmentiation_ui:os',['unsupported OS (' myOS ')']);
end
%}
%%%

addpath 'msseg'
img = imread(filename);
figure, imshow(img);
%system(['convert ' filename ' temp.ppm']);
%% parameters settings
hs = 10; hr = 20; M = 100;
[S labels] = msseg(img,hs,hr,M);
labelsrgb = label2rgb(labels);
imwrite(labelsrgb, [filename '.segpre1.ppm']);

hs = 5; hr = 15; M = 20;
[S labels] = msseg(img,hs,hr,M);
labelsrgb = label2rgb(labels);
imwrite(labelsrgb, [filename '.segpre2.ppm']);

hs = 3; hr = 10; M = 20;
[S labels] = msseg(img,hs,hr,M);
labelsrgb = label2rgb(labels);
imwrite(labelsrgb, [filename '.segpre3.ppm']);

hs = 3; hr = 7; M = 20;
[S labels] = msseg(img,hs,hr,M);
labelsrgb = label2rgb(labels);
imwrite(labelsrgb, [filename '.segpre4.ppm']);

hs = 3; hr = 5; M = 20;
[S labels] = msseg(img,hs,hr,M);
labelsrgb = label2rgb(labels);
imwrite(labelsrgb, [filename '.segpre5.ppm']);
%{
hs = 5; hr = 5; M = 50;
[S labels] = msseg(img,hs,hr,M);
labelsrgb = label2rgb(labels);
imwrite(labelsrgb, [filename '.segpre1.ppm']);

hs = 5; hr = 5; M = 40;
[S labels] = msseg(img,hs,hr,M);
labelsrgb = label2rgb(labels);
imwrite(labelsrgb, [filename '.segpre2.ppm']);

hs = 3; hr = 10; M = 30;
[S labels] = msseg(img,hs,hr,M);
labelsrgb = label2rgb(labels);
imwrite(labelsrgb, [filename '.segpre3.ppm']);

hs = 3; hr = 7; M = 20;
[S labels] = msseg(img,hs,hr,M);
labelsrgb = label2rgb(labels);
imwrite(labelsrgb, [filename '.segpre4.ppm']);

hs = 3; hr = 5; M = 20;
[S labels] = msseg(img,hs,hr,M);
labelsrgb = label2rgb(labels);
imwrite(labelsrgb, [filename '.segpre5.ppm']);
%}

%{
system(['convert ' filename ' temp.ppm']);
delete([ filename '.segpre*.ppm']);
myOS=computer;
s=0;
switch(myOS)
  case {'PCWIN','PCWIN64'}
    exe='felzenszwalb';
    s=s || system(['start ' exe ' 0.5 100  50 temp.ppm ' filename '.segpre1.ppm']);
    s=s || system(['start ' exe ' 0.5  80  50 temp.ppm ' filename '.segpre2.ppm']);
    s=s || system(['start ' exe ' 0.5  50  30 temp.ppm ' filename '.segpre3.ppm']);
    s=s || system(['start ' exe ' 0.5  50  20 temp.ppm ' filename '.segpre4.ppm']);
    s=s || system(['start ' exe ' 0.5  50  10 temp.ppm ' filename '.segpre5.ppm']);
  case {'GLNX86','GLNXA64'}
    exe='felzenszwalb';
    s=s || system([exe ' 0.5 100 2000 temp.ppm ' filename '.segpre1.ppm &']);
    s=s || system([exe ' 0.5 100  500 temp.ppm ' filename '.segpre2.ppm &']);
    s=s || system([exe ' 0.5 100  150 temp.ppm ' filename '.segpre3.ppm &']);
    s=s || system([exe ' 0.5 100   50 temp.ppm ' filename '.segpre4.ppm &']);
    s=s || system([exe ' 0.5 100   10 temp.ppm ' filename '.segpre5.ppm &']);
  otherwise
    error('segmentiation_ui:os',['unsupported OS (' myOS ')']);
end
%}

%%% original %%%
%{
system(['convert ' filename ' temp.ppm']);
delete([ filename '.segpre*.ppm']);
myOS=computer;
s=0;
switch(myOS)
  case {'PCWIN','PCWIN64'}
    exe='felzenszwalb';
    s=s || system(['start ' exe ' 0.5 100 2000 temp.ppm ' filename '.segpre1.ppm']);
    s=s || system(['start ' exe ' 0.5 100  500 temp.ppm ' filename '.segpre2.ppm']);
    s=s || system(['start ' exe ' 0.5 100  150 temp.ppm ' filename '.segpre3.ppm']);
    s=s || system(['start ' exe ' 0.5 100   50 temp.ppm ' filename '.segpre4.ppm']);
    s=s || system(['start ' exe ' 0.5 100   10 temp.ppm ' filename '.segpre5.ppm']);
  case {'GLNX86','GLNXA64'}
    exe='felzenszwalb';
    s=s || system([exe ' 0.5 100 2000 temp.ppm ' filename '.segpre1.ppm &']);
    s=s || system([exe ' 0.5 100  500 temp.ppm ' filename '.segpre2.ppm &']);
    s=s || system([exe ' 0.5 100  150 temp.ppm ' filename '.segpre3.ppm &']);
    s=s || system([exe ' 0.5 100   50 temp.ppm ' filename '.segpre4.ppm &']);
    s=s || system([exe ' 0.5 100   10 temp.ppm ' filename '.segpre5.ppm &']);
  otherwise
    error('segmentiation_ui:os',['unsupported OS (' myOS ')']);
end
if s~=0
  error('segmentation_ui:system','error executing system commands - please check availability of function ''felzenszwalb''!')
end
%}
% ---

function segm=load_segmentation(imgname)

file=[imgname '.seg.gif'];
if exist(file,'file')~=0
  segm=uint32(imread(file));
else
  segm=load_presegmentation(imgname,1);
end

% ---

function segm=load_presegmentation(imgname,level)

file=[imgname '.segpre' num2str(level) '.ppm'];

loop=0;
while exist(file,'file')==0 % wait for file to be rendered
  pause(1); % wait one second
  loop=loop+1;
  if loop>30
    warning('segmentation_ui:waiting','waiting for 30 seconds now. Are you sure the image is being rendered?!');
    loop=0;
  end
end

seg=imread(file);
factor1=uint32(max(max(seg(:,:,1)))+1);
factor2=uint32(max(max(seg(:,:,2)))+1);
segm=uint32(seg(:,:,1))+factor1.*uint32(seg(:,:,2))+factor1.*factor2.*uint32(seg(:,:,3));

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, d)

[map,s] = convert2_8bit(d.segmentation);
imwrite( s, [d.images{d.i} '.seg.gif'] );

j=1;
savelabels=0;
for l=1:length(d.labels) % only save non-empty tokens! (use for display, too?!)
  mylabel=d.labels(l).segmenttoken;
  if( numel(find(d.segmentation==mylabel,1)) )>0
    savelabels=1;
    labels(j)=d.labels(l);
    labels(j).segmenttoken=map( labels(j).segmenttoken+1 ); % and, very important: map to uint8 values!
    j=j+1;
  end
end

if savelabels ~= 1
  warning('segmentation_ui:save_Callback','No labels saved!');
else
  save([d.images{d.i} '.labels.mat'],'labels');
end

% --- Executes on button press in merge.
function merge_Callback(hObject, eventdata, d)

d.oldsegm=d.segmentation;
newtoken=d.segmentation( find(d.selstatus==1,1) );
d.segmentation( d.selstatus==1 ) = newtoken;
guidata(hObject,d);
showimage(d);

% --- Executes on button press in refine.
function refine_Callback(hObject, eventdata, d)

sel = d.selstatus==1;
if ~any(sel(:)), return, end
refinementlevel = min( d.refinelevel(sel))+1;
if refinementlevel>5, return, end % can't refine any further

d.oldrefine=d.refinelevel;
d.oldsegm  =d.segmentation;

d.refinelevel(sel)=refinementlevel;
segm=load_presegmentation(d.images{d.i},refinementlevel);
d.segmentation(sel)=segm(sel);

guidata(hObject,d);

showimage(d);

% --- Executes on button press in label.
function label_Callback(hObject, eventdata, d)

segments=deleteduplicates(d.segmentation(d.selstatus == 1));
if numel(segments)<1, return, end

[sel,ok]=listdlg('ListString',d.categories,'SelectionMode','single', ...
    'ListSize',[250 500],'Name','select label');
if ok ~= 1, return, end % user clicked 'cancel'

answer=getHierarchicalLabel(d.categories,sel);

%answer=inputdlg({'Enter label:'},'Label',1,{'<label>'});
%if numel(answer) ~= 1, return, end  % user clicked 'cancel'

for s=1:length(segments) % for all selected segments

  i=1;
  while i<=length(d.labels) % already an entry existing?
    if d.labels(i).segmenttoken==segments(s), break, end
    i=i+1;
  end % if loop runs through, i is automatically pointing to next entry
  
  d.labels(i).segmenttoken = segments(s);
  d.labels(i).label        = answer;
end

for i=1:length(d.labels), l{i}=d.labels(i).label; end
set(d.listlabels,'String',l);
guidata(hObject,d);

% ---

function initialize_image(handle,i)

d=guidata(handle);
d.i=i;

file = d.images{i};
precompute_segmentations(file);
d.segmentation= load_segmentation(file);
d.oldsegm     = 0;
d.oldrefine   = 0;
d.image       = imread(file);
if exist([file '.labels.mat'],'file')
  labels=load([file '.labels.mat']);
  d.labels = labels.labels;
else
  d.labels = struct([]);
end

l=cell(1);
for i=1:length(d.labels), l{i}=d.labels(i).label; end
set(d.listlabels,'String',l);
set(d.listlabels,'Value',1);

x=size(d.image,2);
y=size(d.image,1);
d.selstatus   = zeros(y,x,'uint8');
d.refinelevel = ones (y,x,'uint8');
d.red         = ones (y,x,'uint8');

guidata(handle,d);
showimage(d);

% --- Executes on button press in selnone.
function selnone_Callback(hObject, eventdata, d)

d.selstatus(:)=0;
guidata(hObject,d);
showimage(d);

% --- Executes on button press in selall.
function selall_Callback(hObject, eventdata, d)

d.selstatus(:)=1;
guidata(hObject,d);
showimage(d);

% --- Executes on button press in selinvert.
function selinvert_Callback(hObject, eventdata, d)

d.selstatus=1-d.selstatus;
guidata(hObject,d);
showimage(d);

% --- Executes on button press in prev10.
function prev10_Callback(hObject, eventdata, handles)

answer=questdlg('save before going to 10th previous image?','save?');
if strcmp(answer,'Cancel'), return, end
if strcmp(answer,'Yes'), save_Callback(handles.save,[],handles); end

d = guidata(gcbo);

i = d.i - 10;
if( i < 1 )
  msgbox('Start of list reached!','Start of list','none','modal');
  return
end

initialize_image(gcbo,i);

% --- Executes on button press in next10.
function next10_Callback(hObject, eventdata, handles)

answer=questdlg('save before going to 10th next image?','save?');
if strcmp(answer,'Cancel'), return, end
if strcmp(answer,'Yes'), save_Callback(handles.save,[],handles); end

d = guidata(gcbo);

i = d.i + 10;
if( i > length(d.images) )
  msgbox('End of list reached!','End of list','none','modal');
  return
end

initialize_image(gcbo,i);


% --- Executes on button press in median.
function median_Callback(hObject, eventdata, d)

answer=inputdlg({'Enter kernel size:'},'Kernel size',1,{'5'});
if numel(answer) ~= 1, return, end  % user clicked 'cancel'

k=str2double(answer{1});
d.oldsegm=d.segmentation;
d.segmentation = medfilt2(d.segmentation,[k k],'symmetric');
guidata(hObject,d);
showimage(d);


% --- Executes on selection change in listlabels.
function listlabels_Callback(hObject, eventdata, d)

s=get(hObject,'Value');
if numel(s)~=1 || s>length(d.labels), return, end
select=d.labels(s).segmenttoken;
d.selstatus(:)=0;
d.selstatus(d.segmentation == select) = 1;
guidata(hObject,d);

showimage(d);

% --- Executes during object creation, after setting all properties.
function listlabels_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in polygon.
function polygon_Callback(hObject, eventdata, d)

[ly,lx,depth]=size(d.image);

[px,py]=getline(d.img);
X=ones(ly,1)*(1:lx);
Y=(1:ly).'*ones(1,lx);
in=inpolygon(X,Y,px,py);

d.oldsegm=d.segmentation;
d.segmentation(in)=findunusedtoken(d.segmentation);
guidata(hObject,d);

showimage(d);

%--

function t=findunusedtoken(segm)

t = uint32( rand(1)*256*256+256 );
while( numel(find(segm==t,1))>0 )
  t = uint32( rand(1)*256*256+256 );
end

