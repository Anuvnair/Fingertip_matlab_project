clc;
clear all;
close all;
function imgout=imgcrop(imgin)          
imgin = imresize(cropimg,[240,240]);     
columnsum=sum(cropimg);                  
rowsum=sum(cropimg');                          
q1=1;
q2=240;
q3=1;
q4=240;
for w=1:240                          
if (columnsum(1,w)>=10)
q1=w;
break;
end
end
for w=q1:240                   
if (columnsum(1,w)>=10)
q2=w;
end
end
for w=1:240                     
if (rowsum(1,w)>=10)
q3=w;
break;
end
end
for w=q3:240                   
if (rowsum(1,w)>=50)
q4=w;
end
end

imgout=cropimg(q3:q4,q1:q2);
imgout=[zeros(q4-q3+1,160-(q2-q1+1)),imgout;zeros(120-(q4- q3+1),160)];
imgout=imresize(imgout,[120,160]);
imgout=double(imgout);    
      
     