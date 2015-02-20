%  Initialize NI DAQ card
%
% Santiago Jaramillo - 2007.11.10
% F. Carnevale 2015.19.02
% Based on CalibrationSpeakers/CalibrateForTuningCurve.m

% Input channel for recording
function out = initdaq

hwinfo = daqhwinfo('nidaq');
AnalogInputObj = analoginput('nidaq',hwinfo.InstalledBoardIds{1});
set(AnalogInputObj,'InputType','SingleEnded');
inchan = addchannel(AnalogInputObj,0);

% Set some general parameters.
% Target sample rate is card's maximum.
cardinfo=daqhwinfo( AnalogInputObj );
set(AnalogInputObj,'SampleRate', cardinfo.MaxSampleRate );
AnalogInputObj.Channel.InputRange=[-10 10];
AnalogInputObj.Channel.SensorRange=[-10 10];
AnalogInputObj.Channel.UnitsRange=[-10 10];

set(AnalogInputObj,'LoggingMode','Memory');
set(AnalogInputObj,'SamplesPerTrigger',inf);

set(AnalogInputObj,'TriggerType','Immediate');   % trigger without using dio lines

out = 1; % INCLUDE ERROR HANDLING

return
