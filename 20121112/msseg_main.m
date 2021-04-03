clc; clear all; close all;

addpath 'msseg'

%% parameters settings
hs = 3; hr = 5; M = 20;

%% paths
img_path = './img/';
out_path = './results/';

name = 'Adam_Rich_0001'; % Aaron_Eckhart_0001                                         Abdel_Nasser_Assidi_0001

img = imread([img_path name '.jpg']);       figure, imshow(img);
%% 
[S labels] = msseg(img,hs,hr,M);
labelsrgb = label2rgb(labels);
figure, imshow(labelsrgb);
imwrite(labelsrgb, [out_path name '_' 'rgb' '.ppm']);

figure, imagesc(labels); figure(gcf);
[imgMasks,segOutline,imgMarkup]=segoutput(im2double(img),double(labels));
figure, imagesc(imgMasks); figure(gcf)
figure, imagesc(segOutline); figure(gcf)
figure, imagesc(imgMarkup); figure(gcf)
a = 1;