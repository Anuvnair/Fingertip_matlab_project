clc;
clear all;
close all;
RGB=imread('myhand1.jpg');
% resize the image
RGB=imresize(RGB,[2000 2000]);
figure,imshow(RGB);
title('Original Image');
 % change the rgb to hsv color space
 SkinImage = RGB;
[r c v] = size(SkinImage);
HSV=rgb2hsv(SkinImage);
figure,imshow(HSV);
title('HSV Image');
H=HSV(:,:,1);
S=HSV(:,:,2);
V=HSV(:,:,2);
h_range = [0 .11];
s_range = [0.2 1.5];
I = S+H;
figure,imshow(I);
title('H+S');
I(find(I==0))=Inf;
BW_Skin= ((S>s_range(1)) & (S<s_range(2)) &(H>h_range(1)) & (H<h_range(2)));
figure,imshow(BW_Skin);
title('Skin filter Image');
 %Averaging Filter
   for i=1:5:r
       for j=1:5:c
           A=BW_Skin(i:i+4,j:j+4);
           Sum=sum(sum(A));
           if Sum>Sum/2
               BW_Skin(i:i+4,j:j+4)=1;
           else
               BW_Skin(i:i+4,j:j+4)=0;
           end
       end
   end
    figure,imshow(BW_Skin); 
title('Averaging Filter');
  %biggest BLOB Operation
   [Bwlbl,num]=bwlabel(BW_Skin);
   for i=1:num
       lblNUM=find(Bwlbl==i);
       [m,n]=size(lblNUM);
       lbl(i)=m*n;
   end
   BW_Skin=bwareaopen(BW_Skin,max(lbl));
   figure,imshow(BW_Skin); 
title('biggest BLOB');
%image multiplication
skinfilterdimage=RGB;
skinfilterdimage(:,:,1)=double(RGB(:,:,1)).*double(BW_Skin);
skinfilterdimage(:,:,2)=double(RGB(:,:,2)).*double(BW_Skin);
skinfilterdimage(:,:,3)=double(RGB(:,:,3)).*double(BW_Skin);
figure;
imshow(skinfilterdimage);
title('BW_Skin*orginal'); 
%Wrist End Detection 
ONbits={find(BW_Skin(:,1)==1),find(BW_Skin(1,:)==1),find(BW_Skin(:,2000)==1),find(BW_Skin(2000,:)==1)};
for i=1:size(ONbits,2)
    [m,n]=size(ONbits{i});
    NUMbits(i)=m*n;
end
 
%Position of max value in NUMbits represent Wrist End
Xvalues=1:4;
bar(Xvalues,NUMbits);

bar(1,NUMbits(1),'y');
hold on;
bar(2,NUMbits(2),'g');

bar(3,NUMbits(3),'r');

bar(4,NUMbits(4),'b');
figure
title('Histogram');
hold off;

[maxval,pos]=max(NUMbits);
%Hand Croping
for i=1:r
    if pos==1
     [rF,cF,vF]=find(BW_Skin(:,i),1,'first');
     [rL,cL,vl]=find(BW_Skin(:,i),1,'last');
    empty=isempty(cL);
    if empty==1
        histData(i)=0;
    else    
        histData(i)=rL-rF;
    end 
    elseif pos==2
       [rF,cF,vF]=find(BW_Skin(i,:),1,'first');
       [rL,cL,vl]=find(BW_Skin(i,:),1,'last');
    empty=isempty(cL);
    if empty==1
        histData(i)=0;
    else    
        histData(i)=cL-cF;
    end 
    elseif pos==3
        
        [rF,cF,vF]=find(BW_Skin(:,2001-i),1,'first');
        [rL,cL,vl]=find(BW_Skin(:,2001-i),1,'last');
        empty=isempty(cL);
        if empty==1
         histData(i)=0;
        else    
         histData(i)=rL-rF;
        end
     elseif pos==4   
        
        [rF,cF,vF]=find(BW_Skin(2001-i,:),1,'first');
        [rL,cL,vl]=find(BW_Skin(2001-i,:),1,'last');
        empty=isempty(cL);
        if empty==1
            histData(i)=0;
        else    
            histData(i)=cL-cF;
        end
    end
end    
plot(histData)               
Temp=histData(10);
 for i=1:r
     if histData(i)>Temp+50
         crop=i;
         break;
     end
 end
 
 if pos==1    
     Cropim=skinfilterdimage(:,crop:end,:);
 elseif pos==2
     Cropim=skinfilterdimage(crop:end,:,:);
 elseif pos==3
     Cropim=skinfilterdimage(:,1:c-crop,:);
 elseif pos==4
     Cropim=skinfilterdimage(1:c-crop,:,:);
 end 
 figure,imshow(Cropim);   
title('Crope Image');
       
        
        
     
