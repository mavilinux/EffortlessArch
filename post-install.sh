#!/bin/bash 
# ======================================================
#   Arch Linux Installation Script - Chroot Phase
#   Version: v1.1.0
#   Author: Muawia Rehman (Mavi)
# ======================================================

# ======================================================
## 1. Configure the System
# ======================================================
clear
echo -e "\e[1;34m=====================================\e[0m"
echo -e "\e[1;32m    Entered Chroot Environment     \e[0m"
echo -e "\e[1;34m=====================================\e[0m"
sleep 1

# Timezone Configuration
echo -e "\n\e[1;33m[ Timezone Configuration ]\e[0m"
while true; do
    read -p "Enter your Region (e.g., America): " region
    if [[ -z "$region" ]]; then
        echo -e "\e[1;31mRegion cannot be empty. Please enter a valid region.\e[0m"
    else
        break
    fi
done

while true; do
    read -p "Enter your City (e.g., New_York): " city
    if [[ -z "$city" ]]; then
        echo -e "\e[1;31mCity cannot be empty. Please enter a valid city.\e[0m"
    else
        break
    fi
done

ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc
echo -e "\e[1;32mTimezone set to $region/$city.\e[0m"

# Locale Configuration
echo -e "\n\e[1;33m[ Locale Configuration ]\e[0m"
echo "Please uncomment the necessary UTF-8 locale, then press Ctrl+O to save and Ctrl+X to exit."
sleep 2
nano /etc/locale.gen
locale-gen

# Hostname Configuration
echo -e "\n\e[1;33m[ Hostname Configuration ]\e[0m"
while true; do
    read -p "Enter your desired hostname: " hostname
    if [[ -z "$hostname" ]]; then
        echo -e "\e[1;31mHostname cannot be empty. Please enter a valid hostname.\e[0m"
    else
        break
    fi
done
echo "$hostname" > /etc/hostname
echo -e "\n\e[1;32mHostname set as $hostname.\e[0m"

echo -e "\n\e[1;31mSet root password:\e[0m"
passwd

# ======================================================
# 2. Creating a New User
# ======================================================
echo -e "\n\e[1;33m[ User Account Setup ]\e[0m"
while true; do
    read -p "Enter the new username (or type 'done' to finish): " username
    if [[ "$username" == "done" ]]; then
        break
    elif [[ -z "$username" ]]; then
        echo -e "\e[1;31mUsername cannot be empty. Please enter a valid username.\e[0m"
    elif id "$username" &>/dev/null; then
        echo -e "\e[1;31mUser '$username' already exists.\e[0m"
    else
        useradd -m -G wheel -s /bin/bash "$username"
        echo -e "\e[1;31mSet password for the new user:\e[0m"
        passwd "$username"
        sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^# //' /etc/sudoers
        echo -e "\n\e[1;32mUser $username created and added to sudoers.\e[0m"
    fi
done

# ======================================================
# 3. Desktop Environment Selection
# ======================================================
echo -e "\nSelect a Desktop Environment:"
echo "1. GNOME"
echo "2. KDE Plasma (default)"
echo "3. XFCE"
echo "4. LXDE"
echo "5. Cinnamon"
echo "6. MATE"
echo "7. Budgie"
echo "8. Pantheon"
echo "9. Enlightenment"
echo "10. COSMIC"
echo "11. Cutefish"
echo "12. Deepin"
echo "13. Skip Desktop Environment Installation"
read -p "Enter the number corresponding to your choice: " de_choice

# If Enter is pressed (empty input), default to KDE Plasma (2)
if [ -z "$de_choice" ]; then
    de_choice=2
fi

if [ "$de_choice" -eq 13 ]; then
    echo -e "\e[1;31mSkipping Desktop Environment installation.\e[0m"
else
    case $de_choice in
        1) desktop_environment="gnome"; additional_packages="gnome gnome-tweaks gnome-shell-extensions xorg"; default_display_manager="gdm" ;;
        2) desktop_environment="kde plasma"; additional_packages="plasma kde-applications konsole xorg"; default_display_manager="sddm" ;;
        3) desktop_environment="xfce4"; additional_packages="xfce4 xfce4-goodies thunar xorg"; default_display_manager="lightdm" ;;
        4) desktop_environment="lxde"; additional_packages="lxde lxde-common lxsession xorg"; default_display_manager="lxdm" ;;
        5) desktop_environment="cinnamon"; additional_packages="cinnamon cinnamon-screensaver nemo xorg"; default_display_manager="lightdm" ;;
        6) desktop_environment="mate"; additional_packages="mate mate-extra caja xorg"; default_display_manager="lightdm" ;;
        7) desktop_environment="budgie"; additional_packages="budgie budgie-extras nemo xorg"; default_display_manager="lightdm" ;;
        8) desktop_environment="pantheon"; additional_packages="pantheon pantheon-session pantheon-files xorg"; default_display_manager="lightdm" ;;
        9) desktop_environment="enlightenment"; additional_packages="enlightenment terminology econnman xorg"; default_display_manager="entrance" ;;
        10) desktop_environment="cosmic"; additional_packages="cosmic cosmic-shell gnome-shell-extensions xorg"; default_display_manager="gdm" ;;
        11) desktop_environment="cutefish"; additional_packages="cutefish cutefish-desktop cutefish-session xorg"; default_display_manager="lightdm" ;;
        12) desktop_environment="deepin"; additional_packages="deepin deepin-extra deepin-terminal xorg"; default_display_manager="lightdm" ;;
        *) echo "Invalid choice, defaulting to kde plasma"; desktop_environment="kde plasma"; additional_packages="plasma kde-applications konsole xorg"; default_display_manager="sddm" ;;
    esac

    # Input validation for Desktop Environment choice
    if [[ ! "1 2 3 4 5 6 7 8 9 10 11 12 13" =~ $de_choice ]]; then
        echo "Invalid choice, exiting the script."
        exit 1
    fi

    read -p "Install meta packages for $desktop_environment ? (yes/no): " install_meta
    if [ "$install_meta" == "yes" ]; then
        pacman -S "$desktop_environment" --noconfirm
    fi
    pacman -S $additional_packages --noconfirm

    # Search for related packages using pacman -Ss
    echo -e "\nSearching for packages related to $desktop_environment..."
    pacman -Ss $desktop_environment

    # Display Manager Selection
    echo -e "\nSelect a Display Manager (default is $default_display_manager):"
    echo "1. gdm"
    echo "2. sddm"
    echo "3. lightdm"
    echo "4. lxdm"
    echo "5. entrance"
    read -p "Enter the number corresponding to your choice (default is $default_display_manager): " dm_choice

    # If Enter is pressed (empty input), default to the previously selected display manager
    if [ -z "$dm_choice" ]; then
        dm_choice=2  # Default to sddm
    fi

    # Input validation for Display Manager choice
    if [[ ! "1 2 3 4 5" =~ $dm_choice ]]; then
        echo "Invalid choice, defaulting to $default_display_manager"
        dm_choice=2  # Default to sddm
    fi

    case $dm_choice in
        1) display_manager="gdm" ;;
        2) display_manager="sddm" ;;
        3) display_manager="lightdm" ;;
        4) display_manager="lxdm" ;;
        5) display_manager="entrance" ;;
        *) echo "Invalid choice, defaulting to $default_display_manager"; display_manager="$default_display_manager" ;;
    esac

    # Installing and Enabling Display Manager
    echo -e "\n\e[1;33m[ Display Manager Installation ]\e[0m"
    pacman -S $display_manager --noconfirm
    pacman -S xorg --noconfirm  # Ensure xorg is installed for all display managers

    systemctl enable $display_manager

    echo -e "\n\e[1;32mSelected Desktop Environment: $desktop_environment\e[0m"
    echo -e "\e[1;32mSelected Display Manager: $display_manager\e[0m"
fi

# ======================================================
# 4. Installing Graphics Driver
# ======================================================
echo -e "\n\e[1;33m[ Graphics Driver Selection ]\e[0m"
echo "1) All opensource (default)  2) AMD/ATI  3) Intel  4) NVIDIA (open)"
echo "5) NVIDIA (proprietary)  6) VMware/VirtualBox"
while true; do
    read -p "Enter your choice (number): " gfx_choice
    if [[ "$gfx_choice" -ge 1 && "$gfx_choice" -le 6 ]]; then
        break
    else
        echo -e "\e[1;31mInvalid choice. Please select a valid number (1-6).\e[0m"
    fi
done

gfx_drivers=("mesa" "xf86-video-amdgpu" "xf86-video-intel" "xf86-video-nouveau" "nvidia nvidia-utils" "xf86-video-vmware")

gfx_index=$((gfx_choice-1))
graphics_driver=${gfx_drivers[$gfx_index]}
pacman -S "$graphics_driver" --noconfirm
echo -e "\n\e[1;32mGraphics Driver $graphics_driver installed.\e[0m"

# Audio Server Selection
echo -e "\n\e[1;33m[ Audio Server Selection ]\e[0m"
echo "1. pipewire"
echo "2. pulseaudio"
while true; do
    read -p "Enter the number corresponding to your choice: " audio_choice
    if [[ "$audio_choice" -ge 1 && "$audio_choice" -le 2 ]]; then
        break
    else
        echo -e "\e[1;31mInvalid choice. Please select a valid number (1-2).\e[0m"
    fi
done

case $audio_choice in
    1) audio_server="pipewire" ;;
    2) audio_server="pulseaudio" ;;
    *) audio_server="pipewire pipewire-alsa pipewire-pulse pipewire-jack" ;;
esac

pacman -S "$audio_server" --noconfirm

echo -e "\e[1;32mSelected Desktop Environment: $desktop_environment\e[0m"
echo -e "\e[1;32mSelected Graphics Driver: $graphics_driver\e[0m"
echo -e "\e[1;32mSelected Audio Server: $audio_server\e[0m"

# ======================================================
# 5. Installing efibootmgr
# ======================================================
echo -e "\n\e[1;33m[ Installing efibootmgr ]\e[0m"
pacman -S efibootmgr --noconfirm

# ======================================================
# 6. Installing git
# ======================================================
echo -e "\n\e[1;33m[ Installing git ]\e[0m"
pacman -S git --noconfirm

# ======================================================
# 7. Installing yay AUR Helper
# ======================================================

# Default URL
repo_url="https://aur.archlinux.org/yay.git"

# Try to clone from the default repository
git clone $repo_url

# Check if the cloning failed
if [ $? -ne 0 ]; then
    echo -e "\n\e[1;31m[ERROR] Failed to clone the repository from $repo_url.\e[0m"
    # Prompt user if they want to continue with a custom URL or skip
    read -p "Do you want to enter a new repository URL or skip? (Enter 'new' to enter a new URL, or 'skip' to skip): " user_choice

    if [ "$user_choice" == "skip" ]; then
        echo -e "\e[1;33m[INFO] Skipping the repository clone step.\e[0m"
    elif [ "$user_choice" == "new" ]; then
        # Prompt user for custom URL
        read -p "Enter the new repository URL: " new_repo_url

        # Attempt to clone again using the new URL
        git clone $new_repo_url

        # Check if the cloning succeeded
        if [ $? -eq 0 ]; then
            echo -e "\e[1;32m[INFO] Successfully cloned from $new_repo_url.\e[0m"
        else
            echo -e "\e[1;31m[ERROR] Failed to clone the repository from the provided URL.\e[0m"
            exit 1
        fi
    else
        echo -e "\e[1;31m[ERROR] Invalid option. Exiting...\e[0m"
        exit 1
    fi
else
    echo -e "\e[1;32m[INFO] Successfully cloned the repository from $repo_url.\e[0m"
fi


# ======================================================
# 8. Installing network manager
# ======================================================
echo -e "\n\e[1;33m[ Network Manager Installation ]\e[0m"
pacman -S networkmanager --noconfirm

# ======================================================
# 9. Installing additional packages
# ======================================================
echo -e "\n\e[1;33m[ Additional Packages Installation ]\e[0m"
read -p "Do you want to install additional packages? (yes/no): " install_additional

if [[ "$install_additional" == "yes" ]]; then
    echo "Please enter the number of additional packages to install (1-10):"
    while true; do
        read -p "Number of packages: " num_pkgs
        if [[ "$num_pkgs" -ge 1 && "$num_pkgs" -le 10 ]]; then
            break
        else
            echo -e "\e[1;31mInvalid number of packages. Please enter a number between 1 and 10.\e[0m"
        fi
    done

    packages=()
    for ((i=1; i<=num_pkgs; i++)); do
        read -p "Enter package $i: " pkg
        packages+=("$pkg")
    done

    while true; do
        filtered_packages=()
        unfound_packages=()

        for pkg in "${packages[@]}"; do
            if [[ -n "$pkg" ]]; then
                if pacman -Si "$pkg" &>/dev/null; then
                    filtered_packages+=("$pkg")
                else
                    unfound_packages+=("$pkg")
                fi
            fi
        done

        if [[ ${#unfound_packages[@]} -eq 0 ]]; then
            break
        fi

        echo "The following packages were not found: ${unfound_packages[@]}"
        echo "Please re-enter the correct names for the unfound packages."
        new_unfound_packages=()
        for pkg in "${unfound_packages[@]}"; do
            read -p "Enter correct name for package '$pkg': " correct_pkg
            if pacman -Si "$correct_pkg" &>/dev/null; then
                filtered_packages+=("$correct_pkg")
            else
                echo "Package '$correct_pkg' still not found."
                new_unfound_packages+=("$pkg")
            fi
        done
        packages=("${new_unfound_packages[@]}")
    done

    if [[ ${#filtered_packages[@]} -gt 0 ]]; then
        pacman -S "${filtered_packages[@]}" --noconfirm
        echo -e "\n\e[1;32mAdditional packages installed.\e[0m"
    fi
fi

# =====================================================
#  10. Copy Network Configuration from Live ISO to New System
# =====================================================

echo -e "\n\e[1;33m[INFO] Copying Network Configuration...\e[0m"

# Copy systemd-networkd settings from the live ISO to the new system
if [ -d /etc/systemd/network ] && [ "$(ls -A /etc/systemd/network)" ]; then
    cp -r /etc/systemd/network/* /mnt/etc/systemd/network/
else
    echo "No network configuration files found in /etc/systemd/network"
fi


# Copy NetworkManager settings from the live ISO to the new system
if [ -d /etc/NetworkManager/ ] && [ "$(ls -A /etc/NetworkManager)" ]; then
    mkdir -p /mnt/etc/NetworkManager/
    cp -r /etc/NetworkManager/* /mnt/etc/NetworkManager/
    chmod 600 /mnt/etc/NetworkManager/*
else
    echo "NetworkManager settings not found in /etc/NetworkManager"
fi

# Copy resolv.conf to retain DNS settings (Use systemd-resolved instead)
if [ -e /etc/resolv.conf ]; then
    ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
else
    echo "resolv.conf not found in /etc"
fi

# Copy iwd Wi-Fi configuration if available
if [ -d /var/lib/iwd ] && [ "$(ls -A /var/lib/iwd)" ]; then
    mkdir -p /mnt/var/lib/iwd
    cp -r /var/lib/iwd/* /mnt/var/lib/iwd/
else
    echo "iwd Wi-Fi configuration not found in /var/lib/iwd"
fi

# Enable both NetworkManager and systemd-networkd
if [ -d /mnt/etc/NetworkManager ]; then
    systemctl enable NetworkManager
    systemctl enable systemd-networkd
    systemctl enable systemd-resolved
else
    echo "NetworkManager settings not found in /mnt/etc/NetworkManager, skipping enablement"
fi


# If systemd-networkd is used, ensure that systemd-resolved is also enabled for DNS
if [ -d /mnt/etc/systemd/network ]; then
    systemctl enable systemd-networkd
    systemctl enable systemd-resolved
    systemctl enable NetworkManager
else
    echo "systemd-networkd configuration not found in /mnt/etc/systemd/network, skipping enablement"
fi

# Enable iwd if necessary
if [ -d /mnt/var/lib/iwd ]; then
    systemctl enable iwd
else
    echo "iwd configuration not found in /mnt/var/lib/iwd, skipping enablement"
fi


echo -e "\e[1;32m[INFO] Network configuration copied and enabled successfully.\e[0m"


# =====================================================
# 11. Install GRUB Boot Loader
# =====================================================
echo -e "\n\e[1;33m[ GRUB Boot Loader Installation ]\e[0m"
while true; do
    read -p "Do you want to install GRUB for UEFI or BIOS? (Enter 'UEFI' or 'BIOS'): " boot_mode
    if [[ "$boot_mode" == "UEFI" || "$boot_mode" == "BIOS" ]]; then
        break
    else
        echo -e "\e[1;31mInvalid option. Please enter 'UEFI' or 'BIOS'.\e[0m"
    fi
done

if [ "$boot_mode" == "UEFI" ]; then
    if grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck; then
        echo -e "\e[1;32mGRUB has been installed successfully.\e[0m"
    else
        echo -e "\e[1;31mGRUB installation failed. Please check the error messages.\e[0m"
        exit 1
    fi
elif [ "$boot_mode" == "BIOS" ]; then
    while true; do
        read -p "Enter the target disk (e.g., /dev/sda): " target_disk
        if [[ -e "$target_disk" ]]; then
            break
        else
            echo -e "\e[1;31mInvalid disk. Please enter a valid target disk.\e[0m"
        fi
    done
    if grub-install --target=i386-pc "$target_disk"; then
        echo -e "\e[1;32mGRUB has been installed successfully.\e[0m"
    else
        echo -e "\e[1;31mGRUB installation failed. Please check the error messages.\e[0m"
        exit 1
    fi
fi

# =====================================================
# 12. Configure GRUB
# =====================================================
grub-mkconfig -o /boot/grub/grub.cfg

echo ""
# Clean up the installation script
if [ $? -eq 0 ]; then
    rm -- "$0"
    echo -e "\e[1;32mScript removed successfully.\e[0m"
else
    echo -e "\e[1;31mThere was an error; script was not removed.\e[0m"
fi

# Exit chroot to return to ArchMavi.sh
exit

