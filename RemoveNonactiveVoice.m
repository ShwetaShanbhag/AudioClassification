function [filteredAudio]=RemoveNonactiveVoice(audiofile,plotFlag)
[yn,Fsn] = audioread(audiofile);

%sound(yn,Fsn);
frame_duration=0.1;
frame_len=frame_duration*Fsn;
%k=floor((y-frame_duration)/(Fs*0.001))+1;
lengh_sound=length(yn);
num_frame=floor(lengh_sound/frame_len);
threshold_h1=0.02;
%setup for the new signal
new_sound=zeros(lengh_sound,1);
count=0;
%extract the frames
for k=1:num_frame 
    frame=yn((k-1)*frame_len+1:frame_len*k);
    max_value=max(frame);
    if(max_value>threshold_h1)
        %this frame has active voice
        count=count+1;
        new_sound((count-1)*frame_len+1:frame_len*count)=frame;
    end
end
%plot the audio
if (plotFlag)
    figure(1);
    hold on
    plot(yn);
    plot(new_sound);
end
%sound(new_sound,Fsn);
filteredAudio=new_sound(1:frame_len*count);
