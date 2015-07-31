
function SoundCalibration
% This protocol is used to calibrate sound
% Written by F.Carnevale, 7/2015.

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with settings default
    
    S.GUI.SoundFreq.panel = 'Current Trial'; S.GUI.SoundFreq.style = 'text'; S.GUI.SoundFreq.string = 0; % Sound Volume
    S.GUI.TrialNumber.panel = 'Current Trial'; S.GUI.TrialNumber.style = 'text'; S.GUI.TrialNumber.string = 0; % Number of current trial
    
    S.GUI.SoundType.panel = 'Calibration Parameters'; S.GUI.SoundType.style = 'popupmenu'; S.GUI.SoundType.string = {'Tone','Noise'}; S.GUI.SoundType.value = 1;
    S.GUI.TargetSPL.panel = 'Calibration Parameters'; S.GUI.TargetSPL.style = 'edit'; S.GUI.TargetSPL.string = 60; 
    S.GUI.MaxFreq.panel = 'Calibration Parameters'; S.GUI.MaxFreq.style = 'edit'; S.GUI.MaxFreq.string = 2000;
    S.GUI.MinFreq.panel = 'Calibration Parameters'; S.GUI.MinFreq.style = 'edit'; S.GUI.MinFreq.string = 200;
    S.GUI.SoundDuration.panel = 'Calibration Parameters'; S.GUI.SoundDuration.style = 'edit'; S.GUI.SoundDuration.string = 1; % Sound Duration
    S.GUI.nFreq.panel = 'Calibration Parameters'; S.GUI.nFreq.style = 'edit'; S.GUI.nFreq.string = 20; % Number of frequencies        
    S.GUI.MinBandLimit.panel = 'Calibration Parameters'; S.GUI.MinBandLimit.style = 'edit'; S.GUI.MinBandLimit.string = 0.3;
    S.GUI.MaxBandLimit.panel = 'Calibration Parameters'; S.GUI.MaxBandLimit.style = 'edit'; S.GUI.MaxBandLimit.string = 0.5;    
end

% Initialize parameter GUI plugin
EnhancedBpodParameterGUI('init', S);

%% Define trials

FrequencyVector = logspace(log10(S.GUI.LowFreq.string),log10(S.GUI.HighFreq.string),S.GUI.nFreq.string);
BandLimits = [S.GUI.MinBandLimit.string S.GUI.MaxBandLimit.string];
maxIterations=8;

MaxTrials = size(FrequencyVector,2)*maxIterations;

BpodSystem.Data.TrialFreq = []; % The trial frequency of each trial completed will be added here.

% Notebook
BpodNotebook('init');

% Program sound server
PsychToolboxSoundServer('init')

% Set soft code handler to trigger sounds
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

BpodSystem.ProtocolFigures.InitialMsg = msgbox({'', ' Edit your settings and click OK when you are ready to start!     ', ''},'Tuning Curves Protocol...');
uiwait(BpodSystem.ProtocolFigures.InitialMsg);

%% Main trial loop
for currentTrial = 1:MaxTrials
    
    S = EnhancedBpodParameterGUI('sync', S); % Sync parameters with EnhancedBpodParameterGUI plugin
    
    % Update stimulus settings    
    StimulusSettings.SoundVolume = S.GUI.SoundVolume.string;
    StimulusSettings.SoundDuration = S.GUI.SoundDuration.string;
    StimulusSettings.Freq = TrialFreq(currentTrial);
    StimulusSettings.Ramp = 0.005;
    
    PreSound = 1;
    
    % This stage sound generation
    Sound = GenerateSound(StimulusSettings);
    PsychToolboxSoundServer('Load', 1, Sound);
    
    sma = NewStateMatrix(); % Assemble state matrix
    
    sma = AddState(sma, 'Name', 'PreSound', ...
        'Timer', PreSound,...
        'StateChangeConditions', {'Tup', 'DeliverStimulus'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'DeliverStimulus', ...
        'Timer', 0.1,...
        'StateChangeConditions', {'Tup', 'Record'},...
        'OutputActions', {'SoftCode', 1});
    sma = AddState(sma, 'Name', 'Record', ...
        'Timer', SoundDuration(currentTrial),...
        'StateChangeConditions', {'Tup', 'InterTrial'},...
        'OutputActions', {'SoftCode', 2});
    sma = AddState(sma, 'Name', 'InterTrial', ...
        'Timer', InterTrial(currentTrial),...
        'StateChangeConditions', {'SoftCode', 255},...
        'OutputActions', {});
    
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialFreq(currentTrial) = TrialFreq(currentTrial);
        BpodSystem.Data.PrestimDuration(currentTrial) = ToneOffset(currentTrial);
        BpodSystem.Data.SoundDuration(currentTrial) = SoundDuration(currentTrial);
        BpodSystem.Data.InterTrial(currentTrial) = InterTrial(currentTrial);
        BpodSystem.Data.PreSound(currentTrial) = PreSound(currentTrial);
        BpodSystem.Data.StimulusSettings = StimulusSettings; % Save Stimulus settings
        
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
        
        if currentTrial<MaxTrials
            
            PossibleFreqs = logspace(log10(S.GUI.LowFreq.string),log10(S.GUI.HighFreq.string),S.GUI.nFreq.string);
            TrialFreq(currentTrial+1:end) = PossibleFreqs(randi(size(PossibleFreqs,2),1,MaxTrials-currentTrial));
            
            % display next trial info
            S.GUI.SoundFreq.string = round(TrialFreq(currentTrial+1)); % Sound Volume
            S.GUI.TrialNumber.string = currentTrial+1; % Number of current trial
            S.GUI.TotalTrials.string = MaxTrials; % Total number of trials
        end
        
    end
    
    if BpodSystem.BeingUsed == 0
        return
    end
    
end
