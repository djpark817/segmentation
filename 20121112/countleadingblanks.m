function c=countleadingblanks(string)
% c = countleadingblanks(string)
% 
% counts leading blanks in a string

%| Copyright 2007 Steffen Gauglitz
%| University of California at Santa Barbara, Vision Research Lab
%| contact: Prof. Manjunath, manj@ece.ucsb.edu

%| Modification/redistribution granted only for the purposes
%| of teaching, non-commercial research or study.


blanks=isspace(string);
c=0;
while blanks(c+1); c=c+1; end
