%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:	X=ctdread3(fname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reads CTD files into one big matrix (X),
% discarding the header (all lines up to '*END*').
%
% Do not manually remove header lines!
%
% The "flag" column (last column) is discarded.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Original code by Bernard Laval; 3rd ed. by Dan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function X=ctdread3(fname)

X=[];
fid=fopen(fname);

% discard all lines up to and including '*END*'
while 1
    L=fgetl(fid);
    if strcmp(L,'*END*')==1,
        break
    end
    if L==-1,
        warning('No *END* found in file.  Action failed.');        
        break
    end
end

% read all subsequent lines into X as character arrays
while 1
    L=fgetl(fid);
    if L==-1, break
    else X=[X; L]; end
end
fclose(fid);

% write X to a temporary data file
fid=fopen('tempdat.txt','w');
w=size(X,2);
for ti=1:size(X,1),
	fprintf(fid,'%s \n',X(ti,:));
end
fclose(fid);

% load X, now in numerical format instead of characters
X=load('tempdat.txt');
X(:,end)=[];

% delete temporary file
!del tempdat.txt

%dum=find((abs(X(:,2))<1e-20)&(X(:,2)<0));
%X(dum,:)=[];
