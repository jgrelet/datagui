function exist_xml_CQ = plot_points_QC(varargin)

% Fonction qui teste si le fichier existe deja et qui trace le profil
% selectionné avec son code qualité associé en points de couleurs. 
% exist_xml_CQ renvoie 1 si le fichier existe et 0 si celui ci n'existe
% pas. 

%% initialisation
path  = varargin{1};
Cles = varargin{2};
profil = varargin{3};
hash = varargin{4};

exist_xml_CQ = 1;
path2 = [path(1:end-4) '_temps.xml'];
fid = fopen(path2, 'r');
if fid == -1
  exist_xml_CQ = 0;
  return
end

%tester si le fichier existe deja ou non....
cleCQ_CQ = [Cles{2} '_CQ'];

while ~feof(fid)
  line = fgetl(fid);
  [tok match] = regexp(line,'<(\w+)>','tokens');
  if isempty(match), continue, end
  if strmatch(tok{1},'DATA')
    header = fgetl(fid);
    var_all = strread( header, '%s' );
    for i=1:length(var_all)
      if strcmp(cleCQ_CQ, var_all{i})
        data_ligne = fgetl(fid);
        data_ligne_vect = strread( data_ligne, '%s' );
        CQ_point = [];
        while data_ligne_vect{1} ==  profil
          CQ_point = [CQ_point; str2double(data_ligne_vect{i})];
          data_ligne = fgetl(fid);
          data_ligne_vect = strread( data_ligne, '%s' );
        end
        y = get(hash,Cles(1));
        y = y.data;
        x = get(hash,Cles(2));
        x = x.data;
        for i=1:length(CQ_point)
          CQ = CQ_point(i);
          if CQ ~= 0
            style = color_style(CQ);
            hold on;
            axis manual;
            plot(x(i),y(i),style, 'Tag',['tag_points_' i])
          end
        end
      end
    end
  end
end
end

function style = color_style(CQ)
txt = '';
switch CQ
  case 1
    txt = '--bo';
  case 2
    txt = '--co';
  case 3
    txt = '--mo';
  case 4
    txt = '--ro';
end
style = txt;
end



