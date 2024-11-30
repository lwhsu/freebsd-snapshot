##
##  Makefile -- FreeBSD UFS/ZFS Backup Snapshot
##

all:
	@echo "make install"
	@echo "make uninstall"
	@echo "make tarball"

install:
	@sh ./install.sh install

uninstall:
	@sh ./install.sh uninstall

tarball:
	@shtool tarball -c "gzip -9" -o ../dist/freebsd-snapshot-`cat VERSION`.tar.gz .

man-html:
	@nroff -man snapshot.8 | rman -f html -n snapshot -s 8 >snapshot.8.html
	@nroff -man periodic-snapshot.8 | rman -f html -n periodic-snapshot -s 8 >periodic-snapshot.8.html

