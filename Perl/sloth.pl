#!/usr/bin/env perl

#
# Select long-running Apache requests from the Apache scoreboard
#

#use strict;
use warnings;
use Data::Dumper;
use Parse::Apache::ServerStatus::Extended;

# File containing FQDN servers to be polled, one per line
my $hostfile = "hosts.dat";

my $port     = 8000;

# First scoreboard key
my $key1 = "m";

# First scoreboard key value
my $val1 = "W ";

my $key2 = "ss";
my $val2 = "2";

# Number of times per server both k/v pairs test true before producing output
my $thresh = "5";

open( FILE, $hostfile ) || die("Could not open hosts file!");
my @hosts = <FILE>;

foreach $server (@hosts) {
    chomp $server;
    print "\n[$server]\n";
    my $parser = Parse::Apache::ServerStatus::Extended->new;
    $parser->request( url => "http://$server:$port/status",
                      timeout => 10 ) || die $parser->errstr;
    my $stat = $parser->parse || die $parser->errstr;

    foreach $i ( @{$stat} ) {
        if ( $i->{'m'} eq $val1 && $i->{'ss'} > $val2 ) {
            push( @pids, $i->{'pid'} );
            %sloth =
              ( pid => $i->{'pid'}, req => $i->{'request'}, sec => $i->{'ss'} );
            foreach $key ( keys %sloth ) {
                $value = $sloth{$key};
                print "$key => $value\n" unless ( scalar(@pids) < $thresh );
            }
        }
    }
}
