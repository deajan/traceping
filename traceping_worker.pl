#!/usr/bin/env perl
#
# Single threaded version of the traceping_daemon, should probably just be used for testing.
#

use strict;
use warnings;

use DBI;
use DBD::SQLite;
use Data::Dumper;

use lib '/opt/smokeping/lib';
use Smokeping;

# CONFIG VARS, CHANGE THESE TO YOUR SETUP.
#
my $config_file = '/opt/smokeping/etc/config';

my $dsn = "dbi:SQLite:dbname=/opt/smokeping/data/traceping.sqlite";
my $db_username = '';
my $db_password = '';

# load the smokeping_config to $Smokeping::cfg
Smokeping::load_cfg($config_file, 1);

my %index_cache;

while (1) {
	# get each server's info.
	foreach my $group ( keys %{ $Smokeping::cfg->{'Targets'} } ) {
		unless ( ref $Smokeping::cfg->{'Targets'}->{$group} ) {
			# Unless the entry in the smokeping hash is a reference to another datastructure
			next;
		}
		my $group_hr = $Smokeping::cfg->{'Targets'}->{$group};

		foreach my $server ( keys %{ $group_hr } ) {
			unless ( ref $group_hr->{$server} && ref $group_hr->{$server} eq 'HASH' ) {
				# Unless the entry in the smokeping hash is a reference to another datastructure
				next;
			}

			# set target to Group.Name, like in the UI
			my $target = "${group}.${server}";
			my $host = $group_hr->{$server}->{host};
			print "${target}: ${host}\n";
			do_traceroute( $target, $host );
		}
	}
}

print Dumper \%index_cache;

# run the traceroute & log it!
sub do_traceroute {
	my ( $target, $host ) = @_;

	my $output = get_traceroute( $host );

	my $dbh = DBI->connect($dsn, $db_username, $db_password);

	my $sth = $dbh->prepare( 'INSERT INTO host (target, tracert) VALUES (?, ?)');
	$sth->execute($target, $output);	
}

# get a traceroute's output or die a terrible terrible death (or something)
sub get_traceroute {
	my ( $host ) = @_;
	my @output;

	my $last_index_with_data = 0;
	my $index = 0;

	open my $tracert_out, "-|", "traceroute", $host;
	while ( my $line = readline $tracert_out ) {
		chomp $line;

		if ( $line =~ /\s*\d+\s+([a-z0-9\*].+)$/i ) {
			# keep track of when we just get * * * responses so that we can strip them out
			$last_index_with_data = $index if $1 ne '* * *';
		}

		push @output, $line;
		$index++;
	}
	close $tracert_out;

	return join("\n", @output[0 .. $last_index_with_data]);
}
