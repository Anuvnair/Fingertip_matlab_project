clc;
clear all;
close all;
I = imread('binaryhand.png');
figure,imshow(I);
[rows, columns] = find(I);
topRow = min(rows);
bottomRow = max(rows);
leftColumn = min(columns);
rightColumn = max(columns);
croppedImage = I(topRow:bottomRow, leftColumn:rightColumn);

J = imcrop(I);
figure,imshow(J);