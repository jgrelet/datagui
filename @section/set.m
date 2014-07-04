function self = set( self, varargin )

% modifier set pour modifier plusieurs propriete (voir doc Using Matlab)
% $Id: set.m 73 2006-07-11 08:15:09Z nvuillau $

if nargin == 3
  prop  = varargin{1}
  value = varargin{2}

  switch prop
    case 'var_x'
      self.var_x = value;
    case 'var_y'
      self.vary = value;
    case 'var'
      self.var = value;
    case 'liste_profils'
      self.liste_profils  = value;  
    case 'code_roscop'
      self.code_roscop  = value;
    case 'pmax_value'
      self.pmax_value = value;
    case 'pmin_value'
      self.pmin_value = value;
    case 'pas_value'
      self.pas_value = value;
    case 'pas_interpol_value'
      self.pas_interpol_value = value;
    case 'titre'
      self.titre = value;
    case 'Clabel_value'
      self.Clabel_value = value;
    case 'Clabel'
      self.Clabel = value;
    case 'ProfilSpec'
      self.ProfilSpec = value;
    case 'ProfilSpec_value'
      self.ProfilSpec_value = value;
    case 'methode_value'
      self.methode_value = value;
    case 'methode'
      self.methode = value;
    case 'sub_plot_value'
      self.sub_plot_value = value;
    case 'interpolation_value'
      self.interpolation_value = value;
    case 'geo_value'
      self.geo_value = value;
    otherwise
      error(sprintf('Unrecognized property name ''%s''.',prop)); 
  end
  
else
  %val = get( self, varargin{:});

end
    
