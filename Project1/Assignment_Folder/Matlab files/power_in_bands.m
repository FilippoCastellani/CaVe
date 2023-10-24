function [D,T,A,B] = power_in_bands(epoch,fs,win_len,OL,nfft)
win_samples=win_len*fs;                                        %getting win len in number of sampleswin len must be in seconds
win = hann(win_samples);                                       %getting window
[pxx,f] = pwelch(epoch,win,OL,nfft,fs);
fD= (f>1.3) &(f<=4);
fT= (f>4)   &(f<=8);
fA= (f>8)   &(f<=13);
fB= (f>13)  &(f<=30);

D = sum(pxx(fD));
T = sum(pxx(fT));
A = sum(pxx(fA));
B = sum(pxx(fB));