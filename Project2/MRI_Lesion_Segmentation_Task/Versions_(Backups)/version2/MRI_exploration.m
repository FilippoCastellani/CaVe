%% Load the MRIdata file
DATA=load('MRIdata.mat');
volume=DATA.vol;

%% Explore the data
volumeViewer(volume)

%% Create an axial video
reframe=reshape(volume,[256 256 1 112]);

map = colormap('gray');
mri_movie = immovie(reframe,map); 
%implay(mri_movie);

v_axial=VideoWriter('axial.avi');
open(v_axial);
writeVideo(v_axial,mri_movie)
close(v_axial)
%% Create a sagittal video
s_reframe=permute(reframe,[4 2 3 1]);

s_mri_movie = immovie(s_reframe,map); 
%implay(s_mri_movie);

v_sagittal=VideoWriter('sagittal.avi');
open(v_sagittal);
writeVideo(v_sagittal,s_mri_movie)
close(v_sagittal)

%% Create a coronal video
c_reframe=permute(reframe,[4 1 3 2]);

c_mri_movie = immovie(c_reframe,map); 
implay(c_mri_movie);

v_coronal=VideoWriter('coronal.avi');
open(v_coronal);
writeVideo(v_coronal,c_mri_movie)
close(v_coronal)


%% Varying Coefficent Sigmoid
n=linspace(0,1,256);
figure Name Modified_Sigmoid
hold on;
plot(n,'color',[0 0 1],'LineWidth',2,'DisplayName','x');
plot(t(n,2.8,0.1),'color',[0 0 0.9],'LineWidth',1,'DisplayName','k=2.8 g=0.1');
plot(t(n,3,0.2),'color',[0.2 0 0.8],'LineWidth',1,'DisplayName','k=3 g=0.2');
plot(t(n,4,0.15),'color',[0.3 0 0.7],'LineWidth',1,'DisplayName','k=4 g=0.15');
plot(t(n,6,0.1),'color',[0.4 0 0.6],'LineWidth',1,'DisplayName','k=6 g=0.1');
plot(sig_k,'color',[1 0 0],'LineWidth',2,'DisplayName','k= coefficent g= coefficent');
legend()
xlim([0 255]);
hold off;

%% Modified Sigmoid Definition
function y=t(x,k,g)
y = ((1+g)./(1+exp((k*0.5)-k*(x))))-g/2;
for i=1:1:length(y)
    if (y(i)>1)
        y(i)=1;
    elseif(y(i)<=0)
        y(i)=0;
    end
end
end
