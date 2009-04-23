#!/usr/bin/perl
#
# Estimate Apache2 maximum MaxClients value (pre-fork)
#

use strict;

my $host = $ENV{HOSTNAME};
chomp(my $maxphy = `cat /proc/meminfo | awk '{print \$2}' | head -1`); 
my $maxapache = .80;
my ($sum, $child);
my @data = `ps -ylC httpd | awk '{print \$8}' | sed \'1d\'`;

# Find average child RSS 
foreach my $n (@data) {
  $child++;                 
  $sum += $n;              
}

my $average = $sum / $child; 

# Estimate MaxClients
my $maxclients = (($maxphy) * $maxapache) / ($average);

# Output
print "\nHost: $host\n";
print "Date: ", scalar localtime(), "\n";
print "---\n";
print "Total physical memory (kB): $maxphy\n";
printf("Percent allocated to Apache: %.0f%%\n", 100 * $maxapache);
printf("Average child size (kB): %.0f\n", $average);
printf("Estimated maximum MaxClients value: %.0f\n", $maxclients);
