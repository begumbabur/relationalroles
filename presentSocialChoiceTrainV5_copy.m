
function [respMat ] = presentSocialChoiceTrainV5_copy(window,scr_rect,...
    pic_box,box1,box2,box3,box4,box5,boxp1,boxp2,boxp3,boxp4,boxp5,boxp6,boxp7,boxp8,faceAssign,curRNoise,curGNoise,...
    scene,imgFlip,curTexts,curTextsBorders, curTextsStocks, blockTime,delayOff,choiceOff,feedbackOff,trustOff)

% this function presents a single Social Choice trial. 
% Records responses and RT into respMat. 

% Psychtoolbox setup
line_height = round(scr_rect(4)/4);
Screen('TextSize', window, 28);

% Vectors of how competent and rewarding each target is in each context
%     Julie--since we don't have two contexts in our study, this will be
%     simpler--can just be two vectors, one for average group size and one 
%    for average ranking, like in the qualtrics version

% Points vector
pVec = [6 12 18 24];

% Set up place holders for points
respMat(15) = NaN; % Amount of points offered this round
respMat(16) = NaN; % Amount of points won

% Which face types are shown on this trial
faceTypes=scene;
%  Create list of face images based on the mapping from face stimulus to
%  face type, as randomized for this subject

faces=curTexts;
% Set up boxes to display images
source_rect=[2,2,295,295];
boxes={'box2','box3'};

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
   % Screen('FrameRect',window,[255 0 0],[curBox(1)-5 curBox(2)-5 curBox(3)+5 curBox(4)+5]); % Frame around box they chose
    Screen('DrawTexture', window, faces(scene), source_rect, box2);
   % Screen('DrawTexture', window, faces(imgFlip), source_rect, box3);
    [x, y, box] = DrawFormattedText(window, 'Do you prefer...', 'center', line_height - 50, [255 255 255]);
    Screen('Flip', window);
    while(GetSecs - blockTime)<choiceOff;
    end
end


 %%%%%% IF THEY RESPONDED, SET FEEDBACK AND RECORD DATA FROM THEIR CHOICE
if isnan(respMat(1))
  % outcome = NaN;
   respMat(7)=NaN; % Which face type picked
   respMat(8)=NaN; % Face stimulus picked
    %pool=round(rank/size);  % Point pool
    pointsOffered = randsample(pVec, 1);
  
   % curVal=vVec(context,faceTypes(respMat(1)));
  %%  oppVal=vVec(3-context,faceTypes(respMat(1)));
  
   % curTrait=gVec(context,faceTypes(respMat(1)));
 %%   oppTrait=gVec(3-context,faceTypes(respMat(1)));
     respMat(7)=faceTypes; % Which face type picked
end

respMat(3) = rt;
%respMat(4) = outcome;
  %   respMat(10)=oppVal;   
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
        if scene == 1
            if respMat(1) == 1
                newscene = 4
                stock = 2
            elseif respMat(1) == 2
                newscene = 3
                stock = 3
            end
        elseif scene == 2
             if respMat(1) == 1
                newscene = 1
                stock = 3
            elseif respMat(1) == 2
                newscene = 2
                stock = 2
             end
         
        elseif scene == 3
             if respMat(1) == 1
                newscene = 7
                stock = 2
            elseif respMat(1) == 2
                newscene = 8
                stock = 3
             end
         elseif scene == 4
             if respMat(1) == 1
                newscene = 6
                stock = 3
            elseif respMat(1) == 2
                newscene = 5
                stock = 2
             end   
         elseif scene == 5
             if respMat(1) == 1
                newscene = 11
                stock = 4
            elseif respMat(1) == 2
                newscene = 12
                stock = 1
             end
         elseif scene == 6
             if respMat(1) == 1
                newscene = 10
                stock = 1
            elseif respMat(1) == 2
                newscene = 9
                stock = 4
             end
        end
      Screen('DrawTexture', window, curTextsBorders(newscene), source_rect, box2); %display who you picked
      %boxpMe=boxesp{respMat(6)};
        
 
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
   else
       Screen('DrawTexture', window, curTextsStocks(stock), source_rect, box2); %display the assigned stock instead 
    Screen('Flip', window);
    WaitSecs(3);
   end


    
end

