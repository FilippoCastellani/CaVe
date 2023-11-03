clear all, close all, clc

% Load and convert to double the image in mri.mat (slice 10)
load('mri.mat');
pixel_size = 0.001; %[m]
MRI_gray = ind2gray(D,map);
MRI_gray = im2double(MRI_gray);
MRI_gray = squeeze(MRI_gray);
Imm = MRI_gray(:,:,10);
% Imm = MRI_gray(:,:,:,10);

figure, imshow(Imm, [], 'InitialMagnification', 'fit')

%% Compute 2D DFT
FT = fft2(Imm);
FT_sh = fftshift(FT);
[M,N] = size(Imm);

% Calculate and visualize DFT modulus with range from 0 to 10% of maximum 
% (both low frequencies in corners and in center, using 2D and 3D visualization tools)

% compute sampling frequency for each direction
fs_x = 1/pixel_size
fs_y = 1/pixel_size
FT_magn = abs(FT);
FT_sh_magn =abs(FT_sh);

Max_val = max(max(FT_magn));
% Max_val = max(FT_magn(:));


% fx_axis = linspace(0, fs_x, M);
% fy_axis = linspace(0, fs_y, N);
[ X,Y ] = meshgrid(linspace(0, fs_x, M), linspace(0, fs_y, N));
[ Xsh,Ysh ] = meshgrid(linspace(-fs_x/2, fs_x/2, M), linspace(-fs_y/2, fs_y/2, N));

figure
subplot(1,2,1), imshow(FT_magn,[0 0.1*Max_val]), xlabel('f_x [1/m]'); ylabel('f_y [1/m]'), axis on
subplot(1,2,2), imshow(FT_sh_magn,[0 0.1*Max_val]), xlabel('f_x [1/m]'); ylabel('f_y [1/m]'), axis on
impixelinfo;

figure
subplot(121), mesh(X, Y, FT_magn); xlabel('f_x [1/m]'); ylabel('f_y [1/m]'), axis tight
subplot(122), mesh(Xsh, Ysh, FT_sh_magn); xlabel('f_x [1/m]'); ylabel('f_y [1/m]'), axis tight

%% Represent amplitude in 2D using logarithmic scale
log_mag_sh = log(1+FT_sh_magn);

figure
imshow(log_mag_sh, [], 'InitialMagnification', 'fit')
colorbar, title('DFT amplitude log scale');

% Calculate and visualize DFT phase
Phase_sh = angle(FT_sh);

figure
imshow(Phase_sh, [], 'InitialMagnification', 'fit')
colorbar, title('DFT phase');

%% Compute inverse 2D-DFT to reconstruct the original image and show the 
% results together with the original image
IFT = ifft2(FT);

figure
subplot(1,2,1), imshow(Imm, []), title('Original')
subplot(1,2,2), imshow(IFT, []), title('Reconstructed')

% Calculate the sum of amplitude differences between the two results.
Amp_diff_puntual = Imm - IFT;
Amp_dif = sum(sum(Amp_diff_puntual))

