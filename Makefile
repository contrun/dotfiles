.DEFAULT_GOAL:=home-install

DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ROOTDIR = $(DIR)/root
IGNOREDDIR = $(DIR)/ignored
HOST ?= $(shell hostname)
DESTDIR ?= ${HOME}
DESTROOTDIR ?= /

# The chezmoi state directory is stored in the same directory as the config file,
# which may not be writable.
ifneq (,$(findstring /nix/store/,$(DIR)))
    chezmoiflags =
else
    chezmoiflags = -c $(IGNOREDDIR)/chezmoi.toml
endif
CHEZMOIFLAGS := -v ${chezmoiflags}

CHEZMOI.home = chezmoi
CHEZMOI.root = sudo chezmoi
DESTDIR.home = $(DESTDIR)
DESTDIR.root = $(DESTROOTDIR)
SRCDIR.home = $(DIR)
SRCDIR.root = $(ROOTDIR)

target = $(firstword $(subst -, ,$1))
script = $(firstword $(subst -, ,$1))
action = $(word 2,$(subst -, ,$1))
chezmoi = ${CHEZMOI.$(call target,$@)}
dest = $(DESTDIR.$(call target,$@))
src = $(SRCDIR.$(call target,$@))

.PHONY: install uninstall update pull push autopush upload update home-install root-install home-uninstall root-uninstall

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

update-upstreams:
	nix flake update

home-install:
	[[ -f $(DESTDIR)/.config/Code/User/settings.json ]] || install -DT $(DIR)/dot_config/Code/User/settings.json $(DESTDIR)/.config/Code/User/settings.json
	diff $(DESTDIR)/.config/Code/User/settings.json $(DIR)/dot_config/Code/User/settings.json || nvim -d $(DESTDIR)/.config/Code/User/settings.json $(DIR)/dot_config/Code/User/settings.json
	$(call chezmoi,$@) $(CHEZMOIFLAGS) -D $(call dest,$@) -S $(call src,$@) apply --keep-going || true

root-install:
	$(call chezmoi,$@) $(CHEZMOIFLAGS) -D $(call dest,$@) -S $(call src,$@) apply --keep-going || true

install: home-install root-install

deps-install deps-uninstall deps-reinstall:
	test -f "$(IGNOREDDIR)/$(call script,$@).sh" && DESTDIR=$(DESTDIR) "$(IGNOREDDIR)/$(call script,$@).sh" "$(call action,$@)" || true

all-install: home-install deps-install root-install

home-uninstall root-uninstall:
	$(call chezmoi,$@) $(CHEZMOIFLAGS) -D $(call dest,$@) -S $(call src,$@) purge

uninstall: deps-uninstall home-uninstall root-uninstall

home-manager: home-install
	home-manager switch -v --keep-going --keep-failed

nixos-rebuild-build: install
	nixos-rebuild build --flake .#$(HOST) --show-trace --keep-going --keep-failed

nixos-rebuild-switch: install
	sudo nixos-rebuild switch --flake .#$(HOST) --show-trace --keep-going --keep-failed

nixos-rebuild: install
	git diff --exit-code && sudo nixos-rebuild switch --flake .#$(HOST) --show-trace --keep-going --keep-failed || (git stash; sudo nixos-rebuild switch --flake .#$(HOST) --show-trace --keep-going --keep-failed; git stash pop;)

# Filters do not work yet, as cachix will upload the closure.
cachix-push: nixos-rebuild-build
	nix path-info .#nixosConfigurations.$(HOST).config.system.build.toplevel -r | grep -vE 'clion|webstorm|idea-ultimate|goland|pycharm-professional|datagrip|android-studio-dev|graalvm11-ce|lock$$|-source$$' | cachix push contrun

nixos-update-channels:
	sudo nix-channel --update
