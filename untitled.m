function varargout = untitled(varargin)
% UNTITLED MATLAB code for untitled.fig
%      UNTITLED, by itself, creates a new UNTITLED or raises the existing
%      singleton*.
%
%      H = UNTITLED returns the handle to a new UNTITLED or the handle to
%      the existing singleton*.
%
%      UNTITLED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED.M with the given input arguments.
%
%      UNTITLED('Property','Value',...) creates a new UNTITLED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled

% Last Modified by GUIDE v2.5 30-May-2024 03:47:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before untitled is made visible.
function untitled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled (see VARARGIN)

% Choose default command line output for untitled
handles.output = hObject;
handles.template = create_template();
try
    load('crops.mat');
    handles.crops = crops;
catch
    crops = containers.Map();
    handles.crops = crops;
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadimage.
function loadimage_Callback(hObject, eventdata, handles)
% hObject    handle to loadimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% this image loads the image and draws it to axes
% if this image has been cropped before, it will take 
% whatever was inside the dictionary and crop it to same me time
% plus it's prettier for the presentation

% do image path string shenanigans
[name, folder] = uigetfile('C:\Users\user\Desktop\slike\projekat\images\*.png', 'select image');
path = strcat(folder, name);
try
    image = imread(path);
catch
    return
end
handles.image_not_eq = image;
handles.imagepath = path;
if ~isa(image, 'double')
    image = im2double(image);
end

%image eq-ing
if handles.eq_input_image.Value
    image = im_eq(image);
end
handles.image = image;
axes(handles.axes1), imshow(image);

%auto-crop
try
    crops = handles.crops;
    if crops.isKey(path)
        a = crops(path);
        y = [a(1), a(2)];
        x = [a(3), a(4)];
        handles.plate = crop_image(image, y, x);
        process_plate(handles);
    end
catch ex
    disp('nesto je puklo');
    disp(ex);
end

guidata(hObject, handles);

% --- Executes on button press in crop.
function crop_Callback(hObject, eventdata, handles)
% hObject    handle to crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% this function just takes two points from where user wants to crop
% then crops the image, if enabled, it will save the points
try
    [y, x] = ginput(2);
    
    if handles.save_crop.Value
        handles.crops(handles.imagepath) = [y x];
        crops = handles.crops;
        save('crops.mat', 'crops');
    end
    
    handles.plate = crop_image(handles.image, y, x);
    guidata(hObject, handles);
    axes(handles.axes2), imshow(handles.plate);
    % timesaving
    process_plate(handles);
    guidata(hObject, handles);
catch
    return
end


% --- Executes on button press in read_letters.
% button exists only to force manual doover
function read_letters_Callback(hObject, eventdata, handles)
% hObject    handle to read_letters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)plate = rgb2gray(plate);
process_plate(handles);
guidata(hObject, handles);


function process_plate(handles)
% this just calls all the functions and does the annoying math
% for turning the plate into text
axes(handles.axes2), imshow(handles.plate);
[boxes, binplate] = detect_letters(handles.plate, handles.dilate_plate.Value);
platetxt = zeros(1, length(boxes));
for i = 1:length(boxes)
    bbox = boxes{i};
    rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 2);
    start_row = ceil(bbox(2));
    end_row = floor(bbox(2)+bbox(4));
    start_col = ceil(bbox(1));
    end_col = floor(bbox(1)+bbox(3));
    letterimg = binplate(start_row:end_row, start_col:end_col);
    platetxt(i) = determine_character(letterimg, handles.template);
end
set(handles.result_box, 'String', char(platetxt));


% --- Executes on button press in eq_input_image.
function eq_input_image_Callback(hObject, eventdata, handles)
% hObject    handle to eq_input_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    if handles.eq_input_image.Value
        handles.image = im_eq(handles.image_not_eq);
    else
        handles.image = handles.image_not_eq;
    end
    axes(handles.axes1), imshow(handles.image);
    process_plate(handles);
    guidata(hObject, handles);
catch
    return
end

% --- Executes on button press in dilate_plate.
function dilate_plate_Callback(hObject, eventdata, handles)
% hObject    handle to dilate_plate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dilate_plate
process_plate(handles);


% --- Executes on button press in automatic_detection.
function automatic_detection_Callback(hObject, eventdata, handles)
% hObject    handle to automatic_detection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
