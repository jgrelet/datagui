function result = get( self, varargin )

% roscop/get -- get structure of "roscop" object.
%
% Input
% -----
% self   ........... instance of 'roscop' object
% key    ........... GF3 code
% member ........... attribute member
%
% Output
% ------
% result ........... structure for the key (hastable)
%
% if key dosn't exist, return empty struct

% $Id: get.m 144 2008-02-01 13:56:12Z jgrelet $

% Test variable argument list
% ---------------------------
switch (nargin)
  
  % Return the list of key 
  % ----------------------
  case 1
     result = keys(self);

  % Return for a valid key the hash (structure)
  % -------------------------------------------
  case 2
    if  ~isempty( find(strcmp(keys(self), varargin{1})))
      result = get(self.hashtable, varargin{1});
    else
      result = {};
    end
    
  % Return the hash member value 
  % ----------------------------
  case 3
    % call method get for an hashtable object
    result = get(self, varargin{1});
    % test if third arg is a valid member of the struct in the hash
    if ~isempty( find(strcmp(keys(self), varargin{1})) ) && ...
        isfield(result,varargin{2})
      result = result.(varargin{2});
    else
      result = {};
    end
    
  otherwise
    error('Wrong input args');
end
