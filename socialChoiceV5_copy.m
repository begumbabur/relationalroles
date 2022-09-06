function socialChoiceV5_copy(n)

% create data files
%  one for learning phase
%  one for test phase
path=pwd;
path_data=[path '/data'];               
subNum=n;
n = num2str(n);
eval(['cd ' path_data])
fid = 1;
fid2=2;
fid3=3;
filename = [(n), 'Train.txt'];
filename2=[(n), 'Test.txt'];
filename3=[(n), 'Trust.txt'];
if exist(filename) == 2
    eval(['cd ' path]);
    warning = 'That filename already exists.  Use a different number to avoid overwriting.';
    return
else
    fid = fopen(filename, 'w');
    fid2 = fopen(filename2,'w');
    fid3 = fopen(filename3,'w');
end
eval(['cd ' path]);

% run script


% Reset random stream 
%      In some versions of Matlab: 
stream = RandStream('mt19937ar','seed',sum(100*clock));
RandStream.setGlobalStream(stream);
% In other versions of Matlab: 
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
% Randomize which face stimulus (1-8) gets assigned to which role; save this for later analysis 
faceAssign=randperm(6);
save(['S' n 'faceAssign'],'faceAssign'); 

%%%%%% SET UP STIMULUS LIST
load facepairsTrain
%facepairs=repmat(facepairsTrain,2,1);

for blockIdx=1:6
    facepairs=shuffleMat(facepairsTrain);
    stimBlockTrain{blockIdx}=facepairs;
    stimBlockTrain{blockIdx}=[stimBlockTrain{blockIdx} ones(length(stimBlockTrain{blockIdx}),1)];
end


%%%%% TRAINING PHASE LOOP
% Loop through training phase across 7 discrete runs
%    (Julie: You will probably be able to have 3 or 4 runs, depending how
%    long each trial takes in the final version)

for run = 2
    Screen('CloseAll');
    % On each run, call the Training Phase script
    [respmat window scr_rect] = SocialChoiceTrainV5_copy(fid,run, faceAssign,stimBlockTrain{run});
end
 
Screen('CloseAll');

%%%%%%

% 
% %%%%%%%% SET UP TEST PHASE STIMULI
% load facepairsTest
% facepairsTest=repmat(facepairsTest,2,1);
% facepairsTest=shuffleMat(facepairsTest);
% 
% for blockIdx=1:3
%     last=40*blockIdx;
%     first=last-39;
%     stimBlockTest{blockIdx}=facepairsTest(first:last, :);
% end
% 
% %%%%% RUN THE TEST PHASE
% % Loop through test phase in 4 runs here
% for run=1:3
%     Screen('CloseAll');
%     % Each run calls the SocialChoiceTestV5 script
% [respmat window scr_rect] = SocialChoiceTestV5(fid2, run, stimBlockTest{run});
% end
% 
% %%%%%%%% SET UP TRUST GAME PHASE STIMULI
% load facepairsTrust
% facepairsTrust=repmat(facepairsTrust,2,1);
% 
% 
% for blockIdx=1:2
%     facepairsTrust=shuffleMat(facepairsTrust);
%     stimBlockTrust{blockIdx}=facepairsTrust;
% end

% 
% %%%%% RUN THE TRUST GAME
% for run=1:2
%     Screen('CloseAll');
%     % Each run calls the SocialChoiceTrustV5 script
%     [respmat window scr_rect] = SocialChoiceTrustV5(fid3,run,stimBlockTrust{run});
% end
% Screen('CloseAll');


%%%%%%%%%%%%%% FIGURE OUT HOW MUCH MONEY PEOPLE WON BASED ON THEIR DATA
eval(['cd ' path_data])
trainData=textread(filename);
% testData = textread(filename2);
eval(['cd ' path]);

% Setup screen
Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames');
screen=max(Screen('Screens'));
[window, scr_rect] = Screen('OpenWindow', screen);

% Screen aesthetics
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 22);
Screen('TextStyle', window, 1);

% Calculate and display bonus won
totalPointsWon = sum(trainData(:, 16), 'omitnan');
disp(totalPointsWon);
bonus = round(totalPointsWon / 1000, 2);
disp(bonus);
pwText = append('You have won a total of ', num2str(totalPointsWon), ' points in your session today.');
bonusText = append('This translates to a bonus of $', num2str(bonus), '.'); 
disp(pwText);
disp(bonusText);

Screen('FillRect', window, [0 0 0]);
Screen('Flip', window);
DrawFormattedText(window, pwText, 'center', 'center', [255 255 255]);
DrawFormattedText(window, bonusText, 'center', 450, [255 255 255]);
Screen('Flip', window);

while (1)
    [responded, when, what] = KbCheck(-1); % should respond to either keyboard or button box when button are attached
   
    if responded == 1
        button = KbName(what);
        if what(KbName('ESCAPE'))
            % Return keyboard control
            ListenChar(0);

            Screen('CloseAll');
            error('Experiment aborted by user!');
        elseif strcmp(button(1),'=');
            while KbCheck()
               
            end
            break
        end
       
    end
end

% Show cursor and allow keyboard output
ListenChar(0);
ShowCursor;

%cond=rem(subNum,2)+1;

%rVec=[3 3 7 7];
%gVec=[2 4 6 8];
% winTrain=trainData(:,6);
%  testData=testData(~isnan(testData(:,9)),:);
%   choiceTest=testData(:,9);
%  for row=1:size(testData,1)
%  choicePool=testData(row,7+(testData(row,1)-1));
%  context=testData(row,11);
%  if context==1 | context==2
%  winTest(row,1)=choicePool*gVec(context,choiceTest(row));
%  else
%      verbWin=choicePool*gVec(1,choiceTest(row));
%      mathWin=choicePool*gVec(2,choiceTest(row));
%      relTotal=verbRel(context)+mathRel(context);
%      mathRelProp=mathRel(context)/relTotal;
%      verbRelProp=verbRel(context)/relTotal;
%      winTest(row,1)=verbWin*verbRelProp + mathWin*mathRelProp; 
%  end
%  end
% winTrials=winTrain;
% winTrials=winTrials(~isnan(winTrials));
% winnings=sum(winTrials)*2;
% 
% winTestSum=sum(winTest);
% winningsTotal=winnings+winTestSum; 

% CLOSE PSYCHTOOLBOX AND DISPLAY WINNINGS ON CONSOLE
Screen('CloseAll');
% display(['Winnings: ' num2str(winningsTotal) ' points = ' num2str(winningsTotal/70) 'cents.'])