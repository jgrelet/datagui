#!/usr/bin/perl -w
# ***************************************************************************
#    FILE:  mktree.pl
#    USAGE: mktree.pl < cruise-name >
#    perl script for setting up a subdirectory system data-raw and 
#    data-processingfor a cruise 
#
#    $Id$
#
# ***************************************************************************

use File::Path;
use File::Copy;
#use strict;

my $CRUISENAME;
my $cfg_file;

if ($#ARGV == 0)
{
   $CRUISENAME = $ARGV[0];
}
else
{
   print " EXAMPLE:  mktree.pl PANDORA\n";
   die " USAGE:  mktree.pl <[pathname/]cruise-name> [dest-path]\n";
}

=pod
$cfg_file = "$CRUISENAME.rc";
unless (my $return = do $cfg_file) {
  die "couldn't parse $cfg_file: $@" if $@;
  die "couldn't do $cfg_file: $!"    unless defined $return;
  die "couldn't run $cfg_file"       unless $return;
}
=cut

$CRUISENAME = uc $CRUISENAME;

eval {
  mkpath([ "$CRUISENAME/data-raw/MERCURY",
           "$CRUISENAME/data-raw/SOLEX",
           "$CRUISENAME/data-raw/CTD",
           "$CRUISENAME/data-raw/PC-ACQUISITION",
           "$CRUISENAME/data-raw/SADCP",
           "$CRUISENAME/data-raw/SADCP/OS75",
           "$CRUISENAME/data-raw/LADCP",
           "$CRUISENAME/data-raw/THERMO",
           "$CRUISENAME/data-raw/SADCP",
           "$CRUISENAME/data-raw/CELERITE",
           "$CRUISENAME/data-raw/CASINO",
           "$CRUISENAME/data-raw/TECHSAS/ARCHIV_NETCDF/MET",
           "$CRUISENAME/data-raw/TECHSAS/ARCHIV_NETCDF/NAV",
           "$CRUISENAME/data-raw/TECHSAS/ARCHIV_NETCDF/THS",
           "$CRUISENAME/data-raw/TECHSAS/ARCHIV_NMEA/BATOS",
           "$CRUISENAME/data-raw/TECHSAS/ARCHIV_NMEA/COLCOR",
           "$CRUISENAME/data-raw/TECHSAS/ARCHIV_NMEA/NAV",
           "$CRUISENAME/data-raw/TECHSAS/ARCHIV_NMEA/PHINS",
           "$CRUISENAME/data-raw/TECHSAS/ARCHIV_NMEA/SBE21",
           "$CRUISENAME/data-processing/CASINO/data",
           "$CRUISENAME/data-processing/CASINO/plots",
           "$CRUISENAME/data-processing/CTD",
           "$CRUISENAME/data-processing/CTD/data",
           "$CRUISENAME/data-processing/CTD/data/asc",
           "$CRUISENAME/data-processing/CTD/data/btl",
           "$CRUISENAME/data-processing/CTD/data/cnv",
           "$CRUISENAME/data-processing/CTD/data/codac",
           "$CRUISENAME/data-processing/CTD/data/nc",
           "$CRUISENAME/data-processing/CTD/data/raw",
           "$CRUISENAME/data-processing/CTD/data/ladcp",
           "$CRUISENAME/data-processing/CTD/data/reports",
           "$CRUISENAME/data-processing/CTD/data/tmp",
           "$CRUISENAME/data-processing/CTD/coupes",
           "$CRUISENAME/data-processing/CTD/plots/downcast",
           "$CRUISENAME/data-processing/CTD/plots/upcast",
           "$CRUISENAME/data-processing/CTD/plots/TS",
           "$CRUISENAME/data-processing/CTD/odv",
           "$CRUISENAME/data-processing/CTD/psa/seasave",
           "$CRUISENAME/data-processing/CTD/psa/codac",
           "$CRUISENAME/data-processing/CTD/psa/btl",
           "$CRUISENAME/data-processing/CTD/psa/ladcp",
           "$CRUISENAME/data-processing/CTD/psa/seaplot",
           "$CRUISENAME/data-processing/CTD/psa/std",
           "$CRUISENAME/data-processing/CTD/tmp",
           "$CRUISENAME/data-processing/CTD/tracks",
           "$CRUISENAME/data-processing/LADCP",
           "$CRUISENAME/data-processing/LADCP/data",
           "$CRUISENAME/data-processing/LADCP/coupes",
           "$CRUISENAME/data-processing/LADCP/logs",
           "$CRUISENAME/data-processing/LADCP/v10.16.2",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/data",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/data/ctdprof",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/data/ctdtime",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/data/nav",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/data/raw_ctdprof",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/data/raw_ctdtime",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/data/raw_ladcp",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/data/raw_nav",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/data/raw_sadcp",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/data/sadcp",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/logs",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/plots",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/profiles",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/tmp",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/$CRUISENAME/m",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/DOCS",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/m",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/m/ladcp",
           "$CRUISENAME/data-processing/LADCP/v10.16.2/m/sw",
           "$CRUISENAME/data-processing/MERCURY",
           "$CRUISENAME/data-processing/MERCURY/data",
           "$CRUISENAME/data-processing/MERCURY/plots",
           "$CRUISENAME/data-processing/SADCP",
           "$CRUISENAME/data-processing/SADCP/OS75",
           "$CRUISENAME/data-processing/SADCP/OS75/data",
           "$CRUISENAME/data-processing/SADCP/OS75/coupes",
           "$CRUISENAME/data-processing/SADCP/OS75/plot",
           "$CRUISENAME/data-processing/THERMO",
           "$CRUISENAME/data-processing/THERMO/data",
           "$CRUISENAME/data-processing/THERMO/plots",
           "$CRUISENAME/data-processing/THERMO/tsgqc",
           "$CRUISENAME/data-processing/THERMO/psa",
           "$CRUISENAME/data-processing/CELERITE/data",
           "$CRUISENAME/data-processing/CELERITE/plots",
           "$CRUISENAME/data-processing/CELERITE/tracks",
           "$CRUISENAME/data-processing/CELERITE/psa",
           "$CRUISENAME/data-processing/PRODUCTS/MSGCOL",
           "$CRUISENAME/data-processing/PRODUCTS/MSGIRT",
           "$CRUISENAME/data-processing/PRODUCTS/MSGVIS",
           "$CRUISENAME/data-processing/PRODUCTS/SSTMSG",
           "$CRUISENAME/data-processing/PRODUCTS/SSTOSTIA",
           "$CRUISENAME/data-processing/PRODUCTS/SSTMI",
           "$CRUISENAME/data-processing/PRODUCTS/WINDCDC",
           "$CRUISENAME/data-processing/PRODUCTS/AVISO",
           "$CRUISENAME/data-processing/MODELS/SST",
           "$CRUISENAME/data-processing/MODELS/SURFACE_CURRENT",
           "$CRUISENAME/data-adjusted/CTD",
           "$CRUISENAME/data-adjusted/CTD/data",
           "$CRUISENAME/data-adjusted/CTD/metrologie",
           "$CRUISENAME/data-adjusted/CTD/psa",
           "$CRUISENAME/data-adjusted/CTD/scripts",
           "$CRUISENAME/data-final/CTD",
           "$CRUISENAME/data-final/CTD/data",
           "$CRUISENAME/Documents",
           "$CRUISENAME/Documents/INSTRUCTIONS",
           "$CRUISENAME/Documents/FORMULAIRES",
           "$CRUISENAME/Documents/ENREGISTREMENTS",
           "$CRUISENAME/Documents/RAPPORTS",
           "$CRUISENAME/Documents/PHOTOS",
           "$CRUISENAME/Documents/ARVOR",
           "$CRUISENAME/Documents/ATLAS",
           "$CRUISENAME/Documents/CO2",
           "$CRUISENAME/Documents/EXPEDITIONS",
           "$CRUISENAME/Documents/METROLOGIE",
           "$CRUISENAME/Documents/PLANNING",
           "$CRUISENAME/Documents/PRESENTATIONS",
           "$CRUISENAME/Documents/SOFTWARES",
           "$CRUISENAME/Documents/TECHNIQUE",
           "$CRUISENAME/tmp",
           "$CRUISENAME/local/etc",
           "$CRUISENAME/local/etc/skel",
           "$CRUISENAME/local/sbin"],
           1, 0777);	
};
if ($@) {
  die "Couldn't create directory: $@";
}

print "\n Done.\n"; 
