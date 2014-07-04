%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trace des profils d'ecart-type autour d'un profil particulier selectionné à la souris
%--------------------------------------------------------------------------------------
nbprofils=3;
%%
%% Je suis obligee de recuperer les donnees a nuveau?

%% Recupere les codes roscop variables d'entree

code_roscop = get( findobj( 'Tag', 'line_std_ctd'), 'Userdata' );
code_roscop1=code_roscop(:,1);
code_roscop2=code_roscop(:,2);
%% UserData de l'élément racine 0
root = get(0, 'UserData' );
self = root.self;
r = roscop(self);

%profils = get(data_1d(self),'PROFILS');
dayd   = get(data_1d(self),'DAYD');
reference_date_time = get(data_1d(self),'REFERENCE_DATE_TIME')
data1  = get(data_2d(self), code_roscop1);
data2  = get(data_2d(self), code_roscop2);

%%
[Y,isel]=(min(abs(sel(1)-dayd)))
%Preparation trace
figure;
selprof=max(1,isel-floor(nbprofils/2)):min(isel+floor(nbprofils/2),length(dayd))
%Gestion de l'echelle horizontale
%pour que ts les profils de la figure soient traces sur la meme échelle
%horizontale 
stddiff=sqrt((data1-data2).^2);% ecart-type de la difference des 2 capteurs: je suis obligee de le recalculer??
stddiff_zoom=stddiff(selprof,:);
stddiff_zoom=reshape(stddiff_zoom,size(stddiff_zoom,1)*size(stddiff_zoom,2),1);
valmax=nanmax(stddiff_zoom);
clear stddiff_zoom
%fin
isubplot=0;
%Trace
for iprof=selprof(1):selprof(end)
	isubplot=isubplot+1;
	axes('Position',[.04+(isubplot-1)*(1/nbprofils-.01) .1 1/nbprofils-.04 .8])
	h=plot(stddiff(iprof,:),-[1:size(data1,2)])
	set(gca,'ylim',[-Depth 0],'Xlim',[0 valmax],'FontSize',8,'FontWeight','Bold')
	if isubplot>1
		set(gca,'YTickLabel',[])
	else
		ylabel('profondeur (m)')
	end;
	if iprof~=isel
		set(gca,'XTicklabel',[])
	else
		xlabel(vr.unit)
		title(DATES(isel,:),'FontSize',8,'FontWeight','Bold')
	end;
	if iprof==isel
		set(h,'color','r')
	else
		set(h,'color','b')
	end;
end; %for iprof
% Titre general de la page
ax=axes('Position',[.05 .96 .9 .03],'Box','on','XTick',[],'YTick',[]);
text(.5,.5,['Ecart-type entre les 2 capteurs'],'FontSize',12,'Units', 'Normalized', 'HorizontalAlignment', 'Center');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trace des profils primaires (rouge) et secondaire (bleu)
%--------------------------------------------------------
%disp('selectionner la profondeur minimale a analyser')
%profmin=ginput;profmin=-profmin(2)
%disp('selectionner la profondeur maximale a analyser')
%profmax=ginput;profmax=-profmax(2)
disp('selectionner la tranche de profondeurs a analyser')
ax=mousebox
profmin=-ax(4); profmax=-ax(3);
figure;
isubplot=0;
%je cale les echelles horizontales en fct de data1
valmax=nanmax(data1(isel,profmin:profmax))
valmin=nanmin(data1(isel,profmin:profmax))
%Trace
for iprof=selprof(1):selprof(end)
	isubplot=isubplot+1;
	axes('Position',[.04+(isubplot-1)*(1/nbprofils-.01) .1 1/nbprofils-.04 .8])
	h=plot(data1(iprof,:),-[1:size(data1,2)],'r')
	hold on
	h=plot(data2(iprof,:),-[1:size(data2,2)],'b')
	set(gca,'ylim',[-profmax -profmin],'xlim',[valmin valmax],'FontSize',8,'FontWeight','Bold')
	if isubplot>1
		set(gca,'YTickLabel',[])
	else
		ylabel('profondeur (m)')
	end;
	if iprof~=isel
		set(gca,'XTicklabel',[])
	else
		xlabel(vr.unit)
		title(DATES(isel,:),'FontSize',8,'FontWeight','Bold')
	end;
end; %for iprof

% Titre general de la page
ax=axes('Position',[.05 .96 .9 .03],'Box','on','XTick',[],'YTick',[]);
text(.5,.5,['PROFILS - Capteur1: rouge, Capteur 2: bleu'],'FontSize',12,'Units', 'Normalized', 'HorizontalAlignment', 'Center');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
