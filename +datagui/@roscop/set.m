function self = set( self, varargin )
% usage: 
% r = roscop;
% r = set(r,'scale','PSAL',[0 50;33 37;33 36;34 36;34 37;33.5 37.5])
% keys(r,'PSAL')
%
% modifier set pour modifier plusieurs proprietes (voir doc Using Matlab)
% $Id: set.m 53 2006-03-03 13:41:22Z jgrelet $

if nargin == 4
  prop  = varargin{1};
  cle   = varargin{2};
  value = varargin{3};

  switch prop
    case 'scale'
      s = keys(self, cle);
      s.scale = value;
      self.keys = put( self.keys, cle, s );	    
    otherwise
      error(sprintf('Unrecognized property name ''%s''.',prop)); 
  end 
else
  error('wrong number argument');
end  
