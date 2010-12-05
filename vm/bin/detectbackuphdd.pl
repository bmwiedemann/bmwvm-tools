#!/usr/bin/perl -w
use strict;

my $tunebin="/sbin/tune2fs";

foreach my $dev (</dev/sd[a-z]>) {
	#next if not -e $dev;
	my $tunestr=`$tunebin -l ${dev}1`;
	if($tunestr=~m/^Filesystem volume name:\s*backuphd([123])$/m) {
		print "detected $dev $1\n";
		symlink($dev, "/dev/backuphd$1");
	}
#	print $tunestr;
}
