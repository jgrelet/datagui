function result = keys(self)

% roscop/keys -- Get all the keys currently being used in the internal
%   roscop hash
%   result = keys(self)

% $Id: keys.m 145 2008-02-01 13:57:08Z jgrelet $

result = keys(self.hashtable);

