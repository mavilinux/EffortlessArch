#!/bin/bash
# =====================================================
#  Arch Linux Installation Script
#  Version: v1.3.0
# -----------------------------------------------------
#  Author: Muawia Rehman (Mavi)
#  License: GPL v3.0
# =====================================================

# =====================================================
#  1. Check Network Interface & Internet Connection
# =====================================================

echo -e "\e[1;34m[INFO]\e[0m Available network interfaces:"
ip link show | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2}'

echo -e "\n\e[1;34m[INFO]\e[0m Detecting active network interface..."
active_interface=$(ip route | grep default | awk '{print $5}')
echo -e "Active network interface: \e[1;32m$active_interface\e[0m"

echo -e "\n\e[1;34m[INFO]\e[0m Testing internet connection..."
ping -c 5 archlinux.org

# =====================================================
#  2. Set Time & Keyboard Layout
# =====================================================

echo -e "\n\e[1;34m[INFO]\e[0m Syncing system clock..."
timedatectl set-ntp true
echo "System clock synchronized."

echo -e "\n\e[1;34m[INFO]\e[0m Available keyboard layouts"
echo "(press 'q' to exit the list view)"
read -p "Press Enter to continue..."
localectl list-keymaps | less

echo -e "\n\e[1;34m[INFO]\e[0m Enter your preferred keyboard layout (default: 'us')"
read -p "Keyboard Layout: " kb_layout
kb_layout=${kb_layout:-us}

echo -e "Setting keyboard layout to \e[1;32m$kb_layout\e[0m..."
localectl set-keymap "$kb_layout"
echo -e "Keyboard layout set to \e[1;32m$kb_layout\e[0m."
echo "Forwarding to the next step..."

# Installing necessary packages silently
echo -e "\n\e[1;34m[INFO]\e[0m Installing essential packages..."
echo "installing fakeroot, pacman-contrib and updating reflector..."
pacman -S --noconfirm --needed fakeroot pacman-contrib reflector

# =====================================================
#  3. Disk Partitioning
# =====================================================

# Function to display available disks
display_disks() {
    echo -e "\n\e[1;34m[INFO]\e[0m Available disks:"
    lsblk
}

# Function to partition the disk
partition_disk() {
    # Prompt for disk
    read -p "Enter the disk to partition (e.g., /dev/sda, /dev/nvme0n1, /dev/mmcblk0): " disk

    # Verify if the disk exists
    if [ ! -b "$disk" ]; then
        echo -e "\e[1;31m[ERROR]\e[0m Invalid disk specified."
        exit 1
    fi

    # Determine partition suffix
    if [[ "$disk" =~ ^/dev/(nvme|mmcblk) ]]; then
        part_suffix="p"
    else
        part_suffix=""
    fi

    # Confirm disk wipe
    echo -e "\n\e[1;31m[WARNING]\e[0m This script will erase all data on $disk."
    read -p "Do you want to wipe all existing partitions on $disk? (y/n): " wipe_choice
    if [[ "$wipe_choice" == "y" ]]; then
        echo -e "\n\e[1;34m[INFO]\e[0m Wiping all existing partitions..."
        wipefs -a "$disk"
        partprobe "$disk"
    fi

    # Select partitioning scheme
    echo -e "\n\e[1;34m[INFO]\e[0m Select partitioning scheme:"
    echo "1) UEFI with GPT"
    echo "2) BIOS with MBR"
    read -p "Enter choice [1 or 2]: " choice

    if [[ "$choice" -eq 1 ]]; then
        # UEFI with GPT
        read -p "Enter size for EFI partition (e.g., 1G): " efi_size
        read -p "Enter size for SWAP partition (e.g., 8G): " swap_size

        echo -e "\n\e[1;34m[INFO]\e[0m Creating GPT partitions using fdisk..."
        (
            echo g          # Create a new GPT partition table
            echo n          # New partition (EFI)
            echo 1          # Partition number
            echo 2048       # First sector (1MiB alignment)
            echo "+$efi_size"  # Last sector
            echo t          # Change partition type
            echo 1          # EFI System partition (FAT32)

            echo n          # New partition (SWAP)
            echo 2          # Partition number
            echo            # First sector (default)
            echo "+$swap_size" # Last sector
            echo t          # Change partition type
            echo 2          # Select partition 2
            echo 19         # Linux swap

            echo n          # New partition (ROOT)
            echo 3          # Partition number
            echo            # First sector (default)
            echo            # Last sector (default: remaining space)
            echo t          # Change partition type
            echo 3          # Select partition 3
            echo 20         # Linux root filesystem

            echo w          # Write changes
        ) | fdisk "$disk"

        # Formatting partitions
        mkfs.fat -F32 "${disk}${part_suffix}1"
        mkswap "${disk}${part_suffix}2"
        swapon "${disk}${part_suffix}2"

        # Select filesystem for root partition
        echo -e "\n\e[1;34m[INFO]\e[0m Select filesystem for root partition:"
        echo "1) ext4"
        echo "2) btrfs"
        read -p "Enter choice [1 or 2]: " fs_choice

        if [[ "$fs_choice" -eq 1 ]]; then
            mkfs.ext4 "${disk}${part_suffix}3"
        elif [[ "$fs_choice" -eq 2 ]]; then
            mkfs.btrfs "${disk}${part_suffix}3"
        else
            echo -e "\e[1;31m[ERROR]\e[0m Invalid choice."
            exit 1
        fi

        # Mounting partitions
        mount "${disk}${part_suffix}3" /mnt
        mkdir -p /mnt/boot/efi
        mount "${disk}${part_suffix}1" /mnt/boot/efi

        echo -e "\e[1;32m[SUCCESS]\e[0m UEFI partitions created and mounted."

    elif [[ "$choice" -eq 2 ]]; then
        # BIOS with MBR
        read -p "Enter size for SWAP partition (e.g., 8G): " swap_size

        echo -e "\n\e[1;34m[INFO]\e[0m Creating MBR partitions using fdisk..."
        (
            echo o          # Create a new MBR partition table

            echo n          # New partition (SWAP)
            echo p          # Primary partition
            echo 1          # Partition number
            echo            # First sector (default)
            echo "+$swap_size" # Last sector
            echo t          # Change partition type
            echo 82         # Linux swap

            echo n          # New partition (ROOT)
            echo p          # Primary partition
            echo 2          # Partition number
            echo            # First sector (default)
            echo            # Last sector (default: remaining space)
            echo t          # Change partition type
            echo 2          # Select partition 2
            echo 83         # Linux root filesystem

            echo w          # Write changes
        ) | fdisk "$disk"

        # Formatting partitions
        mkswap "${disk}${part_suffix}1"
        swapon "${disk}${part_suffix}1"

        # Select filesystem for root partition
        echo -e "\n\e[1;34m[INFO]\e[0m Select filesystem for root partition:"
        echo "1) ext4"
        echo "2) btrfs"
        read -p "Enter choice [1 or 2]: " fs_choice

        if [[ "$fs_choice" -eq 1 ]]; then
            mkfs.ext4 "${disk}${part_suffix}2"
        elif [[ "$fs_choice" -eq 2 ]]; then
            mkfs.btrfs "${disk}${part_suffix}2"
        else
            echo -e "\e[1;31m[ERROR]\e[0m Invalid choice."
            exit 1
        fi

        # Mounting partitions
        mount "${disk}${part_suffix}2" /mnt

        echo -e "\e[1;32m[SUCCESS]\e[0m BIOS partitions created and mounted."

    else
        echo -e "\e[1;31m[ERROR]\e[0m Invalid choice."
        exit 1
    fi

    # Final check
    echo -e "\n\e[1;34m[INFO]\e[0m Verifying disk partitions..."
    lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINTS
    echo -e "\n\e[1;32m[SUCCESS]\e[0m Partitioning completed."
}

# Run the script
display_disks
partition_disk

# =====================================================
#  4. Configure Mirror List
# =====================================================

echo -e "\n\e[1;34m[INFO]\e[0m Configuring mirror list..."
reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist --verbose 2>&1 | grep -v "failed\|download\|timeout"

echo -e "\nDo you want to edit the mirrorlist? (y/n): "
read edit_choice
if [ "$edit_choice" == "y" ]; then
    nano /etc/pacman.d/mirrorlist
fi
echo "Mirror list configured."

# =====================================================
#  5. Install Arch Linux Base System
# =====================================================

echo -e "\n\e[1;34m[INFO]\e[0m Select the kernel to install:"
echo "1) linux"
echo "2) linux-hardened"
echo "3) linux-lts"
echo "4) linux-zen"
read -p "Enter choice [1-4]: " kernel_choice

case $kernel_choice in
    1) kernel="linux" ;;
    2) kernel="linux-hardened" ;;
    3) kernel="linux-lts" ;;
    4) kernel="linux-zen" ;;
    *) echo "Invalid choice, defaulting to linux."; kernel="linux" ;;
esac

pacstrap /mnt base $kernel linux-firmware sudo nano grub

genfstab -U /mnt >> /mnt/etc/fstab

# =====================================================
#  6. Entering Arch-Chroot
# =====================================================
cp post-install.sh /mnt/root/

arch-chroot /mnt /bin/bash /root/post-install.sh
umount -R /mnt
clear
echo -e "\e[1;32mInstallation complete. Type 'reboot' to restart.\e[0m"
exit
