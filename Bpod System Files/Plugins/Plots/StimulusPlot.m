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
% function OutcomePlot(AxesHandle,TrialTypeSides, OutcomeRecord, CurrentTrial)
function StimulusPlot(AxesHandle, Action, varargin)
%% 
% Plug in to Plot Stimulus
% AxesHandle = handle of axes to plot on
% Action = specific action for plot, "init" - initialize OR "update" -  update plot

%Example usage:
% StimulusPlot(AxesHandle,'init',Stimulus)

% Fede

%% Code Starts Here
global BpodSystem

switch Action
    case 'init'
        %initialize pokes plot

        axes(AxesHandle);
        
        nStim = varargin{1};
        
        %plot in specified axes
        
        for i=1:nStim
            BpodSystem.GUIHandles.Stimulus(i) = line([0 0],[0 0]);
        end
        
        ylabel(AxesHandle, 'Stimulus', 'FontSize', 18);
        xlabel(AxesHandle, 'Time', 'FontSize', 18);
        hold(AxesHandle, 'on');
        
    case 'update'

        Stimulus = varargin{1};
        StimulusDetails = varargin{2};
        
        for i=1:size(BpodSystem.GUIHandles.Stimulus,2)
            BpodSystem.GUIHandles.Stimulus(i).XData =  (1:size(Stimulus,2))/192000;
            BpodSystem.GUIHandles.Stimulus(i).YData =  Stimulus(i,:);
        end
        
        BpodSystem.GUIHandles.StimulusPlot.YLim = [1 18]; 
        
        title_str = [];
        fnames = fields(StimulusDetails);
        for i=1:length(fnames)
            title_str = [title_str ' - ' fnames{i} ': ' num2str(StimulusDetails.(fnames{1}))];
        end
        BpodSystem.GUIHandles.StimulusPlot.Title.String = title_str;
end

