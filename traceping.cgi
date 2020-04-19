#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

use DBI;
use DBD::SQLite;

use CGI::Fast;

while (my $q = CGI::Fast->new) {
    print "Content-type: text/html\n\n";


    my $dsn = "dbi:SQLite:dbname=/opt/smokeping/data/traceping.sqlite";
    my $db_username = '';
    my $db_password = '';


    print "Content-Type: text/html\r\n\r\n";

    my $target;

    # Validate input
    if ( $ENV{'QUERY_STRING'} =~ /^target=([a-zA-Z0-9._-]+)$/ ) {
       	$target = $1;
    }
    else {
	print 'No valid target given';
	exit 1;
    }

    print '<div id="traceroute"><pre style="width: 900px; overflow: auto;">' . get_traceroute($target) . '</pre></div>';

    sub get_traceroute {
	my ( $target ) = @_;
	my $result = "";
	my $dbh = DBI->connect($dsn, $db_username, $db_password);
	my $sth = $dbh->prepare('SELECT timestamp, tracert FROM host WHERE target=? ORDER BY record_id DESC LIMIT 5');
	$sth->execute($target);
	my @row;
	while (@row = $sth->fetchrow_array) {
		my ($date, $tracert) = @row;
		$result = $result . $date . ':<br>' . $tracert . '<br><br>';
	}
	if ( $result) {
	return $result;
	}
    return 'No Traceroute Data Found';

    }
}
