#!perl\bin\perl -w
#
# Traitement des fichiers SeaBird CTD acquis avec Seasave et traités avec 
# Seasoft SBEProcessing pour l'ensemble des capteurs
# 
# Ce script lit et enregistre les capteurs primaires et secondaires T,C et 02
# Utilise les fichiers d'extensions .hdr et .asc 
# Les fichiers de sortie prennent le nom du cycle_mesure (entete) + extensions 
# et _ctd + extension eventuelle .xml
#
# J Grelet IRD march 2015 MOORSPICE
#
# 
# $I$ 

use strict; # necessite de declarer toutes les variables globales
#use diagnostics;

use Time::Local;
use File::Basename;
use Data::Dumper;
use Getopt::Long;
use Switch;
use XML::LibXML;
use Oceano::Seawater;
use Oceano::Convert;
use Oceano::Seabird;
use Cwd;
use Config::Tiny;

#------------------------------------------------------------------------------
# Les repertoires de sorties
#------------------------------------------------------------------------------
my $ascii_dir = 'ascii/';
my $odv_dir   = 'odv/';

#------------------------------------------------------------------------------
# Les variables globales
#------------------------------------------------------------------------------
our $VERSION = '1.0';
our $author;
my  $debug;
my  $echo;
my  $dtd = 'public';
my  $dtdLocalPath;
my  $encoding;

# surcharge par la valeurs saisies sur la ligne de commande
my  $version;
my  $help;

# les noms de fichiers
my  $hdr_file;
my  $ctd_file;
my  $xml_ctd_file;
my  $odv_file;
my  @files_descr;

my  $institute;
my  $ctdType;
my  $ctdSn;
my  $pi;
my  $creator;
my  $acquisitionSoftware;
my  $acquisitionVersion;
my  $processingSoftware;
my  $processingVersion;

my  $cycle_mesure;
my  $plateforme;
my  $context;
my  $timezone;
my  $format_date;
my  $processing_code;
my  $begin_date;
my  $end_date;
my  $cruisePrefix;
my  $stationPrefixLength;
my  $title_summary;
my  $comment;
my  $header;
my  @header;
my  $split;
my  %split;
my  $format;
my  @format;
my  %format;
my  %data;
my  @data;
my  ($odv_hdr,$odv_unit);
my  (@odv_hdr, @odv_unit);
my  %odv_hdr;
my  $PRFL;

my  $O2_primary_index   = 5;
my  $O2_secondary_index = 11;

my  $xml           = undef;   # par defaut, sortie XML activee
my  $ascii         = undef;
my  $odv           = undef;   
my  $all           = undef;
my  $top           = undef;
my  $ctd_all       = undef;
my  $ctdall        = '';

my  $code          = -1;  # code pour l'entete

# les lignes d'entete
my  ($header_file, $header_parameters);

# les formats de sorties
my $format_profils;
my $format_data;

# la liste des variables en sortie
my $variables_liste;

#la liste des variables a decoder (extraires) dans les fichiers de donnees
my $decode_variables;

my  $type_odv      = "C" ;
my  $bottom_depth  = 1e+36;

my ($lat, $lat_pos, $lat_deg, $lat_min, $lat_hemi);
my ($long, $long_pos, $long_deg, $long_min, $long_hemi);
my ($julien, $h_date, $date, $mois, $jour, $annee, $heure, $min, $sec, $time);
my $type_cast;     

my  $meta;  # reference anonyme vers la table hashage des coefficients de calibration
my  $primary        = 'primary';
my  $secondary      = 'secondary';

#------------------------------------------------------------------------------
# version()
#------------------------------------------------------------------------------	
sub version() {
  print "Version: $VERSION\nAuthor: $author\n\n";	
  exit 1;
}	

#------------------------------------------------------------------------------
# usage()
#------------------------------------------------------------------------------	
sub usage() {
  print STDERR "\nusage: ctd-all.pl [options] <files>\n\n";
  print STDERR   "Options:\n    --help                 Display this help message\n";
  print STDERR   "    --version              program version\n";
  print STDERR   "    --debug=[1-3]          debug info\n";
  print STDERR   "    --echo                 display filenames processed\n";
  print STDERR   "    --cycle_mesure=<name>  cycle_mesure name\n";
  print STDERR   "    --plateforme=<name>    ship or plateforme name\n";
  print STDERR   "    --begin_date=JJ/MM/YYYY     starting date from cycle_mesure\n";
  print STDERR   "    --end_date=JJ/MM/YYYY     end date from cycle_mesure\n";
  print STDERR   "    --institute=<name>      institute name\n";
  print STDERR   "    --code_oopc=<value>    processing code\n";
  print STDERR   "    --pi=<pi_name> \n";
  print STDERR   "    --ascii                ASCII output instead XML\n";
  print STDERR   "    --xml                  XML output (default)\n";
  print STDERR   "    --odv                  ODV output\n";	
  print STDERR   "    --all                  ASCII, XML and ODV output\n";
  print STDERR   "    --ctd_all              output primary and secondary sensors\n";
  print STDERR   "    --top                  complement surface data with first bin values\n";  
  print STDERR   "    --dtd=[local|public]   define DTD, default public\n";
  print STDERR   "    --sn=<serial_number>\n";
  print STDERR   "    --type=<instrument_type> \n";
  print STDERR   "\naccept short options like -d1 -t2\n\n";
  print STDERR   "example:\n\$ perl ctd-all.pl --cycle_mesure=$cycle_mesure --institute=$institute --plateforme='$plateforme' --sn=$ctdSn --type=$ctdType --pi=$pi --begin_date=$begin_date --end_date=$end_date --echo  --xml data/asc/$cruisePrefix*.hdr\n"; 
  exit 1;
}

#------------------------------------------------------------------------------
# get_options()
# analyse les options
#------------------------------------------------------------------------------	
sub get_options() {
  
  &GetOptions ("cycle_mesure=s"  => \$cycle_mesure, 
               "plateforme=s"    => \$plateforme,  
               "begin_date=s"    => \$begin_date,  
               "end_date=s"      => \$end_date,  
               "type=s"          => \$ctdType,  
               "sn=s"            => \$ctdSn,  
               "pi=s"            => \$pi,  
               "code_oopc=s"     => \$processing_code,
               "xml"             => \$xml,               
               "ascii"           => \$ascii, 
               "odv"             => \$odv,   
               "all"             => \$all,   
               "ctd_all"         => \$ctd_all,   
               "debug=i"         => \$debug,  
               "echo"            => \$echo,  	       
               "institute=s"      => \$institute, 
               "dtd=s"           => \$dtd,  
               "top"             => \$top,  	     
               "version"         => \$version,  
               "help"            => \$help)  or &usage;  
       
  &version if $version;	
  &usage   if $help;

  # xml by default
  $xml = 1 if (!defined $ascii && !defined $odv); 
  if ($all) { $ascii = $odv = $xml = 1; }

  &read_config_ctd_all('../config.ini') if (defined $ctd_all);
}

=pod
# inutile avec Oceano::convert
# a decommenter si Date::manip
#------------------------------------------------------------------------------
# fonctions de calcul de la position/date
#------------------------------------------------------------------------------
sub position {
  my($deg,$min,$hemi) = @_;
  my $sign = 1;
  if( $hemi eq "S" || $hemi eq "W") {
    $sign = -1;
  }
  my $tmp = $min;
  $min = abs $tmp;
  my $sec = ($tmp - $min ) * 100;
  return( ( $deg + ( $min + $sec / 100 ) / 60 ) * $sign ); 
}

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
sub julian {
  my($jj,$h,$m,$s) = @_;
  my $dec = (($h * 3600) + ($m * 60) + $s ) / 86400;
  return( $jj + $dec ); 
}
=cut

#------------------------------------------------------------------------------
# voir documentation 
# http://www.seabird.com/pdf_documents/manuals/Seasave_5.37.pdf
#------------------------------------------------------------------------------
sub decode_con_file {
  my ($fileName, $sensor) = @_;

  open( DATA_CON, $fileName );
  while( <DATA_CON> ){           
    chomp;
    # chomp ne marche pas correctement car le fichier .con est au format DOS
    # avec un CRLF (^M^J ou OD OA) a la fin de chaque ligne
    # on vire le CR si present en fin de ligne
    $_ =~ s/^(.+)\r$/$1/;
    switch( $. ) {
      # conductivity	secondary sensor    
      case 6   {  $meta->{'cond'}->{'secondary'}->{'sn'} =  $_; }
      case 8   { (undef,undef, $meta->{'cond'}->{'secondary'}->{'slope'}, 
	          $meta->{'cond'}->{'secondary'}->{'offset'}) = split; }
      case 112 { ($meta->{'cond'}->{'secondary'}->{'g'}, 
		  $meta->{'cond'}->{'secondary'}->{'h'},
	          $meta->{'cond'}->{'secondary'}->{'i'}, $meta->{'cond'}->{'secondary'}->{'j'},
		  $meta->{'cond'}->{'secondary'}->{'ctcor'},
                  $meta->{'cond'}->{'secondary'}->{'cpcor'}) = split; }
      case 54  {  $meta->{'cond'}->{'date'} =  $_; }
      # temperature secondary sensor 
      case 9   {  $meta->{'temp'}->{'sn'} =  $_; }
      case 5   { (undef,undef,undef,undef,undef, $meta->{'temp'}->{'slope'},
                  $meta->{'temp'}->{'offset'}) = split; }
      case 113 { ($meta->{'temp'}->{'f0'}, $meta->{'temp'}->{'g'},
	          $meta->{'temp'}->{'h'}, $meta->{'temp'}->{'i'},
     		  $meta->{'temp'}->{'j'}) = split; }
      case 55  {  $meta->{'temp'}->{'date'} =  $_; }
      # conductivity	primary sensor     
      case 1   {  $meta->{'cond'}->{'primary'}->{'primary'}->{'sn'} =  $_; }
      case 3   { (undef,undef, $meta->{'cond'}->{'primary'}->{'primary'}->{'slope'}, 
	          $meta->{'cond'}->{'primary'}->{'primary'}->{'offset'}) = split; }
      case 110 { ($meta->{'cond'}->{'primary'}->{'primary'}->{'g'}, $meta->{'cond'}->{'primary'}->{'primary'}->{'h'},
	          $meta->{'cond'}->{'primary'}->{'primary'}->{'i'}, $meta->{'cond'}->{'primary'}->{'primary'}->{'j'},
		  $meta->{'cond'}->{'primary'}->{'primary'}->{'ctcor'},
                  $meta->{'cond'}->{'primary'}->{'primary'}->{'cpcor'}) = split; }
      case 52  {  $meta->{'cond'}->{'primary'}->{'primary'}->{'date'} =  $_; }
      # temperature primary sensor
      case 4   {  $meta->{'temp'}->{'primary'}->{'sn'} =  $_; }
      case 5   { (undef,undef,undef,undef,undef, $meta->{'temp'}->{'primary'}->{'slope'},
                  $meta->{'temp'}->{'primary'}->{'offset'}) = split; }
      case 111 { ($meta->{'temp'}->{'primary'}->{'f0'}, $meta->{'temp'}->{'primary'}->{'g'},
	          $meta->{'temp'}->{'primary'}->{'h'}, $meta->{'temp'}->{'primary'}->{'i'},
		  $meta->{'temp'}->{'primary'}->{'j'}) = split; }
      case 53  {  $meta->{'temp'}->{'primary'}->{'date'} =  $_; }
    }  
  }
  close DATA_CON;
}  

#------------------------------------------------------------------------------
# open_xml_file()
#
# lit le fichier xml
#   arg:     le fichier à lire
#   return:  l'arbre XML
#            -1 si erreur d'ouverture du fichier
#------------------------------------------------------------------------------
sub open_xml_file {
  my ($file) = @_;

  # a modifier par la suite le test sur l'existance du fichier( bloc eval)
  open( FILE, $file ) || die "Erreur d'ouverture du fichier: $file\n";

  my $parser = XML::LibXML->new();

  my $tree = $parser->parse_file($file);

  close(FILE);

  # retourne l'arbre XML
  return $tree->getDocumentElement
}

#------------------------------------------------------------------------------
# get_xml_info()
#
# recupere le(s) infos dans le fichier XML
#   arg:     l'arbre XML
#            le chemin XPATH
#   return:  la variable lue
#            0 si rien dans le noeud
#------------------------------------------------------------------------------
sub get_xml_info {
  my ( $root, $xpath ) = @_;

  my $var = $root->findvalue($xpath);
  print "$var\n"         if ( $debug == 2 );
  print "$xpath\t$var\n" if ( $debug == 3 );

  return $var;
}

#------------------------------------------------------------------------------
# get primary or secondary temperature calibration coefficients
# using XPATH expression to get value from xml file
# $sensor must be egal to 0 for primary sensor, 1 for secondary
#------------------------------------------------------------------------------
sub get_xmlcon_sbe03 {
  my ($root, $sensor, $index) = @_;

  $meta->{'temp'}->{$sensor}->{'sn'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /TemperatureSensor/SerialNumber" );
  $meta->{'temp'}->{$sensor}->{'date'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /TemperatureSensor/CalibrationDate" );
  $meta->{'temp'}->{$sensor}->{'g'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /TemperatureSensor/G" );
  $meta->{'temp'}->{$sensor}->{'h'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /TemperatureSensor/H" );
  $meta->{'temp'}->{$sensor}->{'i'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /TemperatureSensor/I" );
  $meta->{'temp'}->{$sensor}->{'j'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /TemperatureSensor/J" );
  $meta->{'temp'}->{$sensor}->{'f0'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /TemperatureSensor/F0" );
  $meta->{'temp'}->{$sensor}->{'slope'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /TemperatureSensor/Slope" );
  $meta->{'temp'}->{$sensor}->{'offset'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /TemperatureSensor/Offset" );
}

#------------------------------------------------------------------------------
# get primary or secondary conductivity calibration coefficients
# using XPATH expression to get value from xml file
#------------------------------------------------------------------------------
sub get_xmlcon_sbe04 {
  my ($root, $sensor, $index) = @_;

  $meta->{'cond'}->{$sensor}->{'sn'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /ConductivitySensor/SerialNumber" );
  $meta->{'cond'}->{$sensor}->{'date'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /ConductivitySensor/CalibrationDate" );
  $meta->{'cond'}->{$sensor}->{'g'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /ConductivitySensor/Coefficients/G" );
  $meta->{'cond'}->{$sensor}->{'h'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /ConductivitySensor/Coefficients/H" );
  $meta->{'cond'}->{$sensor}->{'i'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /ConductivitySensor/Coefficients/I" );
  $meta->{'cond'}->{$sensor}->{'j'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /ConductivitySensor/Coefficients/J" );
  $meta->{'cond'}->{$sensor}->{'cpcor'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /ConductivitySensor/Coefficients[\@equation=\'1\']/CPcor" );
  $meta->{'cond'}->{$sensor}->{'ctcor'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /ConductivitySensor/Coefficients[\@equation=\'1\']/CTcor" );
  $meta->{'cond'}->{$sensor}->{'slope'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /ConductivitySensor/Slope" );
  $meta->{'cond'}->{$sensor}->{'offset'} = 
    &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /ConductivitySensor/Offset" );
}

#------------------------------------------------------------------------------
# get pressure paroscientifique calibration coefficients
# using XPATH expression to get value from xml file
#------------------------------------------------------------------------------
sub get_xmlcon_pressure {
  my ($root, $sensor, $index) = @_;

  $meta->{'press'}->{$sensor}->{'sn'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/SerialNumber" );
  $meta->{'press'}->{$sensor}->{'date'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/CalibrationDate" );
  $meta->{'press'}->{$sensor}->{'c1'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/C1" );
  $meta->{'press'}->{$sensor}->{'c2'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/C2" );
  $meta->{'press'}->{$sensor}->{'c3'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/C3" );
  $meta->{'press'}->{$sensor}->{'d1'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/D1" );
  $meta->{'press'}->{$sensor}->{'d2'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/D2" );
  $meta->{'press'}->{$sensor}->{'t1'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/T1" );
  $meta->{'press'}->{$sensor}->{'t2'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/T2" );
  $meta->{'press'}->{$sensor}->{'t3'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/T3" );
  $meta->{'press'}->{$sensor}->{'t4'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/T4" );
  $meta->{'press'}->{$sensor}->{'t5'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/T5" );
  $meta->{'press'}->{$sensor}->{'ad590m'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/AD590M" );
  $meta->{'press'}->{$sensor}->{'ad590b'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/AD590B" );
  $meta->{'press'}->{$sensor}->{'slope'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/Slope" );
  $meta->{'press'}->{$sensor}->{'offset'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /PressureSensor/Offset" );
}

#------------------------------------------------------------------------------
# get primary or secondary conductivity calibration coefficients
# using XPATH expression to get value from xml file
#------------------------------------------------------------------------------
sub get_xmlcon_sbe43 {
  my ($root, $sensor, $index) = @_;

  $meta->{'o2'}->{$sensor}->{'sn'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/SerialNumber" );
  $meta->{'o2'}->{$sensor}->{'date'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationDate" );
  $meta->{'o2'}->{$sensor}->{'soc'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/Soc" );
  $meta->{'o2'}->{$sensor}->{'offset'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /CalibrationCoefficients[\@equation=\'1\']/offset" );
  $meta->{'o2'}->{$sensor}->{'a'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/A" );
  $meta->{'o2'}->{$sensor}->{'b'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/B" );
  $meta->{'o2'}->{$sensor}->{'c'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/C" );
  $meta->{'o2'}->{$sensor}->{'d0'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/D0" );
  $meta->{'o2'}->{$sensor}->{'d1'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/D1" );
  $meta->{'o2'}->{$sensor}->{'d2'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/D2" );
  $meta->{'o2'}->{$sensor}->{'e'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/E" );
  $meta->{'o2'}->{$sensor}->{'tau20'} = &get_xml_info( $root,
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/Tau20" );
  $meta->{'o2'}->{$sensor}->{'h1'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/H1" );
  $meta->{'o2'}->{$sensor}->{'h2'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/H2" );
  $meta->{'o2'}->{$sensor}->{'h3'} = &get_xml_info( $root, 
    "/SBE_InstrumentConfiguration/Instrument/SensorArray/Sensor[\@index=\'$index\'] \
    /OxygenSensor/CalibrationCoefficients[\@equation=\'1\']/H3" );
}

#------------------------------------------------------------------------------
# main function to get all calibration coefficients from .xmlcon file 
#------------------------------------------------------------------------------
sub decode_xmlcon_file {
  my ($fileName) = @_;

  ### on recupere les valeurs de l'entete XML
  my $root = &open_xml_file($fileName);
  die "Error: invalid $fileName document, may be check it ...\nExit\n\n" 
    if ( !$root ); 

  # get information value inside .xmlcon calibration file with XPATH expression   
  $acquisitionVersion = 
    &get_xml_info( $root, '/SBE_InstrumentConfiguration/@SB_ConfigCTD_FileVersion' );
  $ctdType = 
    &get_xml_info( $root, '/SBE_InstrumentConfiguration/Instrument/Name' );

    # get primary temperature calibration coefficients, index = 0
    &get_xmlcon_sbe03($root, $primary, 0);

    # get primary conductivity calibration coefficients, index = 1
    &get_xmlcon_sbe04($root, $primary, 1);

    # get pressure paroscientifique calibration coefficients,  index = 2
    &get_xmlcon_pressure($root, $primary, 2);

    # get secondary temperature calibration coefficients,  index = 3
    &get_xmlcon_sbe03($root, $secondary, 3);

    # get secondary conductivity calibration coefficients,  index = 4
    &get_xmlcon_sbe04($root, $secondary, 4);

    # get primary oxygen sbe43 calibration coefficients
    &get_xmlcon_sbe43($root, $primary, $O2_primary_index);

    # get secondary oxygen sbe43 calibration coefficients
    &get_xmlcon_sbe43($root,  $secondary, $O2_secondary_index);
}

#------------------------------------------------------------------------------
# write temperature calibration coefficicients to ctd.xml file using oceano DTD
#------------------------------------------------------------------------------
sub write_xml_oceano_temperature {
  my ($sensor) = @_;

  my $SENSOR = uc $sensor;

  print XML_CTD_FILE "    <INSTRUMENT TYPE=\"SBE03\" NUMERO_SERIE=\"$meta->{'temp'}->{$sensor}->{'sn'}\" CODE_ROSCOP=\"TEMP\" PERE=\"$ctdSn\" NUMERO=\"$SENSOR\">\n"; 
  print XML_CTD_FILE "      <PARAMETRE CLE=\"DATE\" TYPE=\"D\">$meta->{'temp'}->{$sensor}->{'date'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"G\" TYPE=\"N\">$meta->{'temp'}->{$sensor}->{'g'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"H\" TYPE=\"N\">$meta->{'temp'}->{$sensor}->{'h'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"I\" TYPE=\"N\">$meta->{'temp'}->{$sensor}->{'i'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"J\" TYPE=\"N\">$meta->{'temp'}->{$sensor}->{'j'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"F0\" TYPE=\"N\">$meta->{'temp'}->{$sensor}->{'f0'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"SLOPE\" TYPE=\"N\">$meta->{'temp'}->{$sensor}->{'slope'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"OFFSET\" TYPE=\"N\">$meta->{'temp'}->{$sensor}->{'offset'}</PARAMETRE>\n";
  print XML_CTD_FILE "    </INSTRUMENT>\n"; 
}

#------------------------------------------------------------------------------
# write conductivity calibration coefficicients to ctd.xml file using oceano DTD
#------------------------------------------------------------------------------
sub write_xml_oceano_conductivity {
  my ($sensor) = @_;

  my $SENSOR = uc $sensor;

  print XML_CTD_FILE "    <INSTRUMENT TYPE=\"SBE04\" NUMERO_SERIE=\"$meta->{'cond'}->{$sensor}->{'sn'}\" CODE_ROSCOP=\"PSAL\" PERE=\"$ctdSn\" NUMERO=\"$SENSOR\">\n"; 
  print XML_CTD_FILE "      <PARAMETRE CLE=\"DATE\" TYPE=\"D\">$meta->{'cond'}->{$sensor}->{'date'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"G\" TYPE=\"N\">$meta->{'cond'}->{$sensor}->{'g'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"H\" TYPE=\"N\">$meta->{'cond'}->{$sensor}->{'h'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"I\" TYPE=\"N\">$meta->{'cond'}->{$sensor}->{'i'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"J\" TYPE=\"N\">$meta->{'cond'}->{$sensor}->{'j'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"CTCOR\" TYPE=\"N\">$meta->{'cond'}->{$sensor}->{'ctcor'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"CPCOR\" TYPE=\"N\">$meta->{'cond'}->{$sensor}->{'cpcor'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"SLOPE\" TYPE=\"N\">$meta->{'cond'}->{$sensor}->{'slope'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"OFFSET\" TYPE=\"N\">$meta->{'cond'}->{$sensor}->{'offset'}</PARAMETRE>\n";
  print XML_CTD_FILE "    </INSTRUMENT>\n";   
}
#------------------------------------------------------------------------------
# write pressure calibration coefficicients to ctd.xml file using oceano DTD
#------------------------------------------------------------------------------
sub write_xml_oceano_pressure {
  my ($sensor) = @_;

  my $SENSOR = uc $sensor;

  print XML_CTD_FILE "    <INSTRUMENT TYPE=\"PAROSCIENTIFIC\" NUMERO_SERIE=\"$meta->{'press'}->{$sensor}->{'sn'}\" CODE_ROSCOP=\"PRES\" PERE=\"$ctdSn\">\n"; 
  print XML_CTD_FILE "      <PARAMETRE CLE=\"DATE\" TYPE=\"D\">$meta->{'press'}->{$sensor}->{'date'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"C1\" TYPE=\"N\">$meta->{'press'}->{$sensor}->{'c1'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"C1\" TYPE=\"N\">$meta->{'press'}->{$sensor}->{'c2'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"C3\" TYPE=\"N\">$meta->{'press'}->{$sensor}->{'c3'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"D1\" TYPE=\"N\">$meta->{'press'}->{$sensor}->{'d1'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"D2\" TYPE=\"N\">$meta->{'press'}->{$sensor}->{'d2'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"T1\" TYPE=\"N\">$meta->{'press'}->{$sensor}->{'t1'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"T1\" TYPE=\"N\">$meta->{'press'}->{$sensor}->{'t2'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"T3\" TYPE=\"N\">$meta->{'press'}->{$sensor}->{'t3'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"T4\" TYPE=\"N\">$meta->{'press'}->{$sensor}->{'t4'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"SLOPE\" TYPE=\"N\">$meta->{'press'}->{$sensor}->{'slope'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"OFFSET\" TYPE=\"N\">$meta->{'press'}->{$sensor}->{'offset'}</PARAMETRE>\n";
  print XML_CTD_FILE "    </INSTRUMENT>\n";  
}

#------------------------------------------------------------------------------
# write conductivity calibration coefficicients to ctd.xml file using oceano DTD
#------------------------------------------------------------------------------
sub write_xml_oceano_oxygen {
  my ($sensor) = @_;

  my $SENSOR = uc $sensor;

  print XML_CTD_FILE "    <INSTRUMENT TYPE=\"SBE43\" NUMERO_SERIE=\"$meta->{'o2'}->{$sensor}->{'sn'}\" CODE_ROSCOP=\"PSAL\" PERE=\"$ctdSn\" NUMERO=\"$SENSOR\">\n"; 
  print XML_CTD_FILE "      <PARAMETRE CLE=\"DATE\" TYPE=\"D\">$meta->{'o2'}->{$sensor}->{'date'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"SOC\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'soc'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"OFFSET\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'offset'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"A\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'a'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"B\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'b'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"C\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'c'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"D0\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'d0'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"D1\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'d1'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"D2\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'d2'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"E\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'e'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"TAU20\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'tau20'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"H1\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'h1'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"H2\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'h2'}</PARAMETRE>\n";
  print XML_CTD_FILE "      <PARAMETRE CLE=\"H3\" TYPE=\"N\">$meta->{'o2'}->{$sensor}->{'h3'}</PARAMETRE>\n";
  print XML_CTD_FILE "    </INSTRUMENT>\n";   
}

#------------------------------------------------------------------------------
# write all calibration coefficicients to ctd.xml file using oceano DTD
#------------------------------------------------------------------------------
sub write_xml_header_calcoeff { 
  &write_xml_oceano_temperature($primary);
  &write_xml_oceano_temperature($secondary);
  &write_xml_oceano_conductivity($primary);
  &write_xml_oceano_conductivity($secondary);
  &write_xml_oceano_pressure($primary);
  #&write_xml_oceano_oxygen($primary);
  #&write_xml_oceano_oxygen($secondary);
}

#------------------------------------------------------------------------------
# write XML header to output _ctd.xml file using oceano.dtd 
#------------------------------------------------------------------------------
sub write_xml_header { 
  my($conFile) = @_;
  my $today = &dateFormat(undef,"%d/%m/%Y");
  
  print  XML_CTD_FILE "<?xml version=\"1.0\" encoding=\"$encoding\"?>\n"; 
  # les commentaires ne sont pas acceptés par XML Toolbox Matlab de Geodise
  if ( $dtd eq 'local' ) {
    print  XML_CTD_FILE "<!DOCTYPE OCEANO SYSTEM \"$dtdLocalPath/$cycle_mesure/local/oceano.dtd\">\n";
  } else {  
    print  XML_CTD_FILE '<!DOCTYPE OCEANO PUBLIC "-//US191//DTD OCEANO//FR" "http://www.brest.ird.fr/us191/database/oceano.dtd">' . "\n";
  }
  print  XML_CTD_FILE '<OCEANO TYPE="PROFIL">' . "\n";
  print  XML_CTD_FILE "  <ENTETE>\n";
  print  XML_CTD_FILE "    <PLATEFORME>\n";
  print  XML_CTD_FILE "      <LIBELLE>$plateforme</LIBELLE>\n";  
  print  XML_CTD_FILE "    </PLATEFORME>\n";
  print  XML_CTD_FILE "    <CYCLE_MESURE CONTEXTE=\"$context\" TIMEZONE=\"$timezone\" FORMAT=\"$format_date\">\n";  
  print  XML_CTD_FILE "      <LIBELLE>$cycle_mesure</LIBELLE>\n";  
  print  XML_CTD_FILE "      <DATE_DEBUT>$begin_date</DATE_DEBUT>\n";  
  print  XML_CTD_FILE "      <DATE_FIN>$end_date</DATE_FIN>\n";  
  print  XML_CTD_FILE "      <INSTITUT>$institute</INSTITUT>\n";  
  print  XML_CTD_FILE "      <RESPONSABLE>$pi</RESPONSABLE>\n"; 
  print  XML_CTD_FILE "      <ACQUISITION LOGICIEL=\"$acquisitionSoftware\" VERSION=\"$acquisitionVersion\"></ACQUISITION>\n"; 
  print  XML_CTD_FILE "      <TRAITEMENT LOGICIEL=\"$processingSoftware\" VERSION=\"$processingVersion\"></TRAITEMENT>\n"; 
  print  XML_CTD_FILE "      <VALIDATION LOGICIEL=\"$0\" VERSION=\"$VERSION\" DATE=\"$today\" OPERATEUR=\"$creator\" CODIFICATION=\"OOPC\">\n";
  print  XML_CTD_FILE "        <CODE>$processing_code</CODE>\n";	    
  print  XML_CTD_FILE "        <COMMENTAIRE>$comment</COMMENTAIRE>\n";
  print  XML_CTD_FILE "        <COMMENTAIRE>$title_summary</COMMENTAIRE>\n";
  print  XML_CTD_FILE "      </VALIDATION>\n";  
  print  XML_CTD_FILE "    </CYCLE_MESURE>\n";  
  print  XML_CTD_FILE "    <INSTRUMENT TYPE=\"$ctdType\" NUMERO_SERIE=\"$ctdSn\">\n"; 
  print  XML_CTD_FILE "    </INSTRUMENT>\n";  
  
  # attention, verifier si les fichiers sont en majuscules ou minuscules !!!!
  $conFile =~ s/\.HDR/\.CON/i;
  $conFile =~ s/asc/raw/i;
  my $xmlconFile = $conFile;
  $xmlconFile =~ s/\.CON/\.xmlcon/i;
  
  # test si le fichier .con existe
  if (-e $conFile) {
    &decode_con_file($conFile);
    &write_xml_header_calcoeff;
  }
  # test si le fichier .xmlcon existe
  elsif (-e $xmlconFile ) {
    &decode_xmlcon_file($xmlconFile);
    &write_xml_header_calcoeff;
  } else {
    print STDERR "\n\nWARNING: can't find calibration file $conFile or $xmlconFile\n";
    print STDERR "Calibration coefficients will not include in xml file\n";
  }  
  
  print  XML_CTD_FILE "  </ENTETE>\n";  
  print  XML_CTD_FILE "  <DATA>\n";  
}

#------------------------------------------------------------------------------
# entete ODV
#------------------------------------------------------------------------------
sub entete_odv { 
  my $today = &dateFormat(undef,"%d/%m/%Y");
  my $cwd = getcwd();

  print  ODV_FILE "//ODV Spreadsheet file : $odv_file\n"; 
  print  ODV_FILE "//Data treated : $today\n"; 
  print  ODV_FILE "//<DataType>Profiles</DataType>\n";
  print  ODV_FILE "//<InstrumentType>$ctdType</InstrumentType>\n";
  print  ODV_FILE "//<Source>$cwd</Sources>\n"; 
  print  ODV_FILE "//<Creator>$creator</Creator>\n";  
  print  ODV_FILE "//\n"; 
  print  ODV_FILE "Cruise\tStation\tType\tmon/day/yr\thh:mm\tLongitude [degrees_east]\tLatitude [degrees_north]\tBot. Depth [m]";
  foreach my $key (@odv_hdr) {
    print ODV_FILE "\t$key $odv_hdr{$key}";
  }
   print  ODV_FILE "\n";
}

#------------------------------------------------------------------------------
# read string key inside section in config file
#------------------------------------------------------------------------------	
sub read_config_string() {
  my ($Config, $section, $key) = @_;

  my $value = $Config->{$section}->{$key};
  if (!defined $value ) {die "Missing string '$key' in section '$section' $!";}
  return $value;
}

#------------------------------------------------------------------------------
# read config.ini file where cruise parameter are defined 
#------------------------------------------------------------------------------	
sub read_config() {
  my ($configFile) = @_;

  # Create a config
  my $Config = Config::Tiny->new;
  
  $Config = Config::Tiny->read( $configFile ) 
	  or die "Could not open '$configFile' $!";

  $author             = &read_config_string( $Config, 'global', 'author');
  $debug              = &read_config_string( $Config, 'global', 'debug');
  $echo               = &read_config_string( $Config, 'global', 'echo');
  $dtd                = &read_config_string( $Config, 'xml',    'dtd');
  $dtdLocalPath       = &read_config_string( $Config, 'xml',    'dtdLocalPath');
  $encoding           = &read_config_string( $Config, 'xml',    'encoding');
  $cycle_mesure       = &read_config_string( $Config, 'cruise', 'cycle_mesure');
  $plateforme         = &read_config_string( $Config, 'cruise', 'plateforme');
  $context            = &read_config_string( $Config, 'cruise', 'context');
  $timezone           = &read_config_string( $Config, 'cruise', 'timezone');
  $format_date        = &read_config_string( $Config, 'cruise', 'format_date');
  $processing_code    = &read_config_string( $Config, 'cruise', 'processing_code');
  $begin_date         = &read_config_string( $Config, 'cruise', 'begin_date');
  $end_date           = &read_config_string( $Config, 'cruise', 'end_date');
  $institute          = &read_config_string( $Config, 'cruise', 'institute');
  $pi                 = &read_config_string( $Config, 'cruise', 'pi');
  $creator            = &read_config_string( $Config, 'cruise', 'creator');
  $acquisitionSoftware = &read_config_string( $Config, 'ctd', 'acquisitionSoftware');
  $acquisitionVersion = &read_config_string( $Config, 'ctd', 'acquisitionVersion');
  $processingSoftware = &read_config_string( $Config, 'ctd', 'processingSoftware');
  $processingVersion  = &read_config_string( $Config, 'ctd', 'processingVersion');
  $cruisePrefix       = &read_config_string( $Config, 'ctd', 'cruisePrefix');
  $stationPrefixLength = &read_config_string( $Config, 'ctd', 'stationPrefixLength');
  $ctdType            = &read_config_string( $Config, 'ctd',     'type');
  $ctdSn              = &read_config_string( $Config, 'ctd',     'sn');
  $title_summary      = &read_config_string( $Config, 'ctd',     'title_summary');
  $comment            = &read_config_string( $Config, 'ctd',     'comment');
  $header             = &read_config_string( $Config, 'ctd',     'header');
  $split              = &read_config_string( $Config, 'ctd',     'split');
  $format             = &read_config_string( $Config, 'ctd',     'format');
  $odv_hdr            = &read_config_string( $Config, 'ctd',     'odv_hdr');
  $odv_unit           = &read_config_string( $Config, 'ctd',     'odv_unit');
}

#------------------------------------------------------------------------------
# read config.ini file where cruise parameter are defined 
#------------------------------------------------------------------------------	
sub read_config_ctd_all() {
  my ($configFile) = @_;

  # Create a config
  my $Config = Config::Tiny->new;
  
  $Config = Config::Tiny->read( $configFile ) 
	  or die "Could not open '$configFile' $!";

  $header             = &read_config_string( $Config, 'ctd-all',     'header');
  $split              = &read_config_string( $Config, 'ctd-all',     'split');
  $format             = &read_config_string( $Config, 'ctd-all',     'format');
  $ctdall = '-all';
}

#------------------------------------------------------------------------------
# Debut du programme principal
#------------------------------------------------------------------------------
&dateInit( "EN","GMT" );
&read_config('../config.ini');
&usage if( $#ARGV == -1);
&get_options;

# ouverture des fichiers de sortie, on met en minuscule, lower case
my $fileName =  $ARGV[0];
my ($name,$dir) =  fileparse $fileName;

# define files name
$ctd_file     = lc $ascii_dir.$cycle_mesure.$ctdall.'_ctd';
$hdr_file = lc $ascii_dir.$cycle_mesure.$ctdall.'.ctd' if defined $xml or $ascii;
$xml_ctd_file = lc $ascii_dir.$cycle_mesure .$ctdall.'_ctd.xml'if defined $xml;
$odv_file     = lc $odv_dir.$cycle_mesure .$ctdall.'_ctd_odv.txt' if defined $odv;

#print STDERR $xml_ctd_file . "\n";

# get variables liste order from header
@header = split /\s+/, $header;
# convert variable split from config.ini to hash, ex split = bottle,1,mois,2
%split = split /,/, $split;
# convert output format fron config.ini to hash
@format = split /\s+/, $format;
# build hash %format with key: PRES, value: %7.3f
my @tmp = @format;
foreach my $key (@header) {
  $format{$key} = shift @tmp;
}
# build list for odv from config.ini 
@odv_hdr  = split /\s+/, $odv_hdr;
@odv_unit = split /\s+/, $odv_unit;
@tmp = @odv_unit;
foreach my $key (@odv_hdr) {
  $odv_hdr{$key} = shift @tmp;
}

# variables locales
my $lines = 0;

# lecture du premier fichier d'entete pour extraction des parametres
# generaux si ces derniers n'ont pas ete definit sur la ligne de commande.
open( DATA_FILE, $ARGV[0] );
while( <DATA_FILE> ){           # header contient l'entete
  if( /Ship\s*:\s*(.*)/i) {
    if ( not defined $plateforme ) {
      ($plateforme) = $1;
       chomp $plateforme;  # enleve le dernier caractere \n car motif (.*)
    }  
  }
  if( /Cruise\s*:\s*(\S+)/i ) {
    ($cycle_mesure) = $1 if ( not defined $cycle_mesure );
  }
  if( /Sea-Bird\s+(\w+\s+\d+)/ ) {
    ($ctdType) = $1  if ( not defined $ctdType );
  }
  if( /Software Version Seasave V\s+(\d+\.\d+)/ ) {
    ($acquisitionVersion) = $1  if ( not defined $acquisitionVersion );
  }
}  

# display selected output format
print STDERR "Output: ";
print STDERR "ASCII " if (defined $ascii);
print STDERR "XML "   if (defined $xml);
print STDERR "ODV "   if (defined $odv);
print STDERR "WITH ALL SENSORS "   if $echo;

#print STDERR "\nUse secondary sensor\n" if (defined $secondary);

# display debug informationn
if( $debug ) {
  printf "\nInput  file: %s\n", $hdr_file;
  printf "Output file: %s   mode: %s\n",$ctd_file, defined $xml ? 'XML' : 'ASCII'; 
  printf "%s\n%s\n%s\n%s\n%s\n",
          $institute,$plateforme,$ctdType,$ctdSn,$pi;
  for( my $i = 0; $i <= $#ARGV; $i++ ){
    print $ARGV[$i] . "\n";
  }
  print "\nExit ctd.pl ... debug mode\n";
  exit;
}

# open files
if (defined $odv) {
  mkdir($odv_dir) unless(-d $odv_dir);
  open( ODV_FILE,     "+> $odv_file" )   or die "Can't open file : $odv_file\n";
  &entete_odv;
}
if (defined $ascii) {     
  mkdir($ascii_dir) unless(-d $ascii_dir);
  open( CTD_FILE, "+> $ctd_file" ) or die "Can't open file : $ctd_file\n";
  open( HDR_FILE, "+> $hdr_file" ) or die "Can't open file : $hdr_file\n";
  push @files_descr, \*CTD_FILE;
}

if (defined $xml) {     
  mkdir($ascii_dir) unless(-d $ascii_dir);
  open( XML_CTD_FILE, "+> $xml_ctd_file" ) or die "Can't open file : $xml_ctd_file\n";
  push @files_descr, \*XML_CTD_FILE;
}
# Les paramètres supplémentaires
#DOX2;DISSOLVED OXYGEN;micromole/kg;0;450;%7.3lf;
#FLU2;FLUORESCENCE;milligram/m3;0;1;%8.4lf;
#TUR3;LIGHT TRANSMISSION;%;0;100;%6.2lf;999.99
#TUR4:TURBIDITY;N.T.U Nephelo Turb. Unit;0;100;%6.2lf;999.99 (Upoly0)
#LGHT;LIGHT IRRADIANCE IMMERGED PAR;micromole photon/(m2.s);0;4000;%8.3lf;
#LGH4;LIGHT IRRADIANCE SURFACE PAR;micromole photon/(m2.s);0;3000;%8.3lf;
#LGH5;IMMERGED/SURF IRRADIANCE RATIO;%;0;100;%6.2lf;
       
# definition des entetes
$header_file = "$cycle_mesure  $plateforme  $institute  $ctdType  $ctdSn  $pi\n";

# ecriture des entetes
if ( defined $xml ) {
  # printf STDERR "$fileName";
  &write_xml_header( $fileName );
} 
if (defined $ascii) { 
  print CTD_FILE $header_file;
  print CTD_FILE  "$header\n";

  print HDR_FILE $header_file;
  print HDR_FILE "St  Date   Heure    Latitude   Longitude  Profondeur Type\n\n"; 
}
if (defined $xml) {
  print XML_CTD_FILE "$header\n";
}
close DATA_FILE; 

# parcourt des fichiers .HDR et .asc
for( my $i = 0; $i <= $#ARGV; $i++ ){
  my $fileName = $ARGV[$i];
  open( DATA_FILE, $fileName );
  print STDERR  "\nLit: $fileName" if defined $echo;
  # on lit les fichiers d'extention .hdr contenant les entetes
  while( <DATA_FILE> ){           
    # recupere le numero de la station dans le nom du fichier
    ($PRFL) = ($fileName =~ m/$cruisePrefix(\d{$stationPrefixLength})/i);
      
    # decodage du type de cast: H,HFIX,HGEO,SURFGEO,HBIO,CH4,GO-FLO
    if( /Type\s*:\s*(.*)/i ) {
      # on vire le CR si present en fin de ligne
      $type_cast = $1;
      $type_cast =~ s/^(.+)\r$/$1/;
    }  
    # decodage du fond (sonde)
    if( /Bottom Depth\s*:\s*(\d*\.?\d+?)\s*\S*/i ) {
      $bottom_depth = ($1 eq '') ?  1e+36 : $1; 
    }  
    # decodage de la position, date et heure entrees manuellement
    if( m[Date\s*:\s*(\d+)/(\d+)/(\d+)]) {
      ($jour,$mois,$annee) = ($1, $2, $3);	
    };	
    if( /Heure\s*:\s*(\d+)[:hH](\d+):(\d+)/ ) {  # a modifier suivant le contexte
      ($heure,$min,$sec)  = ($1,$2,$3);
      # conversion en format US (MM/DD/YY) pour ParseDate
      $date = $mois."/".$jour."/".$annee." ".$heure.":".$min.":".$sec;
      #print STDERR  "Date: $date\n";
      $date = &ParseDate( $date );
      # transforme le day_of_year en julian day
      $julien = &date2julian($annee,$mois,$jour,$heure,$min,$sec);
      $h_date = &dateFormat($date,"%d/%m/%y %H:%M:%S");
    }
    if( /Latitude\s*:\s*(\d+\s+\d+.\d+\s+\w)/ )	{
      ($lat_deg, $lat_min, $lat_hemi) = split " ", $1;
      $lat_pos = &position($lat_deg, $lat_min, $lat_hemi);
    }
    if( /Longitude\s*:\s*(\d+\s+\d+.\d+\s+\w)/ ) {
      ($long_deg, $long_min, $long_hemi) = split " ", $1;
      $long_pos = &position($long_deg, $long_min, $long_hemi);
    }
    # decodage de la position, date et heure de l'entree NMEA (GPS)
    if( /System UpLoad Time =\s+(\.*)/)	{ # a modifier suivant le contexte
      ($time)  = /System UpLoad Time =\s+(\w+\s+\d+\s+\d+\s+\d+:\d+:\d+)/;	
      # formatte la date au format francais
      $h_date = &dateFormat($time, "%d/%m/%Y %X");
      # recupere l'annee, mois, jour et heure
      $annee  = &dateFormat($time, "%Y");
      $mois   = &dateFormat($time, "%m");
      $jour   = &dateFormat($time, "%d");
      $heure  = &dateFormat($time, "%H");
      $min    = &dateFormat($time, "%M");
      $sec    = &dateFormat($time, "%S");
      # transforme en julian day 0 decimal
      $julien = &date2julian($annee,$annee,$mois,$jour,$heure,$min,$sec);
    }
    if( /NMEA Latitude\s*=\s*(\d+\s+\d+.\d+\s+\w)/ )	{
      ($lat_deg, $lat_min, $lat_hemi) = split " ", $1;
      $lat_pos = &positionDeci($lat_deg, $lat_min, $lat_hemi);
    }
    if( /NMEA Longitude\s*=\s*(\d+\s+\d+.\d+\s+\w)/ ) {
      ($long_deg, $long_min, $long_hemi) = split " ", $1;
      $long_pos = &positionDeci($long_deg, $long_min, $long_hemi);
    }
  }
  # write header in each file open with Z value -1
  for my $file (@files_descr) {
     printf $file "%05d  %d %7.3f %7.4f %8.4f %s", 
    $PRFL, $code, $julien, $lat_pos, $long_pos, &dateFormat($time,"%Y%m%d%H%M%S"), $bottom_depth;
     # and complement empty column with fill value 1e36
     printf  $file "  1e36" x (@header -6) . "\n";
  }

  close DATA_FILE;
  # on lit les fichiers d'extension .cnv contenant les donnees
  # attention aux majuscules/minuscules !!!!!
  if ($fileName =~ /\.HDR/i) {
    $fileName =~ s/\.HDR/\.cnv/i;
    $fileName =~ s/data\/asc\//data\/cnv\/d/i;
  }
 
  open( DATA_FILE, $fileName );
  while( <DATA_FILE> ){           
    # on expurge toutes les lignes des entetes ainsi que les lignes vides
    # n'est pas necessaire avec asciiout
    if( not ( /^[*#]/ || /^\s*$/) ) {
      # lit les donnees, eclate la ligne,utilise la ligne courante $_ par defaut
      # extract values and fill hash %data with position give by hash %split from config.ini
      @data = split /\s+/;
      while( my ($key,$value) = each(%split) ) {
        $data{$key} = $data[$value];
      }   
      next if( $data{'PRES'} eq 'PrDM' );

     $data{'PRFL'} = $PRFL;
     # mets toutes les valeurs inferieur a Pres jusqu'en surface si 
      # option --top
      if (($lines == 0) && defined $top) {
	my $nbin = $data{'NBIN'};
        $data{'NBIN'} = 99999;    
        my $first_depth = $data{'PRES'};	
        for( my $i = 0; $i <= $first_depth; $i++ ) {
	  $data{'PRES'} = $i;
	  if ($i == $first_depth ) { $data{'NBIN'} = $nbin };
          for my $file (@files_descr) {
            foreach my $key (@header) {
  	      printf $file "$format{$key} ",  $data{$key};
            }
            printf $file "\n";
          }
        }
      } 
      else {
        for my $file (@files_descr) {
            foreach my $key (@header) {
  	      printf $file "$format{$key} ",  $data{$key};
            }
            printf $file "\n";
        }
        if (defined $odv) {
          printf ODV_FILE "%s\t%05d\t%s\t%s\t%8.4f\t%7.4f",
            $cycle_mesure, $PRFL, $type_odv, 
	    &dateFormat($time, "%Y-%m-%dT%H:%M:%S"),
            $long_pos, $lat_pos;
          printf ODV_FILE ($bottom_depth > 1e35) ? "\t" : "\t%6.1f", $bottom_depth;
          foreach my $key (@odv_hdr) {
            printf ODV_FILE ($data{$key} > 1e35 || $data{$key} == -9.99e-29) ?
	      "\t" : "\t$format{$key}", $data{$key};
          }
	  printf ODV_FILE "\n";
        }			
      }
      # re-initialise les donnees lues sauf $pres utilise pour le fichier d'entete
      $lines++;
    }
  }
  if (defined $ascii) {
    printf HDR_FILE  "%05d %s %02d°%05.2f %s %03d°%05.2f %s %5.4g %5.4g\n",$PRFL,
      $h_date, $lat_deg, $lat_min, $lat_hemi, $long_deg, $long_min, 
      $long_hemi, $data{'PRES'}, $bottom_depth;
  }    
  # affiche l'entete profil a l'ecran 
  if (defined $ascii or $xml) {
    printf STDERR "   %05d %s %02d°%05.2f %s %03d°%05.2f %s %5.4g %5.4g",$PRFL,
      $h_date, $lat_deg, $lat_min, $lat_hemi, $long_deg, $long_min, 
      $long_hemi, $data{'PRES'}, , $bottom_depth if defined $echo;   
  }
  # et au format odv uniquement si option --odv
  if (defined $odv && !defined $ascii) {
    printf STDERR ": %s %05d %s %s %8.4f %7.4f %5.4g %5.4g",
      $cycle_mesure, $PRFL,$type_odv, &dateFormat($time,"%m/%d/%Y %H:%M"), 
      $lat_pos, $long_pos, $data{'PRES'}, $bottom_depth if defined $echo;    
  }
 
  $data{'PRES'} =  $bottom_depth = 1e36;	  
  $. = 0; # remet le compteur de ligne a zero
  $lines = 0;
  close DATA_FILE;
}

# return result to matlab
# printf STDERR $ctd_file;
 printf STDERR "\n";;

close HDR_FILE;
if( defined $xml ) {
  print  XML_CTD_FILE "  </DATA>\n";  
  print  XML_CTD_FILE "</OCEANO>\n";  
}  
close CTD_FILE     if (defined $ascii);
close XML_CTD_FILE if (defined $xml);
close ODV_FILE     if (defined $odv);

