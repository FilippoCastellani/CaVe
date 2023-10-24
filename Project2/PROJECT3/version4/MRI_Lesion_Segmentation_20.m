clear;
clc;
close all;
%% Load the MRIdata file and other visualizzation settings
load camera_settings.mat

DATA=load('MRIdata.mat');

volume=DATA.vol;
%% Visualizing the volume
figure
volshow(volume,shot0,'ScaleFactors',DATA.pixdim)
figure
plot(shot0.Alphamap)

%% Extracting Sagittal Slice
initial_slice=135;
sag_proj=get_slice(initial_slice,'sagittal',volume);
%% Cropping the slice

Crop = figure('Name','CropTheSlice');
Crop.WindowState = 'fullscreen';
[sag_crop, rectcrop]=imcrop(sag_proj);
close('CropTheSlice');

%% Treating the slice
[trtd_slice,area,mc,mr,sc,sr,br,bc]=treat_slice(sag_crop,-1,-1,nan);

%% Inferring radius
radius=floor(sqrt(area/pi)*2);
%% Show obtained parameters
show_scope(trtd_slice,mc,mr,br,bc);
%% Inferring location
x_center=mc;
y_center=mr;
up_left_corner_x=round(rectcrop(1));
up_left_corner_y=round(rectcrop(2));
world_center_x=up_left_corner_x+x_center;
world_center_y=up_left_corner_y+y_center;

%% Get Coronal Slice corresponding to mu_x
cor_proj=get_slice(world_center_x,'coronal',volume);
%% Show Coronal Slice corresponding to mu_x
figure Name CoronaryProjection
imshow(cor_proj);
%% Get y boundaries

show_scope(cor_proj,initial_slice,world_center_y,[1,1],[1,1]); %first is x second is y
[trtd_cor_slice,carea,cmc,cmr,csc,csr,cbr,cbc]=treat_slice(cor_proj,initial_slice,world_center_y,nan);
show_scope(trtd_cor_slice,cmc,cmr,cbr,cbc);
%% Replicate Area estimation process towards decreasing y

new_center_x=world_center_x;
new_center_y=world_center_y;

old_storyline=[];

status=1;

area_story=[];
scopes=[];
segmented_volume=volume*0.2;

for i=initial_slice:-1:cbc(1) %initial_slice-6
   if(status==1)
   sag_i_projection=get_slice(i,'sagittal',volume);
   
   show_scope(sag_i_projection,new_center_x,new_center_y,[1,1],[1,1]);
   
   [elab_sag_slice,sarea,smc,smr,ssc,ssr,sbr,sbc,status]=treat_slice(sag_i_projection,new_center_x,new_center_y,radius);

   segmented_volume(i,:,:)=imrotate(double(sag_i_projection).*(elab_sag_slice+0.2),-90);
   
   center=[smc,smr];
   [storyline,lcx,lcy]=intertial_drift(old_storyline,center);
   
   old_storyline=storyline;
   new_center_x=lcx;
   new_center_y=lcy;
   disp(i);
   end
area_story=[area_story,sarea];
end
total_area_decreasing=sum(area_story);
%% Replicate Area estimation process towards increasing y

new_center_x=world_center_x;
new_center_y=world_center_y;
old_storyline=[];
status=1;
area_story=[];

for i=initial_slice:+1:cbc(2)
   if(status==1)
   sag_i_projection=get_slice(i,'sagittal',volume);
   
   show_scope(sag_i_projection,new_center_x,new_center_y,[1,1],[1,1]);
   
   [elab_sag_slice,sarea,smc,smr,ssc,ssr,sbr,sbc,status]=treat_slice(sag_i_projection,new_center_x,new_center_y,radius);
   
   segmented_volume(i,:,:)=imrotate(double(sag_i_projection).*(elab_sag_slice+0.2),-90);
   
   
   center=[smc,smr];
   [storyline,lcx,lcy]=intertial_drift(old_storyline,center);
   
   old_storyline=storyline;
   new_center_x=lcx;
   new_center_y=lcy;
   disp(i);
   end
area_story=[area_story,sarea];
end
total_area=total_area_decreasing+sum(area_story);

%% 
%% Cube centimeters estimate
total_area_cmcube=(DATA.pixdim(1)*DATA.pixdim(2)*DATA.pixdim(3))*total_area*10^-3;
disp(['Total volume estimate is ', string(total_area_cmcube), ' cm^3'])
%% Visualize the final segmented volume
volumeViewer(segmented_volume,'ScaleFactors',DATA.pixdim);

%%
figure
volshow(segmented_volume,shot1,'ScaleFactors',DATA.pixdim)
%%
figure
volshow(segmented_volume,shot2,'ScaleFactors',DATA.pixdim)
%%
figure
volshow(segmented_volume,shot3,'ScaleFactors',DATA.pixdim)
%%
figure
volshow(segmented_volume,shot4,'ScaleFactors',DATA.pixdim)
%% Import segmented volume
load segmented_volume.mat
%% Repeat everything
%% Compare results


%% Get_Circle_Mask Function
function [bin_img_masked]=get_circle_mask(bin_img,cent_x,cent_y,radius)
center=[cent_x,cent_y];
bin_img_masked=bin_img;
for i=1:1:size(bin_img,1)
    for j=1:1:size(bin_img,2)
        p1=[i,j];
        dist=p1-center;
        if (norm(dist)>=radius)
            bin_img_masked(i,j)=0;
        end
    end

end
figure Name CircleMask
imshowpair(bin_img_masked,bin_img)
end

%% Inertial_Drift Function
function [history,limited_center_x,limited_center_y]=intertial_drift(old_history,center)
supp_history=old_history;
supp_history(size(old_history,1)+1,:)=center;

n=1:1:size(supp_history,1);
weigths=1./((1.2).^n);                                                     % THIS IS A VERY IMPORTANT PARAMETER

history=supp_history;
weigthed_history=supp_history.*weigths';
limited_center_x=sum(weigthed_history(:,1))./sum(weigths);
limited_center_y=sum(weigthed_history(:,2))./sum(weigths);

limited_center_x=round(limited_center_x);
limited_center_y=round(limited_center_y);
end

%% Get_Scope Function
function scope=get_scope(trtd_slice,mc,mr,br,bc)
    full_scope=zeros(size(trtd_slice));
    full_scope(mr,:)=1;
    full_scope(:,mc)=1;
    full_scope(br(1),:)=1;
    full_scope(br(2),:)=1;
    full_scope(:,bc(1))=1;
    full_scope(:,bc(2))=1;

    scope=full_scope;
end

%% Show_Scope Function
function scope=show_scope(trtd_slice,mc,mr,br,bc)
    full_scope=zeros(size(trtd_slice));
    full_scope(mr,:)=1;
    full_scope(:,mc)=1;
    full_scope(br(1),:)=1;
    full_scope(br(2),:)=1;
    full_scope(:,bc(1))=1;
    full_scope(:,bc(2))=1;

    scope=full_scope;
    figure Name OverlappedGeometricalScope
    imshowpair(full_scope,trtd_slice);
end
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

y(end-3:end)=0; %REMOVE THIS LINE
end

%% Image Setup Function

function t_img = setup_my_image(img, comb, max)
scaled_comb=round(comb*max);
%figure Name Transformation                                                [DO NOT DELETE THIS LINE] PURPOSE = TRANSFORM VISUALIZATION
%plot(scaled_comb)
%xlim([0 max])
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

%% Get_Slice Function
function sl_img=get_slice(sl_num,orientation,volume)
switch orientation
    case 'sagittal'
        sag_proj=volume(sl_num,:,:);
        sag_proj_size=size(sag_proj);

        x_size=sag_proj_size(2);
        y_size=sag_proj_size(3);

        sag_proj_reshaped=reshape(sag_proj,[x_size y_size]);
        sag_proj_rotated=imrotate(sag_proj_reshaped,90);
        sl_img=sag_proj_rotated;

    case 'axial'
        sl_img=volume(:,:,sl_num);
    case 'coronal'
        cor_proj=volume(:,sl_num,:);
        cor_proj_size=size(cor_proj);

        cor_x_size=cor_proj_size(1);
        cor_y_size=cor_proj_size(3);


        cor_proj_reshaped=reshape(cor_proj,[cor_x_size cor_y_size]);
        cor_proj_rotated=imrotate(cor_proj_reshaped,90);
        sl_img=cor_proj_rotated;
end
end

%% Treat_Slice Function
function [treated_slice,area,mu_col,mu_row,std_col,std_row,bou_row,bou_col,exit_status]=treat_slice(slice,r,c,radius)

exit_status=1;
%enhancement
k=10;
g=0.2;
max=255;
enh_slice=enhance(slice,k,g,max);
figure Name Enhanced_Slice
imshow(enh_slice)
%fill
fil_slice=imfill(enh_slice);

%binarize
bin_slice=imbinarize(fil_slice);

if (r==-1)&&(c==-1)
    figure Name MousePick
    imshow(bin_slice,'InitialMagnification','fit'); title('Click on the tumor');
    [c,r]=getpts();
    close('MousePick');
end

if (~isnan(radius))
%%limit the dimension of the object
[bin_slice]=get_circle_mask(bin_slice,c,r,radius);                         %%THIS LINE MUST BE ENHANCED (AUTOMATIC RADIUS)
end
%get the object
[obj_vec,obj_row,obj_col]=get_object_vector(bin_slice,r,c);
   
%we got our treated slice
treated_slice=obj_vec;

%calculate statistics
    %area
area=(sum(reshape(obj_vec,1,[])==1));
    %mean
mu_row=round(mean(obj_row)); 
mu_col=round(mean(obj_col));
    %std
var_row=var(obj_row); 
var_col=var(obj_col);
std_row=round(3*sqrt(var_row)); 
std_col=round(3*sqrt(var_col));
bou_row=[mu_row-std_row,mu_row+std_row]; 
bou_col=[mu_col-std_col,mu_col+std_col];

if (isnan(mu_row))                                                         %it could be any other variable
    disp('The function was not able to identify the presence of abnormal tissue masses')
    exit_status=0;
end

end
%% Enhancement Function
function enh_img=enhance(img,coeff,g_coeff,max)
n=linspace(0,1,256);
support= t(n,coeff,g_coeff);
enh_img=setup_my_image(img,support,max);
end

%% Get_Object_Vector Function
function [bin_vec,obj_row,obj_col]=get_object_vector(bin_img,w,h)
bin_vec=bwselect(bin_img,w,h);
[obj_row,obj_col]=find(bin_vec==1);
figure Name Selection
imshow(bin_vec,'InitialMagnification','fit');title('Selection');
end