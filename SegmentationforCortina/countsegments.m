function n=countsegments(segm)
% n = countsegments( segm )
% 
% counts the number of segments (=number of different tokens)
% in segmentation 'segm'

%| Copyright 2007 Steffen Gauglitz
%| University of California at Santa Barbara, Vision Research Lab
%| contact: Prof. Manjunath, manj@ece.ucsb.edu

%| Modification/redistribution granted only for the purposes
%| of teaching, non-commercial research or study.

d=segm(:);
c=zeros(max(d)+1,1);
for i=1:length(d); c( d(i)+1 )=1; end
n = sum(c);
