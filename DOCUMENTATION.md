# EffortlessArch

Effortless is an automated Arch Linux installation script that simplifies partitioning, setup, and configuration, offering a streamlined experience for users installing Arch Linux. This documentation outlines the setup process, usage instructions, and post-installation configuration.

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Installation Steps](#installation-steps)
   - [Step 1: Boot into Arch Linux Live ISO](#step-1-boot-into-arch-linux-live-iso)
   - [Step 2: Network Configuration](#step-2-network-configuration)
   - [Step 3: Install Git and Clone the Repository](#step-3-install-git-and-clone-the-repository)
   - [Step 4: Make Scripts Executable and Run](#step-4-make-scripts-executable-and-run)
4. [Post Installation](#post-installation)
5. [Customization](#customization)
6. [Enabling and Connecting to the Network After Installation](#enabling-and-connecting-to-the-network-after-installation)
7. [License](#license)

---

## Introduction

EasyArchInstall automates the entire process of Arch Linux installation, including partitioning, system configuration, and installing a desktop environment. The process involves two main scripts:

- `archmavi.sh`: The main installation script that handles partitioning, installing essential packages, and setting up the base system.
- `post-install.sh`: A script that runs inside the chroot environment to handle user creation, configuring the desktop environment, installing drivers, and setting up various services.

---

## Prerequisites

Before starting, ensure that you meet the following requirements:

- A machine with UEFI or BIOS support.
- A bootable Arch Linux USB or live environment.
- Network connectivity for downloading necessary packages.
- Basic knowledge of Linux systems and command-line usage.

---

## Installation Steps

### Step 1: Boot into Arch Linux Live ISO

- Download the Arch Linux ISO from [here](https://archlinux.org/download/).
- Create a bootable USB drive using tools like `dd`, `Rufus`, or `Etcher`.
- Boot the machine from the USB.

### Step 2: Network Configuration

- For Wi-Fi connectivity, use the following commands:
  ```bash
  iwctl
  ```
  Then connect to your network:
  ```bash
  device list
  adapter wlan0 set-property Powered on
  station wlan0 scan
  station wlan0 get-networks
  station wlan0 connect <your-network-name>
  ```
  Or use a direct connection:
  ```bash
  iwctl --passphrase <passphrase> station wlan0 connect <your-network-name>
  ```

### Step 3: Install Git and Clone the Repository

1. Install Git:
   ```bash
   pacman -Sy git
   ```

2. Clone the repository:
   ```bash
   git clone https://github.com/mavilinux/EffortlessArch.git
   cd EffortlessArch
   ```

### Step 4: Make Scripts Executable and Run

1. Make the scripts executable:
   ```bash
   chmod +x archmavi.sh post-install.sh
   ```

2. Run the installation script:
   ```bash
   ./archmavi.sh
   ```

   The script will guide you through these key steps:
   - **Network Configuration**: The script will ensure that your network connection is active.
   - **System Clock Synchronization**: It synchronizes the system clock using NTP.
   - **Keyboard Layout Configuration**: You will be prompted to choose your keyboard layout.
   - **Partitioning**: It asks for disk selection and partitioning (UEFI/GPT or BIOS/MBR).
   - **Mirror List Configuration**: Configures the mirror list for package installations.
   - **Base System Installation**: Installs the base system and essential utilities.
   - **Chroot Environment**: Copies the `post-install.sh` script to the system and enters the chroot environment for further setup.

---

## Post Installation

After running `archmavi.sh`, the script will automatically enter the chroot environment and run `post-install.sh`, which performs the following tasks:

- **Timezone and Locale Configuration**: Set your region, city, and locale settings.
- **Hostname Setup**: Configures your system's hostname.
- **User Setup**: Creates a new user and sets their password.
- **Desktop Environment Installation**: Allows you to choose and install a desktop environment (GNOME, KDE Plasma, XFCE, etc.).
- **Display Manager Setup**: Choose and install a display manager (e.g., GDM, SDDM, LightDM).
- **Graphics Drivers Installation**: Installs the appropriate graphics drivers for your hardware.
- **Audio Server Setup**: Configures the audio server for your system.

---

## Customization

- The script supports various desktop environments (GNOME, KDE Plasma, XFCE) and display managers (GDM, SDDM, LightDM).
- Graphics drivers are automatically selected based on your hardware (AMD, Intel, NVIDIA).
- During post-installation, you can configure your timezone, locale, and hostname.

---

## Enabling and Connecting to the Network After Installation

Once the system reboots and you log into your user session, follow these steps to enable and connect to the network:

### Enable NetworkManager:
```bash
sudo systemctl enable NetworkManager
```

### Start NetworkManager:
```bash
sudo systemctl start NetworkManager
```

#### Connecting to the Internet

- **Wired Connection**: The network will be auto-configured.
- **Wireless Connection**:
  - Open Settings (bottom-left of the screen).
  - In the search bar, type "Wi-Fi" and select Wi-Fi & Networking.
  - Choose a network from the list or click the "+" button to add one.
  - Enter your Wi-Fi credentials to connect.

---

## License

This project is licensed under the MIT License.

For any questions or suggestions, feel free to open an issue or submit a pull request on the GitHub repository.
