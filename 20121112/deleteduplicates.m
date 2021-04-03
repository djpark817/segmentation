function d=deleteduplicates(in)
% d = deleteduplicates(in)
%  returns a vector containing the entries of in without duplicates,
%  for example:
%    deleteduplicates([1 2 3 1 4]);
%  returns [1 2 3 4].

%| Copyright 2007 Steffen Gauglitz
%| University of California at Santa Barbara, Vision Research Lab
%| contact: Prof. Manjunath, manj@ece.ucsb.edu

%| Modification/redistribution granted only for the purposes
%| of teaching, non-commercial research or study.

r=double(in(:));

l=1;
k=1;
while 1
  d(l)=in(k);
  r(r==d(l))=NaN;
  k=find(isfinite(r),1);
  if numel(k)==0, break, end
  l = l+1;
end
