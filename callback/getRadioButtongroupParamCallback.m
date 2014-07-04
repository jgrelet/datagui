function getRadioButtongroupParamCallback( varargin )
% script generique appele sur appui d'un des radio_bouton parametres de
% plot_route

% $Id: getRadioButtongroupParamCallback.m 2 2005-10-12 09:35:32Z jgrelet $

root = get( 0, 'UserData' );

plot( root.self );

clear root;