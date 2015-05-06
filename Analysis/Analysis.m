clear
close all
clc

font_size = 12;
figure_size = [4 3];

time = clock;
date_time = [date '-' num2str(time(4)) '-' num2str(time(5))];
result_path = ['~/../../media/fede/Data/Data-on-Satellite/AAAApostdoc/zador/research/b-pod/Results/' date_time '/'];
mkdir(result_path);

subjectpath = '../Data/';
subject_prefix = 'FT';

subjects = dir([subjectpath '/' subject_prefix '*']);
subjects={subjects.name}'; %session files ordered by date
n_subjects = size(subjects,1);

protocol = 'ToneCloudsFixedTime';

for m=1:n_subjects

    subject = subjects{m,:};

    datapath = ['../Data/' subject '/' protocol '/Session Data/'];

    files = dir([datapath '/*.mat']);
    [ignore,idx]=sort([files.datenum]);
    files={files(idx).name}'; %session files ordered by date

    nSessions = size(files,1);

    nTrials = cell(nSessions,1);
    sideList = cell(nSessions,1);
    outcomeRecord = cell(nSessions,1);
    evidenceStrength = cell(nSessions,1);
    n_difficulties = nan(nSessions,1);
    sound_duration = cell(nSessions,1);
    cloud = cell(nSessions,1);
    task = cell(nSessions,1);
    for i=1:size(files,1)

        load([datapath files{i,:}])

        nTrials{i,1} = size(SessionData.TrialTypes,2);
        sideList{i,1} = SessionData.TrialTypes;
        outcomeRecord{i,1} = SessionData.Outcomes;
        evidenceStrength{i,1} =  SessionData.EvidenceStrength;
        n_difficulties(i,1) =  size(unique(SessionData.EvidenceStrength),2);
        sound_duration{i,1} = SessionData.SoundDuration;
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
    n_difficulties = n_difficulties(fulltask);
    sound_duration = sound_duration(fulltask);
    cloud = cloud(fulltask);
    task = task(fulltask);


    % loop for analysis in each session
    psycho_x = cell(nSessions,1);
    psycho = cell(nSessions,1);
    psycho_fit = cell(nSessions,1);
    performance  = cell(nSessions,1);
    evidence_power = cell(nSessions,1);
    valid  = cell(nSessions,1);
    mean_performance = nan(1,nSessions);
    mean_valid = nan(1,nSessions);
    for i=1:nSessions


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Psychometric
        
        warmup = 50;
        cooldown = 10;
        to_include = warmup:nTrials{i,1}-cooldown;
        x = evidenceStrength{i,1}(to_include); % stimulus strengh
        y = outcomeRecord{i,1}(to_include); % trial outcome (0=incorrect, 1=correct, -1=invalid)
        side = sideList{i,1}(to_include); % correct side
        n_bins = 2; % number of bins in each choice excluding 0 evidence
        psycho{i,1} = psychofcn(x,y,side,n_bins);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        x = psycho{i,1}.x;
        y = psycho{i,1}.y;
        f = @(p,x) p(1) + p(2) ./ (1 + exp(-(x-p(3))/p(4)));
        try
            psycho_fit{i,1} = nlinfit(x,y,f,[0 20 50 5]);
        catch ME
            psycho_fit{i,1} = nan(1,4);
        end
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
        a = outcome(1:end);
        mean_performance(1,i) = mean(sum(a>0)/sum(a>=0));
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
        a = outcome(1:end);

        mean_valid(1,i) = mean(sum(a>=0)/sum(a>=-1));   
    %    mean_valid(1,i) = mean(sum(a>=0 & sound_duration{i,1}==0.5)/sum(a>=-1 & sound_duration{i,1}==0.5));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% psychometric
    figure('Visible','Off')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',[10 10])
    set(gcf, 'PaperPosition',[0 0 10 10])
    for i=1:nSessions
        subplot(floor(sqrt(nSessions)),ceil(sqrt(nSessions)),i)
        hold on
        plot(psycho{i,1}.x,psycho{i,1}.y,'o','MarkerEdgeColor','none','MarkerFaceColor',[i/nSessions 0 1-i/nSessions])

        x = -1:0.1:1;
        p = psycho_fit{i,1};
        y = p(1) + p(2) ./ (1 + exp(-(x-p(3))/p(4)));

        plot(x,y);

        axis([-1 1 0 1])
    end
    set(gca,'FontSize',font_size)
    xlabel('Evidence Strengh','FontSize',font_size)
    ylabel('% Trials','FontSize',font_size)
    title('Psychometric curves')
    print('-dpng', [result_path subject '_psychometric.png']);
    print('-dpdf', [result_path subject '_psychometric.pdf']);
    close
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% performance
    figure('Visible','Off')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize', [3 5])
    set(gcf, 'PaperPosition', [0 0 3 5])
    hold on
    sep=1;
    for i=1:nSessions
        plot(performance{i,1}+1*i,'-','Color',[i/nSessions 0 1-i/nSessions],'linewidth',2)
        plot([1 size(performance{i,1},1)],sep*i*[1 1],'-','Color',0.5*[1 1 1],'linewidth',0.5)
        plot([1 size(performance{i,1},1)],sep*i+1*[1 1],'-','Color',0.5*[1 1 1],'linewidth',0.5)
        plot([1 size(performance{i,1},1)],sep*i+0.5*[1 1],'--','Color',0.5*[1 1 1],'linewidth',0.5)

        plot(valid{i,1}+1*i,'-','Color',0.3*[1 1 1],'linewidth',1)
        text(size(performance{i,1},1)+1,sep*i+0.5,num2str(n_difficulties(i,1)),'FontSize',12)
    end
    set(gca,'FontSize',font_size)
    xlabel('Trials','FontSize',font_size)
    ylabel('% Performance','FontSize',font_size)
    title('Performance')
    print('-dpng', [result_path subject '_performance_trace.png']);
    print('-dpdf', [result_path subject '_performance_trace.pdf']);
    close
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% mean performance
    figure('Visible','Off')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])
    hold on
    h1=plot(mean_performance,'Linewidth',1.5);
    plot(mean_performance,'s');
    h2=plot(mean_performance(n_difficulties==1),'-','Linewidth',1.5);
    legend([h1 h2],'psycho','easy','Location','Northwest')
    legend('boxoff')
    set(gca,'FontSize',font_size)
    xlabel('Session','FontSize',font_size)
    ylabel('% Mean performance','FontSize',font_size)
    title('Mean Performance')
    print('-dpng', [result_path subject '_mean_performance_trace.png']);
    print('-dpdf', [result_path subject '_mean_performance_trace.pdf']);
    close
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


    %% mean valid
    figure('Visible','Off')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',figure_size)
    set(gcf, 'PaperPosition', [0 0 figure_size])
    hold on
    h1=plot(mean_valid,'Linewidth',1.5);
    plot(mean_valid,'s');
    h2=plot(mean_valid(n_difficulties==1),'-','Linewidth',1.5);
    legend([h1 h2],'psycho','easy','Location','Northwest')
    legend('boxoff')
    axis([1 nSessions 0 1])
    set(gca,'FontSize',font_size)
    xlabel('Session','FontSize',font_size)
    ylabel('% Mean valid','FontSize',font_size)
    title('Mean Valid')
    print('-dpng', [result_path subject '_mean_valid_trace.png']);
    print('-dpdf', [result_path subject '_mean_valid_trace.pdf']);
    close
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   
end