PROJECT_NAME = kde-tilling-on-drag
KWINPKG_FILE=$(PROJECT_NAME).kwinscript
MAIN_FILE=contents/code/main.js

install: build
	plasmapkg2 -t kwinscript -s $(PROJECT_NAME) \
		&& plasmapkg2 -u $(KWINPKG_FILE) \
		|| plasmapkg2 -i $(KWINPKG_FILE)
uninstall:
	plasmapkg2 -t kwinscript -r $(PROJECT_NAME)
debug:
	qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.showInteractiveKWinConsole
debug-run: build
	bin/load-script.sh "$(MAIN_FILE)" "$(PROJECT_NAME)-test"
debug-stop:
	bin/load-script.sh "unload" "$(PROJECT_NAME)-test"
debug-logs:
	journalctl -f -t kwin_wayland
debug-console:
	plasma-interactiveconsole
list:
	@grep '^[^#[:space:]].*:' Makefile
compile:
	@rm -Rf node_modules
	@npm install typescript
	@npx tsc
clear:
	rm -f "$(KWINPKG_FILE)"
	rm -Rf build
	rm -f contents/code/main.js
lint:
	npx eslint $(MAIN_FILE)
build: clear compile
	mkdir -p build/contents/code
	cp -r contents/code build/contents/
	@find "build/" '(' -name "*.ts" ')' -delete
	@find "build/" -type d -empty -print -delete
	cp metadata.json build/
	@7z a -tzip $(KWINPKG_FILE) ./build/*
