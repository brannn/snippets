#!/usr/bin/perl

use Socket;
use FileHandle;
use Fcntl;
use Getopt::Std;
use IO::Socket;


   ($host,$user,$pwd) = getArgs();

   unless ( $host and $user and $pwd ) {
      print "Host:Port   > ";
      chomp($host = <>);
      print "Username    > ";
      chomp($user = <>);
      print "Password    > ";
      chomp($pwd = <>);
   }

   unless ( $host and $user and $pwd ) {
      print "Please supply host, username, and password\n";
      exit;
imapCapability.pl: unmodified: line 1


sub login {

my $user = shift;
my $pwd  = shift;
my $conn = shift;

   sendCommand ($conn, "1 LOGIN $user $pwd");
   while (1) {
        readResponse ( $conn );
        last if $response =~ /^1 OK/i;
        if ($response =~ /NO|BAD/i) {
           print "Unexpected LOGIN response: $response\n";
           return 0;
        }
   }
   print "Logged in as $user\n" if $debug;
      
   return 1;
}
   
sub capability {
      
my $conn = shift;
my @response;
my $capability;

   sendCommand ($conn, "1 CAPABILITY");
   while (1) {
        readResponse ( $conn );
        $capability = $response if $response =~ /\* CAPABILITY/i;
        last if $response =~ /^1 OK/i;
        if ($response =~ /^1 NO|^1 BAD/i) {
           print "Unexpected response: $response\n";
           return 0;
        }
   }
   
   print STDOUT "\nThe server supports the following IMAP capabilities:\n\n";
   $capability =~ s/^\* CAPABILITY //;
   print "$capability\n";
 
}

sub logout {
   
my $conn = shift;
   
   undef @response;
   sendCommand ($conn, "1 LOGOUT");
   while ( 1 ) {
        readResponse ($conn);
        if ( $response =~ /^1 OK/i ) {
                last;
        }
        elsif ( $response !~ /^\*/ ) {
                print "Unexpected LOGOUT response: $response\n";
                last;
        }
   }
   close $conn;
   return;
}

sub sendCommand {
   
my $fd = shift;
my $cmd = shift;
 
    print $fd "$cmd\r\n";
}

sub readResponse {

my $fd = shift;

    $response = <$fd>;
    chop $response;
    $response =~ s/\r//g;
    push (@response,$response);
}
