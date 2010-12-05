#!/usr/bin/perl -w
use strict;
my $n=shift(@ARGV)+0;
my $extra=shift(@ARGV);
my $l="/dev/loop$n";
if($extra && $extra eq "-d") {
	exec(qw(/sbin/losetup -d), $l);
}


my @a=glob("/vm/vm$n/.VirtualBox/VDI/*.vdi");
my $fname=shift @a;
#my $offs=8704;

open(my $f, "<", $fname) or die $!;
my $buf;
read($f, $buf, 348);

my $vditype=substr($buf, 76, 1);
if($vditype ne "\002") {
        die "type is not fixed size";
}

# this is the start of the HDD (usually containing the MBR)
my $offs=unpack("L", substr($buf, 344, 4));


#system(qw(/sbin/losetup -o), $offs, "-f", $fname);
system("/sbin/modprobe", "loop");
system("/bin/touch", $fname);
system(qw(/sbin/losetup -o), $offs, $l, $fname);
system("/bin/chown", "vm$n", $l);
chmod(0600, $l);

