#!/bin/bash
# Proxmox GPU passthrough helper script
# Copyright (C) 2022 Igor Sadza (igor@sadza.dev)
# Permission to copy and modify is granted under the foo license
# Last revised 01/03/2022

# DESC: Check if cpu supports virtualization and IOMMU/VT-D
# ARGS: None 
# OUTS: None
function cpu_virt_vtd_check() {

	# Virtualization
	if [[ "$(grep -E 'vmx|svm' /proc/cpuinfo 2>/dev/null)" == ""  ]]; then
	    echo " -> Virtualization is not enabled in the BIOS/UEFI"
	    echo " -> Please enable virtualization and run this script again!"
	    exit 1; 
	else
	    echo " -> Virtualization is enabled in the BIOS/UEFI."
	fi
	
	# IOMMU/VT-D
	if compgen -G "/sys/kernel/iommu_groups/*/devices/*" > /dev/null; then
	    echo " -> AMD's IOMMU / Intel's VT-D is enabled in the BIOS/UEFI."
	else
	    echo " -> AMD's IOMMU / Intel's VT-D is not enabled in the BIOS/UEFI"
	    echo " -> Please enable IOMMU/VT-D settings and run this script again!"
	    exit 1; 
	fi
}
# DESC: Add all vga devices to vfio config file.
# ARGS: None 
# OUTS: None
function gpu_to_vfio() {
     # Create vfio or append to vfio
     # ---
     var=$(cat /etc/modprobe.d/vfio.conf 2> /dev/null );
     if [[ "$var" == "" ]]; then
          echo "options vfio-pci ids= disable_vga=1" > /etc/modprobe.d/vfio.conf
     else
          var=$(cat /etc/modprobe.d/vfio.conf | grep -e vfio-pci -e disable_vga 2> /dev/null );
          if [[ "$var" == "" ]]; then
               echo "options vfio-pci ids= disable_vga=1" >> /etc/modprobe.d/vfio.conf
          fi
     fi

     # Find all gpu id
     # ---
     array_gpu_id_iommu=( "$(lspci | grep VGA | sed 's/ V.*//g')"); # | sed 's/[.].*//g')" );
     array_gpu_id_vendor=();
     for i in ${array_gpu_id_iommu[@]}; do
          array_gpu_id_vendor+=("$(lspci -n -s $i | sed 's/.*[0-9a-z][0-9a-z][0-9a-z][0-9a-z]: //g' | sed s'/ (.*//g'; )");
     done

     # Delete duplicates
     # ---
     len=${#array_gpu_id_vendor[@]};
     for ((i=0;i<len;i++)); do
          for ((j=i+1;j<len;j++)); do
               if [[ "${array_gpu_id_vendor[$i]}" == "${array_gpu_id_vendor[$j]}" ]]; then
                    unset 'array_gpu_id_vendor[$i]';	
               fi
          done
     done

     tmp_array=()
     for value in "${array_gpu_id_vendor[@]}"
     do
         tmp_array+=($value)
     done
     array_gpu_id_vendor=("${tmp_array[@]}")
     unset tmp_array

     # Append ids to vfio conf file
     # ---
     for i in ${array_gpu_id_vendor[@]}; do
          var=$(cat /etc/modprobe.d/vfio.conf | grep "$i" );
          if [[ "$var" == "" ]]; then
          	sed -i 's/=/&'$i',/1' /etc/modprobe.d/vfio.conf
		echo " -> Device added to vfio!  - " $i;
	  else
		echo " -> Device arleady added to vfio!  - " $i;
          fi
     done

     update-initramfs -u > /dev/null 2>&1 

     # Delete last comma in disable_vga line
     # ---
     line_number=$(cat /etc/modprobe.d/vfio.conf | grep -in vga | sed 's/:.*//g');
     len=${#array_gpu_id_vendor[@]};
     sed -i $line_number's/,//'$len'' /etc/modprobe.d/vfio.conf
} 

# DESC: Enable IOMMU. 
# ARGS: None 
# OUTS: None
function enable_iommu() { 
     #check processor vendor (AuthenticAMD / GenuineIntel)
     #---
     cpuid_vendor=$(lscpu | grep "Vendor ID" | sed 's/.*:.*[^A-Za-z]//g');
     if [[ "$cpuid_vendor" != *"AMD"* ]] && [[ "$cpuid_vendor" != *"Intel"* ]]; then
	  echo " -> Unsuported CPU! - " $cpuid_vendor
          exit 1 
     fi

     #check which bootloader is used
     #---
     path_cmdline="/etc/kernel/cmdline";
     path_grub="/etc/default/grub";

     array_settings_cmdline=( "amd_iommu=on", 
                              "intel_iommu=on" );

     exists_cmdline=$( cat $path_cmdline 2>/dev/null );

     if [[ "$exists_cmdline" == "" ]]; then
	  if [[ "$(cat $path_grub | grep "amd_iommu" 2>/dev/null)" == "" ]]; then
               if [[ "$cpuid_vendor" == *"AMD"* ]]; then
                    sed -i 's/="quiet/& amd_iommu/' $path_grub 
                    echo " -> GRUB - AMD IOMMU enabled!";
               else
                    sed -i 's/="quiet/& intel_iommu/' $path_grub 
                    echo " -> GRUB - INTEL IOMMU enabled!";
               fi
          else
               echo " -> IOMMU arleady enabled!";
	  fi
     else
	  if [[ "$(cat $path_cmdline | grep "amd_iommu" 2>/dev/null)" == "" ]]; then
               if [[ "$cpuid_vendor" == *"AMD"* ]]; then
                    sed -i '$s/$/ amd_iommu/' $path_cmdline 
                    echo " -> SYSTEMD - AMD IOMMU enabled!";
               else
                    sed -i '$s/$/ intel_iommu/' $path_cmdline 
                    echo " -> SYSTEMD - INTEL IOMMU enabled!";
               fi
          else
               echo " -> IOMMU arleady enabled!";
	  fi
     fi
} 

# DESC: Enable iommu interrupts 
# ARGS: None 
# OUTS: None
function enable_iommu_interrupt() {
     settings_iommu="options vfio_iommu_type1 allow_unsafe_interrupts=1"
     path_iommu="/etc/modprobe.d/iommu_unsafe_interrupts.conf"

     var=$(cat $path_iommu 2> /dev/null );
     if [[ "$var" == "" ]]; then
          echo $settings_iommu > $path_iommu 
	  echo " -> IOMMU interrupts enabled!"	
     else
          var=$(cat $path_iommu | grep "allow_unsafe_interrupts" 2>/dev/null );
          if [[ "$var" == "" ]]; then
               echo $settings_iommu >> $path_iommu
	       echo " -> IOMMU interrupts enabled!"	
          else
	       echo " -> IOMMU interrupts arleady enabled!"	
          fi
     fi

     settings_kvm="options kvm ignore_msrs=1 report_ignored_msrs=0"
     path_kvm="/etc/modprobe.d/kvm.conf"

     var=$(cat $path_kvm 2> /dev/null );
     if [[ "$var" == "" ]]; then
          echo $settings_kvm > $path_kvm 
	  echo " -> KVM ignoring unknow MSR's enabled!"	
     else
          var=$(cat $path_kvm | grep -e "ignore_msrs=1" -e "report_ignored_msrs=0" 2>/dev/null );
          if [[ "$var" == "" ]]; then
               echo $settings_kvm >> $path_kvm 
	       echo " -> KVM ignoring unknow MSR's enabled!"	
          else 
	       echo " -> KVM ignoring unknow MSR's arleady enabled!"	
          fi
     fi
}

# DESC: Blacklist drivers.
# ARGS: None 
# OUTS: None
function blacklist_drivers() {

    array_drivers=( "radeon"
                    "nouveau"
                    "nvidia" );

    path_blacklist_conf="/etc/modprobe.d/blacklist.conf"

    for i in ${array_drivers[@]}; do
	if [[ "$( cat $path_blacklist_conf 2>/dev/null | grep $i 2>/dev/null)" == "" ]]; then
	     echo "blacklist" $i >> $path_blacklist_conf
	     echo " -> Driver blacklisted!" - $i;
	else
	     echo " -> Driver arleady blacklisted!" - $i;
        fi
    done
}

# DESC: Download VGA bios from https://www.techpowerup.com/
# ARGS: None 
# OUTS: None
function download_vgabios() {
     raw_devices_data=$(lspci -vnn | grep -e VGA -A 1 | sed 's/.*\([0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z]:[0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z]\).*/\1/; s/--/-/g; s/\n\n/\n/g' | sed -z 's/\n/,/g; s/:/-/g; s/,/-/g; s/---/,/g' | rev | sed 's/-//1' | rev);

     raw_devices_names=$(lspci -vnn | grep -e VGA -A 0 | sed 's/.*]: //; s/\([[][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z]:[0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z]\).*//; s/.*\[//g; s/]//g' | rev | sed 's/ //' | rev | sed -z 's/ /_/g; s/\(.*\)/\L\1/; s/\n//g; s/--/,/g');

     array_devices_ids=();
     readarray -td, array_devices_ids <<<"$raw_devices_data"; declare -p array_devices_ids >/dev/null;
     for ((i=0;i<${#array_devices_ids[@]};i++)); do 
           for ((j=i+1;j<${#array_devices_ids[@]};j++)); do
                if [[ "${array_devices_ids[$i]}" == "${array_devices_ids[$j]}" ]]; then
                     unset 'array_devices_ids[$i]';
                fi
           done
     done

     tmp_array=()
     for value in "${array_devices_ids[@]}"
     do
         tmp_array+=($value)
     done
     array_devices_ids=("${tmp_array[@]}")
     unset tmp_array

     array_devices_names=();
     readarray -td, array_devices_names <<<"$raw_devices_names"; declare -p array_devices_names >/dev/null;
     for ((i=0;i<${#array_devices_names[@]};i++)); do 
           for ((j=i+1;j<${#array_devices_names[@]};j++)); do
                if [[ "${array_devices_names[$i]}" == "${array_devices_names[$j]}" ]]; then
                     unset 'array_devices_names[$i]';
                fi
           done
     done

     tmp_array=()
     for value in "${array_devices_names[@]}"; do
         tmp_array+=($value)
     done
     array_devices_names=("${tmp_array[@]}")
     unset tmp_array

     for ((i=0;i<${#array_devices_ids[@]};i++)); do
          sleep 2
          url_techpowerup="https://www.techpowerup.com/vgabios/?architecture=Uploads&manufacturer=&model=&interface=&memType=&memSize=&did=${array_devices_ids[$i]}&since="
          var=$(curl -X GET $url_techpowerup 2>/dev/null | grep ".rom\">Download" | head -1 | sed 's/[>].*$//g' | sed 's/.*[=]//g' | sed 's/\//https:\/\/www.techpowerup.com\//1' | sed 's/"//g');
          if [[ "$var" == "" ]]; then
               echo " -> Unsuported VGA device! - " ${array_devices_names[$i]}; 
          else
               if [[ "$(ls /usr/share/kvm | grep ${array_devices_names[$i]}.rom 2>/dev/null; )" == "" ]]; then
                    wget $var -O /usr/share/kvm/${array_devices_names[$i]}.rom 2>/dev/null;
                    echo " -> VGA driver succesfuly downloaded! - " ${array_devices_names[$i]};
               else
                    echo " -> VGA driver arleady downloaded! - " ${array_devices_names[$i]};
               fi
          fi;
     done 
}

# DESC: Download lastes virtio drivers and place it directly into local proxmox storage
# ARGS: None 
# OUTS: None
function download_virtio() {
    path_drivers="/var/lib/vz/template/iso"
    exist_virtio=$();
    if [[ "$(ls $path_drivers | grep virtio 2>/dev/null)" == "" ]]; then
         wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso -O $path_drivers/drivers_win_virtio.iso 2>/dev/null
         echo " -> VIRTIO drivers succesfuly downloaded! - " $(ls $path_drivers | grep virtio);
    else
         echo " -> VIRTIO drivers arleady downloaded! - " $(ls $path_drivers | grep virtio);
    fi;
}

# DESC: Main control flow
# ARGS: None 
# OUTS: None
function main() { 
    echo -e "\nPROXMOX GPU PASSTHROUGH HELPER SCIPT\n"
    
    cpu_virt_vtd_check 
    enable_iommu
    enable_iommu_interrupt
    gpu_to_vfio
    blacklist_drivers
    download_vgabios
    download_virtio

    echo -e "\nREBOOT NOW\n"
}

main
