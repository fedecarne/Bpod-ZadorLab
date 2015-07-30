function varargout = SoundCalibrationManager(varargin)
% SOUNDCALIBRATIONMANAGER MATLAB code for SoundCalibrationManager.fig
%      SOUNDCALIBRATIONMANAGER, by itself, creates a new SOUNDCALIBRATIONMANAGER or raises the existing
%      singleton*.
%
%      H = SOUNDCALIBRATIONMANAGER returns the handle to a new SOUNDCALIBRATIONMANAGER or the handle to
%      the existing singleton*.
%
%      SOUNDCALIBRATIONMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOUNDCALIBRATIONMANAGER.M with the given input arguments.
%
%      SOUNDCALIBRATIONMANAGER('Property','Value',...) creates a new SOUNDCALIBRATIONMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SoundCalibrationManager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SoundCalibrationManager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SoundCalibrationManager

% Last Modified by GUIDE v2.5 19-Feb-2015 14:09:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SoundCalibrationManager_OpeningFcn, ...
                   'gui_OutputFcn',  @SoundCalibrationManager_OutputFcn, ...
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


% --- Executes just before SoundCalibrationManager is made visible.
function SoundCalibrationManager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SoundCalibrationManager (see VARARGIN)

% Choose default command line output for SoundCalibrationManager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SoundCalibrationManager wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SoundCalibrationManager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in SoundType.
function SoundType_Callback(hObject, eventdata, handles)
% hObject    handle to SoundType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SoundType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SoundType


% --- Executes during object creation, after setting all properties.
function SoundType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SoundType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TargetSPL_Callback(hObject, eventdata, handles)
% hObject    handle to TargetSPL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetSPL as text
%        str2double(get(hObject,'String')) returns contents of TargetSPL as a double


% --- Executes during object creation, after setting all properties.
function TargetSPL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TargetSPL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinBandLimit_Callback(hObject, eventdata, handles)
% hObject    handle to MinBandLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinBandLimit as text
%        str2double(get(hObject,'String')) returns contents of MinBandLimit as a double


% --- Executes during object creation, after setting all properties.
function MinBandLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinBandLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxBandLimit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxBandLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxBandLimit as text
%        str2double(get(hObject,'String')) returns contents of MaxBandLimit as a double


% --- Executes during object creation, after setting all properties.
function MaxBandLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxBandLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calibrate.
function calibrate_Callback(hObject, eventdata, handles)
% hObject    handle to calibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Initialize Sound Server ---

%Get Calibration Parameters

TargetSPL = str2double(handles.TargetSPL.String);
SoundType = handles.SoundType.String(handles.SoundType.Value);
MinFreq = str2double(handles.MinFreq.String);
MaxFreq = str2double(handles.MaxFreq.String);
nFreq = str2double(handles.nFreq.String);
nSpeakers = str2double(handles.nSpeakers.String);

MinBandLimit = str2double(handles.MinBandLimit.String);
MaxBandLimit = str2double(handles.MinBandLimit.String);

FrequencyVector =  logspace(log10(MinFreq),log10(MaxFreq),nFreq);
BandLimits = [MinBandLimit MaxBandLimit];

PsychToolboxSoundServer('init')

% --- Setup NI-card ---
usbdux_daq('init');

%OPEN DIALOG BOX WHERE TO SAVE FILE
OutputFileName = '/home/cnmc/Bpod_r0_5-master/Calibration Files/SoundCalibration';
[FileName,PathName] = uiputfile('.mat','Save Sound Calibration File',OutputFileName);

AttenuationVector = zeros(nFreq,nSpeakers,1);

wbar_handle = waitbar(0,'1','Name','Sound Calibration');

for inds=1:nSpeakers            % --   Loop through speakers  --
    
    % OPEN DIALOG BOX SHOWING PROGRESS
    
    uiwait(msgbox({[' Calibrating speaker ' num2str(inds) '.'],[' Position microphone and press OK to continue...']},'Sound Calibration','modal'));
        
    tic
    
    Sound.Type = SoundType;
    Sound.Speaker = inds;
    
    if ~strcmp(SoundType,'Noise')
        
        for indf=1:nFreq            % -- Loop through frequencies --
            
            waitbar((1/nFreq)*(indf-1)+(1/nSpeakers)*(inds-1),wbar_handle,{'',['Calibrating speaker ' num2str(inds)],['Frequency: ' num2str(FrequencyVector(indf),'%5.2f') 'Hz (' num2str(indf) '/' num2str(nFreq) ')' ],''})
            
            Sound.Frequency = FrequencyVector(indf);
            BandLimits = Sound.Frequency * BandLimits;
            
            FAILURE=true;
            while FAILURE
                try
                    AttenuationVector(indf, inds, indType) = find_amplitude(Sound,TargetSPL,BandLimits);
                    FAILURE=false;
                catch ME
                    FAILURE=true;
                    disp('***** There was an error. This step will be repeated. *****');
                end
            end
        end
    else
        
        
        Sound.Frequency = 0;
        BandLimits = [min(FrequencyVector) max(FrequencyVector)];
        
        FAILURE=true;
        while FAILURE
            try
                NoiseAmplitude(inds) = find_amplitude(Sound,TargetSPL,SoundMachine,AnalogInputObj,BandLimits);
                FAILURE=false;
            catch ME
                FAILURE=true;
                disp('***** There was an error. This step will be repeated. *****');
            end
        end
    end
    toc
end

% Close psychotoolbox??

% -- Saving results --
save(fullfile(PathName,FileName),'FrequencyVector','AttenuationVector','TargetSPL','SoundParam','SoundTypeIndex','NoiseAmplitude');

%msgbox({'The Sound Calibration file has been saved in: ', fullfile(PathName,FileName)});

plotResults = questdlg({'The Sound Calibration file has been saved in: ', fullfile(PathName,FileName)},'Sound Calibration', 'Ok', 'Plot Results','Ok');

if strcmp(plotResults,'Plot Results')
    
    % -- Plot power at each frequency presented --
    figure;
    hp = semilogx(FrequencyVector,10*log10(AttenuationVector(:,:,1)),'o-');
    %set(hp(ind),'Color',PlotColors{ind});
    grid on;
    %ylim([35,95])
    ylabel('Attenuation (dB)');
    
end


% --- Executes on button press in Close.
function Close_Callback(hObject, eventdata, handles)
% hObject    handle to Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function MaxFreq_Callback(hObject, eventdata, handles)
% hObject    handle to MaxFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxFreq as text
%        str2double(get(hObject,'String')) returns contents of MaxFreq as a double


% --- Executes during object creation, after setting all properties.
function MaxFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinFreq_Callback(hObject, eventdata, handles)
% hObject    handle to MinFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinFreq as text
%        str2double(get(hObject,'String')) returns contents of MinFreq as a double


% --- Executes during object creation, after setting all properties.
function MinFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nFreq_Callback(hObject, eventdata, handles)
% hObject    handle to nFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nFreq as text
%        str2double(get(hObject,'String')) returns contents of nFreq as a double


% --- Executes during object creation, after setting all properties.
function nFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nSpeakers_Callback(hObject, eventdata, handles)
% hObject    handle to nSpeakers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nSpeakers as text
%        str2double(get(hObject,'String')) returns contents of nSpeakers as a double


% --- Executes during object creation, after setting all properties.
function nSpeakers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nSpeakers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to MaxBandLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxBandLimit as text
%        str2double(get(hObject,'String')) returns contents of MaxBandLimit as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxBandLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to MinBandLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinBandLimit as text
%        str2double(get(hObject,'String')) returns contents of MinBandLimit as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinBandLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
