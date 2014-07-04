function V = extract_profil(s)

% $Id: extract_profil.m 120 2007-02-02 13:42:20Z jgrelet $

% fonction extract_profil
% V = extract_profil(s) est une fonction dans laquelle ont rentre une
% structure et qui renvoie un vecteur des profils.
% La forme de la structure entrante est la suivante :
% >> s
%
% s =
%
% 1x6 struct array with fields:
%     profil                % Numero de chacune des profils selectionnées
%     longitude              % Longitude "    "   "     "  "
%     latitude               % Latitude  "    "   "     "  "
%     profondeur             % Profondeur maximale"   "   " "   " "
%
%Exemple :
% >> s(1)
%
% ans =
%
%        profil: 9
%        longitude: -15
%        latitude: 1
%        profondeur: 231
%
% Cette fonction compare les longitudes et les latitudes des profils
% selectionnées et determine les profils proche d'au minimum 0.1 degrès.
% Elle effectue ensuite une comparaison entre les profondeurs des profils
% trop proches ,determine la profil la plus profonde et supprime les
% autres.
% Elle renvoie alors un vecteur contenant les profils suffisament ecartées
% afin de tracer une section cohérente.

%% Initialisation
PeuProfonde=[];
V=[];
D=[];
temp = 0;
reponse1=[];
%determine le nombre de comparaison a effectuer.
nbrprofils = size(s);

%initialisation de la boucle.
for i=1:nbrprofils(2);
  V=[V,s(i).profil];
end
for i=1:nbrprofils(2);
  for j=1:nbrprofils(2);
    %comparaison des longitudes et latitudes
    if j==i
      if j ~= nbrprofils(2);
        j=j+1;
        %break;
      else
        break;
      end
    end
    if abs(s(i).longitude-s(j).longitude)<=0.1 && abs(s(i).latitude-s(j).latitude)<=0.1
      %comparaison des profondeurs des profils trop proches.
      if s(i).profondeur-s(j).profondeur >=0
        %Vecteur qui enregistre les profils les moins profondes lors d'une
        %comparaison.
        D=[D,s(j).profil];
      end
    end
  end
end
%supprime les repetitions du vecteur D.
D=unique(D);
%script affichant les profils supprimées de la section.
for i = 1:length(D)
  reponse = sprintf(['Le profil ''%s'' a été supprimée'...
    ' car trop proche d''un autre profil plus profond. '],num2str(D(i)));
  disp( ['Attention : ' reponse]);
end
%Ne conserve que les profils les plus profondes.
V=setxor(D,V);
end
