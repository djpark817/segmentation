function [map,out]=convert2_8bit(in)

out=zeros(size(in,1),size(in,2),'uint8');
map=inf(max(in(:))+1,1);

newtoken=0;
for i=1:length(in(:));
  token=map(in(i)+1);
  
  if ~isfinite(token)
    map(in(i)+1)=newtoken;
    token=newtoken;
    newtoken=newtoken+1;
    if newtoken>256, error('segmentation:convert4saving','error: can''t handle more than 256 segments!'); end
  end
  
  out(i)=token;
end
