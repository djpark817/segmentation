function strings = loaddir( path, pattern )
% strings = loaddir(path, pattern)
% 
% returns a list of files in directory 'path' that match 'pattern',
% for example:
%
%  myimages = loaddir('C:\images','*.jpg');

%| Copyright 2007 Steffen Gauglitz
%| University of California at Santa Barbara, Vision Research Lab
%| contact: Prof. Manjunath, manj@ece.ucsb.edu

%| Modification/redistribution granted only for the purposes
%| of teaching, non-commercial research or study.

a=dir([path filesep pattern]);
strings={};

for i=1:length(a)
  strings{i}=[ path filesep a(i).name ];
end
