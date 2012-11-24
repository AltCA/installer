
BINDIR = build/opt/AltCa/bin
CERT = FC56A9E21F6E59720EBE892B8119994B024C8FEB

altca.pkg: $(BINDIR)/setup.sh $(BINDIR)/uninstall.sh
	pkgbuild --root build --identifier org.altca.installer --version 0.1 --install-location / $@

setup/.git/HEAD:
	xcrun git clone git://github.com/AltCA/setup.git
setup/setup.sh: setup/.git/HEAD

,,bindir:
	mkdir -p $(BINDIR)

$(BINDIR)/setup.sh: setup/setup.sh ,,bindir
	cp $< $@

$(BINDIR)/uninstall.sh: setup/uninstall.sh ,,bindir
	cp $< $@

altca-signed.pkg: altca.pkg
	productsign --sign $(CERT) $< $@

clean:
	rm -rvf altca-signed.pkg altca.pkg $(BINDIR) setup