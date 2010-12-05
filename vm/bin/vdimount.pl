#!/usr/bin/perl -w
use strict;
my $infile=shift;
my $partition=shift||0; # 0 to 3
open(my $f, "<", $infile) or die $!;
my $buf;
read($f, $buf, 348);

my $vditype=substr($buf, 76, 1);
if($vditype ne "\002") {
	die "type is not fixed size";
}

# this is the start of the HDD (usually containing the MBR)
my $offs=unpack("L", substr($buf, 344, 4));

# first partition usually starts at sector 63 of a hard-disk
# see fdisk -lu for exact values
print "#dd if=$infile bs=$offs skip=1\n";
print "#losetup --offset=$offs /dev/loop1 $infile\n";
read($f, $buf, $offs-348); # read away remaining VDI header
read($f, $buf, 512); # read MBR+partition table
close $f;
#$offs+=63*512;
my $sig=substr($buf, 510,2);
if($sig eq "\x55\xaa") { # verify magic to know that this really is a partition table
   my $sector=unpack("L", substr($buf, (0x1c6+$partition*16), 4));
   $offs+=$sector*512;
}

#print "offset=$offs\n";
print "mount -r -o loop,offset=$offs $infile /mnt/1\n";

