# NixOS Configs

Personal NixOS flake with Home Manager integrated as a NixOS module.

## Fresh Install Guide

This guide starts from a fresh NixOS install and gets you to a running system using this repo.

### 1. Install Base NixOS

1. Boot the NixOS installer ISO.
2. Partition, format, and mount disks.

3. Do a normal first install so the machine can boot:

```bash
sudo nixos-install --root /mnt
```

4. Reboot into the installed system.

### 2. Prepare the New System

1. Log in as your user.
2. Install git (temporary, if not already installed):

```bash
nix-shell -p git
```

3. Clone this repo:

```bash
git clone https://github.com/<your-user>/<your-repo>.git ~/nixos_configs
cd ~/nixos_configs
```

4. Replace the repo hardware file with this machine's generated one:

```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
```

### 3. Verify Host and User Values

Check these values match the target machine before switching:

1. Hostname in [configuration.nix](configuration.nix)
2. User account name and groups in [configuration.nix](configuration.nix)
3. Home Manager username and home path in [home.nix](home.nix)

### 4. Validate the Flake

Run validation before applying:

```bash
nix --extra-experimental-features "nix-command flakes" flake check
```

Optional dry build:

```bash
nix --extra-experimental-features "nix-command flakes" build .#nixosConfigurations.nixos.config.system.build.toplevel
```

### 5. Switch to This Configuration

Apply the system and Home Manager config together:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

Home Manager is already integrated in [flake.nix](flake.nix), so no separate home-manager command is needed.

### 6. Reboot and Confirm

1. Reboot.
2. Log in.
3. Confirm expected apps and shell setup are present.

## Ongoing Use

### Flake updates (version bumps)

Inputs stay pinned by `flake.lock` until you update them.

Update all flake inputs:

```bash
cd ~/nixos_configs
nix flake update
```

Update only one input:

```bash
cd ~/nixos_configs
nix flake lock --update-input nixpkgs
nix flake lock --update-input home-manager
```

After updating, validate and apply:

```bash
nix --extra-experimental-features "nix-command flakes" flake check
sudo nixos-rebuild switch --flake .#nixos
```

Tip: commit `flake.lock` after a successful update so the exact versions are reproducible.

### Update after edits

```bash
cd ~/nixos_configs
nix --extra-experimental-features "nix-command flakes" flake check
sudo nixos-rebuild switch --flake .#nixos
```

### Boot next generation only

```bash
sudo nixos-rebuild boot --flake .#nixos
```

## Rollback

Show generations:

```bash
sudo nix-env -p /nix/var/nix/profiles/system --list-generations
```

Roll back to previous generation:

```bash
sudo nixos-rebuild switch --rollback
```

Or roll back from the boot menu by selecting an older generation.

## Notes

1. Keep all referenced files tracked in git when using flakes from a git repo.
2. This config currently targets host output name nixos, so rebuild commands use .#nixos.
