#!/usr/bin/perl -w

# modifs AMOP, a mettre a jour sur svn:
# si une variable n'etait pas un parametre physique declare comme code ROSCOP, l'ensemble
# du fichier passait en mode noroscop. Ceci ne s'applique que pour la variable maintenant
# et dans les 2 modes, short ou full (avec _QC)
# a faire:
# declarer DAYD, LATX, LONX comme des variables
#
#------------------------------------------------------------------------------
# Les modules Perl externes necessaires
#------------------------------------------------------------------------------
# get a module version number:
# perl -MModule::Name -le 'print Module::Name->VERSION';
# example:
# perl -MSwitch -le 'print Switch->VERSION';
#
use strict;
use version;
use English;
use POSIX qw(uname);
use Date::Manip;
use Data::Dumper;
use Getopt::Long;
use feature 'switch';    # given replace switch statement since perl v8.10
use PDL;
use PDL::NetCDF;
use PDL::Ufunc;          # cf min, max et median
use PDL::Char;
use XML::LibXML;
use Oceano::Convert;

#PDL::Core::set_debugging(1);
#
our $revision = '$Id: oceano2oceansites.pl 595 2014-04-21 14:55:57Z jgrelet $';
our $VERSION = qv( '0.2_1' );                      # 05/17/2014 08:00'
our $AUTHOR  = 'Jacques Grelet US191 IRD Brest';

# bug: Name "PDL::SHARE" used only once: possible typo at /usr/lib/perl/5.10/DynaLoader.pm line 216.
# see: http://www.digipedia.pl/usenet/thread/14593/3943/
# The other thing we could do (equally tedious) is to ensure that $PDL::SHARE
# is mentioned more than once by placing, in every test script, something
# like:
if ( defined( $PDL::SHARE ) ) { }

# BUG: 
# rajouter une option data_type=PROFILE, etc pour la transformation des 
# fichiers ASCII

# TODOS:
# transformation des time-series
#
=pod # documention

=head1 NAME

oceano2oceansites.pl:  convert oceano ASCII or XML file to NetCDF OceanSITES format

=head1 DESCRIPTION

 This Perl script read ADCP, CTD, XBT (Sippican), CHIMICAL files under format "oceano" and convert them in NetCDF OceanSITES.

 Ces fichiers sont organises sous forme de matrice n_profils * n_param + 2
 
 Les entetes des colonnes sont au format ROSCOP et leurs descriptions 
 detaillees sont lus dans le fichier code_roscop.csv qui est dorenavant 
 inclue apres la directive __data__ en fin de script.
 Le script est a copier sous /usr/local/bin

 La premiere colonne identifie la profil dont les coordonnees, exprimees
 en decimal, sont reperees par la pronfondeur -1

=for example
 
 PIRATA-FR24  LE SUROIT  IRD  SBE 911plus  09P10828-419  BOURLES
 PRFL   PRES   DEPTH   TEMP    PSAL    DENS    DOX2    NAVG
 00001    -1 101.35096  6.99983 -20.31683 20140412082523  3754 1e36
 00001     4     4   25.934  35.784   23.646    202.162  49
 00001     5     5.0 25.937  35.784   23.645    202.358  36
 00001     6     6.0 25.939  35.785   23.645    202.599  46

=head1 CONVERSION

The output file has 2 dimensions (TIME et DEPTH). 

Variables PROFILE, DAYD, LATITUDE and LONGITUDE varying following
dimension PROFILE.

Exeaple of structure given with ncdump utility:

=for example

$ ncdump -v TIME,LATITUDE,LONGITUDE OS_PIRATA-FR24_CTD.nc
netcdf OS_PIRATA-FR24_CTD {
dimensions:
        TIME = 29 ;
        DEPTH = 4259 ;
variables:
        int PROFILE(TIME) ;
                PROFILE:standard_name = "PROFILE" ;
                PROFILE:long_name = "profiles list number" ;
                PROFILE:units = "integer" ;
                PROFILE:_FillValue = 99999 ;
        double TIME(TIME) ;
                TIME:standard_name = "TIME" ;
                TIME:long_name = "time" ;
                TIME:units = "days since 1950-01-01T00:00:00Z" ;
                TIME:_FillValue = 1.e+36 ;
                TIME:valid_min = 0 ;
                TIME:valid_max = 90000 ;
        float LATITUDE(TIME) ;
                LATITUDE:standard_name = "LATITUDE" ;
                LATITUDE:long_name = "latitude of each location" ;
                LATITUDE:units = "degrees_north" ;
                LATITUDE:_FillValue = 1.e+36f ;
                LATITUDE:valid_min = -90s ;
                LATITUDE:valid_max = 90s ;
        float LONGITUDE(TIME) ;
                LONGITUDE:standard_name = "LONGITUDE" ;
                LONGITUDE:long_name = "longitude of each location" ;
                LONGITUDE:units = "degrees_east" ;
                LONGITUDE:_FillValue = 1.e+36f ;
                LONGITUDE:valid_min = -180s ;
                LONGITUDE:valid_max = 180s ;
        float BATH(TIME) ;
                BATH:standard_name = "BATH" ;
                BATH:long_name = "bathymetric depth" ;
                BATH:units = "meters" ;
                BATH:_FillValue = 1.e+36f ;
                BATH:valid_min = 0s ;
                BATH:valid_max = 11000s ;
        float PRES(TIME, DEPTH) ;
                PRES:standard_name = "PRES" ;
                PRES:long_name = "sea_water_pressure sea surface=0" ;
                PRES:units = "decibar=10000 pascals" ;
                PRES:valid_min = 0s ;
                PRES:valid_max = 6500s ;
                PRES:_FillValue = 1.e+36f ;
        float DEPTH(TIME, DEPTH) ;
                DEPTH:standard_name = "DEPTH" ;
                DEPTH:long_name = "depth of each measurement" ;
                DEPTH:units = "meters" ;
                DEPTH:valid_min = 0s ;
                DEPTH:valid_max = 6000s ;
                DEPTH:_FillValue = 1.e+36f ;
        float TEMP(TIME, DEPTH) ;
                TEMP:standard_name = "TEMP" ;
                TEMP:long_name = "sea temperature" ;
                TEMP:units = "Celsius degree" ;
                TEMP:valid_min = 0s ;
                TEMP:valid_max = 30s ;
                TEMP:_FillValue = 1.e+36f ;
        float PSAL(TIME, DEPTH) ;
                PSAL:standard_name = "PSAL" ;
                PSAL:long_name = "practical salinity scale 1978" ;
                PSAL:units = "P.S.S.78" ;
                PSAL:valid_min = 33s ;
                PSAL:valid_max = 37s ;
                PSAL:_FillValue = 1.e+36f ;
        float DENS(TIME, DEPTH) ;
                DENS:standard_name = "DENS" ;
                DENS:long_name = "density (sigma-theta)" ;
                DENS:units = "kg/m3" ;
                DENS:valid_min = 10s ;
                DENS:valid_max = 35s ;
                DENS:_FillValue = 1.e+36f ;
        float DOX2(TIME, DEPTH) ;
                DOX2:standard_name = "DOX2" ;
                DOX2:long_name = "dissolved oxygen" ;
                DOX2:units = "micromole/kg" ;
                DOX2:valid_min = 0s ;
                DOX2:valid_max = 450s ;
                DOX2:_FillValue = 1.e+36f ;

// global attributes:
                :data_type = "OceanSITES profile data" ;
                :cycle_mesure = "PIRATA-FR24" ;
                :project_name = "AMMA" ;
                :plateforme_name = "LE SUROIT" ;
                :time_coverage_start = "2014-04-12T08:26:15Z" ;
                :time_coverage_end = "2014-05-07T17:48:45Z" ;
                :timezone = "GMT" ;
                :data_assembly_center = "IRD" ;
                :type_instrument = "SBE911+SBE03SBE03SBE04SBE04PAROSCIENTIFIC" ;
                :instrument_number = "09P10828-41920422040154815500419" ;
                :date_update = "2014-05-08T08:22:42Z" ;
                :pi_name = "BOURLES" ;
                :processing_state = "1A" ;
                :codification = "OOPC" ;
                :comment = "Extraction realised before post-calibration and chimical adjustment with temperature, salinity and oxygen from primary sensors" ;
                :title_summary = "CTD casts realised during PIRATA-FR24 cruise with SBE911plus and 2 LADCP 300khz" ;
                :Conventions = "CF-1.4, OceanSITES 1.2" ;
                :format_version = "1.2" ;
                :Netcdf_version = "3.6" ;
data:

 TIME = 23477.3515625, 23479.81640625, 23481.30078125, 23484.861328125, 
    23486.611328125, 23486.845703125, 23487.0625, 23487.2890625, 
    23487.486328125, 23487.703125, 23487.92578125, 23488.75390625, 
    23489.01171875, 23489.22265625, 23489.43359375, 23489.62890625, 
    23489.833984375, 23490.0390625, 23490.255859375, 23490.51953125, 
    23490.732421875, 23490.93359375, 23491.14453125, 23491.982421875, 
    23492.185546875, 23492.38671875, 23492.58203125, 23498.84765625, 
    23502.7421875 ;

 LATITUDE = 6.9998, 0.0025, -3.4393, -9.9113, -9.4992, -9.0005, -8.5013, 
    -8.0013, -7.5027, -7, -6.4982, -6.0118, -5.5128, -5.0005, -4.5047, 
    -4.001, -3.5043, -3.0122, -2.4988, -2.0008, -1.4978, -1.0103, -0.5045, 
    0.04117, 0.5015, 0.995, 1.4915, 0.04367, 0.01067 ;

 LONGITUDE = -20.317, -22.964, -18.522, -9.9823, -8.248, -8.5002, -8.7505, 
    -8.998, -9.2503, -9.4965, -9.7473, -10.012, -10.007, -9.9997, -10.004, 
    -10.004, -10.002, -10.003, -10.001, -10.001, -10.001, -10.003, -10.003, 
    -9.8775, -9.9997, -10.001, -10.002, -9.8697, 0.01383 ;
}


=head1 AUTHOR

Copyright (C) Jacques Grelet (Jacques.Grelet@ird.fr) IRD 2004-2014

This software is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

Address bug reports and comments to: Jacques.Grelet@ird.fr. 

=head1 CREDITS

Thanks very much to:

=over 4

=item Annie Kartavtsef (ak@lodyc.jussieu.fr)

=item Michel Fichaut (Michele.Fichaut@ifremer.fr)

=item Thierry Carval (Thierry Carval@ifremer.fr)

=cut 

#------------------------------------------------------------------------------
# Les variables globales
#------------------------------------------------------------------------------
my %opts;

my $file;
my $xml;

my %meta;    # contient les meta donnees (cycle_mesure, plateforme...)
my $ref_year = 1950;
my $profil_number;
my $d_profil_date_ref = undef;
my $colonne_prof;
my $dim_y;

# changer c_quality en c_quality_profile dans MLD
my ( $c_quality, $c_physical_param_code );
my ( $v_level, $c_quality_value, $c_quality_level, $v_value );
my %colonne       = ();
my %sismer        = ();
my @dimensions    = ();
my %dimensions    = ();
my %data          = ();       # contient les matrices PDL
my $missing_value = 0;
my $fill_value    = 1e+36;
my $date_debut    = undef;
my $date_fin      = undef;
my $indice        = 1;
my $pressure_max  = 0;
my $jj_offset     = 0;        # par defaut 01 janvier = 0
my $bottom_depth  = 1e36;
my $DEBUG         = 0;
my $ECHO          = undef;
my $SHORT         = undef;
my $NODTD         = undef;
my $ST            = undef;    # Station max
my $TRACE         = undef;
my $PMAX          = undef;
my $file_nc       = undef;
my $julian        = undef;
my $noroscop      = undef;
my $date_creation = undef;
my $os;
my ( $lat, $lon, $pres, $temp, $psal, $days, $date_ref, $year_base );

$os = ( uname )[ 4 ];
print "Support BadValues n'est pas compile sur cette plateforme : $os '\n"
  if ( ( $PDL::Bad::Status == 0 ) and ( $DEBUG > 0 ) );

#------------------------------------------------------------------------------
# version()
#------------------------------------------------------------------------------
sub version() {
  print "Version: $VERSION\nAuthor: $AUTHOR\n";
  print "Revison: $revision\n\n";
  exit 1;
}

#------------------------------------------------------------------------------
# usage()
#------------------------------------------------------------------------------
sub usage() {
  print STDERR "\nusage: oceano2oceansites.pl [options] file(s)\n\n";
  print STDERR
    "Options:\n    --help                 Display this help message\n";
  print STDERR "    --version              Program version\n";
  print STDERR "    --debug=[1-3]          Debug info\n";
  print STDERR "    --julian               Convert julian days from 1 to 0\n";
  print STDERR "    --echo                 Display filenames processed\n";
  print STDERR
    "    --short                Short output, don't add variable_xx\n";
  print STDERR "    --noroscop             Don't use ROSCOP codification\n";
  print STDERR "    --nodtd                Don't validate xml with DTD\n";
  print STDERR "    --max=<value>          Process to max depth or press \n";
  print STDERR "    --profil=<n>           Process profils to n\n";
  print STDERR "    --ouput=<file>         Write NetCDF data to <file> \n";
  print STDERR "    --cycle_mesure=<name>  cycle_mesure name\n";
  print STDERR "    --contexte=<name>      contexte name\n";
  print STDERR
    "    --date_debut=JJ/MM/YYYY     starting date from cycle_mesure\n";
  print STDERR "    --date_fin  =JJ/MM/YYYY     end date from cycle_mesure\n";
  print STDERR "    --plateforme=<name>    ship or plateforme name\n";
  print STDERR "    --institut=<name>      institute name\n";
  print STDERR "    --code_oopc=<value>    processing code\n";
  print STDERR "    --codification=<value> codification name\n";
  print STDERR "    --pi=<pi_name> \n";
  print STDERR "    --type_instrument=<instrument_type> \n";
  print STDERR "    --sn=<instrument_serial_number>\n";
  print STDERR "\naccept short options like -d1 -t2\n\n";
  print STDERR
"example:\n\$ oceano2oceansites.pl --cycle_mesure=PIRATA-FR24 --institut=IRD --plateforme='LE SUROIT' --type_instrument=SBE911+ --sn=09P29544 --pi=BOURLES --date_debut=09/04/2014 --date_fin=21/05/2014 --echo pirata-fr24_ctd.xml\n";
  print STDERR
    "\n\$ oceano2oceansites.pl --echo --short --nodtd pirata-fr24_ctd.xml\n";
  exit 1;
}

#------------------------------------------------------------------------------
# get_options()
# analyse les options
#------------------------------------------------------------------------------
sub get_options() {
  my $version;
  my $help;
  my $julian;

  &GetOptions(
    "cycle_mesure=s"    => \$meta{ 'cycle_mesure' },
    "contexte=s"        => \$meta{ 'contexte' },
    "plateforme=s"      => \$meta{ 'plateforme' },
    "date_debut=s"      => \$meta{ 'date_debut' },
    "date_fin=s"        => \$meta{ 'date_fin' },
    "institut=s"        => \$meta{ 'institut' },
    "type_instrument=s" => \$meta{ 'type_instrument' },
    "type=s"            => \$meta{ 'type_instrument' },    # for compatibility
    "sn=s"              => \$meta{ 'sn' },
    "pi=s"              => \$meta{ 'pi' },
    "code_oopc=s"       => \$meta{ 'code_oopc' },
    "codification=s"    => \$meta{ 'codification' },
    "max=i"             => \$PMAX,
    "profil=i"          => \$ST,
    "julian"            => \$julian,
    "noroscop"          => \$noroscop,
    "output=s"          => \$file_nc,
    "debug=i"           => \$DEBUG,
    "short"             => \$SHORT,
    "nodtd"             => \$NODTD,
    "echo"              => \$ECHO,
    "version"           => \$version,
    "help"              => \$help
  ) or &usage;
  &version if $version;
  &usage   if $help;
  $jj_offset = -1   if ( defined $julian );
  $PMAX      = 9999 if ( not defined $PMAX );
}

#------------------------------------------------------------------------------
# lecture du fichier de description des parametres physique (SISMER)
#------------------------------------------------------------------------------
sub read_physical_param_code {
  my ( $c_physical_param_code,
    $l_label, $l_unit, $v_min, $v_max, $l_format, $v_default );

  # on lit maintenant le contenu du fichier roscop a la fin du script
  # apres la directive _ _DATA_ _
  while ( <DATA> ) {
    if ( /^#/ ) {
      $. -= 1;
    }
    else {
      chomp;
      (
        $c_physical_param_code,
        $l_label, $l_unit, $v_min, $v_max, $l_format, $v_default
      ) = split /;/;
      $sismer{ "$c_physical_param_code:1" } = $l_label;
      $sismer{ "$c_physical_param_code:2" } = $l_unit;
      $sismer{ "$c_physical_param_code:3" } = $v_min;
      $sismer{ "$c_physical_param_code:4" } = $v_max;
      $sismer{ "$c_physical_param_code:5" } = $l_format;
      $sismer{ "$c_physical_param_code:6" } = $v_default;

      #print STDERR "$c_physical_param_code\n";
    }
  }

  #print Dumper(\%sismer);
}

#------------------------------------------------------------------------------
# ouvre_entete_file()
#
# lit le fichier xml
#   arg:     le fichier à lire
#   return:  l'arbre XML
#            -1 si erreur d'ouverture du fichier
#------------------------------------------------------------------------------
sub ouvre_entete_file {
  my ( $file ) = @_;

  # a modifier par la suite le test sur l'existance du fichier( bloc eval)
  open( FILE, $file ) || die "Erreur d'ouverture du fichier: $file\n";

  my $parser = XML::LibXML->new();

  my $tree = $parser->parse_file( $file );

  close( $file );

  if ( not defined $NODTD ) {

    # test si le document est valide,
    #   retourne l'arbre XML, sinon, retourne 0
    $tree->is_valid() ? return $tree->getDocumentElement : return 0;
  }
  else {
    return $tree->getDocumentElement;
  }
}

#------------------------------------------------------------------------------
# get_entete_info()
#
# recupere le(s) infos le fichier XML
#   arg:     l'arbre XML
#            le chemin XPATH
#   return:  la variable lue
#            0 si rien dans le noeud
#------------------------------------------------------------------------------
sub get_entete_info {
  my ( $root, $xpath ) = @_;

  my $var = $root->findvalue( $xpath );
  print "$var\n"         if ( $DEBUG == 2 );
  print "$xpath\t$var\n" if ( $DEBUG == 3 );

  return $var;
}

#------------------------------------------------------------------------------
# decode_entete_xml
# Cree une table de hachage globale %colonne associant le
# physical_parameter_code au numero de la colonne dans le fichier de donnees
#------------------------------------------------------------------------------
sub decode_entete_xml {
  my @nb_col = ();
  my $i      = 0;

  ### on recupere les valeurs de l'entete XML
  my $root = &ouvre_entete_file( $file );
  die
"Error: invalid $file document, may be check your global attributes ...\nExit\n\n"
    if ( !$root );

  $meta{ 'data_type' } = &get_entete_info( $root, '/OCEANO/@TYPE' );

  # replace PROFIL par 'OceanSITES profile data' for compatibility
  if ( $meta{ 'data_type' } =~ /PROFIL/i ) {
    $meta{ 'data_type' } = 'OceanSITES profile data';
  }
  if ( $meta{ 'data_type' } =~ /TRAJECTOIRE/
    or $meta{ 'data_type' } =~ /TRAJECTORY/i ) {
    $meta{ 'data_type' } = 'OceanSITES trajectory data';
  }
  if ( $meta{ 'data_type' } =~ /SERIE/
    or $meta{ 'data_type' } =~ /TIME-SERIES/i ) {
    $meta{ 'data_type' } = 'OceanSITES time-series data';
  }
  $meta{ 'plateforme' } =
    &get_entete_info( $root, '/OCEANO/ENTETE/PLATEFORME/LIBELLE' );
  $meta{ 'timezone' } =
    &get_entete_info( $root, '/OCEANO/ENTETE/CYCLE_MESURE/@TIMEZONE' );
  $meta{ 'contexte' } =
    &get_entete_info( $root, '/OCEANO/ENTETE/CYCLE_MESURE/@CONTEXTE' );
  $meta{ 'cycle_mesure' } =
    &get_entete_info( $root, '/OCEANO/ENTETE/CYCLE_MESURE/LIBELLE' );
  $meta{ 'pi' } =
    &get_entete_info( $root, '/OCEANO/ENTETE/CYCLE_MESURE/RESPONSABLE' );
  $meta{ 'institut' } =
    &get_entete_info( $root, '/OCEANO/ENTETE/CYCLE_MESURE/INSTITUT' );
  $meta{ 'comment' } =
    &get_entete_info( $root, '/OCEANO/ENTETE/CYCLE_MESURE/COMMENTAIRE' );
  $meta{ 'title_summary' } =
    &get_entete_info( $root, '/OCEANO/ENTETE/CYCLE_MESURE/TITLE_SUMMARY' );
  $meta{ 'code_oopc' } =
    &get_entete_info( $root, '/OCEANO/ENTETE/CYCLE_MESURE/VALIDATION/CODE' );
  $meta{ 'codification' } =
    &get_entete_info( $root,
    '/OCEANO/ENTETE/CYCLE_MESURE/VALIDATION/@CODIFICATION' );
  $meta{ 'type_instrument' } =
    &get_entete_info( $root, '/OCEANO/ENTETE/INSTRUMENT/@TYPE' );
  $meta{ 'sn' } =
    &get_entete_info( $root, '/OCEANO/ENTETE/INSTRUMENT/@NUMERO_SERIE' );

  # si une valeur est vide, on supprime la cle
  foreach ( keys %meta ) {
    delete $meta{ $_ } if !$meta{ $_ };
  }

  open( FILE, $file ) || die "Erreur d'ouverture du fichier: $file\n";

  # saute toutes les lignes precedents la balise <DATA>
  while ( <FILE> ) {
    next if $_ !~ /<DATA.*>/;
    last;
  }

  if ( not defined $meta{ 'cycle_mesure' } ) {
    print "Erreur $@" . " lors lecture entete cycle_mesure\n";
    exit 1;
  }
  else {
    if ( $ECHO ) {
      foreach ( values %meta ) {
        print "$_ ";
      }
      print "\n";
    }
  }

  ### on recupere les valeurs des entetes de colonnes
  $_      = uc readline( *FILE );
  @nb_col = split;
  foreach my $nb_col ( @nb_col ) {
    if (  ( $nb_col ne "ST" )
      and ( $nb_col ne "PROFIL" )
      and ( $nb_col ne "PROFILE" )
      and ( $nb_col ne "PRFL" )
      and ( $nb_col ne "N/A" )
      and ( $nb_col ne "NAVG" )
      and ( $nb_col ne "YEAR" )
      and ( $nb_col ne "BOTTLE" ) ) {

      # translate DEPH to DEPTH for OceanSITES convention
      $nb_col = 'DEPTH' if ( $nb_col eq 'DEPH' );
      $colonne{ $nb_col } = $i;
    }

 # rajoute pour les fichiers bouteilles car profondeur en colonne 3 au lieu de 2
 # ATTENTION, il faudra rajouter l'attribut positive, 'up' pour HEIG ou 'down'
    if ( ( $nb_col eq "PRES" )
      or ( $nb_col eq "DEPH" )
      or ( $nb_col eq "DEPTH" )
      or ( $nb_col eq "HEIG" ) ) {
      $colonne_prof = $i;
      $dim_y        = 'DEPTH';
    }
    $i++;
  }
  if ( $DEBUG == 2 ) {

    # print Dumper(\%colonne);
    foreach my $cle ( sort { $colonne{ $a } <=> $colonne{ $b } } keys %colonne )
    {
      print "'$cle' => $colonne{$cle},\n";
    }
    print "Profondeur= colonne $colonne_prof\n"
      if ( defined $colonne_prof );
  }
  close( FILE );
}

#------------------------------------------------------------------------------
# decode_entete_ascii
# Cree une table de hachage globale %colonne associant le
# physical_parameter_code au numero de la colonne dans le fichier de donnees
#------------------------------------------------------------------------------
sub decode_entete_ascii {
  my @nb_col = ();
  my $i      = 0;

  ### on recupere les valeurs de la ligne d'entete
  open( FILE, $file ) || die "Erreur d'ouverture du fichier: $file\n";

  # lit la premiere ligne et met en majuscule puis eclate les variables
  $_ = uc readline( *FILE );

  # supprime le caractere \n si il existe
  chomp;

  # sous Windows, supprime un eventuel \r
  $_ =~ s/\r//;
  (
    $meta{ 'cycle_mesure' },
    $meta{ 'plateforme' },
    $meta{ 'institut' },
    $meta{ 'type_instrument' },
    $meta{ 'sn' },
    $meta{ 'pi' }
  ) = split( /\s{2}/ );

  # si une valeur est vide, on supprime la cle
  foreach ( keys %meta ) {
    delete $meta{ $_ } if !$meta{ $_ };
  }

  if ( not defined $meta{ 'cycle_mesure' } ) {
    print "Erreur $@" . " lors lecture entete cycle_mesure\n";
    exit 1;
  }
  else {
    if ( $ECHO ) {
      foreach ( values %meta ) {
        print "$_ ";
      }
      print "\n";
    }
  }

  ### on recupere les valeurs des entetes de colonnes
  $_      = uc readline( *FILE );
  @nb_col = split;
  foreach my $nb_col ( @nb_col ) {
    if (  ( $nb_col ne "ST" )
      and ( $nb_col ne "PROFIL" )
      and ( $nb_col ne "PROFILE" )
      and ( $nb_col ne "PRFL" )
      and ( $nb_col ne "N/A" )
      and ( $nb_col ne "YEAR" )
      and ( $nb_col ne "NAVG" )
      and ( $nb_col ne "BOTTLE" ) ) {

      # translate DEPH to DEPTH for OceanSITES convention
      $nb_col = 'DEPTH' if ( $nb_col eq 'DEPH' );
      $colonne{ $nb_col } = $i;
    }

 # rajoute pour les fichiers bouteilles car profondeur en colonne 3 au lieu de 2
    if ( ( $nb_col eq "PRES" )
      or ( $nb_col eq "DEPH" )
      or ( $nb_col eq "DEPTH" )
      or ( $nb_col eq "HEIG" ) ) {
      $colonne_prof = $i;
      $dim_y        = 'DEPTH';
    }
    $i++;
  }
  if ( $DEBUG == 2 ) {

    # print Dumper(\%colonne);
    foreach my $cle ( sort { $colonne{ $a } <=> $colonne{ $b } } keys %colonne )
    {
      print "'$cle' => $colonne{$cle},\n";
    }
    print "Profondeur= colonne $colonne_prof\n"
      if ( defined $colonne_prof );
  }
  close( FILE );
}

#------------------------------------------------------------------------------
# Extrait les coordonnees du profil
#------------------------------------------------------------------------------
sub extrait_entete_profil {
  my ( @var ) = @_;
  my ( $julien, $time, $date, $mois, $jour, $annee, $heure, $min, $sec );

  $profil_number = $var[ 0 ];

  #$time = &dateFormat($var[5], "%Y%m%d%H%M%S");
  # recupere l'annee, mois, jour et heure
  $annee = substr( $var[ 5 ], 0,  4 );
  $mois  = substr( $var[ 5 ], 4,  2 );
  $jour  = substr( $var[ 5 ], 6,  2 );
  $heure = substr( $var[ 5 ], 8,  2 );
  $min   = substr( $var[ 5 ], 10, 2 );
  $sec   = substr( $var[ 5 ], 12, 2 );

  # transform to julian day with origin 1950
  $julien = &date2julian( $ref_year, $annee, $mois, $jour, $heure, $min, $sec );
  $dimensions{ 'TIME' }      = $julien;
  $dimensions{ 'LATITUDE' }  = $var[ 3 ];
  $dimensions{ 'LONGITUDE' } = $var[ 4 ];
  if ( defined $var[ 6 ] ) {
    $dimensions{ 'BATH' } = $var[ 6 ];
  }
  else {
    $dimensions{ 'BATH' } = 1e36;
  }
  printf "Read profil: %3d  %4d %9.5f %+8.5f %+9.5f, %4.4g\n", $profil_number,
    $ref_year, $dimensions{ 'TIME' }, $dimensions{ 'LATITUDE' },
    $dimensions{ 'LONGITUDE' }, $dimensions{ 'BATH' }
    if ( $ECHO );
}

#------------------------------------------------------------------------------
# give the number of data for trajectory or time-series
#------------------------------------------------------------------------------
sub get_indice_max {
  my @var;
  my $indice = 0;

  open( FILE, $file ) || die "Erreur d'ouverture du fichier: $file\n";

  ### on se positionne au debut des donnees
  if ( $xml ) {
    print "Read XML file :    $file ...  " if ( $DEBUG > 0 );

    # saute toutes les lignes precedents la balise <DATA>
    while ( <FILE> ) {
      next if $_ !~ /<DATA.*>/;
      last;
    }
    readline( *FILE );    # saute la ligne d'entete
  }
  else {
    print "Read ASCII file :    $file ...  " if ( $DEBUG > 0 );
    readline( *FILE );    # saute les 2 lignes d'entete
    readline( *FILE );
  }

  while ( <FILE> ) {
    if ( $xml ) { last if /<\/DATA>/; }    # fin des donnees (fichier XML)
    $indice++;
  }
  close( FILE );
  printf "\n",;
  printf "Julian Day = %d Indice_max: %d\n", $julian ? 1 : 0, $indice,
    if ( $DEBUG > 0 );

  # retourne la taille des objets PDL a creer
  return ( $indice );
}

#------------------------------------------------------------------------------
# donne la profondeur max et la taille (indice_max) de la plus grande matrice
#------------------------------------------------------------------------------
sub get_pmax {
  my @var;
  my $press        = 0;
  my $indice       = 0;
  my $pmax         = 0;
  my $pressure_max = 0;
  my $indice_max   = 1;
  my $profil_max   = 1;
  my $profil       = 0;
  my %profils      = ();    # la liste des numeros de profils lus

  open( FILE, $file ) || die "Erreur d'ouverture du fichier: $file\n";

  ### on se positionne au debut des donnees
  if ( $xml ) {
    print "Read XML file :    $file ...  " if ( $DEBUG > 0 );

    # saute toutes les lignes precedents la balise <DATA>
    while ( <FILE> ) {
      next if $_ !~ /<DATA.*>/;
      last;
    }
    readline( *FILE );    # saute la ligne d'entete
  }
  else {
    print "Read ASCII file :    $file ...  " if ( $DEBUG > 0 );
    readline( *FILE );    # saute les 2 lignes d'entete
    readline( *FILE );
  }

  while ( <FILE> ) {
    if ( $xml ) { last if /<\/DATA>/; }    # fin des donnees (fichier XML)

    @var = split;
    if ( $var[ 1 ] =~ -1 ) {               # entete profil, on reinitialise
      $profil_max = $var[ 0 ];
      #####
      # empile les numeros de profils dans le hash %profils
      $profils{ $profil++ } =
        $var[ 0 ];    # pas besoin d'utiliser profil_max, a revoir
                      # on stop la recherche a profil max
      if ( defined $ST and $profil_max > $ST ) {
        last;
      }
      $indice = 1;
      next;
    }
    else {
      $indice++;
      if ( $indice > $indice_max ) {
        $indice_max = $indice;
      }
      $press = $var[ $colonne_prof ];
      if ( $press > $PMAX ) {
        next;
      }
      else {
        if ( $press > $pressure_max ) {
          $pressure_max = $press;
        }
      }
    }
  }

  close( FILE );
  printf "\n",;
  printf
"Julian Day = %d Profondeur max: %d Indice_max: %d  Profil_max: %d Nb_profil: %d\n",
    $julian ? 1 : 0, $pressure_max, $indice_max - 1, $profil_max,
    scalar keys %profils
    if ( $DEBUG > 0 );

  # retourne la taille des objets PDL a creer
  return ( $indice_max - 1, $profil_max, %profils );
}

#------------------------------------------------------------------------------
# Read trajectory ASCII ou XML file, fill hashtable %colonne with keys/values
#------------------------------------------------------------------------------
sub read_profile_file {
  my @var;
  my $indice_mat = 0;
  my $nb_profil;
  my $profil = -1;

  # supprime le fichier NetCDF si il existe
  unlink $file_nc;

  # initialize @dimensions
  @dimensions = ( 'TIME', 'LATITUDE', 'LONGITUDE', 'BATH' );

  # recupere les dimensions des variables
  my ( $indice_max, $profil_max, %profils ) = &get_pmax();
  $nb_profil = scalar keys %profils;

  # creation des variables TIME, LATITUDE et LONGITUDE de type PDL float
  foreach my $cle ( @dimensions ) {

    # VERIFIER si on utilise $station_number ou $profil_number-1
    $data{ $cle } =
      $cle eq 'TIME'
      ? double zeroes( $nb_profil )
      : float zeroes( $nb_profil );
    $data{ $cle } .= 1e+36;
  }
  $data{ 'PROFILE' } = long zeroes( $nb_profil );

  #$data{'PROFILE'} .= 1e+36;

  # creation des variables ASCII stockees dans %colonne dont la cle est
  # au format ROSCOP(DEPTH/PRES, TEMP,PSAL,DENS,DOX1,... de type PDL float
  foreach my $cle ( sort { $colonne{ $a } <=> $colonne{ $b } } keys %colonne ) {
    $data{ $cle } = float ones( $indice_max, $nb_profil );
    $data{ $cle } .= 1e+36;
  }
  if ( $DEBUG == 5 ) {
    while ( my ( $key, $tab ) = each( %data ) ) {
      print "\nKey: $key\n$data{$key}\n";
    }
  }

  # on relit le fichier pour extraire les donnees
  open( FILE, $file );

  ### on se positionne au debut des donnees
  if ( $xml ) {

    # saute toutes les lignes precedents la balise <DATA>
    while ( <FILE> ) {
      next if $_ !~ /<DATA.*>/;
      last;
    }
    readline( *FILE );    # saute la ligne d'entete
  }
  else {
    readline( *FILE );    # saute les 2 lignes d'entete
    readline( *FILE );
  }

  while ( <FILE> ) {
    if ( $xml ) { last if /<\/DATA>/; }    # fin des donnees (fichier XML)

    @var = split;

    # traite le numero du profil
    if ( $var[ 1 ] =~ -1 ) {               # entete profil
      last if ( $var[ 0 ] > $profil_max );    #derniere profil on sort
      &extrait_entete_profil( @var );
      $indice_mat = 0;
      $profil++;

      # on remplit les "variables" netCDF dans les matrix PDL (entetes profils)
      foreach my $key ( @dimensions ) {

        # A VERIFIER pour le numero de profil
        #####
        set $data{ $key }, $profil, $dimensions{ $key };

        #print  "\nKey: $key\n$data{$key}  new: $dimensions{$key}\n";
      }

      # recupere le profil courant dans la liste
      set $data{ 'PROFILE' }, $profil, $profils{ $profil };
      foreach
        my $cle ( sort { $colonne{ $a } <=> $colonne{ $b } } keys %colonne ) {
        if ( $DEBUG == 3 ) {

          print Dumper( \%colonne );
          print 'Lit fichier: %colonne = ' . "'$cle' => $colonne{$cle}\n";
        }
      }

      #print "\nKey: 'PROFILE'\n$data{'PROFILE'}\n";
      #print "Indice: $profil  Profil: $profils{$profil}\n";
    }
    else {
      $v_level = $var[ $colonne_prof ];
      if ( $indice_mat < $indice_max ) {
        foreach my $cle (
          sort { $colonne{ $a } <=> $colonne{ $b } }
          keys %colonne
          ) {
          $indice          = $colonne{ $cle };
          $v_value         = $var[ $indice ];
          $c_quality_value = 1;
          $c_quality_level = 1;
          print "$v_level, $v_value, $cle, $indice\n"
            if ( $DEBUG == 3 );
          ####
          #print "$indice_mat, $profil\n";
          set $data{ $cle }, ( $indice_mat, $profil ), $v_value;
        }
        $indice_mat++;
      }
    }
  }
  close( FILE );

  if ( $DEBUG == 1 ) {

    #print Dumper keys %data;
    foreach my $key ( @dimensions ) {
      print $data{ $key }->info( "Type: %T  %D %C %M\n" );
    }
    foreach my $cle ( sort { $colonne{ $a } <=> $colonne{ $b } } keys %colonne )
    {
      print $data{ $cle }->info( "Type: %T  %D %C %M\n" );
    }
  }
  if ( $DEBUG == 2 ) {
    foreach my $key ( @dimensions ) {
      print "$data{$key}\n";
    }
    foreach my $cle ( sort { $colonne{ $a } <=> $colonne{ $b } } keys %colonne )
    {
      print $data{ $cle };
    }
  }
}

#------------------------------------------------------------------------------
# Read trajectory ASCII ou XML file, fill hashtable %colonne with keys/values
#------------------------------------------------------------------------------
sub read_trajectory_file {
  my @var;
  my $indice_mat = 0;
  my ( $julien, $year, $annee, $mois, $jour, $heure, $min, $sec );
  my %col;

  # delete previous NetCDF file
  unlink $file_nc;

  # initialize @dimensions
  @dimensions = ( 'TIME', 'LATITUDE', 'LONGITUDE' );

  # read the file and return the size of data for dimension TIME
  my ( $indice_max ) = &get_indice_max();

  # create variables in hash %colonne with keys are ROSCOP
  # TEMP,PSAL,DENS,DOX1,... as PDL float
  foreach my $cle ( sort { $colonne{ $a } <=> $colonne{ $b } } keys %colonne ) {
    given ( $cle ) {
      when ( 'DAYD' ) {    # time is double
        $data{ 'TIME' } = double zeroes( $indice_max );
        $data{ 'TIME' } .= 1e+36;
        $col{ 'TIME' } = $colonne{ $cle };
      }
      when ( 'LATX' ) {    # time is double
        $data{ 'LATITUDE' } = float zeroes( $indice_max );
        $data{ 'LATITUDE' } .= 1e+36;
        $col{ 'LATITUDE' } = $colonne{ $cle };
      }
      when ( 'LONX' ) {    # time is double
        $data{ 'LONGITUDE' } = float zeroes( $indice_max );
        $data{ 'LONGITUDE' } .= 1e+36;
        $col{ 'LONGITUDE' } = $colonne{ $cle };
      }
      when ( 'YEAR' ) { }
      default {
        $data{ $cle } = float zeroes( $indice_max );
        $data{ $cle } .= 1e+36;
        $col{ $cle } = $colonne{ $cle };
      }
    }
  }
  if ( $DEBUG == 5 ) {
    while ( my ( $key, $tab ) = each( %data ) ) {
      print "\nKey: $key\n$data{$key}\n";
    }
  }

  # read file for a second time and extract data
  open( FILE, $file );

  ### on se positionne au debut des donnees
  if ( $xml ) {

    # saute toutes les lignes precedents la balise <DATA>
    while ( <FILE> ) {
      next if $_ !~ /<DATA.*>/;
      last;
    }
    readline( *FILE );    # saute la ligne d'entete
  }
  else {
    readline( *FILE );    # saute les 2 lignes d'entete
    readline( *FILE );
  }

  while ( <FILE> ) {
    if ( $xml ) { last if /<\/DATA>/; }    # fin des donnees (fichier XML)

    # read and split each line
    @var = split;

    # get reference year for file from the first line
    $year = $var[ 0 ] if ( $indice_mat == 0 );

    # loop over each columns, read values and store in hash data
    foreach my $cle ( keys %data ) {
      $indice          = $col{ $cle };
      $v_value         = $var[ $indice ];
      $c_quality_value = 1;
      $c_quality_level = 1;

      # transform julian day from current year to julian day from 1950
      if ( $cle eq 'TIME' ) {
        ( $annee, $mois, $jour, $heure, $min, $sec ) =
          &julian2date( $year, $v_value );
        $v_value =
          &date2julian( $ref_year, $annee, $mois, $jour, $heure, $min, $sec );
      }

      # debug
      print "$v_value, $cle, $indice\n" if ( $DEBUG == 3 );

      # fill peedles
      set $data{ $cle }, ( $indice_mat ), $v_value;
    }
    $indice_mat++;
  }
  close( FILE );

  if ( $DEBUG == 1 ) {

    #print Dumper keys %data;
    foreach my $cle ( @dimensions ) {
      print "Key: $cle, ";
      print $data{ $cle }->info( "Type: %T  %D %C %M\n" );
    }
    foreach my $cle ( sort { $col{ $a } <=> $col{ $b } } keys %col ) {
      print "Key: $cle, ";
      print $data{ $cle }->info( "Type: %T  %D %C %M\n" );
    }
  }
  if ( $DEBUG == 2 ) {
    foreach my $key ( @dimensions ) {
      print "$data{$key}\n";
    }
    foreach my $cle ( sort { $col{ $a } <=> $col{ $b } } keys %col ) {
      print $data{ $cle };
    }
  }
  %colonne = %col;
}

#------------------------------------------------------------------------------
# Read trajectory ASCII ou XML file, fill hashtable %colonne with keys/values
#------------------------------------------------------------------------------
sub read_timeseries_file {
  my @var;
  my $indice_mat = 0;
  my ( $julien, $year, $annee, $mois, $jour, $heure, $min, $sec );
  my %col;
  print STDERR "Conversion to OceanSITES time-series not yet implemented\n";
  exit;
}

#------------------------------------------------------------------------------
# write_netcdf_file
#------------------------------------------------------------------------------
sub write_netcdf_file {
  my $dim;

  # Si les dates elles ne sont pas passees en arguments, on les definies ici en
  # utilisant les fonctions min et max de PDL::Ufunc et &julian2date de
  # Oceano::Convert

  if ( not defined $meta{ 'date_debut' } ) {
    my ( $y, $m, $d, $h, $mn, $s ) =
      &julian2date( $ref_year, min( $data{ 'TIME' } ) );
    $meta{ 'date_debut' } = sprintf "%04d-%02d-%02dT%02d:%02d:%02dZ", $y, $m,
      $d, $h, $mn, $s;
  }
  else {
    $meta{ 'date_debut' } =
      &UnixDate( &ParseDate( $meta{ 'date_debut' } ), "%Y-%m-%dT%H:%M:%SZ" );
  }
  if ( not defined $meta{ 'date_fin' } ) {
    my ( $y, $m, $d, $h, $mn, $s ) =
      &julian2date( $ref_year, max( $data{ 'TIME' } ) );
    $meta{ 'date_fin' } = sprintf "%04d-%02d-%02dT%02d:%02d:%02dZ", $y, $m,
      $d, $h, $mn, $s;
  }
  else {
    $meta{ 'date_fin' } =
      &UnixDate( &ParseDate( $meta{ 'date_fin' } ), "%Y-%m-%dT%H:%M:%SZ" );
  }

  # ecriture du fichier NetCDF
  print "Create NetCDF file : $file_nc\n" if ( $ECHO );

  if ( $DEBUG == 4 ) {
    while ( my ( $key, $tab ) = each( %data ) ) {
      print "\nKey: $key\n$data{$key}\n";
    }
  }

  #----------------------------------------------------------------------------
  # ATTENTION - BE CAREFUL - ATTENTION - BE CAREFUL - ATTENTION - BE CAREFUL
  # Ne modifier les lignes qu'en étant sur du résultat
  # En cas d'erreur, le module PDL::NetCDF ne donne pas le numero de la ligne
  # du programme appelant (cf oceano2cdf.pl), il est donc extremement difficile
  # de remonter a la source de l'erreur !!!!!
  #----------------------------------------------------------------------------

  # ouverture du fichier netcdf en mode creation
  my $ncobj = PDL::NetCDF->new( ">$file_nc" );    # New file

  # formatte les dates suivant la convention utilisee dans le fichier
  $date_creation =
    &UnixDate( &ParseDate( "maintenant" ), "%Y-%m-%dT%H:%M:%SZ" );

  print "Writing Global attributes\n" if ( $ECHO );

  $meta{ 'Netcdf_version' } = "3.6";
  $meta{ 'Conventions' }    = "CF-1.4, OceanSITES 1.2";
  $meta{ 'format_version' } = "1.2";

  # globals attributes definition
  $ncobj->putatt( $meta{ 'data_type' }, 'data_type' )
    if ( exists $meta{ 'data_type' } );
  $ncobj->putatt( $meta{ 'cycle_mesure' }, 'cycle_mesure' )
    if ( exists $meta{ 'cycle_mesure' } );
  $ncobj->putatt( $meta{ 'contexte' }, 'project_name' )
    if ( exists $meta{ 'contexte' } );
  $ncobj->putatt( $meta{ 'plateforme' }, 'plateforme_name' )
    if ( exists $meta{ 'plateforme' } );
  $ncobj->putatt( $meta{ 'date_debut' }, 'time_coverage_start' );
  $ncobj->putatt( $meta{ 'date_fin' },   'time_coverage_end' );
  $ncobj->putatt( $meta{ 'timezone' },   'timezone' )
    if ( exists $meta{ 'timezone' } );
  $ncobj->putatt( $meta{ 'institut' }, 'data_assembly_center' )
    if ( exists $meta{ 'institut' } );
  $ncobj->putatt( $meta{ 'type_instrument' }, 'type_instrument' )
    if ( exists $meta{ 'type_instrument' } );
  $ncobj->putatt( $meta{ 'sn' }, 'instrument_number' )
    if ( exists $meta{ 'sn' } );
  $ncobj->putatt( $date_creation, 'date_update' );
  $ncobj->putatt( $meta{ 'pi' },  'pi_name' )
    if ( exists $meta{ 'pi' } );
  $ncobj->putatt( $meta{ 'code_oopc' }, 'processing_state' )
    if ( exists $meta{ 'code_oopc' } );
  $ncobj->putatt( $meta{ 'codification' }, 'codification' )
    if ( exists $meta{ 'codification' } );
  $ncobj->putatt( $meta{ 'data_mode' }, 'data_mode' )
    if ( exists $meta{ 'data_mode' } );
  $ncobj->putatt( $meta{ 'comment' }, 'comment' )
    if ( exists $meta{ 'comment' } );
  $ncobj->putatt( $meta{ 'title_summary' }, 'title_summary' )
    if ( exists $meta{ 'title_summary' } );
  $ncobj->putatt( $meta{ 'Conventions' }, 'Conventions' )
    if ( exists $meta{ 'Conventions' } );
  $ncobj->putatt( $meta{ 'format_version' }, 'format_version' )
    if ( exists $meta{ 'format_version' } );
  $ncobj->putatt( $meta{ 'Netcdf_version' }, 'Netcdf_version' )
    if ( exists $meta{ 'Netcdf_version' } );

  if ( $meta{ 'data_type' } eq 'OceanSITES profile data' ) {

    # PROFILE: cette variable va contenir la liste des numeros de profils
    # dans ce cas cette definition rentrerait dans la boucle foreach suivante
    $ncobj->put( 'PROFILE', [ 'TIME' ], $data{ 'PROFILE' } );
    $ncobj->putatt( "PROFILE",                 'standard_name', 'PROFILE' );
    $ncobj->putatt( lc "PROFILES LIST NUMBER", 'long_name',     'PROFILE' );
    $ncobj->putatt( "integer",                 'units',         'PROFILE' );
    $ncobj->putatt( long( [ 99999 ] ), '_FillValue', 'PROFILE' );
  }

  # Boucle de creation des variables 1D soit TIME, LATITUDE, LONGITUDE et BATH
  foreach my $cle ( @dimensions ) {
    print "Writing variable : $cle\n" if ( $ECHO );
    if ( $cle eq 'TIME' ) {    # time is double
      $ncobj->put( "$cle", [ 'TIME' ], double $data{ $cle } );
    }
    else {
      $ncobj->put( "$cle", [ 'TIME' ], $data{ $cle } );
    }
    $ncobj->putatt( $cle,                   "standard_name", $cle );
    $ncobj->putatt( lc $sismer{ "$cle:1" }, "long_name",     $cle );
    $ncobj->putatt( $sismer{ "$cle:2" },    'units',         $cle );
    if ( $cle eq 'TIME' ) {
      $ncobj->putatt( double( [ $fill_value ] ),         "_FillValue", $cle );
      $ncobj->putatt( long(   [ $sismer{ "$cle:3" } ] ), 'valid_min',  $cle );
      $ncobj->putatt( long(   [ $sismer{ "$cle:4" } ] ), 'valid_max',  $cle );
    }
    else {
      $ncobj->putatt( float( [ $fill_value ] ),         "_FillValue", $cle );
      $ncobj->putatt( short( [ $sismer{ "$cle:3" } ] ), 'valid_min',  $cle );
      $ncobj->putatt( short( [ $sismer{ "$cle:4" } ] ), 'valid_max',  $cle );
    }
  }

  #print Dumper keys %colonne;

  # for each variables (cle), create variables and attributes
  foreach my $cle ( sort { $colonne{ $a } <=> $colonne{ $b } } keys %colonne ) {

    # for trajectory or time-series, don't rewrite keys in @dimensions
    next if ( grep( /$cle/, @dimensions ) );

    print "Writing variable : $cle\n" if ( $ECHO );

    # cree chaques variables a 2 dimensions ex: float TEMP(TIME,DEPTH)
    if ( defined $dim_y ) {
      $ncobj->put( $cle, [ 'TIME', "$dim_y" ], $data{ $cle } );
    }
    else {
      $ncobj->put( $cle, [ 'TIME' ], $data{ $cle } );
    }

    # attach  attribute to variables
    $ncobj->putatt( $cle, "standard_name", $cle );
    if ( defined $noroscop || not exists $sismer{ "$cle:1" } )
    {    # on n'utilise pas les defintions roscop
      warn( "Variable $cle isn't defined as ROSCOP key\n" );
    }
    else {
      $ncobj->putatt( lc $sismer{ "$cle:1" }, "long_name", $cle );
      $ncobj->putatt( $sismer{ "$cle:2" },    "units",     $cle );
      $ncobj->putatt( short( [ $sismer{ "$cle:3" } ] ), 'valid_min',  $cle );
      $ncobj->putatt( short( [ $sismer{ "$cle:4" } ] ), 'valid_max',  $cle );
      $ncobj->putatt( float( [ $fill_value ] ),         "_FillValue", $cle );
    }

    if ( not defined $SHORT ) {

      # cree la variable <var>_QC
      printf STDERR "Writing variable : %s_QC\n", $cle if ( $ECHO );
      $ncobj->put(
        $cle . '_QC',
        [ 'TIME', "$dim_y" ],
        byte zeroes( dims $data{ $cle } )
      );
      if ( not defined $noroscop && $sismer{ "$cle:1" } ) {
        $ncobj->putatt( lc $sismer{ "$cle:1" } . " quality flag",
          "long_name", $cle . '_QC' );
        $ncobj->putatt( "GOSUD ref table", "conventions", $cle . '_QC' );
        $ncobj->putatt( "0, 1, 2, 3, 4, 5, 7, 8, 9",
          "flag_values", $cle . '_QC' );
        $ncobj->putatt(
          "no_qc_performed, good_data, probably_good_data,"
            . " bad_data_that_are_potentially_correctable, bad_data,"
            . " value_changed, not_used, nominal_value, interpolated_value,"
            . " missing_value",
          "flag_meanings",
          $cle . '_QC'
        );
        $ncobj->putatt( byte( [ $missing_value ] ),
          "default_value", $cle . '_QC' );
      }

      # cree la variable <var>_CAL
      my $var = float zeroes( dims $data{ $cle } );
      $var .= float( 1e+36 );
      printf STDERR "Writing variable : %s_CAL\n", $cle if ( $ECHO );
      $ncobj->put( $cle . '_CAL', [ 'TIME', "$dim_y" ], $var );
      if ( not defined $noroscop && $sismer{ "$cle:1" } ) {
        $ncobj->putatt( lc $sismer{ "$cle:1" } . ' calibrated',
          "long_name", $cle . '_CAL' );
        $ncobj->putatt( $sismer{ "$cle:2" }, "units", $cle . '_CAL' );
        $ncobj->putatt( short( [ $sismer{ "$cle:3" } ] ),
          'valid_min', $cle . '_CAL' );
        $ncobj->putatt( short( [ $sismer{ "$cle:4" } ] ),
          'valid_max', $cle . '_CAL' );
        $ncobj->putatt( float( [ $fill_value ] ), "_FillValue", $cle . '_CAL' );
      }

      # cree la variable <var>_ADJUSTED
      $var = float zeroes( dims $data{ $cle } );
      $var .= $fill_value;
      printf STDERR "Writing variable : %s_ADJUSTED\n", $cle if ( $ECHO );
      $ncobj->put( $cle . '_ADJUSTED', [ 'TIME', "$dim_y" ], $var );
      if ( not defined $noroscop && $sismer{ "$cle:1" } ) {
        $ncobj->putatt( lc $sismer{ "$cle:1" } . ' adjusted',
          "long_name", $cle . '_ADJUSTED' );
        $ncobj->putatt( $sismer{ "$cle:2" }, "units", $cle . '_ADJUSTED' );
        $ncobj->putatt( short( [ $sismer{ "$cle:3" } ] ),
          'valid_min', $cle . '_ADJUSTED' );
        $ncobj->putatt( short( [ $sismer{ "$cle:4" } ] ),
          'valid_max', $cle . '_ADJUSTED' );
        $ncobj->putatt( float( [ $fill_value ] ),
          "_FillValue", $cle . '_ADJUSTED' );
      }

      # cree la variable <var>_ADJUSTED_ERRO
      $var = float zeroes( dims $data{ $cle } );
      $var .= $fill_value;
      printf STDERR "Writing variable : %s_ADJUSTED_ERRO\n", $cle
        if ( $ECHO );
      $ncobj->put( $cle . '_ADJUSTED_ERRO', [ 'TIME', "$dim_y" ], $var );
      if ( not defined $noroscop && $sismer{ "$cle:1" } ) {
        $ncobj->putatt( lc 'Error on adjusted ' . $sismer{ "$cle:1" },
          "long_name", $cle . '_ADJUSTED_ERRO' );
        $ncobj->putatt( $sismer{ "$cle:2" }, "units", $cle . '_ADJUSTED_ERRO' );
        $ncobj->putatt( short( [ $sismer{ "$cle:3" } ] ),
          'valid_min', $cle . '_ADJUSTED_ERRO' );
        $ncobj->putatt( short( [ $sismer{ "$cle:4" } ] ),
          'valid_max', $cle . '_ADJUSTED_ERRO' );
        $ncobj->putatt( float( [ $fill_value ] ),
          "_FillValue", $cle . '_ADJUSTED_ERRO' );
      }

      # cree la variable <var>_ADJUSTED_QC
      printf STDERR "Writing variable : %s_ADJUSTED_QC\n", $cle
        if ( $ECHO );
      $ncobj->put(
        $cle . '_ADJUSTED_QC',
        [ 'TIME', "$dim_y" ],
        byte zeroes( dims $data{ $cle } )
      );
      if ( not defined $noroscop && $sismer{ "$cle:1" } ) {
        $ncobj->putatt( lc $sismer{ "$cle:1" } . " ajusted quality flag",
          "long_name", $cle . '_ADJUSTED_QC' );
        $ncobj->putatt( "GOSUD ref table",
          "conventions", $cle . '_ADJUSTED_QC' );
        $ncobj->putatt( "0, 1, 2, 3, 4, 5, 7, 8, 9",
          "flag_values", $cle . '_ADJUSTED_QC' );
        $ncobj->putatt(
          "no_qc_performed, good_data, probably_good_data,"
            . " bad_data_that_are_potentially_correctable, bad_data,"
            . " value_changed, not_used, nominal_value, interpolated_value,"
            . " missing_value",
          "flag_meanings",
          $cle . '_ADJUSTED_QC'
        );
        $ncobj->putatt( byte( [ $missing_value ] ),
          "default_value", $cle . '_ADJUSTED_QC' );
      }
    }
  }

  # fermeture du fichier
  $ncobj->close;
}

#------------------------------------------------------------------------------
# Debut du programme principal
#------------------------------------------------------------------------------
&Date_Init( "TZ=UTC", "Language=French", "DateFormat=non-US" );
&usage if ( $#ARGV == -1 );
&get_options;
&read_physical_param_code;

# boucle principale de lecture du/des fichiers ASCII ou XML
foreach my $arg ( @ARGV ) {
  %data    = ();        # il faut re-initialiser les hashs lors du traitement de
  %colonne = ();        # plusieurs profils
  $file    = $arg;
  $arg     = uc $arg;
  if ( $arg =~ s/\.XML$/\.nc/i ) {
    $xml = 1;
    $file_nc = "OS_$arg" if ( not defined $file_nc );
    &decode_entete_xml;
  }
  else {
    $xml = 0;
    $file_nc = "OS_$arg.nc" if ( not defined $file_nc );
    &decode_entete_ascii;
  }
  if ( $meta{ 'data_type' } =~ /OceanSITES profile data/ ) {
    &read_profile_file;
  }
  if ( $meta{ 'data_type' } =~ /OceanSITES trajectory data/ ) {
    &read_trajectory_file;
  }
  if ( $meta{ 'data_type' } =~ /OceanSITES time-series data/ ) {
    &read_timeseries_file;
  }
  &write_netcdf_file;
  $file_nc = undef;
}

__DATA__
N/A;NOT AVAILABLE;N/A;;;%5.1g;1e36
CUPW;14C PRODUCTION UNKNOWN FILTER;milligram carbon/(m3.day);0;200;%6.2lf;999.99
C1UW;14C UPTAKE 0.2-1 MICRON;milligram carbon/(m3.day);0;100;%6.2lf;999.99
BFUP;19'BUTANOYLOXYFUCOXANTHINE;milligram/m3;0;5;%6.3lf;99.999
HFUP;19'HEXANOYLOXYFUCOXANTHINE;milligram/m3;0;5;%6.3lf;99.999
ASDW;ABSORPTION STANDARD DEVIATION;milligram/m3;0;10;%5.2lf;99.99
MALF;AL FLUX IN SETTLING PARTICLES;milligram/(m2.day);0;180;%6.2lf;999.99
ALKY;ALKALINITY;millimole/m3;1500;2500;%4.0lf;9999
ALKW;ALKALINITY;micromole/kg;0;9000;%6.1lf;9999.9
AXAP;ALLOXANTHINE;milligram/m3;0;5;%6.3lf;99.999
ABCP;ALPHA BETA CAROTENES;milligram/m3;0;5;%6.3lf;99.999
AMOW;AMMONIUM (NH4-N) CONTENT;micromole/kg;0;1;%6.3lf;99.999
AMON;AMMONIUM (NH4-N) CONTENT;millimole/m3;0;10;%6.2lf;999.99
NHRW;AMMONIUM REGENERATION;micromole nitrogen/(m3.day);0;99;%5.0lf;99999
NHUW;AMMONIUM UPTAKE;micromole nitrogen/(m3.day);0;900;%5.0lf;99999
ATMP;ATMOSPHERIC PRESSURE;hectopascal;1000;1030;%8.3lf;9999.999
ATMS;ATMOSPHERIC PRESSURE - SEA LEV;hectopascal;1000;1030;%8.3lf;9999.999
NFAW;AUTOTROPHIC NANOFLAGELLATES;10+3 cell/m3;0;900000;%6.0lf;999999
VTZA;AVER ZERO CROSSING WAVE PERIOD;second;0;500;%3.0lf;999
VAVH;AVER. HEIGHT HIGHEST 1/3 WAVE;metre;0;30;%5.2lf;99.99
NAVG;AVERAGED DATA CYCLE NUMBER;number;0;999;%3.0lf;999;0 10|0 50|0 100|0 200|0 500|0 1000
MALP;Al IN SUSPENDED MATTER;milligram/m3;0;99.999;%6.3lf;99.999
MALS;Al IN THE SEDIMENT;%;0;99;%6.3lf;99.999
BCCS;BACTERIA NUMBER SEDIMENT;10+9 cell/dm3;0;9999.9;%6.1lf;9999.9
BCMW;BACTERIAL BIOMASS IN SEA WATER;milligram C/m3;0;16;%6.3lf;99.999
BATH;BATHYMETRIC DEPTH;meters;0;11000;%6.1lf;-999.9
MBAP;Ba IN SUSPENDED MATTER;milligram/m3;0;99.9999;%7.4lf;99.9999
MBAS;Ba IN THE SEDIMENT;ppm;0;5000;%7.2lf;9999.99
MBRS;Br IN THE SEDIMENT;ppm;-50;50;%+6.2lf;-99.99
CO3P;CARBONATES CONTENT;%;0;99.99;%5.2lf;99.99
CODW;CHEMICAL OXYGEN DEMAND;millimole/m3;0;650;%7.3lf;999.999
CH1P;CHL-A(LESS DIVINYLCHL-A);milligram/m3;0;3;%6.3lf;99.999
CH2P;CHL-B(LESS DIVINYLCHL-B);milligram/m3;0;1;%6.3lf;99.999
CH1T;CHLOROPHYLL TOTAL;microgram/kg;0;10;%5.2lf;99.99
CPH1;CHLOROPHYLL-A TOTAL;milligram/m3;0;99;%5.2lf;99.99
CPHL;CHLOROPHYLL-A TOTAL;milligram/m3;0;99;%5.2lf;99.99
CPH2;CHLOROPHYLL-A TOTAL;milligram/m3;0;99;%5.2lf;99.99
CHAF;CHLOROPHYLL-A VERTICAL FLUX;milligram/(m2.day);0;99;%6.3lf;99.999
CPH3;CHLOROPHYLL-A/2 MICRON FILTER;milligram/m3;0;99;%5.2lf;99.99
CPH4;CHLOROPHYLL-A/20 MICRON FILTER;milligram/m3;0;99;%5.2lf;99.99
CHLB;CHLOROPHYLL-B TOTAL;milligram/m3;0;99;%5.2lf;99.99
CHLC;CHLOROPHYLL-C TOTAL;milligram/m3;0;99;%6.3lf;99.999
CHCZ;CHLOROPHYLL-C1+C2;milligram/m3;0;900;%6.3lf;99.999
CHC3;CHLOROPHYLL-C3;milligram/m3;0;5;%6.3lf;99.999
CHLT;CHLOROPHYLL-TOTAL;milligram/m3;0;99;%5.2lf;99.99
CLAY;CLAY IN THE SEDIMENT;%;0;100;%6.2lf;999.99
FCO2;CO2 FUGACITY;microatmosphere;0;1000;%6.1lf;9999.9
XCO2;CO2 MOLE FRACTION IN DRY GAS;ppm;0;5000;%8.3lf;9999.999
PCO2;CO2 PART. PRES IN DRY/WET GAS;microatmosphere;100;700;%7.3lf;999.999
COPF;COCCOLITHOPHORIDAE PPC FLUX;milligram C/(m2.day);0;99.999;%6.3lf;99.999
PREC;CORRECTED SEA PRESSURE;decibar=10000 pascals;0;6500;%6.1lf;-999.9
MCUF;CU FLUX IN SETTLING PARTICLES;microgram/(m2.day);0;120;%6.2lf;999.99
EWCS;CURRENT EAST  STD. DEVIATION;cm/s;0;20;%+6.3lf;99.999;0 5|0 10
EWCT;CURRENT EAST COMPONENT;cm/s;-100;100;%+7.3lf;-99.999;-10 10|-20 20|-50 50|-100 100|-150 150|-200 200
NSCT;CURRENT NORTH COMPONENT;cm/s;-100;100;%+7.3lf;-99.999;-10 10|-20 20|-50 50|-100 100|-150 150|-200 200
NSCS;CURRENT NORTH STD. DEVIATION;cm/s;0;20;%+7.3lf;-99.999;0 5|0 10
MCAP;Ca IN SUSPENDED MATTER;milligram/m3;0;99.999;%6.3lf;99.999
MCAS;Ca IN THE SEDIMENT;%;0;99;%6.3lf;99.999
MCES;Ce IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
MCLP;Cl IN SUSPENDED MATTER;milligram/m3;0;99.999;%6.3lf;99.999
MCRS;Cr IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
MCUS;Cu IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
DCAW;DARK CARBON ABSORPTION;milligram/m3;-0.05;10;%5.2lf;99.99
CDFW;DARK FIXATION;milligram carbon/(m3.day);0;2;%5.2lf;99.99
DATE;DATE;mmdd;101;1231;%4.4d;9999
DAYX;DAY WITHIN MONTH;dd;1;31;%2.2d;99
DAYS;DAY WITHIN YEAR;decimal day;1;366;%9.5lf;999.99999
D13C;DELTA 13 C SIGNATURE;%;-50;100;%6.2lf;999.99
C13D;DELTA 13C (13C/12C);per thousand;-50;100;%5.1lf;999.9
N15D;DELTA 15N (15N/14N);per thousand;-2;10;%5.1lf;999.9
HELD;DELTA HELIUM 3;%;-99;99;%6.2lf;999.99
DENS;DENSITY (Sigma-theta);kg/m3;10;35;%6.3lf;99.999;0 20|10 20|0 30|10 30|20 30
DEN1;DENSITY (Sigma-theta) PRIMARY SENSORS;kg/m3;10;35;%6.3lf;99.999;0 20|10 20|0 30|10 30|20 30
DEN2;DENSITY (Sigma-theta) SECONDARY SENSORS;kg/m3;10;35;%6.3lf;99.999;0 20|10 20|0 30|10 30|20 30
DPS1;DEPTH BELOW BOTTOM-LOWER LIMIT;meters;0;11000;%6.1lf;-999.9
DPSF;DEPTH BELOW SEA FLOOR;meters;0;11000;%6.1lf;-999.9
DEPH;DEPTH BELOW SEA SURFACE;meters;0;6000;%6.1lf;-999.9;0 50|0 100|0 250|0 500|0 700|0 800|0 900|0 1000|0 1200|0 1500|0 2000|0 2500|0 4000|1000 2000|3800 4200|2000 4000
DEPTH;DEPTH of each measurement;meters;0;6000;%6.1lf;-999.9;0 50|0 100|0 250|0 500|0 700|0 800|0 900|0 1000|0 1200|0 1500|0 2000|0 2500|0 4000|1000 2000|3800 4200|2000 4000
DXAP;DIADINOXANTHINE;milligram/m3;0;5;%6.3lf;99.999
DIPF;DIATOMS PPC FLUX;milligram C/(m2.day);0;99.999;%6.3lf;99.999
TXAP;DIATOXANTHINE;milligram/m3;0;5;%6.3lf;99.999
DFPF;DINOFLAGELLATES PPC FLUX;milligram C/(m2.day);0;99.999;%6.3lf;99.999
HCDT;DIRECTION REL. TRUE NORTH;degree;0;360;%5.1lf;999.9
TPAW;DISS. TRIPHOSPHATE ADENOSINE;milligram/m3;0;1;%6.3lf;99.999
ETHW;DISSOLVED 234 TH ACT. ERROR;Bq/m3;0;90;%6.3lf;99.999
TH4W;DISSOLVED 234TH;Bq/m3;0;90;%6.3lf;99.999
CL4W;DISSOLVED C-TETRACHLORIDE;picomole/kg;0;10;%6.3lf;99.999
CO2W;DISSOLVED CARBON DIOXYD (CO2);millimole/m3;0;4800;%6.1lf;9999.9
CF1W;DISSOLVED CFC11;picomole/kg;-0.01;90;%7.4lf;99.9999
CE1W;DISSOLVED CFC11 ERROR;picomole/kg;0;0.5;%6.3lf;99.999
EF1W;DISSOLVED CFC11 ERROR;%;0;100;%6.3lf;99.999
CF3W;DISSOLVED CFC113;picomole/kg;0;5;%6.3lf;99.999
CE3W;DISSOLVED CFC113 ERROR;picomole/kg;0;0.5;%6.3lf;99.999
EF3W;DISSOLVED CFC113 ERROR;%;0;100;%6.3lf;99.999
CF2W;DISSOLVED CFC12;picomole/kg;-0.01;90;%7.4lf;99.9999
CE2W;DISSOLVED CFC12 ERROR;picomole/kg;0;0.5;%6.3lf;99.999
EF2W;DISSOLVED CFC12 ERROR;%;0;100;%6.3lf;99.999
HELW;DISSOLVED HELIUM;nanomole/kg;1;2;%7.4lf;99.9999
HEEW;DISSOLVED HELIUM ERROR;nanomole/kg;0;1;%7.4lf;99.9999
TINW;DISSOLVED INORGANIC NITROGEN;millimole/m3;0;100;%6.3lf;99.999
NEOW;DISSOLVED NEON;nanomole/kg;4;8;%7.4lf;99.9999
NEEW;DISSOLVED NEON ERROR;nanomole/kg;0;1;%7.4lf;99.9999
CORG;DISSOLVED ORGANIC CARBON;millimole/m3;0;1000;%5.0lf;99999
NODW;DISSOLVED ORGANIC NITROGEN;micromole/kg;0;99;%5.2lf;99.99
NORG;DISSOLVED ORGANIC NITROGEN;millimole/m3;0;50;%6.3lf;99.999
DOPW;DISSOLVED ORGANIC PHOSPHORUS;millimole/m3;0;50;%6.3lf;99.999
PODW;DISSOLVED ORGANIC PHOSPHORUS;micromole/kg;0;5;%5.2lf;99.99
DOX1;DISSOLVED OXYGEN;ml/l;0;10;%5.2lf;99.99;0 4|0 6|2 6|0 8|2 8
DOX2;DISSOLVED OXYGEN;micromole/kg;0;450;%7.3lf;999.999;0 100|0 200|100 300
DOXY;DISSOLVED OXYGEN;millimole/m3;0;650;%7.3lf;999.999;0 100|0 200|100 300
TRIW;DISSOLVED TRITIUM;TU;0;2;%6.3lf;99.999
TREW;DISSOLVED TRITIUM ERROR;TU;0;5;%6.3lf;99.999
CHAD;DIVINYL CHLOROPHYLL-A;milligram/m3;0;9;%6.3lf;99.999
CHBD;DIVINYL-CHLOROPHYLL-B;milligram/m3;0;5;%6.3lf;99.999
DRYT;DRY BULB TEMPERATURE;Celsius degree;0;90;%5.1lf;999.9;0 10|0 20|0 30|10 20|10 30|20 30|22 30|20 32|22 32|26 32|20 40
DRDD;DURATION (DAYS);ddd;0;999;%3.0lf;999
CNDC;ELECTRICAL CONDUCTIVITY;mho/meter;3;7;%5.3lf;9.999
ETDD;ELLAPSED TIME;decimal days;0;999;%9.5lf;999.99999
CHAE;EPIMERE CHLOROPHYLL-A;milligram/m3;0;5;%6.3lf;99.999
MFEF;FE FLUX IN SETTLING PARTICLES;milligram/(m2.day);0;100;%6.2lf;999.99
FLPF;FLAGELLATES PPC FLUX;milligram C/(m2.day);0;99.999;%6.3lf;99.999
FLU2;FLUORESCENCE;milligram/m3;0;1;%8.4lf;999.9999;0 1|0 5
FLUO;FLUORESCENCE;relative unit;-0.1;10;%6.3lf;99.999
FLU1;FLUORESCENCE;volt;-1;3;%6.3lf;99.999;|0 1|0 2|0 3|1 3
FUCP;FUCOXANTHINE;milligram/m3;0;5;%6.3lf;99.999
MFEP;Fe IN SUSPENDED MATTER;milligram/m3;0;99.999;%6.3lf;99.999
MFES;Fe IN THE SEDIMENT;%;0;99;%6.3lf;99.999
GLUC;GLUCIDE;milligram/m3;0;200;%5.0lf;99999
GSPD;GUST WIND SPEED;meters/second;0;99;%2.0lf;99
HEDW;HELIUM DEV. OF ISOTOPIC RATIO;%;-1.5;100;%8.4lf;999.9999
HEDE;HELIUM ISOTOPIC RATIO ERROR;%;0;100;%8.4lf;999.9999
NFHW;HETEROTROPHIC NANOFLAGELLATES;10+3 cell/m3;0;900000;%6.0lf;999999
HCSP;HORIZONTAL CURRENT SPEED;cm/s;0;9;%5.3lf;9.999
WSPD;HORIZONTAL WIND SPEED;meters/second;0;300;%6.2lf;999.99
HSUL;HYDROGEN SULPHIDE (H2S);millimole/m3;0;500;%6.2lf;999.99
MIIS;I IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
LGH5;IMMERGED/SURF IRRADIANCE RATIO;%;0;100;%6.2lf;999.99;0 10|0 50|0 75|25 50|25 75|25 100|50 75|50 100|75 100
RDIN;INCIDENT RADIATION;watt/m2;-500;500;%+5.1lf;-999.9;-100 100|-250 250|0 100|0 250
SPDI;INDICATED PLATFORM SPEED-SHIP;meters/second;0;90;%6.3lf;99.999
ISMP;INORGANIC SUSPENDED MATTER;gram/m3;0;10;%6.3lf;99.999
IODI;IODINE;millimole/m3;0;10;%5.2lf;99.99
OXIR;ISOTOPIC RATIO O18/O16;per thousand;-10;10;%6.2lf;999.99
MKKP;K IN SUSPENDED MATTER;milligram/m3;0;99.999;%6.3lf;99.999
MKKS;K IN THE SEDIMENT;%;0;99;%6.3lf;99.999
LATX;LATITUDE;decimal degree;-90;90;%+8.4lf;99.9999
LATITUDE;Latitude of each location;degrees_north;-90;90;%+8.4lf;99.9999
LATD;LATITUDE DEGREES;degree;-90;90;%+3.0lf;99
LATM;LATITUDE MINUTES;minute;0;59.999;%6.3lf;99.999
LTUW;LEUCINE UPTAKE RATE;microgram carbon/(m3.h);0;90;%5.2lf;99.99
TUR2;LIGHT ATTENUATION COEFFICIENT;m-1;0;10;%6.3lf;99.999
LCAW;LIGHT CARBON ABSORPTION;milligram/m3;0;40;%5.2lf;99.99
TUR1;LIGHT DIFFUSION COEFFICIENT;m-1;0;10;%6.3lf;99.999
LGH3;LIGHT IRRADIANCE CORRECTED PAR;micromole photon/(m2.s);0;3000;%8.3lf;9999.999;0 500|0 1000|0 2000
LGHT;LIGHT IRRADIANCE IMMERGED PAR;micromole photon/(m2.s);0;4000;%8.3lf;9999.999;0 500|0 1000|0 2000
LGH4;LIGHT IRRADIANCE SURFACE PAR;micromole photon/(m2.s);0;3000;%8.3lf;9
LSCT;LIGH999.999;0 500|0 1000|0 2000T SCATTERING;%;0;100;%5.2lf;99.99;0 10|0 50|0 75|25 50|25 75|25 100|50 75|50 100|75 100
TUR3;LIGHT TRANSMISSION;%;0;100;%6.2lf;999.99;0 10|0 50|0 75|25 50|25 75|25 100|50 75|50 100|75 100
TUR0;LIGHT TRANSMISSION -  NOT USED;%;0;100;%6.2lf;999.99;0 10|0 50|0 75|25 50|25 75|25 100|50 75|50 100|75 100
LIPI;LIPIDS IN THE WATER COLUMN;milligram/m3;0;200;%5.0lf;99999
LSIC;LITHOGENIC CONTENT;%;0;99.99;%5.2lf;99.99
LTHF;LITHOGENIC FRACTION FLUX;milligram/(m2.day);0;3400;%7.2lf;9999.99
LINC;LONG-WAVE INCOMING RADIATION;watt/m2;-500;500;%+5.1lf;-999.9
LONX;LONGITUDE;decimal degree;-180;180;%+9.4lf;999.9999
LONGITUDE;Longitude of each location;degrees_east;-180;180;%+9.4lf;999.9999
LOND;LONGITUDE DEGREES;degree;-179;180;%+4.0lf;999
LONM;LONGITUDE MINUTES;minute;0;59.999;%6.3lf;99.999
MLAS;La IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
VZMX;MAXI ZERO CROSSING WAVE HEIGHT;metre;0;10;%5.2lf;99.99
MSMP;MEAN SPHERIC DIAM. MEDIAN;millimeter;0;99;%5.2lf;99.99
MSDP;MEAN SPHERIC DIAM. OF PARTICLE;millimeter;0;99;%5.2lf;99.99
MSZW;MESOZOOPLANCTON DRY WEIGHT;milligram/m3;0;90;%5.2lf;99.99
MMNF;MN FLUX IN SETTLING PARTICLES;microgram/(m2.day);0;3400;%6.2lf;999.99
SSTM;MODEL SEA SURFACE TEMPERATURE;Celsius degree;-1.5;38;%6.3lf;99.999
MNTH;MONTH;mm;1;12;%2.2d;99
MMGP;Mg IN SUSPENDED MATTER;milligram/m3;0;99.999;%6.3lf;99.999
MMGS;Mg IN THE SEDIMENT;%;0;99;%6.3lf;99.999
MMNP;Mn IN SUSPENDED MATTER;milligram/m3;0;99.999;%6.3lf;99.999
MMNS;Mn IN THE SEDIMENT;%;0;99;%6.3lf;99.999
MMOS;Mo IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
HBAW;NB OF HETEROTROPHIC BACTERIA;10+6 cell/m3;0;900000;%6.0lf;999999
NETR;NET RADIATION;watt/m2;-500;500;%+5.1lf;-999.9
NTRA;NITRATE (NO3-N) CONTENT;millimole/m3;0;56;%6.3lf;99.999;0 1|0 5|0 10|0 20
NTAW;NITRATE (NO3-N) CONTENT;micromole/kg;0;90;%5.2lf;99.99;0 1|0 5|0 10|0 20|0 50
NTRZ;NITRATE + NITRITE CONTENT;millimole/m3;0;100;%6.2lf;999.99
NTZW;NITRATE + NITRITE CONTENT;micromole/kg;0;100;%6.2lf;999.99
NOUW;NITRATE UPTAKE;micromole nitrogen/(m3.day);0;900;%5.0lf;99999
NORW;NITRIFICATION;micromole nitrogen/(m3.day);0;100;%5.0lf;99999
NTIW;NITRITE (NO2-N) CONTENT;micromole/kg;0;100;%7.3lf;999.999;0 1|0 2|0 5|0 10|0 20|0 50
NTRI;NITRITE (NO2-N) CONTENT;millimole/m3;0;10;%6.3lf;99.999;0 1|0 2|0 5
PHCW;NUM. OF SW PHYTOPLANKTON CELLS;10+3 cell/m3;0;900000;%6.0lf;999999
COPP;NUMBER OF COPEPODS;number/m3;0;99999;%5.0lf;99999
NUMP;NUMBER OF PARTICLES;number/m3;0;999999;%9.3e;1.00E+100
BCCW;NUMBER OF SW BACTERIA;10+9 cell/m3;0;9000;%7.2lf;9999.99
CICW;NUMBER OF SW CILIATES;10+3 cell/m3;0;90000;%5.0lf;99999
COCW;NUMBER OF SW COCCOLITHOPHORIDS;10+3 cell/m3;0;900000;%6.0lf;999999
DTCW;NUMBER OF SW DIATOMS;10+3 cell/m3;0;900000;%6.0lf;999999
DFCW;NUMBER OF SW DINOFLAGELLATES;10+3 cell/m3;0;900000;%6.0lf;999999
NFCW;NUMBER OF SW NANOFLAGELLATES;10+3 cell/m3;0;900000;%6.0lf;999999
PCEW;NUMBER OF SW PICOEUCARYOTES;10+6 cell/m3;0;90000;%5.0lf;99999
PRCW;NUMBER OF SW PROCHLOROCOCCUS;10+6 cell/m3;0;900000;%6.0lf;999999
SNCW;NUMBER OF SW SYNECHOCOCCUS;10+6 cell/m3;0;900000;%6.0lf;999999
MNAS;Na IN THE SEDIMENT;%;0;99;%6.3lf;99.999
MNBS;Nb IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
MNDS;Nd IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
MNIS;Ni IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
SLEV;OBSERVED SEA LEVEL;meters;0;6000;%8.3lf;9999.999
OPAP;OPAL CONTENT;%;0;99.99;%5.2lf;99.99
TOMP;ORGANIC MATTER CONTENT;%;0;99.99;%5.2lf;99.99
OSMP;ORGANIC SUSPENDED MATTER;gram/m3;0;10;%6.3lf;99.999
OSAT;OXYGEN SATURATION;%;0;10;%5.2lf;99.99
MPPP;P IN SUSPENDED MATTER;milligram/m3;0;99.999;%6.3lf;99.999
MPPS;P IN THE SEDIMENT;%;0;99;%6.3lf;99.999
SIOF;PART. BIOGENIC Si FLUX;milligram/(m2.day);0;600;%7.3lf;999.999
CO3F;PART. CaCO3 FLUX;milligram/(m2.day);0;600;%7.3lf;999.999
POCF;PART. ORGANIC CARBON FLUX;milligram/(m2.day);0;99;%5.2lf;99.99
OMMF;PART. ORGANIC MATTER FLUX;milligram/(m2.day);0;600;%6.2lf;999.99
PP1P;PART. ORGANIC PHOSPHORUS (P);millimole/m3;0;10;%6.3lf;99.999
CHTF;PART. TOTAL CARBOHYDRATES FLUX;milligram/(m2.day);0;99;%6.3lf;99.999
TCCF;PART. TOTAL CARBON FLUX;milligram/(m2.day);0;999;%7.3lf;999.999
TNNF;PART. TOTAL NITROGEN FLUX;milligram/(m2.day);0;99;%6.3lf;99.999
ETHP;PARTICULATE 234 TH ACT. ERROR;Bq/m3;0;99;%6.3lf;99.999
TH4P;PARTICULATE 234TH ACTIVTY;Bq/m3;0;99;%6.3lf;99.999
PC1P;PARTICULATE ORGANIC CARBON/POC;millimole/m3;0;100;%6.3lf;99.999
POCP;PARTICULATE ORGANIC CARBON/POC;milligram/m3;0;999;%6.2lf;999.99
PN1P;PARTICULATE ORGANIC NITROGEN;millimole/m3;0;2;%6.3lf;99.999
PONP;PARTICULATE ORGANIC NITROGEN;milligram/m3;0;100;%6.2lf;999.99
SLCP;PARTICULATE ORGANIC SILICA(SI);millimole/m3;0;1;%6.3lf;99.999
MPBF;PB FLUX IN SETTLING PARTICLES;microgram/(m2.day);0;200;%6.2lf;999.99
PERP;PERIDININE;milligram/m3;0;5;%6.3lf;99.999
PHPH;PH;pH unit;7.4;8.4;%5.3lf;9.999
PHTF;PHAEOPIGMENTS VERTICAL FLUX;milligram/(m2.day);0;10;%6.3lf;99.999
PHEA;PHEOPHYTIN-A;milligram/m3;0;99;%5.2lf;99.99
PHEB;PHEOPHYTIN-B;milligram/m3;0;99;%5.2lf;99.99
PHEC;PHEOPHYTIN-C;milligram/m3;0;99;%5.2lf;99.99
PHOS;PHOSPHATE (PO4-P) CONTENT;millimole/m3;0;4;%6.3lf;99.999;0 1|0 2
PHOW;PHOSPHATE (PO4-P) CONTENT;micromole/kg;0;10;%5.3lf;9.999;0 1|0 2|0 5
HEAD;PLATFORM HEADING REL. NORTH;degree;-360;360;%+5.1lf;-999.9
PSAL;PRACTICAL SALINITY SCALE 1978;P.S.S.78;33;37;%6.3lf;99.999;33.5 37.5|30 36|30 37|32 36|33 36|33 37|34 36|34 37|34 37.5|30 40
PXAP;PRASINOXANTHINE;milligram/m3;0;5;%6.3lf;99.999
PRRT;PRECIPITATION RATE;millimeters/hour;0;900;%7.3lf;999.999
PROT;PROTEIN;milligram/m3;0;500;%5.0lf;99999
PTZF;PROTOZOA PPC FLUX;milligram C/(m2.day);0;99.999;%6.3lf;99.999
MPBS;Pb IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
REDS;REDOX POTENTIAL;millivolt;-110;200;%+4.0lf;-999
RELH;RELATIVE HUMIDITY;%;0;100;%5.1lf;999.9
MRBS;Rb IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
MSSP;S IN SUSPENDED MATTER;milligram/m3;0;99.999;%6.3lf;99.999
SSAL;SALINITY (PRE-1978 DEFN);P.S.U.;0;40;%6.3lf;99.999
SACC;SALINITY ACCURACY;.;0;4;%2d;-9
SAND;SAND IN THE SEDIMENT;%;0;100;%6.2lf;999.99
PRES;sea_water_pressure sea surface=0;decibar=10000 pascals;0;6500;%6.1lf;-999.9;0 50|0 100|0 250|0 500|0 700|0 800|0 900|0 1000|0 1200|0 1500|0 2000|0 2500|0 4000|1000 2000|2000 4000
SCDT;SEA SURF CURRENT DIR. REL T. N;degree;0;360;%5.1lf;999.9
SCSP;SEA SURFACE CURRENT SPEED;cm/s;0;10;%5.2lf;99.99
SSPS;SEA SURFACE PRACTICAL SALINITY;P.S.S.78;0;40;%6.3lf;99.999;30 36|30 37|32 37;33 37|34 35|34 36|33.5 37.5
SSTP;SEA SURFACE TEMPERATURE;Celsius degree;-1.5;38;%6.3lf;99.999;
TEMP;SEA TEMPERATURE;Celsius degree;0;30;%6.3lf;99.999;0 10|0 20|0 30|0 32|10 20|10 30|10 32|20 30|20 32|20 40
TE03;SEA TEMPERATURE;Celsius degree;-2;32;%6.3lf;99.999;0 30|10 30|20 30|15 25
TE04;SEA TEMPERATURE;Celsius degree;-2;32;%6.3lf;99.999;0 30|10 30|20 30|15 25
TE05;SEA TEMPERATURE;Celcius degree;-2;32;%6.3lf;99.999;0 30|10 30|20 30|15 25
TE07;SEA TEMPERATURE;Celsius degree;-2;32;%6.3lf;99.999;0 30|10 30|20 30|15 25
TE12;SEA TEMPERATURE;Celsius degree;-2;32;%6.3lf;99.999;0 30|10 30|20 30|15 25
TE11;SEA TEMPERATURE;Celsius degree;-2;32;%6.3lf;99.999;0 30|10 30|20 30|15 25
TE10;SEA TEMPERATURE;Celsius degree;-2;32;%6.3lf;99.999;0 30|10 30|20 30|15 25
TE09;SEA TEMPERATURE;Celsius degree;-2;32;%6.3lf;99.999;0 30|10 30|20 30|15 25
TE08;SEA TEMPERATURE;Celsius degree;-2;32;%6.3lf;99.999;0 30|10 30|20 30|15 25
TE06;SEA TEMPERATURE;Celsius degree;-2;32;%6.3lf;99.999;0 30|10 30|20 30|15 25
TE06;SEA TEMPERATURE;Celsius degree;-2;32;%6.3lf;99.999
SECS;SECONDS WITHIN MINUTE;ss;0;59;%2.2d;99
AMIS;SEDIMENT AMINO-ACIDS;microgram/g;0;7000;%4.0lf;9999
SIOS;SEDIMENT BIOGENIC SiO2;%;0;100;%6.2lf;999.99
CHTS;SEDIMENT CARBOHYDRATES;microgram/g;0;7000;%4.0lf;9999
CO3S;SEDIMENT CARBONATES;%;0;100;%6.2lf;999.99
LIPS;SEDIMENT LIPIDS;microgram/g;0;5000;%4.0lf;9999
PHNS;SEDIMENT PHENOLS;microgram/g;0;200;%5.1lf;999.9
TCCS;SEDIMENT TOTAL CARBON;%;0;100;%6.2lf;999.99
TNNS;SEDIMENT TOTAL NITROGEN;%;0;100;%6.2lf;999.99
TOCS;SEDIMENT TOTAL ORGANIC CARBON;%;0;100;%6.2lf;999.99
VTDH;SIGNIFICANT WAVE HEIGHT;meters;0;99.999;%6.3lf;99.999
SLCA;SILICATE (SIO4-SI) CONTENT;millimole/m3;0;200;%7.3lf;999.999
SLCW;SILICATE (SIO4-SI) CONTENT;micromole/kg;0;195;%5.1lf;999.9;0 10|0 20|0 30|0 40|0 50|0 100
SILT;SILT IN THE SEDIMENT;%;0;100;%6.2lf;999.99
SVEL;SOUND VELOCITY;meters/second;1350;1600;%7.2lf;9999.99
SWDR;SWELL DIRECTION  REL TRUE N.;degree;0;360;%5.1lf;999.9
SWHT;SWELL HEIGHT;meters;0;30;%5.2lf;99.99
MSCS;Sc IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
MSIP;Si IN SUSPENDED MATTER;milligram/m3;0;999.999;%7.3lf;999.999
MSIS;Si IN THE SEDIMENT;%;0;99;%6.3lf;99.999
MSRS;Sr IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
TACC;TEMPERATURE ACCURACY;.;0;4;%2d;-9
TIME;TIME;days since 1950-01-01T00:00:00Z;0;90000.0;%6.6d;999999
TCO2;TOTAL CARBON DIOXYD (CO2);mole/m3;0;5000;%8.3lf;9999.999
TDCW;TOTAL DISSOLVED CARBON;millimole/m3;0;9999;%4.0lf;9999
TDPW;TOTAL DISSOLVED PHOSPHORUS;millimole/m3;0;40;%6.3lf;99.999
TICW;TOTAL INORGANIC CARBON;micromole/kg;0;9000;%7.2lf;9999.99
TSMF;TOTAL MASS FLUX;milligram/(m2.day);0;9999.9;%6.1lf;9999.9
NTOT;TOTAL NITROGEN (N) CONTENT;millimole/m3;0;90;%5.2lf;99.99
TOCW;TOTAL ORGANIC CARBON;millimole/m3;0;999.999;%7.3lf;999.999
NOTT;TOTAL ORGANIC NITROGEN (D+P);micromole/kg;0;10;%5.2lf;99.99
POTT;TOTAL ORGANIC PHOSPHORUS (D+P);micromole/kg;0;5;%5.2lf;99.99
PTNP;TOTAL PARTICULATE NITROGEN;milligram/m3;0;5;%5.2lf;99.99
NT1P;TOTAL PARTICULATE NITROGEN;micromole/kg;0;10;%5.2lf;99.99
PTPP;TOTAL PARTICULATE PHOSPHORUS;milligram/m3;0;5;%5.2lf;99.99
PT1P;TOTAL PARTICULATE PHOSPHORUS;micromole/kg;0;5;%5.2lf;99.99
TPHP;TOTAL PHAEOPIGMENTS;milligram/m3;0;100;%6.3lf;99.999
PHTP;TOTAL PHEOPHYTINE;milligram/m3;0;99;%5.2lf;99.99
TPHS;TOTAL PHOSPHORUS (P) CONTENT;millimole/m3;0;10;%5.2lf;99.99
EPMP;TOTAL SUSP. PART. MATTER/ESTER;gram/m3;0;9;%5.3lf;9.999
GPMP;TOTAL SUSP. PART. MATTER/GLASS;gram/m3;0;99;%6.3lf;99.999
TSMP;TOTAL SUSPENDED MATTER;gram/m3;0;100;%7.3lf;999.999
TUR4;TURBIDITY;N.T.U Nephelo Turb. Unit;0;100;%6.2lf;999.99
TUR5;TURBIDITY;relative unit;0;10;%7.4lf;99.9999
TUR6;TURBIDITY;milliF.T.U Formaz Turb Unit;0;5000;%6.1lf;9999.9
MTHS;Th IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
MTIP;Ti IN SUSPENDED MATTER;milligram/m3;0;99.999;%6.3lf;99.999
MTIS;Ti IN THE SEDIMENT;%;0;99;%6.3lf;99.999
MUUS;U IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
UREA;UREA;millimole/m3;0;5;%5.2lf;99.99
MVVS;V IN THE SEDIMENT;ppm;-50;900;%+6.2lf;99.99
VERR;VELOCITY ERROR;cm/s;0;90;%6.3lf;99.999
VCSP;VERTICAL CURRENT SPEED;cm/s;0;9;%5.3lf;9.999
VERT;VERTICAL DISPLACEMENT;meters;0;9999;%8.3lf;9999.999
VOCP;VOLUME CONC. OF PARTICLES;p.p.m.;0;99;%6.3lf;99.999
H2OS;WATER CONTENT;%;0;100;%5.1lf;999.9
WDIR;WIND DIRECTION REL. TRUE NORTH;degree;0;360;%+5.1lf;-999.9
WMSP;WIND SPEED - MAX AVER PER 2 MN;meters/second;0;200;%5.2lf;99.99
WSPE;WIND SPEED EASTWARD COMPONENT;meters/second;0;100;%7.3lf;999.999
WSPN;WIND SPEED NORTHWARD COMPONENT;meters/second;0;100;%7.3lf;999.999
MYYS;Y IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
YEAR;YEAR;yyyy;1900;2020;%4.4d;9999
ZXAP;ZEAXANTHINE;milligram/m3;0;5;%6.3lf;99.999
MZNF;ZN FLUX IN SETTLING PARTICLES;microgram/(m2.day);0;7600;%6.2lf;999.99
MZNS;Zn IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
MZRS;Zr IN THE SEDIMENT;ppm;0;900;%6.2lf;999.99
SSJT;SEA SURFACE WATER JACKET TEMPERATURE;Celsius degree;-1.5;38;%6.3lf;99.999;0 10|0 20|0 30|10 20|10 30|20 30|20 32|26 32|20 40
DAYD;DECIMAL JULIAN DAY TIME ORIGIN 0;decimal day;0.0;3660.0;%9.5lf;999.99999
TE01;SEA TEMPERATURE PRIMARY SENSOR;Celsius degree;-2;32;%6.3lf;99.999;0 10|0 20|0 30|0 32|10 20|10 30|10 32|20 30|20 32|20 40
TE02;SEA TEMPERATURE SECONDARY SENSOR;Celsius degree;-2;32;%6.3lf;99.999;0 10|0 20|0 30|0 32|10 20|10 30|10 32|20 30|20 32|20 40
PSA1;PRACTICAL SALINITY PRIMARY SENSOR;P.S.S.78;33;37;%6.3lf;99.999;33.5 37.5|30 36|30 37|32 36|33 36|33 37|34 36|34 37|34 37.5|30 40
PSA2;PRACTICAL SALINITY SECONDARY SENSOR;P.S.S.78;33;37;%6.3lf;99.999;33.5 37.5|30 36|30 37|32 36|33 36|33 37|34 36|34 37|34 37.5|30 40
CND1;ELECTRICAL CONDUCTIVITY PRIMARY SENSOR;mho/meter;3;7;%5.3lf;9.999
CND2;ELECTRICAL CONDUCTIVITY SECONDARY SENSOR;mho/meter;3;7;%5.3lf;9.999
DO11;DISSOLVED OXYGEN PRIMARY SENSOR;ml/l;0;10;%5.2lf;99.99;0 4|0 6|2 6|0 8|2 8
DO21;DISSOLVED OXYGEN SECONDARY SENSOR;ml/l;0;10;%5.2lf;99.99;0 4|0 6|2 6|0 8|2 8
DO12;DISSOLVED OXYGEN PRIMARY SENSOR;micromole/kg;0;450;%7.3lf;999.999;0 100|0 200|100 300
DO22;DISSOLVED OXYGEN SECONDARY SENSOR;micromole/kg;0;450;%7.3lf;999.999;0 100|0 200|100 300
DOV1;DISSOLVED OXYGEN PRIMARY SENSOR VOLTAGE;V;0;10;%6.4lf;9.9999;
DOV2;DISSOLVED OXYGEN SECONDARY SENSOR VOLTAGE;V;0;10;%6.4lf;9.9999;
DVT1;DISSOLVED OXYGEN PRIMARY SENSOR dV/dt;dv/dt;-1;1;%+7.5lf;9.99999;
DVT2;DISSOLVED OXYGEN SECONDARY SENSOR dV/dt;dv/dt;-1;1;%+7.5lf;9.99999;
WETT;WET BULB TEMPERATURE;Celsius degree;0;90;%5.1lf;999.9
HEIG;ATMOSPHERIC HEIGHT;meters;0;40000;%8.2lf;1e+36;0 100|0 500|0 1000|0 5000|0 10000|0 20000|0 30000
BOTL;SEA WATER SAMPLE BOTTLE NUMBER;;1;36;%4d;9999
