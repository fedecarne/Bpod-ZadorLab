clear
close all
clc

font_size = 12;
figure_size = [4 3];

time = clock;
date_time = [date '-' num2str(time(4)) '-' num2str(time(5))];
result_path = ['~/../../media/fede/Data/Data-on-Satellite/AAAApostdoc/zador/research/b-pod/Results/behavior-' date_time '/'];
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
    rawEvents = cell(nSessions,1);
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
        rawEvents{i,1} = SessionData.RawEvents.Trial;
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
    rawEvents = rawEvents(fulltask);
    task = task(fulltask);


    % loop for analysis in each session
    psycho_x = cell(nSessions,1);
    psycho = cell(nSessions,1);
    psycho_fit = cell(nSessions,1);
    psycho_regress = cell(nSessions,1);
    psycho_logit = cell(nSessions,1);
    psycho_kernel = cell(nSessions,1);
    psycho_kernel2 = cell(nSessions,1);
    performance  = cell(nSessions,1);
    evidence_power = cell(nSessions,1);
    valid  = cell(nSessions,1);
    mean_performance = nan(1,nSessions);
    mean_valid = nan(1,nSessions);
    response_time = cell(1,nSessions);
    for i=1:nSessions

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Psychometric
        
        warmup = 50;
        cooldown = 10;
        to_include = warmup:nTrials{i,1}-cooldown;
        x = evidenceStrength{i,1}(to_include); % stimulus strengh
        y = outcomeRecord{i,1}(to_include); % trial outcome (0=incorrect, 1=correct, -1=invalid)
        side = sideList{i,1}(to_include); % correct side
        n_bins = 10; % number of bins in each choice excluding 0 evidence
        psycho{i,1} = psychofcn(x,y,side,n_bins);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        x = psycho{i,1}.x;
        y = psycho{i,1}.y;
        [b,bint,r,rint,stats] = regress(log(y'./(1-y')),[ones(size(x,2),1) x']) ;
        psycho_regress{i,1} = b;%1./(1+exp(-(b(1)+b(2)*x)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        to_include = outcomeRecord{i,1}~=-1;
        to_include = logical([zeros(1,warmup) to_include(warmup+1:nTrials{i,1}-cooldown) zeros(1,cooldown)]);
        x = (2*sideList{i,1}(to_include)-3)'.*evidenceStrength{i,1}(to_include)';
        y = (sideList{i,1}(to_include)-1)'== outcomeRecord{i,1}(to_include)';
        [b,dev,stats] = glmfit(x,y,'binomial','link','logit');
        psycho_logit{i,1} = b;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % psychophysical kernel
        max_t=size(cloud{i,1}{1,nTrials{i,1}},2);
        minTrial=50;
        for t=1:max_t
            
            s=nan(nTrials{i,1},1);
            for j=1:nTrials{i,1}
                if size(cloud{i,1}{1,j},2)>t
                    s(j,1) = cloud{i,1}{1,j}(1,t);
                end
            end
            
            if sum(~isnan(s)) > minTrial
                
                to_include = outcomeRecord{i,1}~=-1;
                to_include = logical([zeros(1,warmup) to_include(warmup+1:nTrials{i,1}-cooldown) zeros(1,cooldown)]);
                
                x = s(to_include)>9.5;
                x = (x-nanmean(x))./nanstd(x);                
                y = (sideList{i,1}(to_include)-1)'== outcomeRecord{i,1}(to_include)';
                [b,dev,stats] = glmfit(x,y,'binomial','link','logit');
                psycho_kernel{i,1}(:,t) = b;
                
               
%                 yfit = glmval(psycho_kernel{i,1}(:,t),x,'logit');
%                 plot(x,yfit,'b')
%                 hold on
%                 plot(psycho{i,1}.x,psycho{i,1}.y,'o')
%                x = -1:0.1:1;
%                 yfit = glmval(psycho_logit{i,1},x,'logit');
%                 plot(x,yfit,'r')
                
                
                x = s(to_include);
                x = (x-nanmean(x))./nanstd(x);
                y = (sideList{i,1}(to_include)-1)'== outcomeRecord{i,1}(to_include)';
                [b,dev,stats] = glmfit(x,y,'binomial','link','logit');
                psycho_kernel2{i,1}(:,t) = b;
            
            else
                psycho_kernel{i,1}(:,t) = nan(2,1);
                psycho_kernel2{i,1}(:,t) = nan(2,1);
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Response time
        response_time{i,1} = nan(1,nTrials{i,1});
        for j=1:nTrials{i,1}
            switch outcomeRecord{i,1}(1,j)
                case 1
                    response_time{i,1}(1,j) = rawEvents{i,1}{1,j}.States.Reward(1)-rawEvents{i,1}{1,j}.States.GoSignal(1);
                case 0
                    response_time{i,1}(1,j) = rawEvents{i,1}{1,j}.States.Punish(1)-rawEvents{i,1}{1,j}.States.GoSignal(1);
                otherwise
                    response_time{i,1}(1,j) = 0/0;
            end
        end
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
        subplot(floor(sqrt(nSessions)),ceil(nSessions/floor(sqrt(nSessions))),i)
        hold on
        plot(psycho{i,1}.x,psycho{i,1}.y,'o','MarkerEdgeColor','none','MarkerFaceColor',[i/nSessions 0 1-i/nSessions])
        
        %%%psycho regress
        x = -1:0.1:1;
        b = psycho_regress{i,1};
        y = 1./(1+exp(-(b(1)+b(2)*x)));        
        plot(x,y,'k');        

        x = -1:0.1:1;
        if ~isempty(psycho_logit{i,1})
            yfit = glmval(psycho_logit{i,1},x,'logit');
            plot(x,yfit,'b')
        end
        
        axis([-1 1 0 1])
        set(gca,'FontSize',font_size)
        if i==1
            xlabel('Evidence Strengh','FontSize',font_size)
            ylabel('% Trials','FontSize',font_size)
            title('Psychometric curves')
        end
    end
    print('-dpng', [result_path subject '_psychometric.png']);
    print('-dpdf', [result_path subject '_psychometric.pdf']);
    close
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% psychophysical kernel
    figure('Visible','Off')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',[10 10])
    set(gcf, 'PaperPosition',[0 0 10 10])
    for i=1:nSessions
        subplot(floor(sqrt(nSessions)),ceil(nSessions/floor(sqrt(nSessions))),i)
        hold on
        plot(psycho_kernel{i,1}(2,:))
        plot(psycho_kernel2{i,1}(2,:))
        axis([1 16 -1 1])
        if i==1
        xlabel('Time','FontSize',font_size)
        ylabel('Coeff','FontSize',font_size)
        end
        if i==round(0.5*sqrt(nSessions)), title('Psychophysical Kernel'); end
        set(gca,'FontSize',font_size)
    end
    print('-dpng', [result_path subject '_psychokernel.png']);
    print('-dpdf', [result_path subject '_psychokernel.pdf']);
    close
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% psychometric
    figure('Visible','Off')
    set(gcf, 'PaperUnits', 'inches')
    set(gcf, 'PaperSize',[10 10])
    set(gcf, 'PaperPosition',[0 0 10 10])
    for i=1:nSessions
        subplot(floor(sqrt(nSessions)),ceil(nSessions/floor(sqrt(nSessions))),i)
        hold on
        x=0:0.2:1;
        for j=1:size(x,2)-1
            r_correct(1,j) = mean(response_time{i,1}(evidenceStrength{i,1}>=x(j) & evidenceStrength{i,1}<=x(j+1) & outcomeRecord{i,1}==1));
            r_incorrect(1,j) = mean(response_time{i,1}(evidenceStrength{i,1}>=x(j) & evidenceStrength{i,1}<=x(j+1) & outcomeRecord{i,1}==0));
        end
        plot(r_correct,'o','MarkerFaceColor',[0 0 1],'MarkerEdgeColor','none')
        plot(r_incorrect,'o','MarkerFaceColor',[1 0 0],'MarkerEdgeColor','none')
        %axis([0 10 0 2])
    end
    set(gca,'FontSize',font_size)
    ylabel('Response Time','FontSize',font_size)
    xlabel('Evidence Strength','FontSize',font_size)
    title('Response Time')
    print('-dpng', [result_path subject '_response_time.png']);
    print('-dpdf', [result_path subject '_response_time.pdf']);
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