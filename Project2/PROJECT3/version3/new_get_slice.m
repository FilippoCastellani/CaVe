clear
clc
%% Load the MRIdata file
DATA=load('MRIdata.mat');
volume=DATA.vol;
%%

coronal=get_slice(100,'sagittal',volume);
imshow(coronal)
%% Get_Slice Function
function sl_img=get_slice(sl_num,orientation,volume)
switch orientation
    case 'sagittal'
        sag_proj=volume(sl_num,:,:);
        sag_proj_size=size(sag_proj);

        x_size=sag_proj_size(2);
        y_size=sag_proj_size(3);

        sag_proj_reshaped=reshape(sag_proj,[x_size y_size]);
        sag_proj_rotated=imrotate(sag_proj_reshaped,90)
        sl_img=sag_proj_rotated;

    case 'axial'
        sl_img=volume(:,:,sl_num);
    case 'coronal'
        cor_proj=volume(:,sl_num,:);
        cor_proj_size=size(cor_proj);

        cor_x_size=cor_proj_size(1);
        cor_y_size=cor_proj_size(3);


        cor_proj_reshaped=reshape(cor_proj,[cor_x_size cor_y_size]);
        cor_proj_rotated=imrotate(cor_proj_reshaped,90)
        sl_img=cor_proj_rotated;
end
end