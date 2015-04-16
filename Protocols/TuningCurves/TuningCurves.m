
function TuningCurves
% This protocol is used to estimate tuning curves in auditory areas
% Written by F.Carnevale, 4/2015.

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with settings default
    
    S.GUI.SoundType.panel = 'Sound Settings'; S.GUI.SoundType.style = 'popupmenu'; S.GUI.SoundType.string = {'Tone', 'Chord','FM','Noise','FastBips'}; S.GUI.SoundType.value = 1;
    S.GUI.LowFreq.panel = 'Sound Settings'; S.GUI.LowFreq.style = 'edit'; S.GUI.LowFreq.string = 200; % Lowest frequency
    S.GUI.HighFreq.panel = 'Sound Settings'; S.GUI.HighFreq.style = 'edit'; S.GUI.HighFreq.string = 1000; % Highest frequency
    S.GUI.nFreq.panel = 'Sound Settings'; S.GUI.nFreq.style = 'edit'; S.GUI.nFreq.string = 20; % Number of frequencies    
    S.GUI.Ramp.panel = 'Sound Settings'; S.GUI.Ramp.style = 'edit'; S.GUI.Ramp.string = 0.005;
    S.GUI.SoundVolume.panel = 'Sound Settings'; S.GUI.SoundVolume.style = 'edit'; S.GUI.SoundVolume.string = 70; % Sound Volume

    S.GUI.InterTrial.panel = 'Timing Settings'; S.GUI.InterTrial.style = 'edit'; S.GUI.InterTrial.string = 1; % Intertrial Interval
    S.GUI.PreSound.panel = 'Timing Settings'; S.GUI.PreSound.style = 'edit'; S.GUI.PreSound.string = 1; % PreSound Interval
    S.GUI.ToneOffset.panel = 'Timing Settings'; S.GUI.ToneOffset.style = 'edit'; S.GUI.ToneOffset.string = 0.2; % Tone offset
    S.GUI.SoundDuration.panel = 'Timing Settings'; S.GUI.SoundDuration.style = 'edit'; S.GUI.SoundDuration.string = 1; % Sound Duration
    S.GUI.nSounds.panel = 'Timing Settings'; S.GUI.nSounds.style = 'edit'; S.GUI.nSounds.string = 10;
    
    S.GUI.SoundFreq.panel = 'Current Trial'; S.GUI.SoundFreq.style = 'text'; S.GUI.SoundFreq.string = 0; % Sound Volume
    S.GUI.TrialNumber.panel = 'Current Trial'; S.GUI.TrialNumber.style = 'text'; S.GUI.TrialNumber.string = 0; % Number of current trial
    S.GUI.TotalTrials.panel = 'Current Trial'; S.GUI.TotalTrials.style = 'text'; S.GUI.TotalTrials.string = 0; % Total number of trials
    
    % Other Stimulus settings (not in the GUI)
    StimulusSettings.SamplingRate = 192000; % Sound card sampling rate;
    
end

% Initialize parameter GUI plugin
EnhancedBpodParameterGUI('init', S);

%% Define trials

%PossibleFreqs = logspace(S.GUI.LowFreq.string,S.GUI.HighFreq.string,S.GUI.nFreq.string);
PossibleFreqs = logspace(log10(S.GUI.LowFreq.string),log10(S.GUI.HighFreq.string),S.GUI.nFreq.string);

MaxTrials = size(PossibleFreqs,2)*S.GUI.nSounds.string;

TrialFreq = PossibleFreqs(randi(size(PossibleFreqs,2),1,MaxTrials));
ToneOffset = nan(1,MaxTrials); % ToneOffset for each trial
PreSound = nan(1,MaxTrials); % PreSound interval for each trial
InterTrial = nan(1,MaxTrials); % Intertrial interval for each trial
SoundDuration = nan(1,MaxTrials); % Sound duration for each trial


BpodSystem.Data.TrialFreq = []; % The trial frequency of each trial completed will be added here.

% Notebook
BpodNotebook('init');

% Program sound server
PsychToolboxSoundServer('init')

% Set soft code handler to trigger sounds
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

BpodSystem.ProtocolFigures.InitialMsg = msgbox({'', ' Edit your settings and click OK when you are ready to start!     ', ''},'Tuning Curves Protocol...');
uiwait(BpodSystem.ProtocolFigures.InitialMsg);


S.GUI.SoundFreq.string = round(TrialFreq(1)); % Sound Volume
S.GUI.TrialNumber.string = 1; % Number of current trial
S.GUI.TotalTrials.string = MaxTrials; % Total number of trials

%% Main trial loop
for currentTrial = 1:MaxTrials
    
    S = EnhancedBpodParameterGUI('sync', S); % Sync parameters with EnhancedBpodParameterGUI plugin
    
    ToneOffset(currentTrial) = S.GUI.ToneOffset.string;
    InterTrial(currentTrial) = S.GUI.InterTrial.string;
    PreSound(currentTrial) = S.GUI.PreSound.string;
    SoundDuration(currentTrial) = S.GUI.SoundDuration.string;

    % Update stimulus settings    
    StimulusSettings.SoundVolume = S.GUI.SoundVolume.string;
    StimulusSettings.SoundDuration = S.GUI.SoundDuration.string;
    StimulusSettings.Freq = TrialFreq(currentTrial);
    StimulusSettings.Ramp = S.GUI.Ramp.string;
    
    % This stage sound generation
    Sound = GenerateSound(StimulusSettings);
    PsychToolboxSoundServer('Load', 1, Sound);
    
    sma = NewStateMatrix(); % Assemble state matrix
    
    sma = AddState(sma, 'Name', 'PreSound', ...
        'Timer', PreSound(currentTrial),...
        'StateChangeConditions', {'Tup', 'TrigStart'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'TrigStart', ...
        'Timer', 0.01,...
        'StateChangeConditions', {'Tup', 'ToneOffset'},...
        'OutputActions', {}); %DOUT
    sma = AddState(sma, 'Name', 'ToneOffset', ...
        'Timer', ToneOffset(currentTrial),...
        'StateChangeConditions', {'Tup', 'DeliverStimulus'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'DeliverStimulus', ...
        'Timer', SoundDuration(currentTrial),...
        'StateChangeConditions', {'Tup', 'InterTrial'},...
        'OutputActions', {'SoftCode', 1, 'BNCState', 1});
    sma = AddState(sma, 'Name', 'InterTrial', ...
        'Timer', InterTrial(currentTrial),...
        'StateChangeConditions', {'Tup', 'exit'},...
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
