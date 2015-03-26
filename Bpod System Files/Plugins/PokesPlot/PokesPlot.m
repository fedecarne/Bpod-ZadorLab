% [x, y] = PokesPlotSection(obj, action, [arg1], [arg2])

function varargout = PokesPlot(varargin)

global BpodSystem
    
empty_trial_info = ...
  struct('start_time', [], 'align_time', [], 'align_found', [], 'ydelta', [], 'visible', [], ...
  'ghandles', [], 'select_value', [], 'mainsort_value', [], 'subsort_value', []);
    
action = varargin{1};
state_colors = varargin{2};
poke_colors = varargin{3};


switch action

    %% init    
    case 'init'
        
        BpodSystem.ProtocolFigures.PokesPlot = figure('Position', [100 280 300 1000],'name','PokesPlot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'on');
        
        if length(varargin) < 2,
            scolors = struct('states', [], 'pokes', []);
        end;               

        BpodSystem.GUIHandles.PokesPlot.AlignOnMenu = uicontrol('Style', 'popupmenu', 'String', fields(state_colors), 'Position', [30 70 150 20], 'FontWeight', 'normal', 'FontSize', 10, 'BackgroundColor','white', 'FontName', 'Arial','Callback', {@PokesPlot, 'alignon'});
        
        BpodSystem.GUIHandles.PokesPlot.LeftEdgeLabel = uicontrol('Style', 'text','String','t0', 'Position', [30 35 40 20], 'FontWeight', 'normal', 'FontSize', 10,'FontName', 'Arial');
        BpodSystem.GUIHandles.PokesPlot.LeftEdge = uicontrol('Style', 'edit','String',0, 'Position', [90 35 40 20], 'FontWeight', 'normal', 'FontSize', 10, 'BackgroundColor','white', 'FontName', 'Arial','Callback', {@PokesPlot, 'time_axis'});
        
        BpodSystem.GUIHandles.PokesPlot.LeftEdgeLabel = uicontrol('Style', 'text','String','t1', 'Position', [30 10 40 20], 'FontWeight', 'normal', 'FontSize', 10, 'FontName', 'Arial');
        BpodSystem.GUIHandles.PokesPlot.RightEdge = uicontrol('Style', 'edit','String',10, 'Position', [90 10 40 20], 'FontWeight', 'normal', 'FontSize', 10, 'BackgroundColor','white', 'FontName', 'Arial','Callback', {@PokesPlot, 'time_axis'});
         
        BpodSystem.GUIHandles.PokesPlot.LastnLabel = uicontrol('Style', 'text','String','N trials', 'Position', [140 35 50 20], 'FontWeight', 'normal', 'FontSize', 10, 'FontName', 'Arial');
        BpodSystem.GUIHandles.PokesPlot.LastnLabel = uicontrol('Style', 'edit','String',10, 'Position', [200 35 40 20], 'FontWeight', 'normal', 'FontSize', 10, 'BackgroundColor','white', 'FontName', 'Arial','Callback', {@PokesPlot, 'time_axis'});
        
        BpodSystem.GUIHandles.PokesPlot.PokesPlotAxis = axes('Position', [0.1 0.38 0.8 0.54],'Color', 0.3*[1 1 1]);

        BpodSystem.GUIHandles.PokesPlot.ColorAxis = axes('Position', [0.15 0.29 0.7 0.03]);
                
        fnames = fieldnames(state_colors);
        for i=1:length(fnames),
            fill([i-0.9 i-0.9 i-0.1 i-0.1], [0 1 1 0], state_colors.(fnames{i}));
            if length(fnames{i})< 10
                legend = fnames{i};
            else
                legend = fnames{i}(1:10);
            end
            hold on; t = text(i-0.5, -0.5, legend);
            set(t, 'Interpreter', 'none', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'Rotation', 90);
            set(gca, 'Visible', 'off');
        end;
        ylim([0 1]); xlim([0 length(fnames)]);

  %% update    
  case 'update'
      
%       % We initialize a new trial once it's started, so as to have access to its start time:
%       if length(trial_info) < n_started_trials,
%           initialize_trial(n_started_trials, parsed_events, value(my_state_colors), value(alignon), trial_info);
%       end;
      
      time = dispatcher('get_time');
      update_already_started_trial(dispatcher('get_time'), ...
          n_started_trials, parsed_events, latest_parsed_events, ...
          value(my_state_colors), value(alignon), value(axpokesplot), trial_info);
      
      
      set(value(axpokesplot), 'XLim', [value(t0) value(t1)]);
      set_ylimits(n_started_trials, value(axpokesplot), value(trial_limits), ...
          value(start_trial), value(end_trial), value(ntrials));
      
      drawnow;

%% trial_completed
  case 'trial_completed'
      
      trial_info(n_done_trials).visible = trial_selection(value(trial_selector), parsed_events);
      trial_info(n_done_trials).ydelta  = 0;
      if trial_info(n_done_trials).visible == 0,
          for guys = {'states' 'pokes'},
              fnames = fieldnames(trial_info(n_done_trials).ghandles.(guys{1}));
              for j=1:length(fnames),
                  ghandles = trial_info(n_done_trials).ghandles.(guys{1}).(fnames{j});
                  set(ghandles, 'Visible', 'off');
              end;
          end;
      end;
      
      if collapse_selection==1,
          last_yposition_drawn = value(last_ypos_drawn);
          if trial_info(n_done_trials).visible == 1,
              last_yposition_drawn = last_yposition_drawn + 1;
              if isempty(trial_info(n_done_trials).ydelta), trial_info(n_done_trials).ydelta = 0; end;
              delta = n_done_trials + trial_info(n_done_trials).ydelta - last_yposition_drawn;
              vertical_shift(trial_info(n_done_trials).ghandles, -delta);
              trial_info(n_done_trials).ydelta = trial_info(n_done_trials).ydelta - delta; %#ok<NASGU> (This line OK.)
          end;
          last_ypos_drawn.value = last_yposition_drawn;
      end;

      
%% alignon
  case 'alignon'
      
      g = value(trial_info(1:n_started_trials)); %#ok<NODEF> (defined by GetSoloFunctionArgs)
      [X{1:n_started_trials}] = deal(g.align_time);
      old_align_times = cell2mat(X);
      for i=1:min(n_started_trials, length(parsed_events_history))
          % First, see whether we can get the new alignment time:
          if i<n_started_trials, pevs = parsed_events_history{i};
          else                   pevs = parsed_events;
          end;
          atime = find_align_time(value(alignon), pevs); %#ok<NODEF> (defined by GetSoloFunctionArgs)
          
          % If we can't find the alignment time for a trial, align it on trial
          % start:
          if ~isnan(atime), trial_info(i).align_found = 1;
          else              trial_info(i).align_found = 0; atime = trial_info(i).start_time;
          end;
          trial_info(i).align_time = atime;
          
          % delta is how much we have to shift the plots by
          delta = atime - old_align_times(i);
          if delta ~= 0,
              % Now shift the x position of all of this trial's graphics handles
              ghandles = trial_info(i).ghandles;
              for guy = {'states' 'pokes'},
                  fnames = fieldnames(ghandles.(guy{1}));
                  for j=1:length(fnames),
                      gh = ghandles.(guy{1}).(fnames{j});
                      if all(ishandle(gh)), % Only try it if the handles are vald
                          for k=1:length(gh), set(gh(k), 'XData', get(gh(k), 'XData') - delta); end;
                      end;
                  end; % for j
              end; % for guy
              if isfield(ghandles, 'spikes') && ~isempty(ghandles.spikes) && ishandle(ghandles.spikes),
                  set(ghandles.spikes, 'XData', get(ghandles.spikes, 'XData') - delta);
              end;
          end;
      end;
      
        
%% time_axes
  case 'time_axis'
      
    set(value(axpokesplot), 'XLim', [value(t0) value(t1)]);
   

end;





% ------------------------------------------------------------------
%
%              FUNCTION LATEST_TIME
%
% ------------------------------------------------------------------


function [t] = latest_time(pe)

   states = rmfield(rmfield(pe.states, 'starting_state'), 'ending_state');
   pokes  = rmfield(rmfield(pe.pokes,  'starting_state'), 'ending_state');
   
   states = struct2cell(states);
   pokes  = struct2cell(pokes);
   
   ts = [];
   for i=1:length(states), ts = [ts ; states{i}(:)]; end;
   for i=1:length(pokes), ts = [ts ; pokes{i}(:)]; end;
   ts = ts(~isnan(ts));
   
   if isempty(ts), t = 10000; 
   else            t = max(ts);
   end;