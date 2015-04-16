clear
close all
clc

%subject = 'FT0';
subject = 'Dummy Subject';
protocol = 'ToneCloudsFixedTime'; 
datapath = ['../Data/' subject '/' protocol '/Session Data/'];

files = dir(datapath);

for i=3:size(files,1)

    load([datapath files(44,1).name])

    SideList = SessionData.TrialTypes;
    OutcomeRecord = SessionData.Outcomes;
    EvidenceStrength =  SessionData.EvidenceStrength;

    n_bins = 2;%number of bins in each choice excluding 0 evidence
    bin_size = 2/(2*n_bins+1);

    half_x=0:bin_size:1;
    Xdata = unique([-half_x half_x]); Ydata=nan(1,size(Xdata,2));
    h = line([Xdata,Xdata],[Ydata,Ydata],'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6);

    for side=1:2
    for ibin=1:n_bins

    ntrials = sum(EvidenceStrength>half_x(ibin)+bin_size/2 & EvidenceStrength<=half_x(ibin+1)+bin_size/2 & SideList==side & OutcomeRecord>=0);
    ntrials_correct = sum(EvidenceStrength>half_x(ibin)+bin_size/2 & EvidenceStrength<=half_x(ibin+1)+bin_size/2 & SideList==side & OutcomeRecord==1);

    p= binofit(ntrials_correct,ntrials);

    if side==1
       Ydata(n_bins+ibin+1) = p;
    else
       Ydata(ibin) = 1-p;
    end
    end
    % zero evidence
    ntrials = sum(EvidenceStrength<=bin_size/2 & SideList==side & OutcomeRecord>=0);
    ntrials_correct = sum(EvidenceStrength==0 & SideList==side & OutcomeRecord==1);

    [p c] = binofit(ntrials_correct,ntrials);

    Ydata(n_bins+1) = p;    
    end

    set(h, 'xdata', Xdata, 'ydata', Ydata);
end