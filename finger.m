clc;
clear all;
close all;

%% Reading

im=imread('myhand1.jpg');
figure;
imshow(im);
title('Original Image');

RGB=im;

%% Resizing

RGB=imresize(RGB,[2000 2000]);
figure,imshow(RGB);
title('Original Image');

%% HSV Color Space Based Skin Filter

SkinImage = RGB;
[r,c,v] = size(SkinImage);            % r=2000,c=2000,v=3

HSV=rgb2hsv(SkinImage);
figure,imshow(HSV);
title('HSV Image');

H=HSV(:,:,1);
S=HSV(:,:,2);
V=HSV(:,:,2);

h_range = [0 0.11];    
s_range = [0.2 1.5];

I = S+H;                
figure,imshow(I);
title('H+S');

I(find(I==0))=Inf;       

BW_Skin=((S>s_range(1)) & (S<s_range(2)) &(H>h_range(1)) & (H<h_range(2))); % 0<S<0.11 and H: 0.2 to 1.5
figure,imshow(BW_Skin);
title('Skin filter Image');

 %% Averaging Filter 
 f=fspecial('average',[3 3]);
 BW_Skin=imfilter(BW_Skin,f);
 figure,imshow(BW_Skin); 
 title('Averaging Filter');
 
%% Biggest BLOB Operation

[Bwlbl,num]=bwlabel(BW_Skin);    % num = number of components in binary image
 for i=1:num                     % traverses through the components
       lblNUM=find(Bwlbl==i);    % finds each connected component
       [m,n]=size(lblNUM);       % finds size of each connected component
       lbl(i)=m*n;            
 end
                                 % isolating the component with biggest size. 
p=max(lbl);                      % hand element has the biggest size than other connected components.
BW_Skin=bwareaopen(BW_Skin,p);   % size lesser than max size of lbl are removed
figure,imshow(BW_Skin); 
title('biggest BLOB');
 
%% Segemented Hand Image on Black background        :- converting obtained binary image to color image
skinfilterdimage=RGB;
skinfilterdimage(:,:,1)=double(RGB(:,:,1)).*double(BW_Skin);
skinfilterdimage(:,:,2)=double(RGB(:,:,2)).*double(BW_Skin);
skinfilterdimage(:,:,3)=double(RGB(:,:,3)).*double(BW_Skin);
figure;
imshow(skinfilterdimage);
title('BW_Skin*orginal'); 

%% Wrist End Detection 

% wrist_end is detected by checking for max length of pixels along all four border rows
%  and cols of binary image.(left,right,down and up first rows/first cols)

On_pixel={find(BW_Skin(:,1)==1),find(BW_Skin(:,2000)==1),find(BW_Skin(2000,:)==1),find(BW_Skin(1,:)==1)};
% chks for white pixels in first column, last column,last row, first row 
% on_pixels =[1x4] matrix = [ left, right, down, up]

for z=1:size(On_pixel,2)                           % 1:columnsize of onpixels array ( here from 1:4)
    [m,n]=size(On_pixel{z});                       % stores size of each cell of onpixels
    col_size(z)=m*n;  
end
% Bar plot to find the border row/col with max length of white_pixels
x=1:4;
y=col_size;
h=bar(x,y)
title('Bar Plot');
figure;
[maxval,pos]=max(col_size);                        % maxval= max value of col_size. pos represents respective border of binary image.

%% Hand Cropping

for i=1:2000

 if pos==1                                             % if first column of BW_Skin, or 'LEFT'
        
     [y_min,x_min,v_min]=find(BW_Skin(:,i),1,'first');  % finds first non zero elemnt. stores row & col values. Y represents row,x represnts col in mtlab
     [y_max,x_max,v_max]=find(BW_Skin(:,i),1,'last');   % finds last non zero elemnt.
     empty=isempty(x_min);                              % empty variable returns 1 if first column value is empty. 
    
        if empty==1
                coordinate(i)=0;
        else                                                                         
                coordinate(i)=y_max-y_min;
        end 
        
 elseif pos==2                                           % if last column of BW_Skin, or 'RIGHT'
        
      [y_min,x_min,v_min]=find(BW_Skin(:,2001-i),1,'first');
      [y_max,x_max,v_max]=find(BW_Skin(:,2001-i),1,'last');
       empty=isempty(x_max);
       
         if empty==1
                coordinate(i)=0;
        else                                                                         
                coordinate(i)=y_max-y_min;
         end
         
elseif pos==3                                             % if last row of BW_Skin, or 'DOWN'
        
      [y_min,x_min,v_min]=find(BW_Skin(2001-i,:),1,'first');
      [y_max,x_max,v_max]=find(BW_Skin(2001-i,:),1,'last');
       empty=isempty(y_max);
       
         if empty==1
                coordinate(i)=0;
        else                                                                         
                coordinate(i)=x_max-x_min;
         end 
        
 elseif pos==4                                            % if first row of BW_Skin, or 'UP'
        
      [y_min,x_min,v_min]=find(BW_Skin(i,:),1,'first');
      [y_max,x_max,v_max]=find(BW_Skin(i,:),1,'last');
       empty=isempty(y_min);
       
         if empty==1
                coordinate(i)=0;
         else                                                                         
                coordinate(i)=x_max-x_min;
         end 
 end                                                     % if end 
end                                                      % for end

plot(coordinate);                                        
grid on;
title('Histogram of Binary Silhoutte');

temp=coordinate(1);                               % 
%coordinate: [1 X ncolumns] array. assumption: coordinate(1) taken since it
% consists of first wrist end skin pxel

% Slope calculation

% [x1,y1]= ; max peak coordinates
% [x2,y2]=;  ?
% slope=[y2-y1]/[x2-x1];

 for i=1:2000                                         
     if coordinate(i)>temp                               % doubt: why is temp added with a value of 50? 
         crop=i;                                         % gives position of wrist end                             
         break;
     end
 end

%  if pos==1                                       % if 1st col
%      Cropim=skinfilterdimage(:,crop:end,:);
%  elseif pos==2                                   % if 1st row
%      Cropim=skinfilterdimage(:,1:c-crop,:);
%  elseif pos==3                                   % if last row
%      Cropim=skinfilterdimage(1:c-crop,:,:);
%  elseif pos==4                                   % if last col
%      Cropim=skinfilterdimage(crop:end,:,:);
%  end 
 
%for x=1:2000
    % for y=1:2000
     %   if (x>x_min & x<x_max & y>y_max & y<y_max)
      %       Cropim=skinfilteredimage(:,:,:);
       %  else
        %     Cropim=0;
        %end
    % end
%end
y_max=max(coordinate);
y_min=crop;
x_min=crop;
x_max=find(coordinate(1,:),1,'last');

cropim=coordinate(y_min:y_max,x_min:x_max);

figure,imshow(Cropim);   
title('Cropped Image');
  

    
       
         
         
         
         