function g = segmborders(img)
% g = segmborders(segm)
% 
% returns a map of the borders in segmentation 'segm', that is:
% g is 1 if there's a border and 0 otherwise

%| Copyright 2007 Steffen Gauglitz
%| University of California at Santa Barbara, Vision Research Lab
%| contact: Prof. Manjunath, manj@ece.ucsb.edu

%| Modification/redistribution granted only for the purposes
%| of teaching, non-commercial research or study.

im=double(img);
g=zeros(size(im));

for x=1:(size(im,1)-1)
  for y=1:(size(im,2)-1)
    
    g(x,y)=(abs(im(x,y)-im(x,y+1))+abs(im(x,y)-im(x+1,y)) ~= 0);

  end
end
