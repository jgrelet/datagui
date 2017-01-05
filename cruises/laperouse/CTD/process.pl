#!perl -w
#
# script de lancement du processing Seabird AMOP 
# JGrelet IRD US191 Brest janvier 2014
# utiliser la deuxieme option "#w" pour modifier les .psa lors de 
# la premiere configuration du processing
use strict; 
use Getopt::Long;

# modify the variables for the cruise
my $cruise   = 'laperouse';
my $fileName = "lape%02d";

# TODOS: get path from filename
my $drive    = "m:";

# chemin a modifier suivant ou est realise le traitement
my $pathNameForCruise = uc $cruise;
my $path="$drive\\$pathNameForCruise\\data-processing\\CTD";
# location for batch files
my $batch = "$path\\batch";
my $first;
my $last;
my $station;
my ($ros,$hex);
my $codac_file;
my $cmd;
my $user_input;
my $system;
my $config = '';

# define options
my $all = 1;
my ($btl, $codac, $pmel, $ladcp, $std, $plot, $report) = undef; 
my ($DEBUG, $help) = undef;

#------------------------------------------------------------------------------
# usage()
#------------------------------------------------------------------------------	
sub usage() {
  print STDERR "\nusage:   perl process.pl [options] first_station [last_station|\"#w\"]\n";
  print STDERR   "Options:\n    --help                 Display this help message\n";
  print STDERR   "    --debug                display command, don't process\n";  
  print STDERR   "    --btl                  process sample\n";
  print STDERR   "    --codac                process realtime data for CODAC\n";
  print STDERR   "    --pmel                 process realtime data for PMEL\n";
  print STDERR   "    --ladcp                process LADCP data\n";
  print STDERR   "    --std|ctd              process Seabird cast\n";
  print STDERR   "    --plot                 process plots \n";
  print STDERR   "    --report               process Seabird report \n";
  print STDERR   "    --all                  process all steps, default\n";	
  print STDERR "\nexample: perl process.pl 1\n";
  print STDERR "\nexample: perl m:\\LAPEROUSE\\data-processing\\CTD\\process.pl 01\n\n";
  print STDERR "\nexample: perl m:\\LAPEROUSE\\data-processing\\CTD\\process.pl 01 09 --std\n\n";
  # don't close windows before press the RETURN key
  printf STDERR "Press return to exit ....\n";
  # wait for user input
  $user_input = <STDIN>;
  exit 1;
}

#------------------------------------------------------------------------------
# get_options()
# analyse les options
#------------------------------------------------------------------------------	
sub get_options() {
  
  my $debug = undef;

  &GetOptions ("btl"             => \$btl,               
               "codac"           => \$codac, 
               "pmel"            => \$pmel, 	       
               "ladcp"           => \$ladcp,   
               "std"             => \$std,  
               "ctd"             => \$std,  
               "plot"            => \$plot, 
               "report"          => \$report,  	       
               "all"             => \$all,   
	       "debug"           => \$DEBUG,  
               "help"            => \$help)  or &usage;  
       
  &usage   if $help;
  $all = 0 if (defined $btl || defined $codac || defined $ladcp || 
      defined $std || defined $plot || defined $report || defined $pmel); 
  # all by default
  if ($all) { $btl = $codac = $ladcp = $std = $plot = $report = 1; }
}

#------------------------------------------------------------------------------
# Debut du programme principal
#------------------------------------------------------------------------------
&usage if( $#ARGV == -1);
&get_options;

if($#ARGV == 0) {
  $first = $last = $ARGV[0];
} 
elsif( $#ARGV == 1 ) {
  $first = $ARGV[0];
  if( $ARGV[1] =~ /#w/ ) {
    $config = "#w";
    $first = $last = $ARGV[0];
  } 
  else {
    $last = $ARGV[1];
  } 
} 
else {
  &usage();
}

for( my $i = $first; $i <= $last; $i++ ) {

  $station = sprintf($fileName, $i);
  $ros = sprintf("%s\\data\\tmp\\%s.ros", $path, $station);
  $hex = sprintf("%s\\data\\raw\\%s.hex", $path, $station);
  if( -e $hex ) {
    printf STDERR "Process station: %s %s:\n", $station, $config;
    if (defined $ladcp ) {
      # printf STDERR $ros."\n";
      $cmd = sprintf("SBEBatch.exe %s\\ladcp.batch %s %s %s", 
                    $batch, $station, $path,$config);
      defined $DEBUG ? printf STDERR "$cmd\n" : system($cmd);
    }
    if (defined $codac ) {
      $cmd = sprintf("SBEBatch.exe %s\\codac.batch %s %s %s", 
                      $batch, $station, $path,$config);
      defined $DEBUG ? printf STDERR "$cmd\n" : system($cmd);
    }
    if (defined $pmel ) {
      $cmd = sprintf("SBEBatch.exe %s\\pmel.batch %s %s %s", 
                      $batch, $station, $path,$config);
      defined $DEBUG ? printf STDERR "$cmd\n" : system($cmd);
    }    
    if (defined $std ) {
      $cmd = sprintf("SBEBatch.exe %s\\std.batch %s %s %s", 
                      $batch, $station, $path,$config);
      defined $DEBUG ? printf STDERR "$cmd\n" : system($cmd);
    }
    if (defined $plot ) {
      $cmd = sprintf("SBEBatch.exe %s\\seaplot.batch %s %s %s", 
                      $batch, $station, $path,$config);
      defined $DEBUG ? printf STDERR "$cmd\n" : system($cmd);
    }
    if (defined $report ) {
      $cmd = sprintf("%s\\report.bat %s %s", $path, $station, $path);
      defined $DEBUG ? printf STDERR "$cmd\n" : system($cmd);
    }    
    if (defined $btl ) {
      # if bottle, call rossum
      if( -e $ros ) {
        printf STDERR " with bottles\n";
        $cmd = sprintf("SBEBatch.exe %s\\btl.batch %s %s %s", 
                        $batch, $station, $path, $config);
        defined $DEBUG ? printf STDERR "$cmd\n" : system($cmd);
      } 
      else {
        printf STDERR "\n";
      }
    }
    if (defined $codac ) {
      # compress file averaged every 5 db for Coriolis
      $codac_file = sprintf("%s\\data\\codac\\%s.cnv", $path, $station);
      if( -e $codac_file ) {
        $cmd = sprintf("bzip2.exe -f %s", $codac_file);
        defined $DEBUG ? printf STDERR "$cmd\n" : system($cmd);
      }
      else {
        printf STDERR "Warning !!!\nCodac: file \"%s\" not exit !!!\n", $codac_file;
      }
    }
  } 
  else {
    printf STDERR "Warning !!!\nFile \"%s\" not exist !!!\n", $hex;
  }
}
# don't close windows before press the RETURN key
printf STDERR "Press return to exit ....\n";
# wait for user input
$user_input = <STDIN>;
exit;
