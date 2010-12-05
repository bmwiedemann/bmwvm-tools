#!/bin/sh
in=virtualbox_1.6.6-35336_Debian_etch_i386.deb
out=virtualbox-server_1.6.6-35336_Debian_etch_i386.deb
wget -nc http://download.virtualbox.org/virtualbox/debian/pool/non-free/v/virtualbox/$in
dir=tmp
rm -rf $dir
mkdir $dir/DEBIAN -p
dpkg-deb --extract $in $dir
dpkg-deb --control $in $dir/DEBIAN

# clean
cd $dir
rm -rf usr/share/virtualbox/sdk usr/lib/virtualbox/VirtualBox usr/lib/virtualbox/VBoxSDL usr/bin/VirtualBox usr/bin/VBoxSDL

# drop X11&co from dependencies
perl -i -pe 's/Package: virtualbox/$&-server\nConflicts: virtualbox/;\
s/(Depends: ).*/$1libc6 (>= 2.3.6-6), libgcc1 (>= 1:4.1.1-12), libssl0.9.8 (>= 0.9.8c-1), libstdc++6 (>= 4.1.1-12), libxml2 (>= 2.6.27), debconf (>= 0.5) | debconf-2.0, psmisc, adduser/;\
s/(Recommends: ).*/$1linux-headers, gcc, make, binutils, bridge-utils, uml-utilities, libhal1 (>= 0.5)/' DEBIAN/control


cat >etc/vbox/settings <<EOF
# this file is sourced by /etc/init.d/vbox

# list numbers of VMs to start at boot on this host
START_VMS=""
EOF
echo /etc/vbox/settings >>DEBIAN/conffiles

cat >etc/init.d/vbox <<EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:       vbox
# Required-Start: \$network vboxnet vboxdrv
# Required-Stop:
# Default-Start:  2 3 4 5
# Default-Stop:   0 1 6
# Description:    VirtualBox server autostart
### END INIT INFO

. /etc/vbox/settings

case \$1 in
	start)
		echo "starting vms"
		for i in \$START_VMS ; do
			su -c /vm/vm\$i/start - vm\$i
		done
	;;
	stop)
		echo "stopping vms"
		for i in \$(seq 1 9) ; do
			su -c /vm/vm\$i/stop - vm\$i &
		done
		n=20
		# wait up to \$n seconds for VMs to stop cleanly
		while test \$n -gt 0 && killall -0 VBoxSVC ; do
			sleep 1
			n=\$(expr $n - 1)
		done
	;;
	status)
		ps axu|grep "/usr/lib/virtualbox/*V"
	;;
	*)
	echo "Usage: \$0 {start|stop|status}"
	;;
esac
EOF
chmod 755 etc/init.d/vbox

dpkg-deb --build . ../$out
