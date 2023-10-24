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
T0 = maketform('affine',[0 -1.4; 0.9375 0; 0 0]);
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

%% Enhancing the histogram

n=linspace(0,1,256);
coeff=10;
g_coeff=0.1;
sig_k = t(n,coeff,g_coeff);

[val, bin_x]=imhist(FIL);

trsf_img=setup_my_image(FIL,sig_k,255);

figure Name TransformComparison
subplot(221);imshow(FIL,'InitialMagnification','fit');title('Original');
subplot(222);imshow(trsf_img,'InitialMagnification','fit');title('Trasformed');
subplot(223);imhist(FIL); title('Original Histogram');
subplot(224);imhist(trsf_img); title('New Histogram');

%% Making comparison
figure Name Comparison
imshowpair(trsf_img,FIL,'montage');

%% Binarizing the image
bnrz=imbinarize(trsf_img);
figure Name BinarizingProcedure_OtsusMethod
subplot(211);imshowpair(bnrz,trsf_img,'montage')
%comparing with the non-transformed version of the image
subplot(212);imshowpair(imbinarize(sag_crop),sag_crop,'montage')
%% Get binary vector selcting with mouse
figure Name MousePick
imshow(bnrz,'InitialMagnification','fit');title('Binarized');
[ms_x, ms_y]=getpts();
bin_vec=bwselect(bnrz,ms_x,ms_y);
imshow(bin_vec,'InitialMagnification','fit');title('Selection');
[vec_row,vec_col]=find(bin_vec==1);
%% Get geometrical center
center_row=round(mean(vec_row));
center_col=round(mean(vec_col));

null_scope=zeros(size(bin_vec));
null_scope(center_row,:)=1;
null_scope(:,center_col)=1;
figure Name GeometricalCenter
imshowpair(null_scope,bin_vec);
%% Get variances
var_row=var(vec_row);
var_col=var(vec_col);
sv_row=round(3*sqrt(var_row));
sv_col=round(3*sqrt(var_col));
bound_row=[center_row+sv_row,center_row-sv_row];
bound_col=[center_col+sv_col,center_col-sv_col];

null_bound=zeros(size(bin_vec));
null_bound(bound_row(1),:)=1;
null_bound(bound_row(2),:)=1;
null_bound(:,bound_col(1))=1;
null_bound(:,bound_col(2))=1;
figure Name GeometricalStd
imshowpair(null_bound,bin_vec);

%% Show Coronal Slice corresponding to mu_x

x_center=center_row;
up_left_corner_x=round(rectcrop(1));
world_center_x=up_left_corner_x+x_center;

cor_tit=sprintf('Slice %d',world_center_x);

cor_proj=volume(:,world_center_x,:);
cor_proj_size=size(cor_proj);

cor_x_size=cor_proj_size(1);
cor_y_size=cor_proj_size(3);

cor_proj_reshaped=reshape(cor_proj,[cor_x_size cor_y_size]);
T1 = maketform('affine',[0 -1.4; 0.9375 0; 0 0]);
cor_proj_rotated=imtransform(cor_proj_reshaped,T1,'cubic');

figure Name CoronaryProjection
imshow(cor_proj_rotated);

%% Get y boundaries
%% Replicate Area estimation process
 %1 
 %2
%% Add noise to the volume
%% Repeat everything
%% Compare results



%% Varying Coefficent Sigmoid

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

%% Image Setup Function

function t_img = setup_my_image(img, comb, max)
scaled_comb=round(comb*max);
figure Name Transformation
plot(scaled_comb)
xlim([0 max])
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