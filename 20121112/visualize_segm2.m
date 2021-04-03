function cimg = visualize_segm2(img,segm)
% newimg = visualize_segm2(img, segm)
% 
% visualizes segmentation: 'newimg' is image 'img' with
% the segmentation borders from 'segm' sketched in as red lines

%| Copyright 2007 Steffen Gauglitz
%| University of California at Santa Barbara, Vision Research Lab
%| contact: Prof. Manjunath, manj@ece.ucsb.edu

%| Modification/redistribution granted only for the purposes
%| of teaching, non-commercial research or study.

b=segmborders(segm);
cimg=img;
mask=(b>0);
c=[255 0 0]; % change this line if you prefer another color

for channel=1:3
  temp=cimg(:,:,channel);
  temp(mask)=c(channel);
  cimg(:,:,channel)=temp;
end
