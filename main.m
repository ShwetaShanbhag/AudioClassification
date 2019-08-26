



cd '/Users/iamshweta/SemesterIII/LABII/patRecDat/forStudents/timit/train';
%%
global numOfFeatures numOfModes numOfFilters numOfSamples audioFreq gamma;
numOfFeatures=15;
numOfModes=49;
numOfFilters=22;
numOfSamples=320;
audioFreq=16000;
gamma=0;
samOverlap=audioFreq*0.01;
num=1;
plotFlag=1;
%%
curDir=pwd;
listing = dir(curDir);
frames=[];
testFrames=[];
speakerMapping=struct([]);

for idx=1:length(listing)
    folder1=[listing(idx).folder,'/',listing(idx).name];
    if isfolder(folder1) && ~(sum(strcmp(listing(idx).name,{'.','..'})))
        cd(folder1);
        listing1 = dir(folder1);
        for idx1=1:length(listing1)
            folder2=[listing1(idx1).folder,'/',listing1(idx1).name];
            if isfolder(folder2) && ~(sum(strcmp(listing1(idx1).name,{'.','..'})))
                speakerMapping(num).name=listing1(idx1).name;
                speakerMapping(num).value=num;
                cd(folder2);
                listing2 = dir(folder2);
                for idx2=1:length(listing2)
                    audioFile=[listing2(idx2).folder,'/',listing2(idx2).name];
                   if isfile(audioFile)
                        [y,fs]=audioread(audioFile);
                        y=RemoveNonactiveVoice(audioFile,plotFlag);
                        plotFlag=0;
                        n =ceil((length(y)-numOfSamples)/(samOverlap)+1);
                        P= zeros(numOfSamples+1,n);
                        start=1;finish=numOfSamples;
                        for k=0:n-1
                            P(1:numOfSamples,k+1)=y(start:finish);
                            start=start+samOverlap;
                            finish=finish+samOverlap;
                            if finish>length(y)
                                y(length(y)+1:finish)=0;
                            end
                            P(numOfSamples+1,k+1)=speakerMapping(num).value;
                        end
%                       
%                         framePower=sum(pow2(P(1:320,:)),1)/numOfSamples;
%                        
%                         noisePower=sum(framePower(1:9))/9;
% 
%                         P=P(:,framePower>noisePower*1.0002);
                        
                        if (idx2==3)
                            testFrames=horzcat(testFrames, P);
                        else
                            frames=horzcat(frames, P);
                        end
                    end
                end
                num=num+1;
            end
        end
    end
end
audioFrames=frames';
testAudioFrames=testFrames';
%% cleanup
clear frames testFrames listing listing1 listing2 folder1 folder2 idx idx2 idx1 y P k num 

%fprintf("%s",'Press any key to continue');
%pause;
cd '/Users/iamshweta/SemesterIII/LABII/patRecDat/forStudents/timit/train';
%% extract features through melfilters
[featureMatrix]=melFilterBank(audioFrames);
[featureTestMatrix]=melFilterBank(testAudioFrames);
%% GMM
load /Users/iamshweta/SemesterIII/LABII/patRecDat/forStudents/ubm/UBM_GMMNaive_MFCC_Spectrum0to8000Hz.mat;
trueLabels=featureTestMatrix(:,end);
concatSpeakerProbablities=zeros(size(featureTestMatrix,1),length(speakerMapping));
for speaker=1:length(speakerMapping)
    b=featureMatrix((featureMatrix(:,end)==speakerMapping(speaker).value),1:numOfFeatures);
    [speakerProbabilities]=getSpeakerModel(b,means,var,weights,featureTestMatrix(:,1:end-1));
    concatSpeakerProbablities(:,speaker)=speakerProbabilities;
end
%% probablities of different speaker model
maxProbablities=zeros(length(speakerMapping),length(speakerMapping));
for speaker=1:length(speakerMapping)
    idx=(trueLabels==speakerMapping(speaker).value);
    maxProbablities(speaker,:)=sum(log10(concatSpeakerProbablities(idx,:)),1);
end
[~,predictedLabels]=max(maxProbablities,[],2) ;
[trueLabels, ia, ic]=unique(trueLabels,'stable');
acc=sum(predictedLabels==trueLabels)/length(predictedLabels);
clear b speakerProbabilities 
