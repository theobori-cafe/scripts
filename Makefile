PREFIX_DIR ?= /usr/local

# Symbolic links path
INSTALL_DIR = $(PREFIX_DIR)/bin

# Scripts path
OPT_DIR = $(PREFIX_DIR)/opt/scripts

SCRIPTS = backup-docker-db.sh \
	report-range.sh

SCRIPTS_LINKS = $(foreach script, $(SCRIPTS), $(INSTALL_DIR)/$(script))

all: help

.PHONY: init
init:
	test -d $(INSTALL_DIR) || mkdir -p $(INSTALL_DIR)
	test -d $(OPT_DIR) || mkdir -p $(OPT_DIR)

.PHONY: install
install: init
	cp -f $(SCRIPTS) $(OPT_DIR)
	ln -s $(OPT_DIR)/* $(INSTALL_DIR)

.PHONY: clean
clean:
	$(RM) $(OPT_DIR)/*
	$(RM) $(SCRIPTS_LINKS)

.PHONY: uninstall
uninstall: clean
	$(RM) -r $(OPT_DIR)

.PHONY: re
re: uninstall install

.PHONY: help
help:
	@echo "scripts"
	@echo 
	@echo "Install the scripts with the following command"
	@echo "make install"
	@echo 
	@echo "Uninstall the scripts with the following command"
	@echo "make uninstall"
