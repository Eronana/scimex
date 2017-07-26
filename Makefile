SRCDIR = src
BINDIR = bin
CC = clang
CFLAGS = -O2 -Wall
TARGETS = $(BINDIR)/scimex $(BINDIR)/scimex.dylib $(BINDIR)/bootstrap.dylib
DEAMON_PLIST = /Library/LaunchDaemons/scimex.deamon.plist
DYLIB_PATH =  ~/Library/Containers/com.apple.inputmethod.SCIM/Data/scimex.dylib
SCIM_BIN_DIR = /usr/local/share/scimex
SCIMEX_PATH = $(SCIM_BIN_DIR)/scimex
BOOTSTRAP_PATH = $(SCIM_BIN_DIR)/bootstrap.dylib

all: $(TARGETS)

$(BINDIR)/scimex: $(shell find $(SRCDIR)/injector -name *.cpp -o -name *.c -o -name *.h)
	@mkdir -p $(BINDIR)
	$(CC) $(CFLAGS) -Wno-implicit-function-declaration -framework CoreFoundation -o $@ $(shell find $(SRCDIR)/injector -name *.cpp -o -name *.c)

$(BINDIR)/scimex.dylib: $(shell find $(SRCDIR)/injlib -name *.m -o -name *.h)
	@mkdir -p $(BINDIR)
	$(CC) $(CFLAGS) -Wno-objc-method-access -framework Foundation -dynamiclib -o $@ $(shell find $(SRCDIR)/injlib -name *.m)


$(BINDIR)/bootstrap.dylib: $(shell find $(SRCDIR)/bootstrap -name *.cpp -o -name *.h)
	@mkdir -p $(BINDIR)
	$(CC) $(CFLAGS) -framework CoreFoundation -dynamiclib -o $@ $(shell find $(SRCDIR)/bootstrap -name *.cpp)

$(DEAMON_PLIST): scimex.deamon.plist
	cat scimex.deamon.plist| sed 's/{{USER}}/$(shell whoami)/' | sudo tee $@ > /dev/null
	sudo chown root $@

$(DYLIB_PATH): $(BINDIR)/scimex.dylib
	cp $< $@

$(SCIMEX_PATH): $(BINDIR)/scimex
	mkdir -p $(SCIM_BIN_DIR)
	cp $< $@

$(BOOTSTRAP_PATH): $(BINDIR)/bootstrap.dylib
	mkdir -p $(SCIM_BIN_DIR)
	cp $< $@

test: $(DYLIB_PATH) $(SCIMEX_PATH) $(BOOTSTRAP_PATH)
	sudo $(SCIMEX_PATH) /Users/`whoami`

install:$(DEAMON_PLIST) $(DYLIB_PATH) $(SCIMEX_PATH) $(BOOTSTRAP_PATH)
	sudo launchctl load $(DEAMON_PLIST)

uninstall:
	sudo launchctl unload $(DEAMON_PLIST)
	sudo rm -f $(DEAMON_PLIST)
	rm -f $(DYLIB_PATH)
	rm -rf $(SCIM_BIN_DIR)

clean:
	rm -f $(TARGETS)
