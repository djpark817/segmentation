function main

close all; clear; clc;

imgpath = 'H:\Research\hairSeg\database\LFW\lfw_frontal\female';
segmentation_ui( loaddir(imgpath,'*.jpg'), loadstrings([imgpath filesep 'categ.txt']));


% imgpath = 'H:\Research\hairSeg\database\LFW\lfw_funneled';
% segmentation_ui( loadsubdir(imgpath,'*.jpg'), loadstrings([imgpath filesep 'categ.txt']));

a = 1;
