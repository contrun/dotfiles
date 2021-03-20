.DEFAULT_GOAL:=home-install

DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ROOTDIR = $(DIR)/root
IGNOREDDIR = $(DIR)/ignored
HOST ?= $(shell hostname)
DESTDIR ?= ${HOME}
DESTROOTDIR ?= /

.PHONY: install uninstall update pull push autopush upload update home-install root-install home-uninstall root-uninstall

script = $(firstword $(subst -, ,$1))
action = $(word 2,$(subst -, ,$1))

pull:
	git pull --rebase --autostash

push:
	git status
	git commit -a -m "auto push at $(shell date -R)"
	git log HEAD^..HEAD
	git diff HEAD^..HEAD
	read -p 'Press enter to continue, C-c to exit' && git push

autopush:
	git commit -a -m "auto push at $(shell date -R)"
	git push

upload: pull push

update: pull update-upstreams deps-install install

update-upstreams:
	if cd $(DESTDIR)/.local/share/chezmoi/dot_config/nixpkgs/; then niv update; fi

home-install:
	[[ -f $(DESTDIR)/.config/Code/User/settings.json ]] || install -DT $(DIR)/dot_config/Code/User/settings.json $(DESTDIR)/.config/Code/User/settings.json
	diff $(DESTDIR)/.config/Code/User/settings.json $(DIR)/dot_config/Code/User/settings.json || nvim -d $(DESTDIR)/.config/Code/User/settings.json $(DIR)/dot_config/Code/User/settings.json
	chezmoi -c $(IGNOREDDIR)/chezmoi.toml -D $(DESTDIR) apply -v

home-manager: home-install
	home-manager switch -v --keep-going

root-install:
	(mkdir -p $(DESTROOTDIR); sudo chezmoi -c $(IGNOREDDIR)/chezmoi.toml -D $(DESTROOTDIR) -S $(ROOTDIR) apply -v)

install: home-install root-install

deps-install deps-uninstall deps-reinstall:
	test -f "$(IGNOREDDIR)/$(call script,$@).sh" && DESTDIR=$(DESTDIR) "$(IGNOREDDIR)/$(call script,$@).sh" "$(call action,$@)" || true

nixos-rebuild: install
	sudo nixos-rebuild switch --flake .#$(HOST) --show-trace --keep-going

nixos-update-channels:
	sudo nix-channel --update

all-install: nixos-update-channels nixos-rebuild home-manager

home-uninstall:
	chezmoi -c $(IGNOREDDIR)/chezmoi.toml purge -v

root-uninstall:
	(mkdir -p $(DESTROOTDIR); sudo chezmoi -c $(IGNOREDDIR)/chezmoi.toml -D $(DESTROOTDIR) -S $(ROOTDIR) purge -v)

uninstall: deps-uninstall home-uninstall root-uninstall
