function hdl = get_handle( handle, type )
%

% $Id: get_handle.m 2 2005-10-12 09:35:32Z jgrelet $

%h = get( get( handle, 'Children'), 'Type' );
%indice = find( strcmp( h, type ));
h = get( handle, 'Children');
indice = find( strcmp( get( get( handle, 'Children'), 'Type' ), type ));
for i=1:length(indice)
  hdl(i) = h(indice(i));
end
