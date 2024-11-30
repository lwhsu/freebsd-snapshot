##
##  Makefile -- FreeBSD UFS/ZFS Backup Snapshot Installation/Uninstallation
##

#   make sure system tools are used first
PATH="/bin:/usr/bin:/sbin:/usr/sbin:$PATH"

#   edit a textfile
editfile () {
	file="$1"; shift
    if [ ! -f $file ]; then
        cp /dev/null $file
    fi
    if [ ! -s $file ]; then
        echo "" >>$file # workaround sed(1) bug related to '$r ...'
    fi
	sed <$file >$file.new "$@"
	if cmp $file $file.new >/dev/null 2>&1; then
		rm -f $file.new
	else
		cp -p $file $file.old
		cat $file.new >$file
		rm -f $file.new
	fi
}

#   dispatch into commands
cmd="$1"
shift
case "$cmd" in
    install )
        #   install programs
        install -c -o root -g wheel -m 555 snapshot /usr/sbin/snapshot
        install -c -o root -g wheel -m 555 periodic-snapshot /usr/sbin/periodic-snapshot

        #   install manual pages
        install -c -o root -g wheel -m 444 snapshot.8 /usr/share/man/man8/snapshot.8
        install -c -o root -g wheel -m 444 periodic-snapshot.8 /usr/share/man/man8/periodic-snapshot.8
        gzip -9 -f /usr/share/man/man8/snapshot.8
        gzip -9 -f /usr/share/man/man8/periodic-snapshot.8

		#   install /etc/amd.map.snap configuration
        install -c -o root -g wheel -m 444 amd.map.snap /etc/amd.map.snap

        #   install /etc/crontab extension
        editfile /etc/crontab \
            -e '/maintenance (FreeBSD UFS\/ZFS snapshots only)/,/periodic-snapshot weekly/d' \
            -e '/periodic monthly/r crontab'

        #   install /etc/rc.conf extension
        editfile /etc/rc.conf \
            -e '/UFS\/ZFS Snapshot Access/,/amd_flags/d' \
            -e '$r rc.conf'

        #   install /etc/periodic.conf extension
        editfile /etc/periodic.conf \
            -e '/UFS\/ZFS Snapshot Creation/,/snapshot_schedule/d' \
            -e '$r periodic.conf'
        ;;
    
    uninstall )
        #   uninstall programs
        rm -f /usr/sbin/snapshot
        rm -f /usr/sbin/periodic-snapshot

        #   uninstall manual pages
        rm -f /usr/share/man/man8/snapshot.8.gz
        rm -f /usr/share/man/man8/periodic-snapshot.8.gz

		#   uninstall /etc/amd.map.snap configuration
        rm -f /etc/amd.map.snap

        #   uninstall /etc/crontab extension
        editfile /etc/crontab \
            -e '/maintenance (FreeBSD UFS\/ZFS snapshots only)/,/periodic-snapshot weekly/d'

        #   install /etc/rc.conf extension
        editfile /etc/rc.conf \
            -e '/UFS\/ZFS Snapshot Access/,/amd_flags/d'

        #   install /etc/periodic.conf extension
        editfile /etc/periodic.conf \
            -e '/UFS\/ZFS Snapshot Creation/,/snapshot_schedule/d'
        ;;
esac

