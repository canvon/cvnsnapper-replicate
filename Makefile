DEST=/usr/local
export DEST

all:
	@echo "Available targets: install"

install:
	@echo "Installing to $$DEST ..."
	install -d "$$DEST/lib/cvnsnapper-toolbox"
	install -t "$$DEST/lib/cvnsnapper-toolbox" -p -m u=rw,g=r,o=r \
		lib/cvnsnapper-toolbox/liblog.sh \
		lib/cvnsnapper-toolbox/libbtrfs.sh \
		lib/cvnsnapper-toolbox/libsnapper.sh
	install -t "$$DEST/lib/cvnsnapper-toolbox" -p \
		lib/cvnsnapper-toolbox/replicate-send \
		lib/cvnsnapper-toolbox/replicate-receive \
		lib/cvnsnapper-toolbox/replace-active \
		lib/cvnsnapper-toolbox/import-name2infoxml \
		lib/cvnsnapper-toolbox/import-byreplication \
		lib/cvnsnapper-toolbox/plain-backingstorage \
		lib/cvnsnapper-toolbox/plain-genmetadata \
		lib/cvnsnapper-toolbox/plain-statusmetadata
	ln -sf plain-genmetadata "$$DEST/lib/cvnsnapper-toolbox/plain-diffmetadata"
	install -d "$$DEST/bin"
	install -t "$$DEST/bin" -p \
		bin/cvnsnapper
