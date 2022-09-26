.DEFAULT_GOAL := home-install
.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))

DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ROOTDIR = $(DIR)/root
IGNOREDDIR = $(DIR)/ignored
HOST ?= $(shell hostname)
DESTDIR ?= ${HOME}
DESTROOTDIR ?= /
VERBOSE ?=
# The chezmoi state directory is stored in the same directory as the config file,
# which may not be writable.
CHEZMOIFLAGS ?= $(strip $(if $(VERBOSE),-v) --keep-going)

CHEZMOI.home = chezmoi
CHEZMOI.root = sudo chezmoi
DESTDIR.home = $(DESTDIR)
DESTDIR.root = $(DESTROOTDIR)
SRCDIR.home = $(DIR)
SRCDIR.root = $(ROOTDIR)
target = $(firstword $(subst -, ,$1))
script = $(firstword $(subst -, ,$1))
action = $(word 2,$(subst -, ,$1))
chezmoi = ${CHEZMOI.$(firstword $(subst -, ,$1))} ${CHEZMOIFLAGS}
dest = $(DESTDIR.$(firstword $(subst -, ,$1)))
src = $(SRCDIR.$(firstword $(subst -, ,$1)))

pull:
	git pull --rebase --autostash

push:
	git status
	git commit -a -m "auto push at $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')"
	git log HEAD^..HEAD
	git diff HEAD^..HEAD
	read -p 'Press enter to continue, C-c to exit' && git push

autopush:
	git commit -a -m "auto push at $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')"
	git push

upload: pull push

update: pull update-upstreams deps-install install

home-install:
	$(call chezmoi,$@) -D $(call dest,$@) -S $(call src,$@) apply || true

root-install:
	$(call chezmoi,$@) -D $(call dest,$@) -S $(call src,$@) apply || true

install: home-install root-install

deps-install deps-uninstall deps-reinstall:
	test -f "$(IGNOREDDIR)/$(call script,$@).sh" && DESTDIR=$(DESTDIR) "$(IGNOREDDIR)/$(call script,$@).sh" "$(call action,$@)" || true

all-install: home-install deps-install root-install

home-uninstall root-uninstall:
	$(call chezmoi,$@) -D $(call dest,$@) -S $(call src,$@) purge

uninstall: deps-uninstall home-uninstall root-uninstall
