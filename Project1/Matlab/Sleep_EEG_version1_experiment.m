%% Resetting enviroment
clear all;
clc;
%% Load EEG
hour = 3600;
load record;
load record&filter
EEG = record ;
fs = 512; %sampling frequency 250Hz
new_seconds = 2*hour;            %how many seconds of EEG do we want ?
trim_point = new_seconds*fs;
EEG=EEG(1:trim_point);                       %reducing EEG length

t = (0:1/fs:length(EEG)/fs - 1/fs); %time vector

%% Filtering
EEGd=double(EEG);
dn = designfilt('bandstopiir','FilterOrder',20,'HalfPowerFrequency1',59.8,'HalfPowerFrequency2',60.2,'DesignMethod','butter','SampleRate',fs);
dpb = designfilt('bandpassfir','FilterOrder',2,'CutoffFrequency1',0.5,'CutoffFrequency2',90,'SampleRate',fs);
EEG_f=filtfilt(dn,EEGd);
EEG_filt=filtfilt(dpb,EEG_f);

%% Plot 1
figure; sb(1)=subplot(2,1,1); plot(t,EEG); title('original signal (with noise)');
        sb(2)=subplot(2,1,2); plot (t,EEG_filt); title('filtered signal');
linkaxes(sb,'x');

%% Plot 2

figure;
sig(1) = subplot(2,1,1); plot(t,EEG,'b','linewidth',1); title('Original segment of EEG');
sig(2) = subplot(2,1,2); plot(t,EEG_filt,'r','linewidth',1); title('Filtered segment of EEG');
xlabel('time [s]'); linkaxes(sig,'x'); %(axis linking)
axis([0 60 min(EEG) max(EEG)]);

%%  Band Power detection & Graph
epoch_len = 30; %seconds
win_len = 15;    %seconds
epoch_samples = epoch_len*fs;
win_samples = win_len*fs;
OL = 0.5;
nfft=2^nextpow2(win_samples);

k = 1:epoch_samples:(size(EEG,2));
t_k = 0:epoch_samples:(size(EEG,2)-epoch_samples);
t_k = t_k*(1/fs);

for i=1:1:(size(k,2)-1)
    [D(i),T(i),A(i),B(i)]= power_in_bands(EEG(k(i):k(i+1)),fs,win_len,OL,nfft);
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
axis([0 1800 min(EEG) max(EEG)]);

%% Prevalence
length_movwin=10; %VA CONVERTITO IN SECONDI E NON IN NUMERO LIBERO
COLL=[D;T;A;B];
[M,I]=max(COLL,[],1);

I_mov=movmean(I,length_movwin);
figure('Name','PIB + EEG signal','NumberTitle','off')
pibe(1) = subplot(2,1,1); plot(t,EEG_filt,'b','linewidth',1); title('Filtered segment of EEG');
pibe(2) = subplot(2,1,2); 
plot(t_k,D,'r','linewidth',0.5); title('PIB of EEG'); 
hold on
plot(t_k,T,'b','linewidth',0.5);
plot(t_k,A,'g','linewidth',0.5); 
plot(t_k,B,'c','linewidth',0.5);
plot(t_k,M,'b--o','color','y','linewidth',0.3);
plot(t_k,I*50,'--','color','k','linewidth',1.5)
plot(t_k,I_mov*50,'-*','color','k','linewidth',2)
legend('delta','theta','alpha','beta','maximum','indices','movmean')
xlabel('time [s]'); linkaxes(pibe,'x'); %(axis linking)
axis([0 t_k(end) 0 300]);

%% HYPNOGRAM PLOT

hold off
R=indices_conversion(I);
R=movmean(R,8);
R=ceil(R);
figure; 
plot(R*-1);
axis([0 length(R)+300 -4 0]);

%% Power in bands Graph
figure('Name','Measured Data','NumberTitle','off');
plot(D,'r');
hold on
plot(T,'b');
plot(A,'g');
plot(B,'c');
title('Power in bands');
legend('delta','theta','alpha','beta')
%% Percentage minus mean Graph
TOT=D+T+A+B;
figure;
plot(D./TOT - mean(D./TOT),'r');
hold on
plot(T./TOT - mean (T./TOT),'b');
plot(A./TOT - mean (A./TOT),'g');
plot(B./TOT - mean (B./TOT),'c');
title('Percentage minus mean')
legend('delta','theta','alpha','beta')

%% Percentage Graph
TOT=D+T+A+B;
figure;
plot(D./TOT,'r');
hold on
plot(T./TOT,'b');
plot(A./TOT,'g');
plot(B./TOT,'c');
title('Percentage graph')
legend('delta','theta','alpha','beta')
