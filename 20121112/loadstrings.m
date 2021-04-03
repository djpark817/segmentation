function strings = loadstrings( filename )
% strings = loadstrings( filename )
% 
% loads a list of strings out of a given text file,
% for example:
%
%  strings = loaddir('C:\data\list.txt');

%| Copyright 2007 Steffen Gauglitz
%| University of California at Santa Barbara, Vision Research Lab
%| contact: Prof. Manjunath, manj@ece.ucsb.edu

%| Modification/redistribution granted only for the purposes
%| of teaching, non-commercial research or study.

line=0;
fid=fopen(filename,'r');
strings={};

while 1
  tline = fgetl(fid);
  if ~ischar(tline); break; end;
  line = line +1;
  strings{line}=tline;
end
fclose(fid);
