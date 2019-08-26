

function [speakerProbabilities]=getSpeakerModel(b,means,var,weights,testAudioFrames)
    %[weighedpdf,priorUBM]=findPriorUBM(b,means,var,weights);
    
    [newMeans,newCovs,newWeights]= findPostProb(b,means,var,weights);
    obj = gmdistribution(newMeans,newCovs,newWeights);
    speakerProbabilities = pdf(obj,testAudioFrames);
end

% function [weighedpdf,priorUBM]=findPriorUBM(b,means,var,weights)
% % b is audioframes over one speaker
%     global numOfModes ;  
%     weighedpdf=zeros(length(b),numOfModes);
%     for m=1:numOfModes
%         cov=diag(var(m,:));
%         pb=mvnpdf(b,means(m,:),cov);
%         weighedpdf(:,m)=weights(m)*pb;        
%     end
%     priorUBM=sum(weighedpdf,2);

%     cov=zeros(1,numOfFeatures,numOfModes);
%     for m=1:numOfModes
%         cov(:,:,m)=var(m,:);
%     end
%     obj = gmdistribution(means,cov,weights);
%     weighedpdf = pdf(obj,b);
%     priorUBM=sum(weighedpdf,2);
%end

function [newMeans,newCovs,newWeights]=findPostProb(b,means,var,weights)
    global numOfModes numOfFeatures gamma;
    cov=zeros(1,numOfFeatures,numOfModes);
    for m=1:numOfModes
        cov(:,:,m)=var(m,:);
    end
    obj = gmdistribution(means,cov,weights);
    priorUBM = pdf(obj,b);
    
    newMeans=zeros(numOfModes,numOfFeatures);
    newCovs=zeros(1,numOfFeatures,numOfModes);
    weightHat=zeros(numOfModes,1);
    newWeights=zeros(1,numOfModes);
    postProb=posterior(obj,b);
    for idx=1:numOfModes
        %postProb=weighedpdf(:,idx)./priorUBM;
        
        meanHat=(postProb(:,idx)'*b)/sum(postProb(:,idx));
        covHat=zeros(numOfFeatures);
        for idx1=1:size(b,1)  
            covHat=covHat+postProb(idx1,idx)*b(idx1,:)'*b(idx1,:);
        end
        covHat=(covHat/sum(postProb(:,idx)))-(meanHat'*meanHat);
        weightHat(idx)=sum(postProb(:,idx))/numel(postProb(:,idx));
        alpha=sum(postProb(:,idx))/(sum(postProb(:,idx))+gamma);
        newMeans(idx,:)=(alpha)*meanHat+(1-alpha)*means(idx,:);
        newCovs(:,:,idx)=(diag((alpha)*covHat+(1-alpha)*diag(var(idx,:))))';
        newWeights(idx)=(alpha)*weightHat(idx)+(1-alpha)*weights(idx);
        
    end
    if (round(sum(weightHat))~=1)
        fprintf("%s %d",['sum of weights(timit) is not equal to 1', round(sum(weightHat))]);
       % pause;
    end
    
    if (round(sum(newWeights))~=1)
        fprintf("%s %d",['sum of updated weights(timit+ubm)is not equal to 1', round(sum(newWeights))]);
        %pause;
    end
end