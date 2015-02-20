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
function varargout = EnhancedBpodParameterGUI(varargin)

% EnhancedBpodParameterGUI('init', ParamStruct) - initializes a GUI with edit boxes for every field in subfield ParamStruct.GUI
% EnhancedBpodParameterGUI('sync', ParamStruct) - updates the GUI with fields of
%       ParamStruct.GUI, if they have not been changed by the user. 
%       Returns a param struct. Fields in the GUI sub-struct are read from the UI.

% EnhancedBpodParameterGUI is based on BpodParameterGUI
% Written by F. Carnevale 02/16/2015

global BpodSystem
Op = varargin{1};
Params = varargin{2};
Op = lower(Op);
switch Op
    case 'init'
        Params = Params.GUI;
        ParamNames = fieldnames(Params);
        nValues = length(ParamNames);
        ParamStyle = cell(1,nValues);
        ParamString = cell(1,nValues);
        ParamValues = zeros(1,nValues);
        ParamPanel = cell(1,nValues);
        for x = 1:nValues
            ParamPanel{1,x} = Params.(ParamNames{x}).panel;
            ParamStyle{1,x} = Params.(ParamNames{x}).style;
            switch Params.(ParamNames{x}).style
                case 'text'
                    ParamString{1,x} = Params.(ParamNames{x}).string;
                    ParamValues(1,x) = Params.(ParamNames{x}).string;
                case 'edit'
                    ParamString{1,x} = Params.(ParamNames{x}).string;
                    ParamValues(1,x) = Params.(ParamNames{x}).string;
                case 'popupmenu'
                    ParamString{1,x} = Params.(ParamNames{x}).string;
                    ParamValues(1,x) = Params.(ParamNames{x}).value;
                case 'checkbox'
                    ParamString{1,x} = Params.(ParamNames{x}).string;
                    ParamValues(1,x) = Params.(ParamNames{x}).value;
            end
        end
        
        uniqueParamPanel = unique(ParamPanel);
        nPanels = length(unique(ParamPanel));
        
        Vsize = 20+(30*nValues)+70*(nPanels)+20;
        Width = 350;
        BpodSystem.ProtocolFigures.BpodParameterGUI = figure('Position', [100 280 Width Vsize],'name','Live Params','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
        
        BpodSystem.GUIHandles.ParameterGUI = struct;
        BpodSystem.GUIHandles.ParameterGUI.ParamNames = ParamNames;
        BpodSystem.GUIHandles.ParameterGUI.LastParamValues = ParamValues;
        BpodSystem.GUIHandles.ParameterGUI.Labels = zeros(1,nValues);
        
        
        panel_y = Vsize-20;
        Pos = panel_y-70;
        for i=1:nPanels
            
            % Elements in this panel
            indx_in_panel = find(strcmp(ParamPanel,uniqueParamPanel{i}));
            n_indx_in_panel = length(indx_in_panel);
            
            panel(i) = uipanel('title', uniqueParamPanel{i},'FontSize',12, 'BackgroundColor','white','Units','Pixels', 'Position',[25 panel_y-30*(n_indx_in_panel+2) Width-50 30*(n_indx_in_panel+2)]);
            
            
            for j=1:length(indx_in_panel)
                
                x = indx_in_panel(j);
                BpodSystem.GUIHandles.ParameterGUI.Labels(x) = uicontrol('Style', 'text', 'String', ParamNames{x}, 'Position', [25+10 Pos 1/2*(Width-50) 25], 'FontWeight', 'normal', 'FontSize', 12, 'BackgroundColor','white', 'FontName', 'Arial');
                BpodSystem.GUIHandles.ParameterGUI.ParamValues(x) = uicontrol('Style', ParamStyle{1,x}, 'String', ParamString{x}, 'Position', [25+20+3/5*(Width-50) Pos+5 0.3*(Width-50) 25], 'FontWeight', 'normal', 'FontSize', 12, 'FontName', 'Arial');
                Pos = Pos - 30;
            end            
            Pos = Pos - 70;
            panel_y = panel_y - 30*(n_indx_in_panel+2.5);
        end



        
    case 'sync'
        ParamNames = fieldnames(Params.GUI);
        nValues = length(BpodSystem.GUIHandles.ParameterGUI.LastParamValues);
        for x = 1:nValues            
            switch Params.GUI.(ParamNames{x}).style
                case 'edit'
                    thisParamGUIValue = str2double(get(BpodSystem.GUIHandles.ParameterGUI.ParamValues(x), 'String'));
                    thisParamLastValue = BpodSystem.GUIHandles.ParameterGUI.LastParamValues(x);
                    thisParamInputValue = Params.GUI.(ParamNames{x}).string;
                    if thisParamGUIValue == thisParamLastValue % If the user didn't change the GUI, the GUI can be changed from the input.
                        set(BpodSystem.GUIHandles.ParameterGUI.ParamValues(x), 'String', sprintf('%g',thisParamInputValue));
                        thisParamGUIValue = thisParamInputValue;
                    end
                    Params.GUI.(BpodSystem.GUIHandles.ParameterGUI.ParamNames{x}).string = thisParamGUIValue;
                case 'popupmenu'
                    thisParamGUIValue = BpodSystem.GUIHandles.ParameterGUI.ParamValues(x).Value;
                    thisParamLastValue = BpodSystem.GUIHandles.ParameterGUI.LastParamValues(x);
                    thisParamInputValue = Params.GUI.(ParamNames{x}).value;
                    if thisParamGUIValue == thisParamLastValue % If the user didn't change the GUI, the GUI can be changed from the input.
                        set(BpodSystem.GUIHandles.ParameterGUI.ParamValues(x), 'Value', thisParamInputValue);
                        thisParamGUIValue = thisParamInputValue;
                    end
                    Params.GUI.(BpodSystem.GUIHandles.ParameterGUI.ParamNames{x}).value = thisParamGUIValue;
                case 'checkbox'
                    thisParamGUIValue = BpodSystem.GUIHandles.ParameterGUI.ParamValues(x).Value;
                    thisParamLastValue = BpodSystem.GUIHandles.ParameterGUI.LastParamValues(x);
                    thisParamInputValue = Params.GUI.(ParamNames{x}).value;
                    if thisParamGUIValue == thisParamLastValue % If the user didn't change the GUI, the GUI can be changed from the input.
                        set(BpodSystem.GUIHandles.ParameterGUI.ParamValues(x), 'Value', thisParamInputValue);
                        thisParamGUIValue = thisParamInputValue;
                    end
                    Params.GUI.(BpodSystem.GUIHandles.ParameterGUI.ParamNames{x}).value = thisParamGUIValue;
            end


            
            BpodSystem.GUIHandles.ParameterGUI.LastParamValues(x) = thisParamGUIValue;
        end
    varargout{1} = Params;
end