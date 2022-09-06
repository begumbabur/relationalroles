% Social Learning Training Block Phase
%
% This script will present 144 trials about who to choose in a game, and
% record participant responses. 
%Then, participants are given feedback and play the trust game


% Headers

function [respmat window scr_rect] = SocialChoiceTrainV5_copy(fid, run, faceAssign,stimMat)

% Set random number stream
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
stream = RandStream('mt19937ar','seed',sum(100*clock));
RandStream.setGlobalStream(stream);

% Set current paths
path=pwd;
path_data=[path '/data'];

% Set psychtoolbox preferences
Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames');

% Hide cursor and suppress keyboard output
 HideCursor;
 ListenChar(2); 

% Initialize inter-trial interval matrix
ITI=ones(size(stimMat,1),1);

% Set timing with jitters
%   Note that this experiment had two jittered time periods--an inter-trial
%   interval and a delay period between a cue and a response. Our
%   experiment will also have an ITI and a delay (between feedback-trust
%   game). 
%   We should go over setting up the timing together once the rest is
%   programmed, since timing is very important for fMRI. 
load jittersTrainVMv1  % Load file containing jitters
jittersTrain=jittersTrainVMv1';
ITI=jittersTrain;
delay=jittersTrain;
% Randomize lists of jitters
ITI(:,2)=randperm(length(ITI));
ITI=sortrows(ITI,2);
ITI=ITI(:,1); 
delay(:,2)=randperm(length(delay)); 
delay=sortrows(delay,2); 
delay=delay(:,1); 
% Ahead of time, create a list of when each trial needs to turn off
%cueOff(1)=12; % First cue turns off 2s after 10s ramp-up
choiceOff(1)=12; 
choiceLength=2;
feedbackLength=3;
trustLength=2;
%choiceOff(1)=cueOff(1)+delay(1)+2;  % First choice screen ends 2s after that plus delay
for i=2:size(ITI,1)
%    cueOff(i,1)=choiceOff(i-1)+ITI(i-1)+2+2; % 2s feedback + 2s cue
    %choiceOff(i,1)=cueOff(i)+delay(i)+2; % 2s choice
%     choiceOff(i,1)=choiceOff(i-1)+2+delay(i-1)+3+ITI(i-1)+2; 
    choiceOff(i,1)=choiceOff(i-1)+choiceLength+feedbackLength+delay(i-1)+...
        trustLength+ITI(i-1); 
end
feedbackOff=choiceOff+feedbackLength; %end of feedback
delayOff=choiceOff+feedbackLength+delay; %end of delay in between feedback and the trust game
trustOff=choiceOff+feedbackLength+delay+trustLength; %end of trust game
jitterOff=trustOff+ITI;


% Create orthogonal noise vectors for competence and reward
[rows columns]=size(stimMat);
noiseMat=createOrthonormal(rows,2);
rNoise=(noiseMat(:,1) * 1) / std(noiseMat(:,1)); % Set SDs
gNoise=(noiseMat(:,2) * 1) / std(noiseMat(:,2));

%%%%%% PSYCHTOOLBOX SCREEN SETUP
% Set up screens and display areas for text and pictures
res = 0;
AssertOpenGL
background = [0,0,0];

Screen('Preference', 'SkipSyncTests', 1);
screen=max(Screen('Screens'));
if numel(res) ~= 2 || any(res == 0)
    Screen('Preference', 'SkipSyncTests', 1);
    [window, scr_rect] = Screen('OpenWindow', screen);
else
   % clrdepth = 32;
    %[window, scr_rect] = Screen('OpenWindow', screen, 0, [0 0 res(1),res(2)],clrdepth);
    Screen('Preference', 'SkipSyncTests', 1);
    [window, scr_rect] = Screen('OpenWindow', screen);
end

Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 22);
Screen('TextStyle', window, 1);

% Set up dimensions for boxes to display target pictures and scales
q_h = round(scr_rect(4)/2);
q_w = round((1364*q_h)/648);
q_l = scr_rect(3)/2 - round(q_w/2);
q_r = q_l + q_w;
q_t = scr_rect(4) - q_h - 100;
q_b = q_t + q_h;
q_box = [q_l, q_t, q_r, q_b];

lPic_h = round(q_b - round(q_h / 7)) - (q_t + round(q_h / 3));
lPic_w = round((295*lPic_h)/295);
lPic_t = q_t ;%+ round(q_h / 3);
lPic_b = lPic_t + lPic_h;
lPic_l = round(q_l + round(q_w / 20));
lPic_r = lPic_l + lPic_w;
lPic_box = [lPic_l, lPic_t, lPic_r, lPic_b];

rPic_h = round(q_b - round(q_h /4)) - (q_t + round(q_h / 3));
rPic_w = round((295*rPic_h)/295);
rPic_t = q_t ;%+ round(q_h / 3);
rPic_b = rPic_t + rPic_h;
rPic_r = round(q_r - round(q_w / 20));
rPic_l = rPic_r - rPic_w;
rPic_box = [rPic_l, rPic_t, rPic_r, rPic_b];

q_l_box = [lPic_l - lPic_w/10, lPic_t - lPic_h / 2, lPic_r + lPic_w / 10, lPic_b + lPic_h / 10];
q_r_box = [rPic_l - rPic_w/10, rPic_t - rPic_h / 2, rPic_r + rPic_w / 10, rPic_b + rPic_h / 10];

box_h=rPic_h;
box_w=rPic_w;
box_t=q_t;
box_b=box_t+box_h;

% Create box tops and bottoms for the second row
box_t2 = box_b + 20;
box_b2 = box_t2 + box_h;

scr_width=scr_rect(3)-scr_rect(1);
boxes_w=box_w*4;

leftover_scr_width=scr_width-boxes_w;
edges_width=leftover_scr_width-60;
edge_width=edges_width/2;

box1_l=scr_rect(1)+edge_width;
box1_r=box1_l + box_w;
box1=[box1_l, box_t, box1_r, box_b];

box2_l=box1_r+20;
box2_r=box2_l + box_w;
box2=[box2_l, box_t, box2_r, box_b];

box3_l=box2_r+20;
box3_r=box3_l + box_w;
box3=[box3_l, box_t, box3_r, box_b];

box4_l=box3_r+20;
box4_r=box4_l + box_w;
box4=[box4_l, box_t, box4_r, box_b];

box5_b=box_t+55;
box5_t=(box_t-box_b)+box5_b;
box5_l=(box2_l+box3_l)/2;
box5_r=box5_l + box_w;
box5=[box5_l, box5_t, box5_r, box5_b];

%%% Boxes for the 2nd row of 4 faces
box6 = [box1_l, box_t2, box1_r, box_b2];
box7 = [box2_l, box_t2, box2_r, box_b2];
box8 = [box3_l, box_t2, box3_r, box_b2];
box9 = [box4_l, box_t2, box4_r, box_b2];

littleDudeW = round((222*box_h)/233); % Replace 288 and 216 by the pixels of the images

boxp1_l=scr_rect(1)+edge_width;
boxp1_r=boxp1_l + box_w/2;
boxp1_t=box_t+(box_h/2);
boxp1=[boxp1_l, boxp1_t, boxp1_r, box_b];

boxp2_l=boxp1_r+10;
boxp2_r=boxp2_l + box_w/2;
boxp2=[boxp2_l, boxp1_t, boxp2_r, box_b];

boxp3_l=boxp2_r+10;
boxp3_r=boxp3_l + box_w/2;
boxp3=[boxp3_l, boxp1_t, boxp3_r, box_b];

boxp4_l=boxp3_r+10;
boxp4_r=boxp4_l + box_w/2;
boxp4=[boxp4_l, boxp1_t, boxp4_r, box_b];

boxp5_l=boxp4_r+10;
boxp5_r=boxp5_l + box_w/2;
boxp5=[boxp5_l, boxp1_t, boxp5_r, box_b];

boxp6_l=boxp5_r+10;
boxp6_r=boxp6_l + box_w/2;
boxp6=[boxp6_l, boxp1_t, boxp6_r, box_b];

boxp7_l=boxp6_r+10;
boxp7_r=boxp7_l + box_w/2;
boxp7=[boxp7_l, boxp1_t, boxp7_r, box_b];

boxp8_l=boxp7_r+10;
boxp8_r=boxp8_l + box_w/2;
boxp8=[boxp8_l, boxp1_t, boxp8_r, box_b];

%%%%%% SET UP IMAGES OF AVATARS TODO REPLACE CHARS
w1img=imread('scene1', 'JPG');
w2img=imread('scene1_flip', 'JPG');
w3img=imread('scene2', 'JPG');
w4img=imread('scene2_flip', 'JPG');
w5img=imread('scene3', 'JPG');
w6img=imread('scene3_flip', 'JPG');
%w7img=imread('male7', 'JPG');
%w8img=imread('male8', 'JPG');

faces={'scene1','scene1_flip','scene2','scene2_flip', 'scene3', 'scene3_flip'}; % TODO REPLACE CHARS
%, 'male7', 'male8'

% Create images
w1=Screen('MakeTexture', window, double(w1img));
w2=Screen('MakeTexture', window, double(w2img));
w3=Screen('MakeTexture', window, double(w3img));
w4=Screen('MakeTexture', window, double(w4img));
w5=Screen('MakeTexture', window, double(w5img));
w6=Screen('MakeTexture', window, double(w6img));
%w7=Screen('MakeTexture', window, double(w7img));
%w8=Screen('MakeTexture', window, double(w8img));

texturePtrs=[w1 w2 w3 w4 w5 w6];
%w7 w8
% Setup practice faces
pracfaces={'temp1', 'temp2', 'temp3', 'temp4', 'temp5', 'temp6'};

% Read practice images
p1img = imread('temp1', 'JPG');
p2img = imread('temp2', 'JPG');
p3img = imread('temp3', 'JPG');
p4img = imread('temp4', 'JPG');
p5img = imread('temp5', 'JPG');
p6img = imread('temp6', 'JPG');
%p7img = imread('temp7', 'JPG');
%p8img = imread('temp8', 'JPG');

% Setup practice image textures
temp1 = Screen('MakeTexture', window, double(p1img));
temp2 = Screen('MakeTexture', window, double(p2img));
temp3 = Screen('MakeTexture', window, double(p3img));
temp4 = Screen('MakeTexture', window, double(p4img));
temp5 = Screen('MakeTexture', window, double(p5img));
temp6 = Screen('MakeTexture', window, double(p6img));
%temp7 = Screen('MakeTexture', window, double(p7img));
%temp8 = Screen('MakeTexture', window, double(p8img));

% Put textures in an array
ptexts = [temp1 temp2 temp3 temp4 temp5 temp6];

%Read instructions from text file
    instruct_text=text2cells('instructionsTrain.txt');
% Start psychtoolbox screen with black background
 Screen('FillRect', window, [0 0 0]);
    Screen('Flip', window);

    % If it's the first run, show the instructions
if run == 1   

    Screen('FillRect', window, [0 0 0]);
    Screen('Flip', window);
    
    dispTextThenWait(window,instruct_text,1,scr_rect); 
    
    drawImage(faces{1},window,[2,2,288,216], box1)
    drawImage(faces{2},window,[2,2,288,216], box2)
    drawImage(faces{3},window,[2,2,288,216], box3)
    drawImage(faces{4},window,[2,2,288,216], box4)
    drawImage(faces{5},window,[2,2,288,216], box6)
    drawImage(faces{6},window,[2,2,288,216], box7)
   % drawImage(faces{7},window,[2,2,288,216], box8)
   % drawImage(faces{8},window,[2,2,288,216], box9)
    [nx, ny, textbounds] = DrawFormattedText (window, 'Press any key to continue.', 'center',box8(4)+50, [255 255 255]);
    Screen('Flip', window);
    WaitSecs(.5);
   while 1
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                % Return keyboard control
                ListenChar(0);

                disp('Task aborted!');
                Screen('CloseAll');
            else
                break
            end
        end
    end
  
    dispTextThenWait(window,instruct_text,2,scr_rect);
    dispTextThenWait(window,instruct_text,3,scr_rect);
    dispTextThenWait(window,instruct_text,4,scr_rect);
    dispTextThenWait(window,instruct_text,5,scr_rect);
    dispTextThenWait(window,instruct_text,6,scr_rect);
    dispTextThenWait(window,instruct_text,7,scr_rect);
    dispTextThenWait(window,instruct_text,8,scr_rect);
    dispTextThenWait(window,instruct_text,9,scr_rect);

    % Set up me vs other feedback images
otherimg=imread('Other', 'JPEG');
meimg=imread('Me', 'JPEG');
other=Screen('MakeTexture', window, double(otherimg));
me=Screen('MakeTexture', window, double(meimg));
source_rect=[2,2,288,216];
rank = 3;

    %% Example of Feedback where Rank is VISIBLE

    % Draw feedback
    boxesp={'boxp1','boxp2','boxp3','boxp4','boxp5','boxp6','boxp7','boxp8'};

    % Draw face
    drawImage(pracfaces{1},window,[2,2,288,216], box5);

    otherFrames= 4; 
           frameNums= [1 3 6 7];
         for r=1:7 %display ranks
            curBoxp=eval(boxesp{r+(1*(r>=4))});
            Screen('DrawTexture', window, other, source_rect, curBoxp);
            if ismember(r,frameNums)
                Screen('FrameRect',window,[0 255 0],[curBoxp(1)-5 curBoxp(2)-5 curBoxp(3)+5 curBoxp(4)+5],3);
            end
         end
            %if boxesp{r}==boxpMe
            curBoxp=eval(boxesp{4});
            Screen('DrawTexture', window, me, source_rect, curBoxp);
                 % Display rank underneath
           [x, y, box] = DrawFormattedText(window, ['Rank: ',num2str(rank)],curBoxp(1) + 15, curBoxp(4)+30, [255 255 255]);

           % Frame own box
                Screen('FrameRect',window,[0 255 0],[curBoxp(1)-5 curBoxp(2)-5 curBoxp(3)+5 curBoxp(4)+5],3);         

                % Add text description of the example
                [nx, ny, textbounds] = DrawFormattedText (window, 'You are the BLUE avatar, while the other players are the GREY avatars. Your position on the screen never changes throughout the game.', 'center',box8(4)-80, [255 255 255], 65);

                % Continue text
            [nx, ny, textbounds] = DrawFormattedText (window, 'Press any key to continue.', 'center',box8(4)+50, [255 255 255]);
            Screen('Flip', window);
            WaitSecs(0.5);

            while 1
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                % Return keyboard control
                ListenChar(0);

                disp('Task aborted!');
                Screen('CloseAll');
            else
                break
            end
        end
    end

    %% Second page of example feedback
    % Draw face
    drawImage(pracfaces{1},window,[2,2,288,216], box5);

    otherFrames= 4; 
           frameNums= [1 3 6 7];
         for r=1:7 %display ranks
            curBoxp=eval(boxesp{r+(1*(r>=4))});
            Screen('DrawTexture', window, other, source_rect, curBoxp);
            if ismember(r,frameNums)
                Screen('FrameRect',window,[0 255 0],[curBoxp(1)-5 curBoxp(2)-5 curBoxp(3)+5 curBoxp(4)+5],3);
            end
         end
            %if boxesp{r}==boxpMe
            curBoxp=eval(boxesp{4});
            Screen('DrawTexture', window, me, source_rect, curBoxp);
                 % Display rank underneath
           [x, y, box] = DrawFormattedText(window, ['Rank: ',num2str(rank)], curBoxp(1) + 15, curBoxp(4)+30, [255 255 255]);

           % Frame own box
                Screen('FrameRect',window,[0 255 0],[curBoxp(1)-5 curBoxp(2)-5 curBoxp(3)+5 curBoxp(4)+5],3);         

                % Add text description of the example
                [nx, ny, textbounds] = DrawFormattedText (window, 'If you and your chosen Decider MATCHED, you will see a GREEN SQUARE around your BLUE ICON. In this case, you were MATCHED to play with this player.', 'center',box8(4)-80, [255 255 255], 65);

                % Continue text
            [nx, ny, textbounds] = DrawFormattedText (window, 'Press any key to continue.', 'center',box8(4)+50, [255 255 255]);
            Screen('Flip', window);
            WaitSecs(0.5);

            while 1
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                % Return keyboard control
                ListenChar(0);

                disp('Task aborted!');
                Screen('CloseAll');
            else
                break
            end
        end
    end

    %% Third page of example feedback
    % Draw face
    drawImage(pracfaces{1},window,[2,2,288,216], box5);

    otherFrames= 4; 
           frameNums= [1 3 6 7];
         for r=1:7 %display ranks
            curBoxp=eval(boxesp{r+(1*(r>=4))});
            Screen('DrawTexture', window, other, source_rect, curBoxp);
            if ismember(r,frameNums)
                Screen('FrameRect',window,[0 255 0],[curBoxp(1)-5 curBoxp(2)-5 curBoxp(3)+5 curBoxp(4)+5],3);
            end
         end
            %if boxesp{r}==boxpMe
            curBoxp=eval(boxesp{4});
            Screen('DrawTexture', window, me, source_rect, curBoxp);
                 % Display rank underneath
           [x, y, box] = DrawFormattedText(window, ['Rank: ',num2str(rank)], curBoxp(1) + 15, curBoxp(4)+30, [255 255 255]);

           % Frame own box
                Screen('FrameRect',window,[0 255 0],[curBoxp(1)-5 curBoxp(2)-5 curBoxp(3)+5 curBoxp(4)+5],3);         

                % Add text description of the example
                [nx, ny, textbounds] = DrawFormattedText (window, 'There are also green boxes around the other Responders who matched this round. Including the box around you, there are FIVE green boxes in total, and so for this round the Decider received FIVE MATCHES from the computer.', 'center',box8(4)-80, [255 255 255], 65);

                % Continue text
            [nx, ny, textbounds] = DrawFormattedText (window, 'Press any key to continue.', 'center',box8(4)+50, [255 255 255]);
            Screen('Flip', window);
            WaitSecs(0.5);

            while 1
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                % Return keyboard control
                ListenChar(0);

                disp('Task aborted!');
                Screen('CloseAll');
            else
                break
            end
        end
    end

    %% Fourth page of example feedback
    % Draw face
    drawImage(pracfaces{1},window,[2,2,288,216], box5);

    otherFrames= 4; 
           frameNums= [1 3 6 7];
         for r=1:7 %display ranks
            curBoxp=eval(boxesp{r+(1*(r>=4))});
            Screen('DrawTexture', window, other, source_rect, curBoxp);
            if ismember(r,frameNums)
                Screen('FrameRect',window,[0 255 0],[curBoxp(1)-5 curBoxp(2)-5 curBoxp(3)+5 curBoxp(4)+5],3);
            end
         end
            %if boxesp{r}==boxpMe
            curBoxp=eval(boxesp{4});
            Screen('DrawTexture', window, me, source_rect, curBoxp);
                 % Display rank underneath
           [x, y, box] = DrawFormattedText(window, ['Rank: ',num2str(rank)], curBoxp(1) + 15, curBoxp(4)+30, [255 255 255]);

           % Frame own box
                Screen('FrameRect',window,[0 255 0],[curBoxp(1)-5 curBoxp(2)-5 curBoxp(3)+5 curBoxp(4)+5],3);         

                % Add text description of the example
                [nx, ny, textbounds] = DrawFormattedText (window, 'Underneath your blue avatar is the RANK that the Decider gave you for this round. Here, you were ranked 3RD.', 'center',box8(4)-80, [255 255 255], 65);

                % Continue text
            [nx, ny, textbounds] = DrawFormattedText (window, 'Press any key to continue.', 'center',box8(4)+50, [255 255 255]);
            Screen('Flip', window);
            WaitSecs(0.5);

            while 1
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(KbName('ESCAPE'))
                % Return keyboard control
                ListenChar(0);

                disp('Task aborted!');
                Screen('CloseAll');
            else
                break
            end
        end
    end

    dispTextThenWait(window,instruct_text,10,scr_rect);
    dispTextThenWait(window,instruct_text,11,scr_rect);

    %% Example of Feedback where Rank is HIDDEN
    % Draw face
   % Screen('DrawTexture', window, faces{1}, source_rect, box5);
   drawImage(pracfaces{2},window,[2,2,288,216], box5);

    % Draw feedback
    boxesp={'boxp1','boxp2','boxp3','boxp4','boxp5','boxp6','boxp7','boxp8'};

    otherFrames= 4; 
           frameNums=randperm(7,otherFrames);
         for r=1:7 %display ranks
            curBoxp=eval(boxesp{r+(1*(r>=4))});
            Screen('DrawTexture', window, other, source_rect, curBoxp);
            if ismember(r,frameNums)
                Screen('FrameRect',window,[0 255 0],[curBoxp(1)-5 curBoxp(2)-5 curBoxp(3)+5 curBoxp(4)+5],3);
            end
         end
            %if boxesp{r}==boxpMe
            curBoxp=eval(boxesp{4});
            Screen('DrawTexture', window, me, source_rect, curBoxp);
                 % Display rank underneath
           [x, y, box] = DrawFormattedText(window, ['Rank: ',num2str(rank)],curBoxp(1) + 15, curBoxp(4)+30, [255 255 255]);

                 rectColor = [255 255 255]; % Create a white box
                 Screen('FillRect', window, rectColor, [curBoxp(3) - 15, curBoxp(4) + 10, curBoxp(3) + 15, curBoxp(4)+35]);

                 % Frame own box
                Screen('FrameRect',window,[0 255 0],[curBoxp(1)-5 curBoxp(2)-5 curBoxp(3)+5 curBoxp(4)+5],3); 

                % Add text description of the example
                [nx, ny, textbounds] = DrawFormattedText (window, 'You were matched to play with this player (green box around blue avatar), but you do not know how the player ranked you (white box covering rank). The computer gave the player 5 matches.', 'center',box8(4)-80, [255 255 255], 65);

                 [nx, ny, textbounds] = DrawFormattedText (window, 'Press any key to continue.', 'center',box8(4)+50, [255 255 255]);
                 Screen('Flip', window);
                 WaitSecs(.5);
   while 1
        [keyIsDown,~,keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(KbName('ESCAPE'))

                % Return keyboard control
                 ListenChar(0);

                disp('Task aborted!');
                Screen('CloseAll');
            else
                break
            end
        end
   end
   
    dispTextThenWait(window,instruct_text,12,scr_rect);
    dispTextThenWait(window,instruct_text,13,scr_rect);

    %% Practice round of binary choice

    % Setup stuff
    line_height = round(scr_rect(4)/4);
    boxes={'box2','box3'};

    % Show options
    drawImage(pracfaces{3},window,[2,2,288,216], box2);
    drawImage(pracfaces{4},window,[2,2,288,216], box3);
   % Screen('TextSize', window, 36);
   [x, y, box] = DrawFormattedText(window, 'Do you prefer...', 'center', line_height - 50, [255 255 255]);
Screen('Flip', window);

    % Collect response
    [respMat(1), respMat(2)] = collectResponse({'1!' '2@', 'ESCAPE'}, inf);

    % Highlight response
if ~isnan(respMat(1));
    i = respMat(1);
    curBox=eval(boxes{i});
    Screen('FrameRect',window,[255 0 0],[curBox(1)-5 curBox(2)-5 curBox(3)+5 curBox(4)+5]); % Frame around box they chose
    drawImage(pracfaces{3},window,[2,2,288,216], box2);
    drawImage(pracfaces{4},window,[2,2,288,216], box3);
    [x, y, box] = DrawFormattedText(window, 'Do you prefer...', 'center', line_height - 50, [255 255 255]);
    Screen('Flip', window);
    WaitSecs(0.5);
end

    dispTextThenWait(window,instruct_text,14,scr_rect);
    dispTextThenWait(window,instruct_text,15,scr_rect);
    Screen('TextSize', window, 18);
    dispTextThenWait(window,instruct_text,16,scr_rect);
    Screen('TextSize', window, 22);
    dispTextThenWait(window,instruct_text,17,scr_rect);

    %% Multiple practice rounds

% Practice timing
pracChoiceOff(1) = 4;

for i = 2:5
    pracChoiceOff(i,1)=pracChoiceOff(i-1)+choiceLength+feedbackLength+2+...
        trustLength; 
end

pracFeedbackOff=pracChoiceOff+feedbackLength; %end of feedback
pracDelayOff=pracChoiceOff+feedbackLength+ 1; %end of delay in between feedback and the trust game
pracTrustOff=pracChoiceOff+feedbackLength+ 1 +trustLength; %end of trust game

% Create mat to hold practice trials
pracmat = zeros(5, 3);
pleftface = [1 2 3 4 1];
prightface = [2 1 4 3 2];
prankvis = [1 1 0 0 1];
pblocktime = GetSecs;

% Draw a fixation cross
Screen('FillRect', window, [0 0 0]);
    [ready_x, ready_y, ready_box] = DrawFormattedText(window, '+', 'center', 'center', [255 255 255],((scr_rect(3)-100)/12));
    Screen('Flip', window);
    while(GetSecs-pblocktime)<3;
     end

     % Loop through 5 practice trials
    for idx = 1:5
        % Call presentSocialChoiceTrainV5 function to show a trial
        [pracmat(idx,[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16])] = presentSocialChoiceTrainV5(window,...
            scr_rect,q_box,box1,box2,box3,box4,box5,boxp1,boxp2,boxp3,boxp4,boxp5,boxp6,boxp7,boxp8,...
            faceAssign, 1, 1, pleftface(idx), prightface(idx), prankvis(idx),...
            ptexts,pblocktime,pracDelayOff(idx),pracChoiceOff(idx),pracFeedbackOff(idx),pracTrustOff(idx));

        % Show a fixation cross
    Screen('FillRect', window, [0 0 0]);
    [ready_x, ready_y, ready_box] = DrawFormattedText(window, '+', 'center', 'center', [255 255 255],((scr_rect(3)-100)/12));
    Screen('Flip', window);
   
    % Tell fixation cross when to end
    while(GetSecs-pblocktime)< 3;
    end

    end
       
        Screen('FillRect', window, [0 0 0]);
[ready_x, ready_y, ready_box] = DrawFormattedText(window,...
   'That concludes the practice. Please wait for final instructions from the experimenter. If you have any remaining questions about the game, you will be able to ask them shortly.', 'center', 'center', [255 255 255],((scr_rect(3)-100)/12));
Screen('Flip', window);
% Holding period (waits for experimenter to press "=")
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
   
else   %If run > 1, give rest break 
    dispTextThenWait(window,instruct_text,20,scr_rect); 
end    

 % put up wait screen and wait for first trigger
Screen('FillRect', window, [0 0 0]);
[ready_x, ready_y, ready_box] = DrawFormattedText(window, 'Get Ready.', 'center', 'center', [255 255 255],((scr_rect(3)-100)/12));
Screen('Flip', window);
% Trigger (takes ~)
%    Julie--do you know what the trigger key is at DNI? 
while (1)
    [responded, when, what] = KbCheck(-1); % should respond to either keyboard or button box when button are attached
    
    if responded == 1
        button = KbName(what);
        if what(KbName('ESCAPE'))

            % Return keyboard control
            ListenChar(0);

            Screen('CloseAll');
            error('Experiment aborted by user!');
        elseif strcmp(button(1),'5');
            while KbCheck()
                
            end
            break
        end
        
    end
end




%% Start Experiment
respmat = zeros(144,3); % Set up empty matrix to record data

nTrials=size(stimMat,1);
blockTime = GetSecs;  % Establish start time of block
% Rampup (shows fixation cross for 10s while magnet reachers equilibrium)
Screen('FillRect', window, [0 0 0]);
    [ready_x, ready_y, ready_box] = DrawFormattedText(window, '+', 'center', 'center', [255 255 255],((scr_rect(3)-100)/12));
    Screen('Flip', window);
     while(GetSecs-blockTime)<10;
     end
         
for idx = 1:nTrials % trial loop TODO add rank-invis info
       
    
     scene=stimMat(idx,1);  % Face type to show on left
     imgFlip=stimMat(idx,2);  % Face type to show on right
  %   rankVis = stimMat(idx, 3);      Indicate whether rank is visible or not
    
     curRNoise=rNoise(idx);         % Noise to add to reward this trial
     curGNoise=gNoise(idx,:);       % Noise to add to competence on this trial
     curTexts=texturePtrs(1:6);
        respmat(idx,21) = GetSecs - blockTime; % trial start relative to beginning of block 

        % Call presentSocialChoiceTrainV5 function to show a trial
        [respmat(idx,[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16])] = presentSocialChoiceTrainV5(window,...
            scr_rect,q_box,box1,box2,box3,box4,box5,boxp1,boxp2,boxp3,boxp4,boxp5,boxp6,boxp7,boxp8,...
            faceAssign,curRNoise, curGNoise, scene, imgFlip,...
            curTexts,blockTime,delayOff(idx),choiceOff(idx),feedbackOff(idx),trustOff(idx));
      
     % Record the rest of the data that is not saved above or in the
     % presentation script
     respmat(idx,17)=scene;
     respmat(idx,18)=imgFlip;
     respmat(idx,19)=ITI(idx);
     respmat(idx,20)=delay(idx);
     
     % Show a fixation cross
    Screen('FillRect', window, [0 0 0]);
    [ready_x, ready_y, ready_box] = DrawFormattedText(window, '+', 'center', 'center', [255 255 255],((scr_rect(3)-100)/12));
    Screen('Flip', window);
   
    % Tell fixation cross when to end
    while(GetSecs-blockTime)<jitterOff(idx);
    end
         
    
    % OUTPUT
    eval(['cd ' path_data]);
    fprintf(fid, '%f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \n',...
        respmat(idx,1), respmat(idx,2), respmat(idx,3), respmat(idx,4), respmat(idx,5), respmat(idx,6), respmat(idx,7), respmat(idx,8),...
        respmat(idx,9), respmat(idx,10), respmat(idx,11), respmat(idx,12),respmat(idx,13), respmat(idx,14), respmat(idx,15), respmat(idx,16),... 
        respmat(idx,17), respmat(idx,18), respmat(idx,19), respmat(idx,20), respmat(idx, 21));
    eval(['cd ' path]);
    
end

% Rampdown (to let BOLD signal from last trials peak)
Screen('FillRect', window, [0 0 0]);
    [ready_x, ready_y, ready_box] = DrawFormattedText(window, '+', 'center', 'center', [255 255 255],((scr_rect(3)-100)/12));
    Screen('Flip', window);
    WaitSecs(10);
    
end
