%{
----------------------------------------------------------------------------

This file is part of the Bpod Project
Copyright (C) 2014 Joshua I. Sanders, Cold Spring Harbor Laboratory, NY, USA

----------------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed  WITHOUT ANY WARRANTY and without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}


function ToneCloudsFixedTime
% This protocol implements the fixed time version of ToneClouds (developed by P. Znamenskiy) on Bpod
% Based on PsychoToolboxSound (written by J.Sanders)

% Training stages based on Jaramillo and Zador (2014)

% Written by F.Carnevale, 2/2015.
%
% SETUP
% You will need:
% - Ubuntu 14.XX with the -lowlatency package installed
% - ASUS Xonar DX 7-channel sound card installed
% - PsychToolbox installed
% - The Xonar DX comes with an RCA cable. Use an RCA to BNC adapter to
%    connect channel 3 to one of Bpod's BNC input channels for a record of the
%    exact time each sound played.

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
        
    S.GUI.Stage.panel = 'Training Stage'; S.GUI.Stage.style = 'popupmenu'; S.GUI.Stage.string = {'Direct', 'Full task'}; S.GUI.Stage.value = 1;% Training stage
    
    % Stimulus section
    S.GUI.UseMiddleOctave.panel = 'Stimulus settings'; S.GUI.UseMiddleOctave.style = 'popupmenu'; S.GUI.UseMiddleOctave.string = {'no', 'yes'}; S.GUI.UseMiddleOctave.value = 1;% Training stage
            
    S.GUI.ToneOverlap.panel = 'Stimulus settings'; S.GUI.ToneOverlap.style = 'edit'; S.GUI.ToneOverlap.string = 0.66; % Overlap between tones (0 to 1) 0 meaning no overlap
    S.GUI.ToneDuration.panel = 'Stimulus settings'; S.GUI.ToneDuration.style = 'edit'; S.GUI.ToneDuration.string = 0.03;
    S.GUI.NoEvidence.panel = 'Stimulus settings'; S.GUI.NoEvidence.style = 'edit'; S.GUI.NoEvidence.string = 0; % Number of tones with no evidence
    S.GUI.AudibleHuman.panel = 'Stimulus settings'; S.GUI.AudibleHuman.style = 'checkbox'; S.GUI.AudibleHuman.string = 'AudibleHuman'; S.GUI.AudibleHuman.value = 1;
    
    % Reward 
    S.GUI.CenterRewardAmount.panel = 'Reward settings'; S.GUI.CenterRewardAmount.style = 'edit'; S.GUI.CenterRewardAmount.string = 0.5;
    S.GUI.RewardAmount.panel = 'Reward settings'; S.GUI.RewardAmount.style = 'edit'; S.GUI.RewardAmount.string = 2.5;
    S.GUI.FreqSide.panel = 'Reward settings'; S.GUI.FreqSide.style = 'popupmenu'; S.GUI.FreqSide.string = {'LowLeft', 'LowRight'}; S.GUI.FreqSide.value = 1;% Training stage
    S.GUI.PunishSound.panel = 'Reward settings'; S.GUI.PunishSound.style = 'checkbox'; S.GUI.PunishSound.string = 'Active';  S.GUI.PunishSound.value = 1;
    
    % Trial structure section     
    S.GUI.TimeForResponse.panel = 'Trial Structure'; S.GUI.TimeForResponse.style = 'edit'; S.GUI.TimeForResponse.string = 10;
    S.GUI.TimeoutDuration.panel = 'Trial Structure'; S.GUI.TimeoutDuration.style = 'edit'; S.GUI.TimeoutDuration.string = 4;    
    
    S.GUI.PrestimDistribution.panel = 'Prestim Timing'; S.GUI.PrestimDistribution.style = 'popupmenu'; S.GUI.PrestimDistribution.string = {'Delta', 'Uniform', 'Exponential'}; S.GUI.PrestimDistribution.value = 1;% Training stage
    S.GUI.PrestimDurationStart.panel = 'Prestim Timing'; S.GUI.PrestimDurationStart.style = 'edit'; S.GUI.PrestimDurationStart.string = 0.050; % Prestim duration start
    S.GUI.PrestimDurationEnd.panel = 'Prestim Timing'; S.GUI.PrestimDurationEnd.style = 'edit'; S.GUI.PrestimDurationEnd.string = 0.300; % Prestim duration end
    S.GUI.PrestimDurationStep.panel = 'Prestim Timing'; S.GUI.PrestimDurationStep.style = 'edit'; S.GUI.PrestimDurationStep.string = 0.050; % Prestim duration end
    S.GUI.PrestimDurationCurrent.panel = 'Prestim Timing'; S.GUI.PrestimDurationCurrent.style = 'text'; S.GUI.PrestimDurationCurrent.string = S.GUI.PrestimDurationStart.string; % Prestim duration end    
    
    S.GUI.SoundDurationStart.panel = 'Stimulus Timing'; S.GUI.SoundDurationStart.style = 'edit'; S.GUI.SoundDurationStart.string = 0.050; % Sound duration start
    S.GUI.SoundDurationEnd.panel = 'Stimulus Timing'; S.GUI.SoundDurationEnd.style = 'edit'; S.GUI.SoundDurationEnd.string = 0.300; % Sound duration end
    S.GUI.SoundDurationStep.panel = 'Stimulus Timing'; S.GUI.SoundDurationStep.style = 'edit'; S.GUI.SoundDurationStep.string = 0.050; % Sound duration end
    S.GUI.SoundDurationCurrent.panel = 'Stimulus Timing'; S.GUI.SoundDurationCurrent.style = 'text'; S.GUI.SoundDurationCurrent.string = S.GUI.SoundDurationStart.string; % Sound duration end

    
    % Antibias
    S.GUI.Antibias.panel = 'Antibias'; S.GUI.Antibias.style = 'popupmenu'; S.GUI.Antibias.string = {'no', 'yes'}; S.GUI.Antibias.value = 1;% Training stage

    
    if S.GUI.AudibleHuman.value, minFreq = 200; maxFreq = 2000; else minFreq = 5000; maxFreq = 40000; end

    % Other Stimulus settings (not in the GUI)
    StimulusSettings.ToneOverlap = S.GUI.ToneOverlap.string;
    StimulusSettings.ToneDuration = S.GUI.ToneDuration.string;
    StimulusSettings.minFreq = minFreq;
    StimulusSettings.maxFreq = maxFreq;
    StimulusSettings.SamplingRate = 192000; % Sound card sampling rate;
    StimulusSettings.UseMiddleOctave = S.GUI.UseMiddleOctave.string(S.GUI.UseMiddleOctave.value);
    StimulusSettings.Noevidence = S.GUI.NoEvidence.string;   
    StimulusSettings.nFreq = 18; % Number of different frequencies to sample from
    StimulusSettings.ramp = 0.005;    
    
end

% Initialize parameter GUI plugin
EnhancedBpodParameterGUI('init', S);

%% Define trials
MaxTrials = 5000;
TrialTypes = ceil(rand(1,MaxTrials)*2); % correct side for each trial
EvidenceStrength = nan(1,MaxTrials); % evidence strength for each trial
PrestimDuration = nan(1,MaxTrials); % prestimulation delay period for each trial
SoundDuration = nan(1,MaxTrials); % sound duration period for each trial
Outcomes = nan(1,MaxTrials);
AccumulatedReward=0;

BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
BpodSystem.Data.EvidenceStrength = []; % The evidence strength of each trial completed will be added here.
BpodSystem.Data.PrestimDuration = []; % The evidence strength of each trial completed will be added here.

%% Initialize plots

% Outcome plot
BpodSystem.ProtocolFigures.OutcomePlotFig = figure('Position', [457 803 1000 163],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot = axes('Position', [.075 .3 .89 .6]);
OutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'init',2-TrialTypes);

% Notebook
BpodNotebook('init');

% Performance
%BpodSystem.ProtocolFigures.PerformancePlotFig = figure('Position', [455 595 1000 163],'name','Performance plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.ProtocolFigures.PerformancePlotFig = figure('Position', [455 595 1000 250],'name','Performance plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.PerformancePlot = axes('Position', [.075 .3 .89 .6]);
PerformancePlot(BpodSystem.GUIHandles.PerformancePlot,'init')  %set up axes nicely

% Psychometric
BpodSystem.ProtocolFigures.PsychoPlotFig = figure('Position', [1450 100 400 300],'name','Pshycometric plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.PsychoPlot = axes('Position', [.075 .3 .89 .6]);
PsychoPlot(BpodSystem.GUIHandles.PsychoPlot,'init')  %set up axes nicely


state_colors = struct( ...
        'WaitForCenterPoke', [0.5 0.5 1],...
        'Delay',[1,0,0],...
        'DeliverStimulus', 0.75*[1 1 0],...
        'GoSignal',[0.5 1 1],...        
        'Reward',[0,1,0],...
        'Drinking',[1,0,0],...
        'Punish',[1,0,0],...
        'EarlyWithdrawalPunish',[1,0,0],...
        'WaitForResponse',[1,0,0],...
        'CorrectWithdrawalEvent',[1,0,0],...
        'exit',0.5*[1 1 1]);
    
poke_colors = struct( ...
      'L', 0.6*[1 0.66 0], ...
      'C', [0 0 0], ...
      'R',  0.9*[1 0.66 0]);
    
PokesPlot('init', state_colors,poke_colors);

%% Repositionate GUI's
BpodSystem.GUIHandles.MainFig.Position = [389 92 BpodSystem.GUIHandles.MainFig.Position(3:4)];
BpodSystem.ProtocolFigures.Notebook.Position = [229 -1.5 BpodSystem.ProtocolFigures.Notebook.Position(3:4)];
BpodSystem.ProtocolFigures.BpodParameterGUI.Position = [66 1 BpodSystem.ProtocolFigures.BpodParameterGUI.Position(3:4)];
BpodSystem.ProtocolFigures.PerformancePlotFig.Position = [705 533 BpodSystem.ProtocolFigures.PerformancePlotFig.Position(3:4)];
BpodSystem.ProtocolFigures.OutcomePlotFig.Position = [705 832 BpodSystem.ProtocolFigures.OutcomePlotFig.Position(3:4)];
BpodSystem.ProtocolFigures.PsychoPlotFig.Position = [1196 193 BpodSystem.ProtocolFigures.PsychoPlotFig.Position(3:4)];


%% Define stimuli and send to sound server

SF = StimulusSettings.SamplingRate;
PunishSound = (rand(1,SF*.5)*2) - 1;
% Generate early withdrawal sound
W1 = GenerateSineWave(SF, 1000, .5); W2 = GenerateSineWave(SF, 1200, .5); EarlyWithdrawalSound = W1+W2;
P = SF/100; Interval = P;
for x = 1:50
    EarlyWithdrawalSound(P:P+Interval) = 0;
    P = P+(Interval*2);
end

% Program sound server
PsychToolboxSoundServer('init')
PsychToolboxSoundServer('Load', 3, PunishSound);
PsychToolboxSoundServer('Load', 4, EarlyWithdrawalSound);

% Set soft code handler to trigger sounds
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';

BpodSystem.ProtocolFigures.InitialMsg = msgbox({'', ' Edit your settings and click OK when you are ready to start!     ', ''},'ToneCloud Protocol...');
uiwait(BpodSystem.ProtocolFigures.InitialMsg);

CenterValveCode = 2;

% control the step up of prestimulus period and stimulus duration
controlStep_Prestim = 0; % valid trial counter
controlStep_nRequiredValid_Prestim = 10; % Number of required valid trials before next step
controlStep_Sound = 0; % valid trial counter
controlStep_nRequiredValid_Sound = 10; % Number of required valid trials before next step

%% Main trial loop
for currentTrial = 1:MaxTrials
    
    S = EnhancedBpodParameterGUI('sync', S); % Sync parameters with EnhancedBpodParameterGUI plugin
    
    if S.GUI.AudibleHuman.value, minFreq = 200; maxFreq = 2000; else minFreq = 5000; maxFreq = 40000; end
    
    %Prestimulation Duration
    if S.GUI.SoundDurationCurrent.string >= S.GUI.SoundDurationEnd.string % step up prestim only if stimulus is already at end duration
        
        if controlStep_Prestim > controlStep_nRequiredValid_Prestim

            controlStep_Prestim = 0; %restart counter

            % step up, unless we are at the max
            if S.GUI.PrestimDurationCurrent.string + S.GUI.PrestimDurationStep.string > S.GUI.PrestimDurationEnd.string
                S.GUI.PrestimDurationCurrent.string = S.GUI.PrestimDurationEnd.string;
            else
                S.GUI.PrestimDurationCurrent.string = S.GUI.PrestimDurationCurrent.string + S.GUI.PrestimDurationStep.string;
            end
        end
    end
    
    switch S.GUI.PrestimDistribution.value
        case 1
            PrestimDuration(currentTrial) = S.GUI.PrestimDurationCurrent.string;
        case 2'
            PrestimDuration(currentTrial) = rand+S.GUI.PrestimDurationCurrent.string-0.5;
        case 3
            PrestimDuration(currentTrial) = exprnd(S.GUI.PrestimDurationCurrent.string);
    end
        
    %Sound Duration
    if controlStep_Sound > controlStep_nRequiredValid_Sound
        
        controlStep_Sound = 0; %restart counter
        
        % step up, unless we are at the max
        if S.GUI.SoundDurationCurrent.string + S.GUI.SoundDurationStep.string > S.GUI.SoundDurationEnd.string
            S.GUI.SoundDurationCurrent.string = S.GUI.SoundDurationEnd.string;
        else
            S.GUI.SoundDurationCurrent.string = S.GUI.SoundDurationCurrent.string + S.GUI.SoundDurationStep.string;
        end
    end
        
    SoundDuration(currentTrial) = S.GUI.SoundDurationCurrent.string;

    R = GetValveTimes(S.GUI.RewardAmount.string, [1 3]); LeftValveTime = R(1); RightValveTime = R(2); % Update reward amounts
    C = GetValveTimes(S.GUI.CenterRewardAmount.string, 2); CenterValveTime = C(1);

    
    % Update stimulus settings
    StimulusSettings.nTones = floor((S.GUI.SoundDurationCurrent.string-S.GUI.ToneDuration.string*S.GUI.ToneOverlap.string)/(S.GUI.ToneDuration.string*(1-S.GUI.ToneOverlap.string)));
    StimulusSettings.ToneOverlap = S.GUI.ToneOverlap.string;
    StimulusSettings.ToneDuration = S.GUI.ToneDuration.string;
    StimulusSettings.minFreq = minFreq;
    StimulusSettings.maxFreq = maxFreq;
    StimulusSettings.UseMiddleOctave = S.GUI.UseMiddleOctave.string(S.GUI.UseMiddleOctave.value);
    StimulusSettings.Noevidence = S.GUI.NoEvidence.string;   
    
    if S.GUI.Antibias.value==2 %apply antibias
        if Outcomes(currentTrial-1)==0
            TrialTypes(currentTrial)=TrialTypes(currentTrial-1);
        end
    end
    
    switch TrialTypes(currentTrial) % Determine trial-specific state matrix fields
        
        case 1 % Left is rewarded
            
            if strcmp(S.GUI.FreqSide.string(S.GUI.FreqSide.value),'LowLeft')                
                TargetOctave = 'low';
            else
                TargetOctave = 'high';
            end
            
            LeftActionState = 'Reward'; RightActionState = 'Punish'; CorrectWithdrawalEvent = 'Port1Out';
            ValveCode = 1; ValveTime = LeftValveTime;
            RewardedPort = {'Port1In'};PunishedPort = {'Port3In'};
            
        case 2 % Right is rewarded
            
            if strcmp(S.GUI.FreqSide.string(S.GUI.FreqSide.value),'LowRight')                
                TargetOctave = 'low';
            else
                TargetOctave = 'high';
            end
            
            LeftActionState = 'Punish'; RightActionState = 'Reward'; CorrectWithdrawalEvent = 'Port3Out';
            ValveCode = 4; ValveTime = RightValveTime;
            RewardedPort = {'Port3In'}; PunishedPort = {'Port1In'};
    end
    
    
    if S.GUI.PunishSound.value
        PsychToolboxSoundServer('Load', 4, EarlyWithdrawalSound);
    else
        PsychToolboxSoundServer('Load', 4, 0);
    end
    
    switch S.GUI.Stage.value
        
        case 1 % Training stage 1: Direct sides - Poke and collect water

            EvidenceStrength(currentTrial) = 1;
            
            % This stage sound generation
            [Sound, Cloud] = GenerateToneCloud(TargetOctave, EvidenceStrength(currentTrial), StimulusSettings);
            PsychToolboxSoundServer('Load', 1, Sound);
            
            
            sma = NewStateMatrix(); % Assemble state matrix
            
            sma = AddState(sma, 'Name', 'WaitForCenterPoke', ...
                'Timer', 0,...
                'StateChangeConditions', {'Port2In', 'Delay'},...
                'OutputActions', {});
            sma = AddState(sma, 'Name', 'Delay', ...
                'Timer', PrestimDuration(currentTrial),...
                'StateChangeConditions', {'Tup', 'DeliverStimulus'},...
                'OutputActions', {});
            sma = AddState(sma, 'Name', 'DeliverStimulus', ...
                'Timer', SoundDuration(currentTrial),...
                'StateChangeConditions', {'Tup', 'GoSignal'},...
                'OutputActions', {'SoftCode', 1, 'BNCState', 1});
            sma = AddState(sma, 'Name', 'GoSignal', ...
                'Timer', CenterValveTime,...
                'StateChangeConditions', {'Tup', 'Reward'},...
                'OutputActions', {'ValveState', CenterValveCode});
            sma = AddState(sma, 'Name', 'Reward', ...
                'Timer', ValveTime,...
                'StateChangeConditions', {'Tup', 'Drinking'},...
                'OutputActions', {'ValveState', ValveCode});
            sma = AddState(sma, 'Name', 'Drinking', ...
                'Timer', 0.01,...
                'StateChangeConditions', {'Tup', 'exit'},...
                'OutputActions', {});
            
            SendStateMatrix(sma);
            RawEvents = RunStateMatrix;     
            
        case 2 %
            
            EvidenceStrength(currentTrial) = 1;
            
            % This stage sound generation
            [Sound, Cloud] = GenerateToneCloud(TargetOctave, EvidenceStrength(currentTrial), StimulusSettings);
            PsychToolboxSoundServer('Load', 1, Sound);
            
            
            sma = NewStateMatrix(); % Assemble state matrix
            
            sma = AddState(sma, 'Name', 'WaitForCenterPoke', ...
                'Timer', 0,...
                'StateChangeConditions', {'Port2In', 'Delay'},...
                'OutputActions', {});
            sma = AddState(sma, 'Name', 'Delay', ...
                'Timer', PrestimDuration(currentTrial),...
                'StateChangeConditions', {'Tup', 'DeliverStimulus', 'Port2Out', 'EarlyWithdrawal'},...
                'OutputActions', {});
            sma = AddState(sma, 'Name', 'DeliverStimulus', ...
                'Timer', SoundDuration(currentTrial),...
                'StateChangeConditions', {'Tup', 'GoSignal', 'Port2Out', 'EarlyWithdrawal'},...
                'OutputActions', {'SoftCode', 1, 'BNCState', 1});
            sma = AddState(sma, 'Name', 'GoSignal', ...
                'Timer', CenterValveTime,...
                'StateChangeConditions', {'Tup', 'WaitForResponse'},...
                'OutputActions', {'ValveState', CenterValveCode});
            sma = AddState(sma, 'Name', 'EarlyWithdrawal', ...
                'Timer', 0,...
                'StateChangeConditions', {'Tup', 'EarlyWithdrawalPunish'},...
                'OutputActions', {'SoftCode', 255});
            sma = AddState(sma, 'Name', 'WaitForResponse', ...
                'Timer', S.GUI.TimeForResponse.string,...
                'StateChangeConditions', {'Tup', 'exit', 'Port1In', LeftActionState, 'Port3In', RightActionState},...
                'OutputActions', {});
            sma = AddState(sma, 'Name', 'Reward', ...
                'Timer', ValveTime,...
                'StateChangeConditions', {'Tup', 'Drinking'},...
                'OutputActions', {'ValveState', ValveCode});
            sma = AddState(sma, 'Name', 'Drinking', ...
                'Timer', 0,...
                'StateChangeConditions', {CorrectWithdrawalEvent, 'exit'},...
                'OutputActions', {});
            sma = AddState(sma, 'Name', 'Punish', ...
                'Timer', S.GUI.TimeoutDuration.string,...
                'StateChangeConditions', {'Tup', 'exit'},...
                'OutputActions', {'SoftCode', 4});
            sma = AddState(sma, 'Name', 'EarlyWithdrawalPunish', ...
                'Timer', S.GUI.TimeoutDuration.string,...
                'StateChangeConditions', {'Tup', 'exit'},...
                'OutputActions', {});
            
            SendStateMatrix(sma);
            RawEvents = RunStateMatrix;     
    
    end
    
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes(currentTrial); % Adds the trial type of the current trial to data
        BpodSystem.Data.EvidenceStrength(currentTrial) = EvidenceStrength(currentTrial); % Adds the evidence strength of the current trial to data
        BpodSystem.Data.PrestimDuration(currentTrial) = PrestimDuration(currentTrial); % Adds the evidence strength of the current trial to data
        BpodSystem.Data.SoundDuration(currentTrial) = SoundDuration(currentTrial); % Adds the evidence strength of the current trial to data
        BpodSystem.Data.StimulusSettings = StimulusSettings; % Save Stimulus settings
        BpodSystem.Data.Cloud{currentTrial} = Cloud; % Saves Stimulus 
        BpodSystem.Data.Outcomes(currentTrial) = Outcomes(currentTrial);
        
        %Outcome
        if ~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.Reward(1))
            Outcomes(currentTrial) = 1;
            AccumulatedReward = AccumulatedReward+S.GUI.RewardAmount.string;
            controlStep_Prestim = controlStep_Prestim+1; % update because this is a valid trial
            controlStep_Sound = controlStep_Sound+1; % update because this is a valid trial
        elseif ~isnan(BpodSystem.Data.RawEvents.Trial{currentTrial}.States.Punish(1))
            Outcomes(currentTrial) = 0;
            controlStep_Prestim = controlStep_Prestim+1; % update because this is a valid trial
            controlStep_Sound = controlStep_Sound+1; % update because this is a valid trial
        else
            Outcomes(currentTrial) = -1;
        end
        
        BpodSystem.Data.AccumulatedReward = AccumulatedReward;
        
        
        UpdateOutcomePlot(TrialTypes, Outcomes);
        UpdatePerformancePlot(TrialTypes, Outcomes);
        UpdatePsychoPlot(TrialTypes, Outcomes);
        
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    if BpodSystem.BeingUsed == 0
        return
    end
end

function UpdateOutcomePlot(TrialTypes, Outcomes)
global BpodSystem
EvidenceStrength = BpodSystem.Data.EvidenceStrength;
nTrials = BpodSystem.Data.nTrials;
OutcomePlot(BpodSystem.GUIHandles.OutcomePlot,'update',nTrials+1,2-TrialTypes,Outcomes,EvidenceStrength);

function UpdatePerformancePlot(TrialTypes, Outcomes)
global BpodSystem
nTrials = BpodSystem.Data.nTrials;
PerformancePlot(BpodSystem.GUIHandles.PerformancePlot,'update',nTrials,2-TrialTypes,Outcomes);

function UpdatePsychoPlot(TrialTypes, Outcomes)
global BpodSystem
EvidenceStrength = BpodSystem.Data.EvidenceStrength;
nTrials = BpodSystem.Data.nTrials;
PsychoPlot(BpodSystem.GUIHandles.PsychoPlot,'update',nTrials,2-TrialTypes,Outcomes,EvidenceStrength);