function good_titles(N1,N2,N3,N4)

% plot bold axes and title 
% N1,N2,N3 = size of texts (for xlabel, ylabel, title, axes)
% 
% if only 1 input (N1), then N1=N2=N3=N4
%
% if no input: N1=N2=N3=N4=12
% 
% Alexis chaigneau - May 2006

if nargin == 0
    N = [12 12 12 12];
elseif nargin == 1
    N = [N1 N1 N1 N1];
elseif nargin == 2 | nargin==3
    error('Must have 0,1 or 4 input arguments.');
elseif nargin == 4
    N = [N1 N2 N3 N4];
end

h = get(gca,'xlabel');
set(h,'fontweight','bold','fontname','times','fontsize',N(1));
h = get(gca,'ylabel');
set(h,'fontweight','bold','fontname','times','fontsize',N(2));
h = get(gca,'title');
set(h,'fontweight','bold','fontname','times','fontsize',N(3));
set(gca,'fontweight','bold','fontname','times','fontsize',N(4));
box on
