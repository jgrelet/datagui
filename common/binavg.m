% BINAVG Bin-averaging function, using SORTING first
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% usage: [meanx meand]=binavg(x,d,binsize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% x = property to be bin averaged
% d = independent vector
% binsize = a monotonically increasing vector of depth 
%           bins in units of whatever d is in.  
%           If binsize is a scalar then a vector
%           of bins is created using binsize, default = 1
% 
% Coded by DJP

function [meanx,meand]=binavg(x,d,binsize)
% Originally coded by BL
if nargin<3, binsize=1;  end

if max(size(binsize))==1,
  mind=min(d);
  maxd=max(d);
  bins=mind:binsize:maxd;
else,
  bins=binsize;
end

% Algorithm changed by DJP from this point:
bins=sortrows(bins(:)); % make sure bins in ascending order
DX=[d(:) x(:)];
DX=sortrows(DX,1); % sorted to ascending order of d
ndata=size(DX,1);

meand=bins(1:(length(bins)-1))+diff(bins)/2;
meanx=NaN*ones(size(meand));

% find first row of data to be used:
row=1;
if DX(end,1)<bins(1), return, end % no data in any bins!
while DX(row,1)<bins(1),
    row=row+1; end

for p=1:length(meanx),
    value=[];
    while (DX(row,1)<bins(p+1))&(row<ndata),
        value=[value DX(row,2)];
        row=row+1;
    end
    if ~isempty(value),
        meanx(p)=mean(value);
    end            
end