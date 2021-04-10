Ansible playbook to install nixos

# Install on raspberry pi

It is a little tricky to install nixos on raspberry bi. I made some trivial modification to https://github.com/NixOS/nixpkgs/issues/63720#issuecomment-522331183

Here is my configuration.nix.

```nix
{ pkgs, ... }:

{
  # Tell the host system that it can, and should, build for aarch64.
  nixpkgs = rec {
    crossSystem = (import <nixpkgs> {}).pkgsCross.aarch64-multiplatform.stdenv.targetPlatform;
    localSystem = crossSystem;
  };

  fileSystems."/" =
    { device = "default/ROOT/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "default/NIX/nix";
      fsType = "zfs";
    };

  fileSystems."/tmp" =
    { device = "default/TMP/tmp";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "default/HOME/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/ABF1-9994";
      fsType = "vfat";
    };

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.xterm.enable = false;
    windowManager.i3.enable = true;
    videoDrivers = [ "fbdev" ];
  };

  services.openssh.enable = true;

  networking.hostName = "hostname";
  networking.hostId = "6666f459";
  networking.wireless.iwd.enable = true;

  hardware.enableRedistributableFirmware = true;

  users.users.e = {
    isNormalUser = true;
    password = "badpassword";
  };

  # For the ugly hack to run the activation script in the chroot'd host below. Remove after sd card is set up.
  environment.etc."binfmt.d/nixos.conf".text = ":aarch64:M::\\x7fELF\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\xb7\\x00:\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xfe\\xff\\xff\\xff:/run/binfmt/aarch64:";
  boot= {
    kernelPackages = pkgs.linuxPackages_rpi4;
    loader = {
      grub.enable = false;
      raspberryPi = {
        enable = true;
        version = 4;
      };
    };
  };
}
```

You may need to change the zpool name, boot partition uuid, user name, hostname, hostid.

```shell
zfs_passphrase=zfs_passphrase
root_password=root_password
user_password=user_password
tmp_mount_path=/tmpmount

ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -i inventory --become --become-user=root --extra-vars host=localhost --extra-vars '{"zfs_pool_disks": ["/dev/sda"]}' --extra-vars "zfs_passphrase=$zfs_passphrase" --extra-vars "root_password=$root_password" --extra-vars "user_password=$user_password" --extra-vars "tmp_mount_path=$tmp_mount_path" site.yml

NIX_PATH="nixpkgs=$HOME/Workspace/nixpkgs" nix-build -E "(import <nixpkgs/nixos> { configuration.imports = [ configuration.nix ]; }).system"

sudo nixos-install --root "$tmp_mount_path" --system "$(readlink result)"

bash_path="$(head -n1 $tmp_mount_path/nix/var/nix/profiles/system/activate | sed -E 's/#!\s*//g')"

sudo install -D /etc/binfmt.d/nixos.conf "$tmp_mount_path/etc/binfmt.d/nixos/conf"; sudo install -D /run/binfmt/ "$tmp_mount_path/run/binfmt/"

sudo chroot $tmp_mount_path $bash_path -c /nix/var/nix/profiles/system/activate

sudo install -D /etc/binfmt.d/nixos.conf "$tmp_mount_path/etc/binfmt.d/nixos/conf"; sudo install -D /run/binfmt/aarch64-linux "$tmp_mount_path/run/binfmt/aarch64-linux"

sudo chroot $tmp_mount_path $bash_path -c /nix/var/nix/profiles/system/activate

sudo chroot $tmp_mount_path $bash_path -c '/run/current-system/bin/switch-to-configuration boot'

sudo chroot $tmp_mount_path $bash_path -c "(echo \"$root_password\"; echo \"$root_password\") | passwd"
sudo chroot $tmp_mount_path $bash_path -c "(echo \"$user_password\"; echo \"$user_password\") | passwd e"
```
