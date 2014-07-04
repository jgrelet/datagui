function val = get( self, prop )
% GET: Get profil properties from specified object

% $Id: get.m 73 2006-07-11 08:15:09Z nvuillau $

if nargin==1  % list properties if only object is given
  disp('profil properties:')
  disp(sprintf('var_x, liste_profils, pmax, code_roscop'));
  %disp(sprintf(' visible, indice,  data_0d,  data_1d,  data_2d\n'));
  return
end

if ~ischar(prop), error('GET: prop must be string.'), end
%prop = lower(prop(isletter(prop))); %remove nonletters
%if (length(prop) < 2), error('GET: prop must be at least 2 chars.'), end
%switch prop(1:2)

switch prop
  % get parent properties
    case 'var_x'
      val = self.var_x
    case 'var_y'
      val = self.vary 
    case 'var'
      val = self.var 
    case 'liste_profils'
      val = self.liste_profils  
    case 'code_roscop'
      val = self.code_roscop  
    case 'pmax_value'
      val = self.pmax_value 
    case 'pmin_value'
      val = self.pmin_value 
    case 'pas_value'
      val = self.pas_value 
    case 'pas_interpol_value'
      val = self.pas_interpol_value
    case 'titre'
      val = self.titre 
    case 'Clabel_value'
      val = self.Clabel_value 
    case 'Clabel'
      val = self.Clabel 
    case 'ProfilSpec'
      val = self.ProfilSpec
    case 'ProfilSpec_value'
      val = self.ProfilSpec_value 
    case 'methode_value'
      val = self.methode_value 
    case 'methode'
      val = self.methode 
    case 'sub_plot_value'
      val = self.sub_plot_value 
    case 'interpolation_value'
      val = self.interpolation_value 
    case 'geo_value'
      val = self.geo_value 
  otherwise
    error(['GET: ', prop,' is not a valid profil property.']);
end

