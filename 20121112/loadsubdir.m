function strings = loadsubdir( path, pattern )
% strings = loaddir(path, pattern)
% 
% returns a list of files in directory 'path' that match 'pattern',
% for example:
%
%  myimages = loaddir('C:\images\*\','*.jpg');

%| Copyright 2007 Steffen Gauglitz
%| University of California at Santa Barbara, Vision Research Lab
%| contact: Prof. Manjunath, manj@ece.ucsb.edu

%| Modification/redistribution granted only for the purposes
%| of teaching, non-commercial research or study.

% Modified by Ilkoo Ahn

strings={};
cnt = 0;

flist = dir(path);
for i=1:length(flist)
    if flist(i).isdir
        fdname = flist(i).name;
        imgfiles = dir([path filesep fdname filesep pattern]);
        if ~isempty(imgfiles)
            for j=1:length(imgfiles)
                cnt = cnt + 1;
                strings{cnt}=[path filesep fdname filesep imgfiles(j).name];
            end
        end
    end
end

