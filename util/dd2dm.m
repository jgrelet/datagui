function string = dd2dm( posit, latlon )
% STRING = DD2DM( posit, latlon )
% Convertit une position decimale en chaine de caractere
% 
% string    chaine de caracteres

% posit     en degres decimaux
% latlon    0 pour la latitude - 1 pour la longitude
%
% $Id: dd2dm.m 2 2005-10-12 09:35:32Z jgrelet $
 

    % Determine si latitude ou longitude
    % ----------------------------------
    if latlon == 1
        neg = 'W';
        pos = 'E';
    else
        neg = 'S';
        pos = 'N';
    end

    % Cree les labels
    % ---------------
    if posit < 0
        geo = neg;
    else
        geo = pos;
    end
   
    % Conversion et formattage
    % on n'affiche pas les decimales pour les minutes 
    % car la precision n'est pas suffisante (currentpoint)
    % ---------------------------------------------
    % posit 
    h = fix( posit );
    m = (posit - h ) * 60;
    if abs(m) > 59
      if posit > 0
        h = h+1;
      else
        h = h-1;
      end
      m = 0;
    end
    string = sprintf( '%02d°%06.3f %c', abs(h), abs(m), geo );
            
