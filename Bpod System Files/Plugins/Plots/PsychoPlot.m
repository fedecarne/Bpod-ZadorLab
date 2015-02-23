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
function PsychoPlot(AxesHandle, Action, varargin)
%%
% Plug in to Plot Psychometric curve in real time
% AxesHandle = handle of axes to plot on
% Action = specific action for plot, "init" - initialize OR "update" -  update plot

%Example usage:
% PsychoPlot(AxesHandle,'init')
% PsychoPlot(AxesHandle,'update',TrialTypeSides,OutcomeRecord)

% varargins:
% TrialTypeSides: Vector of 0's (right) or 1's (left) to indicate reward side (0,1), or 'None' to plot trial types individually
% OutcomeRecord:  Vector of trial outcomes
% EvidenceStrength: Vector of evidence strengths

% Adapted from BControl (PsychCurvePlotSection.m)
% F.Carnevale 2015.Feb.17

%% Code Starts Here
global bin_size %this is for convenience
global BpodSystem

switch Action
    case 'init'
        
        bin_size =0.1;
        
        axes(AxesHandle);
        %plot in specified axes
        Xdata = -1:bin_size:1; Ydata=nan(1,size(Xdata,2));
        BpodSystem.GUIHandles.PsychometricLine = line([Xdata,Xdata],[Ydata,Ydata],'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6);
        BpodSystem.GUIHandles.PsychometricData = [Xdata',Ydata'];
        set(AxesHandle,'TickDir', 'out', 'XLim', [-1, 1],'YLim', [0, 1], 'FontSize', 16);
        xlabel(AxesHandle, 'Evidence Strength', 'FontSize', 18);
        ylabel(AxesHandle, 'P(Right)', 'FontSize', 18);
        hold(AxesHandle, 'on');
        
    case 'update'
        try
            
        CurrentTrial = varargin{1};
        SideList = varargin{2};
        OutcomeRecord = varargin{3};
        EvidenceStrength =  varargin{4};
        
        Xdata = BpodSystem.GUIHandles.PsychometricData(:,1);
        Ydata = BpodSystem.GUIHandles.PsychometricData(:,2);
        
        evidence_ind = round(EvidenceStrength/bin_size);
        
        if evidence_ind(CurrentTrial)>0
            ntrials = sum(evidence_ind==evidence_ind(CurrentTrial) & SideList(1:CurrentTrial)==SideList(CurrentTrial) & OutcomeRecord(1:CurrentTrial)>=0);
            ntrials_correct = sum(evidence_ind==evidence_ind(CurrentTrial) & SideList(1:CurrentTrial)==SideList(CurrentTrial) & OutcomeRecord(1:CurrentTrial)==1);
            
            [p c] = binofit(ntrials_correct,ntrials);
        else
            ntrials = sum(evidence_ind==0 & OutcomeRecord(1:CurrentTrial)>=0);
            ntrials_correct = sum(SideList(1:CurrentTrial)==1 && OutcomeRecord(1:CurrentTrial)==1 || SideList(1:CurrentTrial)==0 && OutcomeRecord(1:CurrentTrial)==0);
            
            [p c] = binofit(ntrials_correct,ntrials);
        end
               
        if SideList(CurrentTrial)==0
            Ydata((size(Xdata,1)-1)/2 + 1 + evidence_ind(CurrentTrial)) = p;
        else
            Ydata((size(Xdata,1)-1)/2 + 1 - evidence_ind(CurrentTrial)) = 1-p;
        end
        
        set(BpodSystem.GUIHandles.PsychometricLine, 'xdata', [Xdata], 'ydata', [Ydata]);
        
        BpodSystem.GUIHandles.PsychometricData(:,1) = Xdata;
        BpodSystem.GUIHandles.PsychometricData(:,2) = Ydata;
        
        set(AxesHandle,'XLim',[-1 1], 'Ylim', [0 1]);
        catch
            disp('')
        end
end

end

