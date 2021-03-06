%% Questionnaire analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
quest.questions = cell(3,1);
quest.questions{1} = 'How do you feel today?'
quest.questions{2} = ['In general, how easily do you become nervous or' ...
                      'anxious in everyday life?'];
quest.questions{3} = 'How well do you believe you performed the task?'

quest.resp = zeros(20,3);

%% Automated input
cont = 1
i = 0;
while cont
    i = i+1;
    id = input('ID: ');
    quest.resp(id,1) = input('Q1: ');
    quest.resp(id,2) = input('Q2: ');
    quest.resp(id,3) = input('Q3: ');  
    in = input('Continue?');
    if isempty(in)
        cont = 1;
        disp('Next.')
    else
        cont = 0;
        fprintf('\n%d subjects recorded',i)
    end
end
%% Add IDs
quest.resp = [[1:20]' quest.resp]
%% Check which ones are usable (remove all zeros and nans)
available = sum(quest.resp(:,2:end),2)==0;
available = logical(~available .* ~any(isnan(quest.resp),2))
usable = quest.resp(available,:);
%% Plotting 1: Various correlations within questionnaire data
disp('Correlations:')
disp(corr(usable))

figure
subplot(121)
scatter(usable(:,3),usable(:,4))
xlabel('How easily do you become nervous/anxious?')
ylabel('How well do you think you performed?')
axis([0 10 0 10])

subplot(122)
scatter(usable(:,2),usable(:,4))
xlabel('How well do you feel today?')
ylabel('How well do you think you performed?')
axis([0 10 0 10])

figure
scatter(usable(:,1),usable(:,2))
ylabel('How well do you feel today?')
xlabel('Subject ID','fontsize',20)
hold on

text(2,4,'\rho = - 0.7','interpreter','tex','fontsize',15)
coeffs = polyfit(usable(:,1),usable(:,2),1);
x = 0:0.01:18;
y = polyval(coeffs,x);
plot(x,y)
%% Correlations between subjective and actual performance

scores = zeros(20,3);
scores = [[1:20]' scores];

% Get actual performance
for i = 1:18
    try
        load(['subject_',num2str(i),'.mat'])
        scores(i,2)=subject.stats.total_score_neutral;
        scores(i,3)=subject.stats.total_score_aversive;
        scores(i,4)=0.5*(scores(i,2)+scores(i,3));  
        if scores(i,4)==0; 
            available(i)=0; 
            fprintf('\nSubject %d discarded',i)
        end
    catch 
        fprintf('\nSubject %d not found',i)
        available(i)=0;
    end
end

%% Plot
usable_resp = quest.resp(available,1:4)
usable_scores = scores(available,:) % only look at mean score

data = [usable_resp(:,3) usable_scores(:,3)]
corr(data)

corr_plot(usable_resp(:,3)*10,usable_scores(:,3)*100,'Subjective performance (%)',...
                                               'Actual performance* (%)')

% nothing interesting here...                                       
%% Anxiety proneness vs. omega2-differentials

% Get omegas, calculate differences
oms = parameter_plot(default_config);
%%
[~,idx] = sort(oms(3,:));
oms_sorted = oms(:,idx)

% delete all omegas where we dont have questionnaire answers
oms_sorted(:,8)=[]
oms_sorted(:,end-1)=[]

oms_d = oms_sorted(2,:)-oms_sorted(1,:);

corr_plot(oms_d',usable_resp(:,4)*10,'\Delta \omega_{2}',...
    'Subjective anxiety-proneness')





