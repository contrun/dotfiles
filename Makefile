.DEFAULT_GOAL:=home-install

DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ROOTDIR = $(DIR)/root

.PHONY: install uninstall update pull push autopush upload update home-install root-install home-uninstall root-uninstall

pull:
	git diff --exit-code && git pull --rebase=true || (git stash; git pull --rebase=true; git stash pop;)

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

update: pull install

home-install:
	cp ~/.config/Code/User/settings.json $(DIR)/dot_config/Code/User/settings.json
	chezmoi apply -v

home-manager: home-install
	home-manager switch -v

root-install:
	(cd; sudo chezmoi -c $(ROOTDIR)/chezmoi.toml apply -v)

install: home-install root-install

nixos-rebuild: install
	sudo nixos-rebuild switch --show-trace

aio: install
	home-manager switch -v
	sudo nixos-rebuild switch --show-trace

home-uninstall:
	chezmoi purge -v

root-uninstall:
	(cd; sudo chezmoi -c $(ROOTDIR)/chezmoi.toml purge -v)

uninstall: home-uninstall root-uninstall
