%% Load EEG
clc
load record;
EEG = record ;
fs = 512; %sampling frequency
t = (0:1/fs:length(EEG)/fs - 1/fs); %time vector

%% Filtering (notch)
EEGd=double(EEG);
dn = designfilt('bandstopiir','FilterOrder',20,'HalfPowerFrequency1',59.8,'HalfPowerFrequency2',60.2,'DesignMethod','butter','SampleRate',fs);
EEG_f=filtfilt(dn,EEGd);

%% Filtering pass band
load ('pb_G.mat');
load ('pb_SOS.mat');
EEG_filt=filtfilt(pb_SOS,pb_G,EEG_f);
EEG_filt=EEG_filt-mean(EEG_filt);

%% Plotting notch filter
fvtool(dn);
%% Plotting band filter
fvtool(pb_SOS);
%%  Band Power detection & Graph
epoch_len = 30; %seconds
win_len = 10;    %seconds
epoch_samples = epoch_len*fs;
win_samples = win_len*fs;
OL = 0.5;
nfft=2^nextpow2(win_samples);

jump=0.9; %in portion of epoch we are jumping
epoch_jump=epoch_samples*jump;
k = 1:epoch_jump:(size(EEG_filt,2));
t_k = 0:epoch_jump:(size(EEG_filt,2)-epoch_jump);
t_k = t_k*(1/fs);

for i=1:1:(size(k,2)-1)
    [D(i),T(i),A(i),B(i)]= power_in_bands(EEG_filt(k(i):k(i+1)),fs,win_len,OL,nfft);
    disp(strcat('Processing % = ',num2str(i/(size(k,2)-1)*100)))
end

figure('Name','PIB + EEG signal','NumberTitle','off')
pibe(1) = subplot(2,1,1); plot(t,EEG_filt,'b','linewidth',1); title('Filtered segment of EEG');
pibe(2) = subplot(2,1,2); 
plot(t_k,D,'r','linewidth',0.5); title('PIB of EEG'); 
hold on
plot(t_k,T,'b','linewidth',0.5); 
plot(t_k,A,'g','linewidth',0.5); 
plot(t_k,B,'c','linewidth',0.5);
legend('delta','theta','alpha','beta')
xlabel('time [s]'); linkaxes(pibe,'x'); %(axis linking)
axis([0 1800 min(EEG_filt) max(EEG_filt)]);

%% HYPNOGRAM PLOT
COLL=[D;T;A;B];
[M,I]=max(COLL,[],1);
m=60; %optimal
threshold=10; % optimal
R=indices_conversion(I,0);
R_rem=indices_conversion(I,1);
Z=sliding_assignment(R,m,threshold);
Z_rem=sliding_assignment(R_rem,m,threshold);

t_h=t_k*(1/3600);
figure;
hold on;
%plot(t_h,Z_rem*-1,'g','linewidth',7);
%plot(t_h,R*-1,'k','linewidth',0.1);
plot(t_h,Z*-1,'b','linewidth',2);
legend('REM','indices','sliding priority')
title(strcat('m value = ',string(m),' threshold value= ',string(threshold)))
yticks([-3 -2 -1 -0.9])
yticklabels({'Stage 3&4','Stage 2','Stage 1','REM'})
axis([-0.5 9.5 -4.5 -0.5]);