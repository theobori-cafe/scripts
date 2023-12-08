PREFIX_DIR = /usr/local

# Symbolic links path
INSTALL_DIR = $(PREFIX_DIR)/bin

# Scripts path
OPT_DIR = $(PREFIX_DIR)/opt/scripts

SCRIPTS = backup-docker-db \
	backup-docker-volumes \
	report-range

SCRIPTS_LINKS = $(foreach script, $(SCRIPTS), $(INSTALL_DIR)/$(script))

all: help

init:
	test -d $(INSTALL_DIR) || mkdir -p $(INSTALL_DIR)
	test -d $(OPT_DIR) || mkdir -p $(OPT_DIR)

install: init
	cp -f $(SCRIPTS) $(OPT_DIR)
	ln -s $(OPT_DIR)/* $(INSTALL_DIR)

clean:
	$(RM) $(OPT_DIR)/*
	$(RM) $(SCRIPTS_LINKS)

uninstall: clean
	$(RM) -r $(OPT_DIR)

re: uninstall install

help:
	@echo "scripts"
	@echo 
	@echo "Install the scripts with the following command"
	@echo "sudo make install"
	@echo 
	@echo "Uninstall the scripts with the following command"
	@echo "sudo make uninstall"

.PHONY: \
	init \
	clean \
	install \
	uninstall \
	re \
	help
