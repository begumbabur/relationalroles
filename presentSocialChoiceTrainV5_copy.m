
function [respMat ] = presentSocialChoiceTrainV5(window,scr_rect,...
    pic_box,box1,box2,box3,box4,box5,boxp1,boxp2,boxp3,boxp4,boxp5,boxp6,boxp7,boxp8,faceAssign,curRNoise,curGNoise,...
    scene,imgFlip,curTexts,blockTime,delayOff,choiceOff,feedbackOff,trustOff)

% this function presents a single Social Choice trial. 
% Records responses and RT into respMat. 

% Psychtoolbox setup
line_height = round(scr_rect(4)/4);
Screen('TextSize', window, 28);

% Vectors of how competent and rewarding each target is in each context
%     Julie--since we don't have two contexts in our study, this will be
%     simpler--can just be two vectors, one for average group size and one 
%    for average ranking, like in the qualtrics version
rVec=[3 3 7 7 3 3 7 7];
gVec=[2 4 6 8 2 4 6 8];

% Points vector
pVec = [6 12 18 24];

% Set up place holders for points
respMat(15) = NaN; % Amount of points offered this round
respMat(16) = NaN; % Amount of points won

% Which face types are shown on this trial
faceTypes=scene;
%  Create list of face images based on the mapping from face stimulus to
%  face type, as randomized for this subject
faces=curTexts(faceAssign);
% Set up boxes to display images
source_rect=[2,2,288,216];
boxes={'box2','box3'};
boxesp={'boxp1','boxp2','boxp3','boxp4','boxp5','boxp6','boxp7','boxp8'};

% Set up me vs other feedback images
otherimg=imread('Other', 'JPEG');
meimg=imread('Me', 'JPEG');
other=Screen('MakeTexture', window, double(otherimg));
me=Screen('MakeTexture', window, double(meimg));


%%%%%%% SHOW CONTEXT DUE
% [x, y, box] = DrawFormattedText(window, contextLabels{context}, 'center','center', [255 255 255]);
% Screen('Flip', window);
%   while(GetSecs - blockTime)<cueOff;
%   end


    
 %%%%% SHOW CHOICE, RECORD RESPONSE
    Screen('DrawTexture', window, faces(scene), source_rect, box2);
   % Screen('DrawTexture', window, faces(imgFlip), source_rect, box3); 
    Screen('TextSize', window, 36);
   [x, y, box] = DrawFormattedText(window, 'Do you prefer...', 'center', line_height - 50, [255 255 255]);
Screen('Flip', window);
choiceOnset=GetSecs-blockTime; 
start = GetSecs;
% collect response
 %  At the NYU MRI center, the relevant buttons on the button box sent a 3
 %  or 4 signal to the computer; we will need to find out what this is at
 %  DNI
[respMat(1), respMat(2)] = collectResponse({'1!' '2@', 'ESCAPE'}, 2); 
rt = GetSecs - start;

%%%%%% IF THEY RESPONDED, HIGHLIGHT RESPONSE
if ~isnan(respMat(1));
    i = respMat(1);
    curBox=eval(boxes{i});
    Screen('FrameRect',window,[255 0 0],[curBox(1)-5 curBox(2)-5 curBox(3)+5 curBox(4)+5]); % Frame around box they chose
    Screen('DrawTexture', window, faces(scene), source_rect, box2);
   % Screen('DrawTexture', window, faces(imgFlip), source_rect, box3);
    [x, y, box] = DrawFormattedText(window, 'Do you prefer...', 'center', line_height - 50, [255 255 255]);
    Screen('Flip', window);
    while(GetSecs - blockTime)<choiceOff;
    end
end


 %%%%%% IF THEY RESPONDED, SET FEEDBACK AND RECORD DATA FROM THEIR CHOICE
if isnan(respMat(1))
    outcome = NaN;
    rank= NaN;
    size = NaN;
   respMat(7)=NaN; % Which face type picked
   respMat(8)=NaN; % Face stimulus picked
    curRankType=NaN;
    curGroupType=NaN;

else
    rank=round(rVec(faceTypes)+curRNoise); % rank feedback
    if rank < 1
        rank=1;
    end
    if rank > 8
        rank=8;
    end
    size=round(gVec(faceTypes)+curGNoise);  % group size
    if size < 1
        size = 1;
    end
    if size > 8
        size = 8;
    end
    %pool=round(rank/size);  % Point pool
    pointsOffered = randsample(pVec, 1);
    outcome=(rank<=size)*1; 
    curRankType=rVec(faceTypes);
    curGroupType=gVec(faceTypes);
   % curVal=vVec(context,faceTypes(respMat(1)));
  %%  oppVal=vVec(3-context,faceTypes(respMat(1)));
  
   % curTrait=gVec(context,faceTypes(respMat(1)));
 %%   oppTrait=gVec(3-context,faceTypes(respMat(1)));
     respMat(7)=faceTypes; % Which face type picked
     respMat(8)=faceAssign(faceTypes); % Face Stimulus picked
    
end

respMat(3) = rt;

respMat(4) = outcome;
respMat(5)= size;
respMat(6) = rank;
 respMat(9)=curRankType;
  %   respMat(10)=oppVal;
     respMat(10)=curGroupType;
   %  respMat(12)=oppTrait;
     respMat(11)=choiceOnset; 



%%%%%%% GIVE FEEDBACK
Screen('TextSize', window, 22);
    if isnan(respMat(1))
         [x, y, box] = DrawFormattedText(window, 'No Response!', 'center', line_height - 50, [255 0 0]);
    Screen('DrawTexture', window, faces(scene), source_rect, box2);
  %  Screen('DrawTexture', window, faces(imgFlip), source_rect, box3);
    else
        curBox=eval(boxes{i});
      Screen('DrawTexture', window, faces(faceTypes), source_rect, box5); %display who you picked
      %boxpMe=boxesp{respMat(6)};
       otherFrames=size-outcome; 
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
           % if rankVis == 0
          %       rectColor = [255 255 255]; % Create a white box
          %       Screen('FillRect', window, rectColor, [curBoxp(3) - 15, curBoxp(4) + 10, curBoxp(3) + 15, curBoxp(4)+35]);
          %   end
            
           % Frame own box if accepted
           if outcome==1
                Screen('FrameRect',window,[0 255 0],[curBoxp(1)-5 curBoxp(2)-5 curBoxp(3)+5 curBoxp(4)+5],3);
           end
           % Frame the others
          
     % boxpSize=eval(boxesp{respMat(5)}); %display group size using rectangle frame
     % Screen('FrameRect',window,[0 255 0],[boxp1(1)-5 boxp1(2)-5 boxpSize(3)+5 boxp1(4)+5],3);
      
      %this should be commented out, but right now it's just to make sure
      %display matches generated numbers
%         [x, y, box] = DrawFormattedText(window, ['Rank: ',num2str(rank)],curBox(1), curBox(4)+10, [255 255 255]);       
%         [x, y, box] = DrawFormattedText(window, ['Group Size: ',num2str(size)], curBox(1),curBox(4)+50,  [255 255 255]);
    end
     Screen('Flip', window);
   
     
     
%%%%% TELL IT HOW LONG TO HOLD FOR
while(GetSecs - blockTime)<feedbackOff
end

    
 %%%%% JITTERED DELAY
Screen('FillRect', window, [0 0 0]);
   if isnan(respMat(1))
      [x, y, box] = DrawFormattedText(window, 'No Response!', 'center', line_height - 50, [255 0 0]);
   end
Screen('Flip', window);
  while(GetSecs - blockTime)<delayOff
  end
  
  
 %%%%%% TRUST GAME
   if isnan(respMat(1))
      [x, y, box] = DrawFormattedText(window, 'No Response!', 'center', line_height - 50, [255 0 0]);
    %Screen('DrawTexture', window, faces(scene), source_rect, box2);
    %Screen('DrawTexture', window, faces(imgFlip), source_rect, box3);
    respMat(12)=NaN;
    respMat(13)=NaN;
    trustChoiceOnset=NaN;
    Screen('Flip', window);
    while(GetSecs - blockTime)<trustOff
    end
   elseif outcome==0
       Screen('FillRect', window, [0 0 0]);
      [x, y, box] = DrawFormattedText(window, 'No Game', 'center', line_height - 50, [255 0 0]);
      respMat(12)=NaN;
    respMat(13)=NaN;
    trustChoiceOnset=NaN;
        Screen('Flip', window);
        while(GetSecs - blockTime)<trustOff
        end
   else
       % If they matched, add points won
       respMat(15) = pointsOffered; 
       pointsStr = append(num2str(pointsOffered), ' POINTS');

    [x, y, box] = DrawFormattedText(window, 'What would you like to do?', 'center', line_height - 50, [255 255 255]);
    Screen('DrawTexture', window, faces(faceTypes), source_rect, box5);
    Screen('TextSize', window, 24);
    [x, y, pointBox] = DrawFormattedText(window, pointsStr , 'center', box5(4) + 40, [255 255 255]);
    %%%% SHOULD WE COUNTERBALANCE SIDE OF KEEPING/RETURNING? PROBABLY
    [x, y, returnBox] = DrawFormattedText(window, 'RETURN HALF', box5(1)-100, box5(4)+100, [255 255 255]);
    [x, y, keepBox] = DrawFormattedText(window, 'KEEP ALL', box5(3)-50, box5(4)+100, [255 255 255]);
    Screen('Flip', window);
    trustChoiceOnset=GetSecs-blockTime; 
    trustStart = GetSecs;
    % collect response
    [respMat(12), respMat(13)] = collectResponse({'1!' '2@', 'ESCAPE'},2); 
    rt = GetSecs - trustStart;
   end

   % Get points won depending on whether they returned half or not
   if respMat(12) == 1
       respMat(16) = pointsOffered / 2; % Total points earned is halved
   elseif respMat(12) == 2
       respMat(16) = pointsOffered'; % Total points earned is full
   end
   
%   Screen('Flip', window);
%     trustChoiceOnset=GetSecs-blockTime; 
%     trustStart = GetSecs;
%     rt = GetSecs - trustStart;


%%%%%% TRUST GAME HIGHLIGHT RESPONSE
 if ~isnan(respMat(12))
    i = respMat(12);
    boxesT={'returnBox','keepBox'};
    curBox=eval(boxesT{i});
    Screen('FrameRect',window,[255 0 0],[curBox(1)-20 curBox(2)-20 curBox(3)+20 curBox(4)+20]); % Frame around box they chose
    Screen('TextSize', window, 36);
    [x, y, box] = DrawFormattedText(window, 'What would you like to do?', 'center', line_height - 50, [255 255 255]);
    Screen('DrawTexture', window, faces(faceTypes), source_rect, box5);
    Screen('TextSize', window, 24);
    [x, y, pointBox] = DrawFormattedText(window, pointsStr , 'center', box5(4) + 40, [255 255 255]);
    [x, y, returnBox] = DrawFormattedText(window, 'RETURN HALF', box5(1)-100, box5(4)+100, [255 255 255]);
    [x, y, keepBox] = DrawFormattedText(window, 'KEEP ALL', box5(3)-50, box5(4)+100, [255 255 255]);
    Screen('Flip', window);
    while(GetSecs - blockTime)<trustOff
    end
    
end
respMat(14)=trustChoiceOnset; 

