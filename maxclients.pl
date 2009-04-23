#!/usr/bin/perl
#
# Estimate maximum MaxClients value for Apache2 (pre-fork)
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
printf("Total physical memory: %d GB\n", $maxphy / (1024*1024));
printf("Percent allocated to Apache: %.0f%%\n", 100 * $maxapache);
printf("Average child size: %d MB\n", $average / 1024);
printf("Estimated maximum MaxClients value: %.0f\n", $maxclients);
