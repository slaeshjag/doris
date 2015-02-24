VALAPKG	=	--pkg gdk-3.0 --pkg gtk+-3.0 --pkg webkit2gtk-4.0 --pkg libsoup-2.4 --pkg libnotify
SRC	=	browser_web_view.vala doris_window.vala doris.vala doris_config.vala doris_navigate.vala doris_download.vala
BIN	=	doris.elf
VALAC	:=	valac
VALAFLAG=	-X -w

all:
	$(VALAC) $(VALAFLAG) $(VALAPKG) $(SRC) -o $(BIN)

clean:
	rm -f $(BIN)
