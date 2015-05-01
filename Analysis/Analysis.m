clear
close all
clc

font_size = 12;

subject = 'FT1';
protocol = 'ToneCloudsFixedTime';
datapath = ['../Data/' subject '/' protocol '/Session Data/'];

files = dir([datapath '/*.mat']);
[ignore,idx]=sort([files.datenum]);
files={files(idx).name}'; %session files ordered by date

nSessions = size(files,1);

nTrials = cell(nSessions,1);
sideList = cell(nSessions,1);
outcomeRecord = cell(nSessions,1);
evidenceStrength = cell(nSessions,1);
cloud = cell(nSessions,1);
task = cell(nSessions,1);
for i=1:size(files,1)

    load([datapath files{i,:}])
    
    nTrials{i,1} = size(SessionData.TrialTypes,2);
    sideList{i,1} = SessionData.TrialTypes;
    outcomeRecord{i,1} = SessionData.Outcomes;
    evidenceStrength{i,1} =  SessionData.EvidenceStrength;
    cloud{i,1} =  SessionData.Cloud;
    task{i,1} = char(SessionData.TrialSettings(1,1).GUI.Stage.string(SessionData.TrialSettings(1,1).GUI.Stage.value));
end

% conserve only 'full task' sessions
fulltask = strcmp(task,'Full task');
nSessions = sum(fulltask);
nTrials = nTrials(fulltask);
sideList = sideList(fulltask);
outcomeRecord = outcomeRecord(fulltask);
evidenceStrength = evidenceStrength(fulltask);
cloud = cloud(fulltask);
task = task(fulltask);


% loop for analysis in each session
psycho_x = cell(nSessions,1);
psycho = cell(nSessions,1);
psycho_x_power = cell(nSessions,1);
psycho_power = cell(nSessions,1);
performance  = cell(nSessions,1);
evidence_power = cell(nSessions,1);
valid  = cell(nSessions,1);
performance_change = nan(1,nSessions);

for i=1:nSessions

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Psychometric
    x = evidenceStrength{i,1}; % stimulus strengh
    y = outcomeRecord{i,1}; % trial outcome (0=incorrect, 1=correct, -1=invalid)
    side = sideList{i,1}; % correct side
    n_bins = 2; % number of bins in each choice excluding 0 evidence
    psycho{i,1} = psychofcn(x,y,side,n_bins);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Performance
    performance{i,1} = nan(nTrials{i,1},1);
    win_width = 20;
    outcome = outcomeRecord{i,1};
    %convolution with sliding window ignoring non valid trials
    for j=1:nTrials{i,1}-win_width
        a = outcome(j:j+win_width); %proportion of correct over valid
        performance{i,1}(j,1) = sum(a>0)/sum(a>=0);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % valid trials
    valid{i,1} = nan(nTrials{i,1},1);
    win_width = 20;
    outcome = outcomeRecord{i,1};
    %convolution with sliding window
    for j=1:nTrials{i,1}-win_width
        a = outcome(j:j+win_width); % proportion of valid over all trials
        valid{i,1}(j,1) = sum(a>=0)/sum(a>=-1);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Psychometric with cloud
    
    for j=1:nTrials{i,1}
        evidence_power{i,1}(1,j) = sum(abs(cloud{i,1}{1,j}-9.5))/(8.5*size(cloud{i,1}{1,j},2));
    end 
    
    x = evidence_power{i,1}; % stimulus strengh
    y = outcomeRecord{i,1}; % trial outcome (0=incorrect, 1=correct, -1=invalid)
    side = sideList{i,1}; % correct side
    n_bins = 3; % number of bins in each choice excluding 0 evidence
    psycho_power{i,1} = psychofcn(x,y,side,n_bins);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Change of side prediction
    change_side=abs([0 diff(sideList{i,1})]); %1 when there is a side change
    outcome_change = outcomeRecord{i,1}(change_side==1);
    performance_change(1,i) = sum(outcome_change==1)/sum(outcome_change>=0);
    
    change_side_test = [0 change_side(1:end-1)];
    outcome_change = outcomeRecord{i,1}(change_side_test==1);
    performance_change_test(1,i) = sum(outcome_change==1)/sum(outcome_change>=0);
    %convolution with sliding window
%     for j=1:size(outcome_change,2)-win_width
%         a = outcome_change(j:j+win_width);
%         performance_change{i,1}(j,1) = sum(a>0)/sum(a>=0);
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% psychometric
figure%('Visible','Off')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',[2.5 2])
set(gcf, 'PaperPosition', [0 0 2.5 2])
hold on
for i=1:nSessions
    plot(psycho{i,1}.x,psycho{i,1}.y,'o','MarkerEdgeColor','none','MarkerFaceColor',[i/nSessions 0 1-i/nSessions])
    plot(psycho{i,1}.x([1 2*psycho{i,1}.n_bins+1]),psycho{i,1}.y([1 2*psycho{i,1}.n_bins+1]),'-','Color',[i/nSessions 0 1-i/nSessions])    
end
set(gca,'FontSize',font_size)
xlabel('Evidence Strengh','FontSize',font_size)
ylabel('% Trials','FontSize',font_size)
%print('-dpng', [foldername '/psychometric']);
%print('-dpdf', [foldername '/psychometric']);
%close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% performance
figure%('Visible','Off')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',[2.5 2])
set(gcf, 'PaperPosition', [0 0 2.5 2])
hold on
sep=1;
for i=1:nSessions
    plot(performance{i,1}+1*i,'-','Color',[i/nSessions 0 1-i/nSessions],'linewidth',2)
    plot([1 size(performance{i,1},1)],sep*i*[1 1],'-','Color',0.5*[1 1 1],'linewidth',0.5)
    plot([1 size(performance{i,1},1)],sep*i+1*[1 1],'-','Color',0.5*[1 1 1],'linewidth',0.5)
    plot([1 size(performance{i,1},1)],sep*i+0.5*[1 1],'--','Color',0.5*[1 1 1],'linewidth',0.5)
    
    plot(valid{i,1}+1*i,'-','Color',0.3*[1 1 1],'linewidth',1)
end
set(gca,'FontSize',font_size)
xlabel('Trials','FontSize',font_size)
ylabel('% Performance','FontSize',font_size)
%print('-dpng', [foldername '/performance_trace']);
%print('-dpdf', [foldername '/performance_trace']);
%close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% psychometric power
figure%('Visible','Off')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',[2.5 2])
set(gcf, 'PaperPosition', [0 0 2.5 2])
hold on
for i=1:nSessions
    plot(psycho_power{i,1}.x,psycho_power{i,1}.y,'o','MarkerEdgeColor','none','MarkerFaceColor',[i/nSessions 0 1-i/nSessions])
    plot(psycho_power{i,1}.x,psycho_power{i,1}.y,'-','Color',[i/nSessions 0 1-i/nSessions])
end
set(gca,'FontSize',font_size)
xlabel('Evidence Power','FontSize',font_size)
ylabel('% Trials','FontSize',font_size)
%print('-dpng', [foldername '/psychometric_power']);
%print('-dpdf', [foldername '/psychometric_power']);
%close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% proportion of errors on side changes
figure%('Visible','Off')
set(gcf, 'PaperUnits', 'inches')
set(gcf, 'PaperSize',[2.5 2])
set(gcf, 'PaperPosition', [0 0 2.5 2])
hold on
sep=1;
for i=1:nSessions
    plot(performance_change,'Marker','s','MarkerEdgeColor','none','Color',[1 0.5 0],'MarkerFaceColor',[1 0.5 0],'linewidth',2)
    plot(performance_change_test,'Marker','o','MarkerEdgeColor','none','Color',[1 0.5 0],'MarkerFaceColor',[1 0.5 0],'linewidth',2)
end
set(gca,'FontSize',font_size)
xlabel('# Session','FontSize',font_size)
ylabel('% Performance','FontSize',font_size)
%print('-dpng', [foldername '/performance_trace']);
%print('-dpdf', [foldername '/performance_trace']);
%close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
