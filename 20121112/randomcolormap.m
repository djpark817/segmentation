function c=randomcolormap(k)
% colors = randomcolormap(k)
% 
% creates a random RGB colormap with k colors.
% k can be omitted and in this case defaults to 256.

%| Copyright 2007 Steffen Gauglitz
%| University of California at Santa Barbara, Vision Research Lab
%| contact: Prof. Manjunath, manj@ece.ucsb.edu

%| Modification/redistribution granted only for the purposes
%| of teaching, non-commercial research or study.

if nargin < 1, k=256; end;
q=ceil( k^(1/3) ); % quantization levels per color channel

d=zeros( q^3, 3 );
i=1;
for r=0:1/(q-1):1
  for g=0:1/(q-1):1
    for b=0:1/(q-1):1
      d(i,:)=[r g b];
      i=i+1;
    end
  end
end

c=d(randperm( q^3 ),:);
c=c(1:k,:); % only k colors required
