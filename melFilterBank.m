function [featureMatrix]=melFilterBank(audioFrames)
   global numOfFilters numOfSamples numOfFeatures;
  hamm=hamming(numOfSamples);
  labels=audioFrames(:,end);
  audioFrames=audioFrames(:,1:end-1)*diag(hamm);
   fFrames=rfft(audioFrames,[],2);
   absFFrames=abs(fFrames(:,1:160));
   clear fFrames
   lowFreq=0;
   highFreq=8000;
   [filterBank,mc,mn,mx]=melbankm(numOfFilters,numOfSamples,16000,lowFreq,highFreq,'hty');
   filterBank=filterBank(:,1:160);
   filterBank=filterBank';
     %plot the filterbank
   figure(2);
   x=linspace(lowFreq,highFreq,numOfSamples/2);
   for i=1:size(filterBank,2)
       hold on ;
       plot(x,filterBank(:,i));
       title('filterbank')
       xlabel('melFreq');
   end
   
   figure(3);
   x=linspace(0,16000,160);
   plot(x, absFFrames(1,:));
   preDCT=(absFFrames.^2)*filterBank;
%    labels=audioFrames(:,end);
%    audioFrames=audioFrames(:,1:end-1);
%    [absFFrames,freqPoints] = periodogram(audioFrames',[],numOfSamples,16000); 
%    filterBank = melfilter(numOfFilters,freqPoints);
%    filterBank=filterBank';  
%    preDCT=absFFrames'*filterBank;
%    
   dctm=@(N,M)(sqrt(2.0/M)*cos(repmat([1:N].',1,M).*repmat(pi*([1:M]-0.5)/M,N,1)));
   DCT=dctm(numOfFeatures,numOfFilters);
   featureMatrix=log10(preDCT)*DCT';
   %featureMatrix=dct(preDCT,numOfFeatures,2,'Type',3);
   featureMatrix=[featureMatrix, labels];
end   
    



function [featureMatrix]=oldmelFilterBank(audioFrames)
   global numOfFilters numOfSamples numOfFeatures;
  hamm=hamming(numOfSamples);
  labels=audioFrames(:,end);
  audioFrames=audioFrames(:,1:end-1); % *diag(hamm);
   fFrames=fft(audioFrames,numOfSamples,2);
   absFFrames=abs(fFrames);
   absFFrames=absFFrames(:,1:numOfSamples/2);
   clear fFrames
   lowFreq=0;
   highFreq=8000;
   melLowFreq=melScale(lowFreq);
   melHighFreq=melScale(highFreq);
   melPoints=linspace(melLowFreq,melHighFreq,(numOfFilters+2));
   freqPoints=invMelScale(melPoints);
   bin=floor((numOfSamples+1).*freqPoints/16000);
   filterBank=zeros(numOfSamples/2,numOfFilters);
   for m=1:(numOfFilters)      
       fM=bin(m);
       f=bin(m+1);     
       fP=bin(m+2);
       for k=fM:f
          filterBank(k+1,m)=(k-fM)/(f-fM);
       end
       for k=f:fP
          filterBank(k+1,m)=(fP-k)/(fP-f);
       end
   end
   filterBank=filterBank(1:160,:);
     %plot the filterbank
   figure(2);
   x=linspace(melLowFreq,melHighFreq,numOfSamples/2);
   for i=1:size(filterBank,2)
       hold on ;
       plot(x,filterBank(:,i));
   end
   title('filterbank')
   xlabel('melFreq');
   figure(3);
   x=linspace(0,16000,160);
   plot(x, absFFrames(1,:));
   preDCT=(absFFrames.^2)*filterBank;   
   dctm=@(N,M)(sqrt(2.0/M)*cos(repmat([1:N].',1,M).*repmat(pi*([1:M]-0.5)/M,N,1)));
   DCT=dctm(numOfFeatures,numOfFilters);
   featureMatrix=log10(preDCT)*DCT';
   %featureMatrix=dct(preDCT,numOfFeatures,2,'Type',3);
   featureMatrix=[featureMatrix, labels];
end   
    





function [melFrequency]=melScale(freq)
melFrequency=zeros(size(freq));
    for i=1:(length(freq))
        if freq > 1000
          melFrequency(i)=  2595*log10(1+(freq(i)/700));
        else
            melFrequency(i)=freq(i);
        end
    end
end

function [freq]=invMelScale(melFrequency)
freq=zeros(size(melFrequency));
    for i=1:(length(melFrequency))
        if melFrequency(i) > 1000
          freq(i)= 700*(10.^(melFrequency(i)/2595)-1);
        else
          freq(i)=melFrequency(i);
        end
    end  
end

