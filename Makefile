
BINDIR = build/opt/AltCa/bin
CERT = FC56A9E21F6E59720EBE892B8119994B024C8FEB
altca.pkg: $(BINDIR)/setup.sh $(BINDIR)/uninstall.sh installer_scripts/postinstall
	pkgbuild --root build --identifier org.altca.installer \
	--version 0.$(shell cat VERSION) --install-location / \
	--scripts installer_scripts \
	$@

setup/.git/HEAD:
	xcrun git clone git://github.com/AltCA/setup.git

setup/setup.sh: setup/.git/HEAD

,,bindir:
	mkdir -p $(BINDIR)

$(BINDIR)/setup.sh: setup/setup.sh ,,bindir
	cp $< $@

$(BINDIR)/uninstall.sh: setup/uninstall.sh ,,bindir
	cp $< $@

installer_scripts/postinstall: $(BINDIR)/setup.sh
	mkdir -p installer_scripts
	ln $(BINDIR)/setup.sh installer_scripts/postinstall

distribution-template.xml: altca.pkg
	productbuild --synthesize --package altca.pkg $@

# requires xmlstarlet
distribution.xml: distribution-template.xml
	xml ed -i '//installer-gui-script/pkg-ref[1]' -t elem -n title -v "AltCA.org root certificates" < $< | \
	xml ed -i //installer-gui-script/title -t elem -n background -v '' | \
	xml ed -i //installer-gui-script/background -t attr -n file -v ./background.png | \
	xml ed -i //installer-gui-script/background -t attr -n scaling -v proportional | \
	xml ed -i //installer-gui-script/background -t attr -n alignment -v bottomleft \
	> $@

altca-distribution.pkg: altca.pkg distribution.xml resources/background.png
	productbuild --distribution distribution.xml --resources resources $@

altca-signed.pkg: altca-distribution.pkg
	productsign --sign $(CERT) $< $@

clean:
	xcrun git clean -fxd

,,bump-version:
	echo $(shell expr `cat VERSION` + 1 ) > VERSION

,,publish: ,,bump-version altca-signed.pkg
	cp -v altca-signed.pkg ../www/AltCa.pkg
	(cd ../www && xcrun git add AltCA.pkg && xcrun git commit -m "new installer package" && xcrun git push)
	xcrun git reset
	xcrun git add VERSION
	xcrun git commit -m "version bump"
	xcrun git push
