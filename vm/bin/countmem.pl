#!/usr/bin/perl -w
use strict;

my $mem=`grep mem /vm/vm*/options`;
my $sum=0;
foreach(split("\n",$mem)) {
	next unless m/mem=(\d+)M/;
	$sum+=$1;
}
print "total memory needed: $sum MB\n";

