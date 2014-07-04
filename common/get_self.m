function self = get_self
% permet de recuperer une instance stockee dans le champ UserData

% $Id: get_self.m 2 2005-10-12 09:35:32Z jgrelet $

self = get( findobj( 'Tag', 'main' ), 'UserData' );