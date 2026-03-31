---
icon: lucide/file-text
title: Docker Installation Guide
---

# Docker Installation Guide 
**Platforms:** Windows, macOS, NixOS

## Overview
This guide provides step-by-step instructions for installing Docker on Windows, macOS, and NixOS.

## 🪟 Windows (Docker Desktop)

### Prerequisites
  - Windows 10/11 (64-bit)
  - WSL 2 enabled
  - Virtualization enabled in BIOS 

### Steps
  1. Download Docker Desktop: https://www.docker.com/products/docker-desktop/
  2. Run the installer and follow prompts.
  3. Enable WSL 2 if not already enabled
  ```powershell
  wsl --install
  ```
  4. Restart your computer.
  5. Launch Docker Desktop and wait until it is running.

### Verify Installation 
```powershell
docker --version
docker run hello-world
```

## 🍎 macOS (Docker Desktop)
### Prerequisites
  - macOS 11 or newer
  - Apple Silicon or Intel processor

### Steps
  1. Download Docker Desktop for Mac: https://www.docker.com/products/docker-desktop/ 
  2. Open the `.dmg` file.
  3. Drag Docker into the Applications folder.
  4. Launch Docker from Applications.
  5. Grant necessary permissions when prompted.

### Verify Installation
```bash
docker --version
docker run hello-world
``` 

## ❄️NixOS
### Prerequisites
  - NixOS system with root access

### Steps
  1. Edit your NixOS configuration file
  ```bash
  sudo nano /etc/nixos/configuration.nix
  ```

  2. Add Docker to your configuration
  ```nix
  virtualisation.docker.enable = true;
  ```
  3. (Optional) Add your user to the Docker group
  ```nix
  users.users.yourUsername.extraGroups = [ "docker" ];
  ```
  4. Apply the configuration:
  ```bash
  sudo nixos-rebuild switch
  ```
  5. Start Docker service (if not already running)
  ```bash
  sudo systemctl start docker
  ```
### Verify Installation
```bash
docker --version
docker run hello-world
```
## Troubleshooting
### Common Issues
  - **Permission denied (Linux/NixOS):**
  ```bash
  sudo usermod -aG docker $USER
  ```
  - **Docker not starting (Windows/macOS):**
    - Ensure virtualization is enabled
    - Restart Docker Desktop

## References
  - https://docs.docker.com/
  - https://nixos.org/manual/nixos/stable/
