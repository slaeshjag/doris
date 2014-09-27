VALAPKG	=	--pkg gdk-2.0 --pkg gtk+-2.0 --pkg webkit-1.0 --pkg libsoup-2.4
SRC	=	browser_web_view.vala doris_window.vala doris.vala doris_config.vala doris_navigate.vala
BIN	=	doris.elf
VALAC	:=	valac
VALAFLAG=	-X -w

all:
	$(VALAC) $(VALAFLAG) $(VALAPKG) $(SRC) -o $(BIN)

clean:
	rm -f $(BIN)
