#!/usr/bin/perl -w
#
# btl-all.pl
#
#  Genere un fichier btl avec tous les parametres a partir des fichiers
#  Seabird .btl
#
# $Id J Grelet avril 2014$
#
use strict; # necessite de declarer toutes les variables globales
#use diagnostics;

# use open qw(:std :utf8); 
# binmode(STDERR, ":utf8");
use Time::Local;
use Date::Manip;
use Getopt::Long;
use File::Basename;
use Data::Dumper;
use Oceano::Seawater;
use Oceano::Convert;
use Oceano::Seabird;
use Cwd;
use Config::Tiny;
#use Tie::IxHash;

#------------------------------------------------------------------------------
# Les repertoires de sorties
#------------------------------------------------------------------------------
my $ascii_dir = 'ascii/';
my $odv_dir   = 'odv/';

#------------------------------------------------------------------------------
# Les variables globales
#------------------------------------------------------------------------------
our $VERSION = "1.0";
my  $version;
my  $help    = undef;
my  $author;
my  $debug;
my  $echo;
my  $dtd;
my  $dtdLocalPath;
my  $encoding;

my  $file;
my  $xml_file;
my  $odv_file;

my  $institute;
my  $btlType;
my  $btlSn;
my  $pi;
my  $creator;
my  $acquisitionSoftware;
my  $acquisitionVersion;
my  $processingSoftware;
my  $processingVersion;

my  $cycle_mesure;
my  $plateforme;
my  $contexte;
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


my $code     = -1;  # code pour l'entete


# fichiers bouteille seabird .btl
my  $sbe_file;
my ($s_date, $e_date, $e_time, $iso_date, $t_date);
my ($PRFL, $BOTL);
my ($lat, $lat_pos, $lat_deg, $lat_min, $lat_hemi);
my ($long, $long_pos, $long_deg, $long_min, $long_hemi);
my ($julien, $date, $month, $day, $year, $heure, $min, $time);

my  $type_odv      = 'B';  # station-type (either B, C or X for bottle, CTD or XBT data
my  $bottom_depth  = 1e36;

#------------------------------------------------------------------------------
# display_version()
# display program version
#------------------------------------------------------------------------------	
sub display_version() {
  print "Version: $VERSION\nAuthor: $author\n\n";	
  exit 1;
}	

#------------------------------------------------------------------------------
# usage()
#------------------------------------------------------------------------------	
sub usage() {
  print STDERR "\nusage: btl-all.pl [options] <files>\n\n";
  print STDERR   "Options:\n    --help                 Display this help message\n";
  print STDERR   "    --version              program version\n";
  print STDERR   "    --debug                debug info\n";
  print STDERR   "    --echo                 display filenames processed\n";
  print STDERR   "    --dtd=[local|public]   define DTD\n";
  print STDERR   "examples:\n\$ perl btl-all.pl --echo data/btl/*.btl\n"; 
  exit 1;
}

#------------------------------------------------------------------------------
# get_options()
# analyse les options
#------------------------------------------------------------------------------	
sub get_options() {
  
  &GetOptions ("echo"            => \$echo,  	       
               "dtd=s"           => \$dtd,  
               "debug"           => \$debug,  
               "version"         => \$version,  
               "help"            => \$help)  or &usage;  
       
  &display_version if $version;	
  &usage   if $help;
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
  $contexte           = &read_config_string( $Config, 'cruise', 'context');
  $timezone           = &read_config_string( $Config, 'cruise', 'timezone');
  $format_date        = &read_config_string( $Config, 'cruise', 'format_date');
  $processing_code    = &read_config_string( $Config, 'cruise', 'processing_code');
  $begin_date         = &read_config_string( $Config, 'cruise', 'begin_date');
  $end_date           = &read_config_string( $Config, 'cruise', 'end_date');
  $institute           = &read_config_string( $Config, 'cruise', 'institute');
  $pi                 = &read_config_string( $Config, 'cruise', 'pi');
  $creator            = &read_config_string( $Config, 'cruise', 'creator');
  $acquisitionSoftware = &read_config_string( $Config, 'ctd', 'acquisitionSoftware');
  $acquisitionVersion = &read_config_string( $Config, 'ctd', 'acquisitionVersion');
  $processingSoftware = &read_config_string( $Config, 'ctd', 'processingSoftware');
  $processingVersion  = &read_config_string( $Config, 'ctd', 'processingVersion');
  $cruisePrefix       = &read_config_string( $Config, 'ctd', 'cruisePrefix');
  $stationPrefixLength = &read_config_string( $Config, 'ctd', 'stationPrefixLength');
  $btlType            = &read_config_string( $Config, 'btl',     'type');
  $btlSn              = &read_config_string( $Config, 'btl',     'sn');
  $title_summary      = &read_config_string( $Config, 'btl',     'title_summary');
  $comment            = &read_config_string( $Config, 'btl',     'comment');
  $header             = &read_config_string( $Config, 'btl',     'header');
  $split              = &read_config_string( $Config, 'btl',     'split');
  $format             = &read_config_string( $Config, 'btl',     'format');
  $odv_hdr            = &read_config_string( $Config, 'btl',     'odv_hdr');
  $odv_unit           = &read_config_string( $Config, 'btl',     'odv_unit');
}

#------------------------------------------------------------------------------
# write XML header to output _ctd.xml file using oceano.dtd 
#------------------------------------------------------------------------------
sub write_xml_header { 
  my $today = &dateFormat(undef,"%d/%m/%Y");
  
  print  XML_BTL_FILE "<?xml version=\"1.0\" encoding=\"$encoding\"?>\n"; 
  # les commentaires ne sont pas acceptés par XML Toolbox Matlab de Geodise
  if ( $dtd eq 'local' ) {
    print  XML_BTL_FILE "<!DOCTYPE OCEANO SYSTEM \"$dtdLocalPath/$cycle_mesure/local/oceano.dtd\">\n";
  } else {  
    print  XML_BTL_FILE '<!DOCTYPE OCEANO PUBLIC "-//US191//DTD OCEANO//FR" "http://www.brest.ird.fr/us191/database/oceano.dtd">' . "\n";
  }
  print  XML_BTL_FILE '<OCEANO TYPE="PROFIL">' . "\n";
  print  XML_BTL_FILE "  <ENTETE>\n";
  print  XML_BTL_FILE "    <PLATEFORME>\n";
  print  XML_BTL_FILE "      <LIBELLE>$plateforme</LIBELLE>\n";  
  print  XML_BTL_FILE "    </PLATEFORME>\n";
  print  XML_BTL_FILE "    <CYCLE_MESURE CONTEXTE=\"$contexte\" TIMEZONE=\"$timezone\" FORMAT=\"$format_date\">\n";  
  print  XML_BTL_FILE "      <LIBELLE>$cycle_mesure</LIBELLE>\n";  
  print  XML_BTL_FILE "      <DATE_DEBUT>$begin_date</DATE_DEBUT>\n";  
  print  XML_BTL_FILE "      <DATE_FIN>$end_date</DATE_FIN>\n";  
  print  XML_BTL_FILE "      <INSTITUT>$institute</INSTITUT>\n";  
  print  XML_BTL_FILE "      <RESPONSABLE>$pi</RESPONSABLE>\n"; 
  print  XML_BTL_FILE "      <ACQUISITION LOGICIEL=\"$acquisitionSoftware\" version=\"$acquisitionVersion\"></ACQUISITION>\n"; 
  print  XML_BTL_FILE "      <TRAITEMENT LOGICIEL=\"$processingSoftware\" version=\"$processingVersion\"></TRAITEMENT>\n"; 
  print  XML_BTL_FILE "      <VALIDATION LOGICIEL=\"$0\" VERSION=\"$VERSION\" DATE=\"$today\" OPERATEUR=\"$creator\" CODIFICATION=\"OOPC\">\n";
  print  XML_BTL_FILE "        <CODE>$processing_code</CODE>\n";	    
  print  XML_BTL_FILE "        <COMMENTAIRE>$comment</COMMENTAIRE>\n";
  print  XML_BTL_FILE "        <COMMENTAIRE>$title_summary</COMMENTAIRE>\n";
  print  XML_BTL_FILE "      </VALIDATION>\n";  
  print  XML_BTL_FILE "    </CYCLE_MESURE>\n";  
  print  XML_BTL_FILE "    <INSTRUMENT TYPE=\"$btlType\" NUMERO_SERIE=\"$btlSn\">\n"; 
  print  XML_BTL_FILE "    </INSTRUMENT>\n";  
  print  XML_BTL_FILE "  </ENTETE>\n";  
  print  XML_BTL_FILE "  <DATA>\n";  
}

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
#sub julian {
#  my($jj,$h,$m) = @_;
#  my $tmp = (($h * 60) + $m ) / 1440;
#  return( $jj + $tmp ); 
#}

#------------------------------------------------------------------------------
# entete ODV
#------------------------------------------------------------------------------
sub entete_odv { 
  my $today = &dateFormat(undef,"%Y-%m-%dT%H:%M:%S");
  my $cwd = getcwd();

  print  ODV_FILE "//ODV Spreadsheet file : $odv_file\n"; 
  print  ODV_FILE "//Data treated : $today\n"; 
  print  ODV_FILE "//<DataType>Profiles</DataType>\n";
  print  ODV_FILE "//<InstrumentType>$btlType</InstrumentType>\n";
  print  ODV_FILE "//<Source>$cwd</Sources>\n"; 
  print  ODV_FILE "//<Creator>$creator</Creator>\n";
  print  ODV_FILE "//\n"; 
  print  ODV_FILE "Cruise\tStation\tType\tyyyy-mm-ddThh:mm:ss\tLongitude [degrees_east]\tLatitude [degrees_north]\tBot. Depth [m]";
  foreach my $key (@odv_hdr) {
    print ODV_FILE "\t$key $odv_hdr{$key}";
  }
  print  ODV_FILE "\n";
}


#------------------------------------------------------------------------------
# Debut du programme principal
#------------------------------------------------------------------------------
# the TZ Date::Manip config variable is deprecated
# &Date_Init( "TZ=UTC" );
&Date_Init('SetDate=now,UTC');
&read_config('../config.ini');
&usage if( $#ARGV == -1);
&get_options;

# define files name
$file     = lc $ascii_dir.$cycle_mesure .'-all.btl';
$xml_file = lc $ascii_dir.$cycle_mesure .'-all_btl.xml';
$odv_file = lc $odv_dir.$cycle_mesure .'-all_btl-odv.txt';

# get variables liste order from header
@header = split /\s+/, $header;
# convert variable $split from config.ini to hash, ex $split = bottle,1,month,2,...
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

# test if output dirs exist and create them if not
mkdir($odv_dir) unless(-d $odv_dir);
mkdir($ascii_dir) unless(-d $ascii_dir);

# ouvre les fichiers de sortie
open( BTL_FILE, "+> $file" ) or die "Can't open file : $file\n";
open( XML_BTL_FILE, "+> $xml_file" ) or die "Can't open file : $xml_file\n";
open( ODV_FILE,     "+> $odv_file" )   or die "Can't open file : $odv_file\n";

print BTL_FILE " St  Date_deb  Heure_deb  Date_fin Heure_fin  Latitude  Longitude  Nb_btl\n\n"; 
&entete_odv;
&write_xml_header;
print XML_BTL_FILE "$header\n";

# parcourt des fichiers .btl passes en argument sur la ligne de commande
for( my $i = 0; $i <= $#ARGV; $i++ ){
  my $fileName = $ARGV[$i];

  # ouverture du fichier
  open( DATA_FILE, $fileName );
  print STDERR  "\nLit: $fileName  = " if $debug;

  # recupere le numero de la station dans le nom du fichier
  ($PRFL) = ($fileName =~ m/$cruisePrefix(\d{$stationPrefixLength})/i);

  $BOTL = 0;

  # on lit le fichier bouteille
  while( <DATA_FILE> ){  
    # decode la date et heure de debut de station	  
    if( /System UpLoad Time =\s+(\.*)/)	{ # a modifier suivant le contexte
      ($time)  = /System UpLoad Time =\s+(\w+\s+\d+\s+\d+\s+\d+:\d+:\d+)/;	
    $date=&ParseDate($time);
    # transforme le day_of_year en julian day
    $julien = &UnixDate($time,"%j") -1;
    $julien = &julian( $julien, &UnixDate($date,"%H"),&UnixDate($date,"%M"),&UnixDate($date,"%S") );
    $s_date = &UnixDate($date,"%d/%m/%Y %H:%M:%S");
    #$t_date = &UnixDate($date,"%Y%m%d%H%M%S");
    $t_date = &UnixDate($date,"%q");
    }
    if( /NMEA Latitude\s*=\s*(\d+\s+\d+.\d+\s+\w)/ )	{
      ($lat_deg, $lat_min, $lat_hemi) = split " ", $1;
      $lat_pos = &position($lat_deg, $lat_min, $lat_hemi);
    }
    if( /NMEA Longitude\s*=\s*(\d+\s+\d+.\d+\s+\w)/ ) {
      ($long_deg, $long_min, $long_hemi) = split " ", $1;
      $long_pos = &position($long_deg, $long_min, $long_hemi);
      # print header and add 1e36 to complement columns
      printf XML_BTL_FILE "%05d  %d %7.3f %7.4f %8.4f %s" ,$PRFL,$code,$julien,$lat_pos, $long_pos,$t_date;
      printf XML_BTL_FILE " 1e36" x (@header -6);
      printf XML_BTL_FILE "\n";
    }
    # decodage du fond (sonde)
    if( /Bottom Depth\s*:\s*(\d*)\s*\S*/i ) {
      $bottom_depth = ($1 eq '') ?  1e+36 : $1; 
    }  
     # decode la date de chaque prelevement et extrait les donnees dans la ligne correspondante
     # les parametres suivants doivent etre presents:
     # Bottle Date Sal00 Sal11 Sbeox0ML/L Sbeox0Mm/Kg Sbeox1ML/L Sbeox1Mm/Kg Sbeox0dOV/dT Sbeox1dOV/dT PrDM DepSM 
     # T090C T190C C0S/m C1S/m Sbeox0V Sbeox1V (optionnels) FlECO-AFL Xmiss
     # amop
     # Bottle Date Sal00 Sal11 Sbeox0ML/L Sbeox0Mm/Kg Sbeox1ML/L Sbeox1Mm/Kg TimeJ PrDM DepSM T090C T190C
     # C0S/m C1S/m Sbeox0V Sbeox1V Upoly0 FlC CStarAt0 CStarTr0 Spar Par Cpar Sbeox0dOV/dT Sbeox1dOV/dT
     # Position Time    
     # TUR3 -> CStarTr0  (transmissiometre Wetlab %)
     # TUR4 -> Upoly0 (turbidimètre)
     # LGHT;LIGHT IRRADIANCE IMMERGED PAR;micromole photon/(m2.s);0;4000;%8.3lf;9999.999;
     # LGH3;float32;light irradiance corrected par;;micromole photon/(m2.s);;TIME DEPTH LATITUDE LONGITUDE;;0;3000;%8.3f;1E+36;;0.001;;;;;;;
     # LGH4;LIGHT IRRADIANCE SURFACE PAR;micromole photon/(m2.s);0;3000;%8.3lf;9999.999;
     # LGH5 -> CPar (%)
     # #LGHT;LIGHT IRRADIANCE IMMERGED PAR;micromole photon/(m2.s);0;4000;%8.3lf;
     # FLU2 -> FlC (Chelsea Acquatracka III) 
     #
     if( /^\s+\d+\s+\w+\s+\d+\s+\d+/) {
       # extract values and fill hash %data with position give by hash %split from config.ini
       @data = split /\s+/;
       while( my ($key,$value) = each(%split) ) {
         $data{$key} = $data[$value];
       }   
       $date = &ParseDate($data{'month'}.' '.$data{'day'}.' '.$data{'year'});
       $e_date = &UnixDate($date,"%d/%m/%Y");	
       $iso_date = &UnixDate($date,"%Y-%m-%dT");	
       # a changer eventuellement si LADCP et choix "table driven" dans seaseave
       $BOTL += 1;
       # only for profile number or station 
       $data{'PRFL'} = $PRFL;
       # print for each value from hash %data with format from hash %format describe in config.ini
       foreach my $key (@header) {
	  printf XML_BTL_FILE "$format{$key} ",  $data{$key};
       }
       printf XML_BTL_FILE "\n";
     }
     # decode l'heure sur la ligne suivante
     if( /\s+(\d+:\d+:\d+)/) {
       ($time) = /\s+(\d+:\d+:\d+)/;	
       $date = &ParseDate($time);
       $e_time = &UnixDate($date,"%H:%M:%S");	
       if( $BOTL >= 1) {
         printf ODV_FILE "%s\t%05d\t%s\t%s\t%8.4f\t%7.4f",
         $cycle_mesure, $PRFL, $type_odv, $iso_date.&UnixDate($date,"%H:%M:%S"),
         $long_pos, $lat_pos;

         printf ODV_FILE ($bottom_depth > 1e35) ? ("%c", "\t") : ("\t%6.1f", $bottom_depth);

         foreach my $key (@odv_hdr) {
           if ($data{$key} > 1e35 || $data{$key} == -9.99e-29) { 
             print ODV_FILE "\t";
           } else {
             printf ODV_FILE  "\t$format{$key}", $data{$key};
	     #print STDERR  "Key: $key, Format: $format{$key}\n";
           }
         }
         printf ODV_FILE "\n";     
       }  
     }
  }
  # pour chaque fichier, on garde la date et heure de la derniere bouteille
  # impression a l'ecran
  printf STDERR "%05d  %s  %s %s  %02d%c%05.2f %s  %03d\xB0%05.2f %s  %2d", $PRFL, 
    $s_date,$e_date, $e_time, $lat_deg, 176, $lat_min, $lat_hemi, $long_deg, 
    $long_min, $long_hemi,  $BOTL  if $echo;
  printf STDERR "\n" if not $debug and $echo; 

  # impression dans le fichier 
  printf BTL_FILE "%05d %s %s %s %02d%c%05.2f %s %03d%c%05.2f %s  %2d\n", 
    $PRFL, $s_date, $e_date, $e_time, $lat_deg, 176, $lat_min, $lat_hemi,
    $long_deg, 176, $long_min, $long_hemi, $BOTL; 
}  

printf STDERR "\n";

print  XML_BTL_FILE "  </DATA>\n";  
print  XML_BTL_FILE "</OCEANO>\n";  

close BTL_FILE;
close XML_BTL_FILE;
close ODV_FILE;
