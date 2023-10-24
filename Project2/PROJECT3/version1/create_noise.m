%function create_noise (I, coord)
% add noise to original image
% process original image and noise image
% compute surface on one slice for each and compute difference

% load data
clear all
DATA=load('MRIdata.mat');
volume=DATA.vol;

%% extract slice
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

%% add noise
I=sag_proj_rotated;
var_local=0.02;
I_gnoise=imnoise(I,'gaussian');
I_spnoise=imnoise(I,'salt & pepper');

figure Name Noisecomparison

subplot(321),imshow(sag_proj_rotated,'InitialMagnification', 'fit');title(tit);
subplot(322),imhist(sag_proj_rotated); title('Histogram');
subplot(323),imshow(I_gnoise,'InitialMagnification', 'fit');title(tit);
subplot(324),imhist(I_gnoise); title('Histogram');
subplot(325),imshow(I_spnoise,'InitialMagnification', 'fit');title(tit);
subplot(326),imhist(I_spnoise); title('Histogram');

%% crop and fill original
figure Name CropTheOriginalImage
[sag_crop, rectcrop]=imcrop(I);
close('CropTheOriginalImage');
FIL_orig=imfill(sag_crop);

figure Name FilledImage
subplot(121);imshow(imcrop(I,rectcrop));title('Original');
subplot(122);imshow(FIL_orig,'InitialMagnification','fit');title('Filled');
%% crop and fill gaussian noise image
figure Name CropTheGaussianNoiseImage
[sag_crop_gnoise]=imcrop(I_gnoise,rectcrop);
close('CropTheGaussianNoiseImage');
FIL_gnoise=imfill(sag_crop_gnoise);
figure; imshow(FIL_gnoise,'InitialMagnification','fit');title('Gaussian');

%% crop and fill salt and pepper image
figure Name CropTheSaltandPepperImage
[sag_crop_spnoise]=imcrop(I_spnoise,rectcrop);
close('CropTheSaltandPepperImage');
FIL_spnoise=imfill(sag_crop_spnoise);
figure; imshow(FIL_spnoise,'InitialMagnification','fit');title('SaltPepper');

%% show crop and filled images
figure Name FilledImage
subplot(311);imshow(imcrop(FIL_orig,'InitialMagnification','fit'));title('Original');
subplot(312);imshow(FIL_gnoise,'InitialMagnification','fit');title('Gaussian');
subplot(313);imshow(FIL_spnoise,'InitialMagnification','fit'); title('SaltandPepper')
%% enhance histogram
n=linspace(0,1,256);
coeff=10;
g_coeff=0.1;
sig_k = t(n,coeff,g_coeff);
[val, bin_x]=imhist(FIL_orig);
trsf_img=setup_my_image(FIL_orig,sig_k,255);
figure Name TransformedOriginal
subplot(121);imshow(FIL_orig,'InitialMagnification','fit');title('Transformed original');
subplot(122);imhist(FIL_orig); title('Trasnformed Original Hist');

[val, bin_x]=imhist(FIL_gnoise);
trsf_img=setup_my_image(FIL_gnoise,sig_k,255);
figure Name GaussianNoise
subplot(121);imshow(FIL_gnoise,'InitialMagnification','fit');title('Gaussian');
subplot(122);imhist(FIL_gnoise); title('Gaussian Hist');

[val, bin_x]=imhist(FIL_spnoise);
trsf_img=setup_my_image(FIL_spnoise,sig_k,255);
figure Name SaltPepperNoise
subplot(121);imshow(FIL_spnoise,'InitialMagnification','fit');title('SaltPepper');
subplot(122);imhist(FIL_spnoise); title('SaltPepper Hist');

%% compare 
figure Name GuassianComparison;
imshowpair(FIL_orig,FIL_gnoise);
figure Name SaltPepperComparison
imshowpair(FIL_orig,FIL_spnoise);

%% Binarize
bnrz_orig=imbinarize(FIL_orig);
bnrz_gnoise=imbinarize(FIL_gnoise);
bnrz_spnoise=imbinarize(FIL_spnoise);
figure Name BinarizingProcedure_OtsusMethod
subplot(311);imshowpair(bnrz_orig,FIL_orig,'montage')
%comparing with the non-transformed version of the image
subplot(312);imshowpair(bnrz_gnoise,FIL_gnoise,'montage')
subplot(313);imshowpair(bnrz_spnoise,FIL_spnoise,'montage')

%% Binary vector Orig
figure Name MousePickOrig
imshow(bnrz_orig,'InitialMagnification','fit');title('Original');
[ms_x ms_y]=getpts();
bin_vec_orig=bwselect(bnrz_orig,ms_x,ms_y);
imshow(bin_vec_orig,'InitialMagnification','fit');title('Selection');
%% Binary vector Gauss
figure Name MousePickGauss
imshow(bnrz_gnoise,'InitialMagnification','fit');title('Gaussian');
%[ms_x ms_y]=getpts();
bin_vec_gnoise=bwselect(bnrz_gnoise,ms_x,ms_y);
imshow(bin_vec_gnoise,'InitialMagnification','fit');title('G Selection');
%% Binary vector S&P
figure Name MousePickSaltPepper
imshow(bnrz_spnoise,'InitialMagnification','fit');title('SaltPepper');
%[ms_x ms_y]=getpts();
bin_vec_spnoise=bwselect(bnrz_spnoise,ms_x,ms_y);
imshow(bin_vec_spnoise,'InitialMagnification','fit');title('SP Selection');
%% area differences
orig_area= sum(sum(bin_vec_orig))
gnoise_area=sum(sum(bin_vec_gnoise))
spnoise_area=sum(sum(bin_vec_spnoise))
gnoise_diff=orig_area-gnoise_area
spnoise_diff=orig_area-spnoise_area
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
%figure Name Transformation
%plot(scaled_comb);
%xlim([0 max]);
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