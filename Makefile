.DEFAULT_GOAL:=home-install

DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ROOTDIR = $(DIR)/root

.PHONY: install uninstall update pull push autopush upload update home-install root-install home-uninstall root-uninstall

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

update: pull update-upstreams install

update-upstreams:
	if cd ~/.local/share/chezmoi/dot_config/nixpkgs/; then niv update; fi

home-install:
	[[ -f ~/.config/Code/User/settings.json ]] || install -DT $(DIR)/dot_config/Code/User/settings.json ~/.config/Code/User/settings.json
	diff ~/.config/Code/User/settings.json $(DIR)/dot_config/Code/User/settings.json || nvim -d ~/.config/Code/User/settings.json $(DIR)/dot_config/Code/User/settings.json
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
