# EffortlessArch
Automated Arch Linux installation script to simplify partitioning, setup, and configuration for a streamlined experience.

## Overview

This guide provides the steps to install Arch Linux using two bash scripts: `archmavi.sh` (for the installation process) and `post-install.sh` (for post-installation setup in a chroot environment). These scripts automate the entire process of Arch Linux installation, partitioning, configuring your system, and installing a desktop environment.

## Prerequisites

- A machine with UEFI or BIOS support.
- A bootable Arch Linux USB or live environment.
- Network connectivity to download necessary packages.
- Basic knowledge of Linux systems and command-line usage.

## Files

1. **`archmavi.sh`** - This is the main Arch Linux installation script that handles partitioning, essential packages installation, and initial system configuration.
2. **`post-install.sh`** - This script is executed inside the chroot environment and handles further system configuration, including setting up users, configuring the desktop environment, additional packages, and installing drivers.

## Features
- Supports both **UEFI (GPT)** and **BIOS (MBR)** installations.
- Allows user-driven **disk partitioning** and **automatic mounting**.
- Automates **keyboard layout setup**.
- Installs **user profile setup**, **additional packages**, **GRUB bootloader**.
- Configures **users**, **localization**, and **system services**.

## Installation Steps
1. Boot into an **Arch Linux Live ISO**.
2. Connect to the network:
   - Wi-Fi—authenticate to the wireless network using iwctl.
     ```bash
     root@archiso ~ # iwctl
     [iwd]# help
     ```
     Connect to a network:
     ```bash
     [iwd]# device list
     ```
     If the device or its corresponding adapter is turned off, turn it on:
     ```bash
     [iwd]# adapter wlan0 set-property Powered on
     ```
     Scan for networks:
     ```bash
     [iwd]# station wlan0 scan
     ```
     You can then list all available networks:
     ```bash
     [iwd]# station wlan0 get-networks
     ```
     Finally, to connect to a network:
     ```bash
     [iwd]# station wlan0 connect tux-wifi
     ```
     If the network is hidden:
     ```bash
     [iwd]# station wlan0 connect-hidden tux-wifi
     ```
     You can also give a command line argument to connect to a network directly with a passphrase:
     ```bash
     root@archiso ~ # iwctl --passphrase passphrase station wlan0 connect tux-wifi
     ```
3. Install Git:
   ```bash
   pacman -Sy git
   ```
4. Download the script:
   ```bash
   git clone https://github.com/mavilinux/EffortlessArch.git
   cd EffortlessArch
   ```
5. Make the script executable:
   ```bash
   chmod +x archmavi.sh post-install.sh
   ```
6. Run the script:
   ```bash
   ./archmavi.sh
   ```

7. The script will guide you through the following steps:
    
    - **Network Configuration**: The script checks for network interfaces and tests your connection to the internet.
    - **System Clock Synchronization**: It syncs the system clock using NTP.
    - **Keyboard Layout Configuration**: Allows you to select your preferred keyboard layout.
    - **Partitioning**: Prompts for disk selection and partitioning (UEFI/GPT or BIOS/MBR).
    - **Mirror List Configuration**: Configures the mirror list for package installations.
    - **Base System Installation**: Installs the base Arch system, Linux kernel, and some essential utilities.
    - **Chroot Environment**: Copies the `post-install.sh` script to the system and enters the chroot environment to continue the installation.

### `post-install.sh`
  
Once `archmavi.sh` completes, it will automatically enter the chroot environment and run the `post-install.sh` script, which will perform:
  
- **Timezone and Locale Configuration**: Set your region, city, and locale settings.
- **Hostname Setup**: Configure your system’s hostname.
- **User Setup**: Create a new user and set their password.
- **Desktop Environment Installation**: Choose and install a desktop environment (GNOME, KDE Plasma, XFCE, etc.).
- **Display Manager Setup**: Choose a display manager (e.g., GDM, SDDM, LightDM).
- **Graphics Drivers**: Choose your graphics driver based on your hardware.
- **Audio Server Setup**: Configure the audio server.
  
### 5. Reboot
  
Once the `post-install.sh` script finishes, you can reboot your system:
  
```bash
reboot
```
  
Remove the installation media, and your Arch Linux system should boot into your selected desktop environment.
  
## Customization Options
  
- You can choose from various desktop environments (e.g., GNOME, KDE Plasma, XFCE) and display managers (e.g., GDM, SDDM, LightDM).
- The script provides options for selecting the graphics drivers for different hardware (e.g., AMD, Intel, NVIDIA).
- You can configure your timezone, locale, and hostname as part of the post-installation phase.

## Documentation
For further details, please read the [DOCUMENTATION.md](DOCUMENTATION.md) file.

---

## Enabling and Connecting to the Network After Installation  

After the system reboots and you log into your user session, follow these steps to enable and start NetworkManager:  

1. Open the terminal by pressing **Ctrl + Alt + T**.  
2. Enable NetworkManager to start on boot:  
   ```bash
   sudo systemctl enable NetworkManager
   ```  
3. Start NetworkManager immediately:  
   ```bash
   sudo systemctl start NetworkManager
   ```  

#### Connecting to the Internet  

- **For Wired Connection:**  
  - The network will be auto-configured. No further steps are needed.  

- **For Wireless Connection:**  
  1. Open **Settings** (bottom-left of the screen).  
  2. In the search bar, type **Wi-Fi** and select **Wi-Fi & Networking**.  
  3. Choose a network from the list or click the **+** button to add one.  
  4. Enter your Wi-Fi credentials to connect.  

Your internet should now be fully functional!

---

## License

This project is licensed under the MIT License.

If you have any questions or suggestions, feel free to open an issue or submit a pull request on the GitHub repository.

Feel free to tweak as necessary! If you need anything else, just let me know.
