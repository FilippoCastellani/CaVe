clear;
clc;
%% Load the MRIdata file
DATA=load('MRIdata.mat');
volume=DATA.vol;
%% Explore the data
volumeViewer(volume)

%% Extracting axial slices
ax_sl=70;
tit=sprintf('Slice %d',ax_sl);

figure Name AxialView
title(tit)
imshow(volume(:,:,ax_sl),'InitialMagnification', 'fit')

%% Create a video
reframe=reshape(volume,[256 256 1 112]);

map = colormap('gray');
mri_movie = immovie(reframe,map); 
implay(mri_movie);

%% Create a sagittal video
s_reframe=permute(reframe,[4 2 3 1]);

s_mri_movie = immovie(s_reframe,map); 
implay(s_mri_movie);

%% Create a coronal video
c_reframe=permute(reframe,[4 1 3 2]);

c_mri_movie = immovie(c_reframe,map); 
implay(c_mri_movie);


%% Extracting sagittal slices
sag_sl=135;
tit=sprintf('Slice %d',sag_sl);

sag_proj=volume(sag_sl,:,:);
sag_proj_size=size(sag_proj);

x_size=sag_proj_size(2);
y_size=sag_proj_size(3);


sag_proj_reshaped=reshape(sag_proj,[x_size y_size]);
T0 = maketform('affine',[0 -2.5; 1 0; 0 0]);
sag_proj_rotated=imtransform(sag_proj_reshaped,T0,'cubic');

figure Name SagittalView

subplot(121),imshow(sag_proj_rotated,'InitialMagnification', 'fit');title(tit);
subplot(122),imhist(sag_proj_rotated); title('Histogram');

%% Filling the image with imfill() once it has been cropped
figure Name CropTheImage
[sag_crop, rectcrop]=imcrop(sag_proj_rotated);
close('CropTheImage');
FIL=imfill(sag_crop);

figure Name FilledImage
subplot(121);imshow(imcrop(sag_proj_rotated,rectcrop));title('Original');
subplot(122);imshow(FIL,'InitialMagnification','fit');title('Filled');


sag_proj_rotated=FIL;
%% Enhancing the histogram

n=linspace(0,1,256);
coeff=10;
g_coeff=0.1;
sig_k = t(n,coeff,g_coeff);

[val, bin_x]=imhist(sag_proj_rotated);

trsf_img=setup_my_image(sag_proj_rotated,sig_k,255);

figure Name TransformComparison
subplot(221);imshow(sag_proj_rotated,'InitialMagnification','fit');title('Original');
subplot(222);imshow(trsf_img,'InitialMagnification','fit');title('Trasformed');
subplot(223);imhist(sag_proj_rotated); title('Original Histogram');
subplot(224);imhist(trsf_img); title('New Histogram');

%% Showing histogram effect
figure Name HistogramTransform
subplot(121); plot(val*(1/max(val))); hold on; plot(sig_k); hold off;
subplot(122); plot(val_t);
%subplot(223); imshow()
%subplot(224); imshow()

%% Varying Coefficent Sigmoid

figure Name Modified_Sigmoid
hold on;
plot(x,'color',[0 0 1],'LineWidth',2,'DisplayName','x');
plot(t(n,2.8),'color',[0 0 0.9],'LineWidth',1,'DisplayName','k=2.8');
plot(t(n,3),'color',[0.2 0 0.8],'LineWidth',1,'DisplayName','k=3');
plot(t(n,4),'color',[0.3 0 0.7],'LineWidth',1,'DisplayName','k=4');
plot(t(n,6),'color',[0.4 0 0.6],'LineWidth',1,'DisplayName','k=6');
plot(sig_k,'color',[1 0 0],'LineWidth',2,'DisplayName','k= coefficent');
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

%% Image Setup Function

function t_img = setup_my_image(img, comb, max)
scaled_comb=round(comb*max);
figure
plot(scaled_comb)
ret=[];
[original_x,original_y]=size(img);
img_vectorized=reshape(img,[1],[]);
for i=1:1:(length(img_vectorized))
    intensity=img_vectorized(i);
    new_intensity=scaled_comb(intensity+1);
    ret(i)=new_intensity*(1/max);
end
t_img=reshape(ret,original_x,original_y);
end