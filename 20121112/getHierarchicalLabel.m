function string=getHierarchicalLabel(categorytree,index)
% string = getHierarchicalLabel(categorytree,index)
% 
% returns a multi-level label like 'category1\subcategory3\class2'
% that is associated with the given index.
% For example, when categorytree is a list of strings like this:
%
% aa
%  bb
% cc
%  dd
%  ee
%
% getHierarchicalLabel(categorytree,5) returns 'cc\ee'.

%| Copyright 2007 Steffen Gauglitz
%| University of California at Santa Barbara, Vision Research Lab
%| contact: Prof. Manjunath, manj@ece.ucsb.edu

%| Modification/redistribution granted only for the purposes
%| of teaching, non-commercial research or study.

level=nan(index,1);
for n=1:index, level(n)=countleadingblanks(categorytree{n}); end
mylevel=level(index);
string=strtrim(categorytree{index});

while mylevel>0
 index=find(level==mylevel-1,1,'last');
 mylevel=mylevel-1;
 level(index:end)=nan;
 string=[ strtrim(categorytree{index}) '\' string];
end
