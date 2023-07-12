#!/bin/bash
###################################################################################################
##
## check if wdckit connected 
##
###################################################################################################
function If_wdckit_Exist {
#FILE="/home/qa/Desktop/wdckit-2.2.0.0-x86_64-tar-gz-Linux-x86-64/wdckit-2.2.0.0-x86_64/wdckit"
#FILE="/home/qa/Desktop/wdckit-2.13.0.0-x86_64/wdckit"
FILE="$path_wdckit"

flag=0
if [ -f "$FILE" ]; then
    echo "$FILE -> Wdckit File Exists."
    flag=1
else 
    echo "$FILE -> Wdckit File Does Not Exist."
    flag=0
fi
}



###################################################################################################
##
## identify device and print to file 
##
###################################################################################################
function identify {
sudo nvme id-ctrl /dev/nvme0n1 > idntfy.txt
if [ $? -ne 0 ]
then
    echo "Error - identify command fail"
fi

device_fw=$(grep -w "fr" idntfy.txt | awk '{print $3}')
device_sn=$(grep -w "sn" idntfy.txt | awk '{print $3}')
device_mn=$(grep -w "mn" idntfy.txt | awk '{print $3}')
#echo "##################################################"
#echo $device_fw
#echo "##################################################"             
}



###################################################################################################
##
## check Devices connected 
##
###################################################################################################
function checkDevice {
echo "checking if device connected...."
sudo nvme list > device.txt
#Search any line that contains the word in filename on Linux:   grep 'word' filename
numOfDevices_full_line=$(grep  "/dev/" device.txt)
numOfDevices=$(grep  "/dev/" device.txt | wc -l)
devicePath=$(grep  "/dev/" device.txt | awk '{print $1}')
chrDevicePath=$(grep  "/dev/" device.txt | awk '{print $1}'| rev | cut -c 3- |rev)
if [ "$numOfDevices" -lt 1 ]
then
	echo "ERROR - no devices is connected : $numOfDevices"
	finishTest
fi

echo "Device is connected"
}



function finishTest {
rm -rf device.txt
exit 
}


###################################################################################################
##
## chanege bot folder names inside the versions 
##
###################################################################################################
function bot_versions {

##Performance_Version
if [[ $Vulcan_Version = "Performance_Version" ]]
then
  bot_version="vulcan_perf_BOT/"
  echo "########################################################"
  echo "### bot ver : " $bot_version
  echo "########################################################"
##SED_Performance_Version  
elif [[ $Vulcan_Version = "SED_Performance_Version" ]]
then
  bot_version="vulcan_sed_perf_BOT/"
  echo "########################################################"
  echo "### bot ver : " $bot_version
  echo "########################################################"
##Debug_Version  
elif [[ $Vulcan_Version = "Debug_Version" ]]
then
  bot_version= "vulcan_BOT/"
  echo "########################################################"
  echo "### bot ver : " $bot_version
  echo "########################################################"
##SED_Debug_Version  
elif [[ $Vulcan_Version = "SED_Debug_Version" ]]
then
  bot_version="vulcan_sed_BOT/"
  echo "########################################################"
  echo "### bot ver : " $bot_version
  echo "########################################################"
##Performance_Version_Pre_RDT
elif [[ $Vulcan_Version = "Performance_Version_Pre_RDT" ]]
then
  bot_version="vulcan_perf_pre_rdt_BOT/"
  echo "########################################################"
  echo "### bot ver : " $bot_version
  echo "########################################################"
##SED_Performance_Version_Pre_RDT  
elif [[ $Vulcan_Version = "SED_Performance_Version_Pre_RDT" ]]
then
  bot_version="vulcan_sed_perf_pre_rdt_BOT/"
  echo "########################################################"
  echo "### bot ver : " $bot_version
  echo "########################################################"
else
  echo $Vulcan_Version : "ERROR."
fi
}



###################################################################################################
##
## check versions from SED -> NON SED  / NON SED -> SED 
##
###################################################################################################
function bot_versions2_sed_nonsed {
#Performance_Version
#Performance_Version_Pre_RDT
if [[ $Vulcan_Version = "Performance_Version_Pre_RDT" ]]
then
  new_Vulcan_Version="SED_Performance_Version_Pre_RDT"
  new_bot_version="vulcan_sed_perf_pre_rdt_BOT"
  echo "##########################################################################"
  echo "### Before  : current vulcan version -> " $Vulcan_Version
  echo "### After   : SED version     -> " $new_Vulcan_Version
  echo "### bot ver : " $new_bot_version
  echo "##########################################################################"
  ##cut vcp to vco ->>>>>>NON sed VCP -> SED VCO
  sed_nonsed="O"
  sub=$(echo $fw1| cut -c1-7)
  sed_new=$sub$sed_nonsed

elif [[ $Vulcan_Version = "SED_Performance_Version_Pre_RDT" ]]
then  
  new_Vulcan_Version="Performance_Version_Pre_RDT"
  new_bot_version="vulcan_perf_pre_rdt_BOT"
  echo "##########################################################################"
  echo "### Before   : current vulcan version     -> " $new_Vulcan_Version
  echo "### After  : Non-SED version -> " $Vulcan_Version
  echo "### bot ver : " $new_bot_version
  echo "##########################################################################"
  ##cut vcp to vco ->>>>>>NON sed VCP -> SED VCO
  sed_nonsed="P"
  sub=$(echo $fw1| cut -c1-7)
  sed_new=$sub$sed_nonsed

elif [[ $Vulcan_Version = "Performance_Version" ]]
then    
  new_Vulcan_Version="SED_Performance_Version"
  new_bot_version="vulcan_sed_perf_BOT"
  echo "##########################################################################"
  echo "### Before  : current vulcan version -> " $Vulcan_Version
  echo "### After   : SED version     -> " $new_Vulcan_Version
  echo "### bot ver : " $new_bot_version
  echo "##########################################################################"
  ##cut vcp to vco ->>>>>>NON sed VCP -> SED VCO
  sed_nonsed="O"
  sub=$(echo $fw1| cut -c1-7)
  sed_new=$sub$sed_nonsed
  
elif [[ $Vulcan_Version = "SED_Performance_Version" ]]
then  
  new_Vulcan_Version="Performance_Version"
  new_bot_version="vulcan_perf_BOT"
  echo "##########################################################################"
  echo "### Before   : current vulcan version     -> " $new_Vulcan_Version
  echo "### After  : Non-SED version -> " $Vulcan_Version
  echo "### bot ver : " $new_bot_version
  echo "##########################################################################"
  ##cut vcp to vco ->>>>>>NON sed VCP -> SED VCO
  sed_nonsed="P"
  sub=$(echo $fw1| cut -c1-7)
  sed_new=$sub$sed_nonsed
  
else
  echo $new_Vulcan_Version : "ERROR."
fi

}



###################################################################################################
##
## check if folder found for mount - if not create one
##
###################################################################################################
function mount_folder_check {
##check if folder found for mount - if not create one 
echo -e "\n"
echo "#Mount Information: "
file1=/home/qa/Desktop/mnt
if [ ! -d $file1 ]; then
    echo "/home/qa/Desktop/mnt -> not found!"
    sudo mkdir /home/qa/Desktop/mnt
else
	echo "/home/qa/Desktop/mnt -> found!"
	#unmount_folder >> $logfile
fi

#################################
#sleep 1
#file2=/mnt/share/versions/
#if [ ! -d $file2 ]; then
#    echo " /mnt/share/versions -> not found!"
#    sudo mkdir /mnt/share/versions/
#else
#	echo "/mnt/share/versions/ ->  found!"
#	unmount_folder >> $logfile
#fi

echo "End Mount Information "

}



###################################################################################################
##
## unmount files if exist in /mnt/share
## if files exist before ,mount will return error ..
##
###################################################################################################
function unmount_folder {
mount_point=/home/qa/Desktop/mnt
#sudo su
#chmod ugo+rwx /mnt/share
sudo umount -l $mount_point
echo "unmount $mount_point" >> $logfile
sleep 3
}


###################################################################################################
##
## MOUNT fluf files not vendors(CFGenc.fluf) from network - put in (/mnt/share/versions) 
##
###################################################################################################
function mount() {
#sudo apt install cifs-utils (just for first run)
##mount fw path
#sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/Vulcan/Firmware/Releases/Official_Builds/Performance_Version/AO062VCP/vulcan_perf_BOT/LE /mnt/share/versions -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 
sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$Vulcan_Version/$fw1/$bot_version/ /home/qa/Desktop/mnt -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 
#sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$Vulcan_Version/$fw1/$bot_version /home/qa/Desktop/mount/ -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 
}


###################################################################################################
##
## MOUNT fluf files not vendors(CFGenc.fluf) from network - put in (/mnt/share/versions)  direct
##
###################################################################################################
function mount_direct() {
#sudo apt install cifs-utils (just for first run)
##mount fw path
#sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/Vulcan/Firmware/Releases/Official_Builds/Performance_Version/AO062VCP/vulcan_perf_BOT/LE /mnt/share/versions -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 
sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$Vulcan_Version/$1/$bot_version$vendor /home/qa/Desktop/mnt -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 
#sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$Vulcan_Version/$fw1/$bot_version /home/qa/Desktop/mount/ -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 
echo -e "\n"
echo "Mount From: "
echo "//10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$Vulcan_Version/$1/$bot_version$vendor" >> $logfile
echo -e "\n"
}


###################################################################################################
##
## MOUNT Vendor(GO,DE,LE,HP) fluf files Inside this folders from network - put in (/mnt/share/versions)
## this function get 1 parameter ($vendor)  
##
###################################################################################################
###parameters to a Bash function
#function_name () {
#   command...
#} 
#call the function:from run2.sh file
#function_name "$arg1" "$arg2"
function mount_versions_base() { 
unmount_folder >> $logfile
sleep 4
#sudo apt install cifs-utils (just for first run)
##mount fw path
#sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/Vulcan/Firmware/Releases/Official_Builds/Performance_Version/AO040VCP/vulcan_perf_BOT/ /mnt/share -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 
sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$Vulcan_Version/$1/$bot_version /home/qa/Desktop/mnt -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 
echo -e "\n"
echo "Mount From: "
echo "//10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$Vulcan_Version/$1/$bot_version" >> $logfile
echo -e "\n"
}


###################################################################################################
##
## check if mount directory not empty 
##
###################################################################################################
function if_empty() { 
##-A, --almost-all
##do not list implied . and ..
is_exist="before"
echo $is_exist
echo "#############################"
echo "Check if FW Exist :"
if [ -z "$(ls -a /home/qa/Desktop/mnt)" ]; then
   #echo "/mnt/share/  ->  Empty"
   ##FW Not Exist
   is_exist="0"
   echo "Not Exist -> is_exist= $is_exist"
   
else
   #echo "/home/qa/Desktop/mnt  -> Files Exist"
   ##FW Exist
   is_exist="1"
   echo "Exist -> is_exist= $is_exist"
fi
echo "#############################"
echo $is_exist


#////
DIR="/home/qa/Desktop/mnt"
if [ -d "$DIR" ]
then
	if [ "$(ls -A $DIR)" ]; then
	ls -a $DIR >>logfile
    echo "Take action $DIR is not Empty"
	else
    echo "$DIR is Empty"
	fi
else
	echo "Directory $DIR not found."
fi
}

###################################################################################################
##
## MOUNT Vendor(GO,DE,LE,HP) fluf files Inside this folders from network - put in (/mnt/share/versions)
## this function get 1 parameter ($vendor)  
##
###################################################################################################
###parameters to a Bash function
#function_name () {
#   command...
#} 
#call the function:from run2.sh file
#function_name "$arg1" "$arg2"
function mount_versions() { 
#sudo apt install cifs-utils (just for first run)
##mount fw path
#sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/Vulcan/Firmware/Releases/Official_Builds/Performance_Version/AO040VCP/vulcan_perf_BOT/ /mnt/share/versions -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 
#sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$Vulcan_Version/$fw1/$bot_version/$vendor /mnt/share/versions -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 
## $1 value got from the function not from the user enter 
sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$Vulcan_Version/$1/$bot_version$vendor /home/qa/Desktop/mnt -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 

echo -e "\n"
echo "Mount From: "
echo "//10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$Vulcan_Version/$fw1/$bot_version$vendor" >> $logfile
echo -e "\n"
}


###################################################################################################
##
## MOUNT Vendor(GO,DE,LE,HP) fluf files Inside this folders from network - put in (/mnt/share/versions)
## this function get 1 parameter ($vendor)  
##
###################################################################################################
###parameters to a Bash function
#function_name () {
#   command...
#} 
#call the function:from run2.sh file
#function_name "$arg1" "$arg2"
function mount_versions_sed_nonsed() {
#sudo apt install cifs-utils (just for first run)
##cut vcp to vco ->>>>>>NON sed VCP -> SED VCO 
#sed="O"
#sub=$(echo $fw1| cut -c1-7)
#sed_new=$sub$sed
#echo "########################################################"
#echo "############## Vendor             : " $vendor 
#echo "########################################################"
  echo -e "\n"
  echo "########################################################"
  echo "############## Test check Version : " $sed_new
  echo "############## Vendor             : " $vendor 
  echo "########################################################"
##mount fw path
#sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/Vulcan/Firmware/Releases/Official_Builds/Performance_Version/AO040VCP/vulcan_perf_BOT/ /mnt/share/versions -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 

sudo mount.cifs //10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$new_Vulcan_Version/$sed_new/$new_bot_version/$vendor /home/qa/Desktop/mnt -o username=qa,password=12 ,dir_mode=0777,file_mode=0777,serverino,sec=ntlmssp 

echo -e "\n"
echo "Mount From: "
echo "//10.0.56.14/Images/PlatformTesting/FW_Versions/$project/Firmware/Releases/Official_Builds/$new_Vulcan_Version/$sed_new/$new_bot_version/$vendor" >> $logfile
echo -e "\n"
}



###################################################################################################
##
## find (CFGenc.fluf) into /mnt/share/versions  save to file and read it ..  
##
###################################################################################################
function find_read_fluf {
echo #--------------------------------------------
#fw_file= find /mnt/share/versions -name *.fluf > fw_file.txt
#fw_file= find /mnt/share/versions -name CFGenc.fluf > fw_file.txt
fw_file= find /home/qa/Desktop/mnt -name CFGenc.fluf > fw_file.txt

#echo $fw_file
############################################################################################################
##read text file to read file path
echo #--------------------------------------------
#input="/home/qa/Desktop/wdckit-2.2.0.0-x86_64-tar-gz-Linux-x86-64/FFU_Automation/Scripts/fw1.txt"
##read text file 
input="fw_file.txt"
while IFS= read -r line
do
  #echo "$line"
  fw_ver_read=$line
done < "$input"
############################################################################################################
}



###################################################################################################
##
## find (*.fluf) into /mnt/share/versions  save to file and read it ..  
## difference from previous func, here looking for files end with fluf , because fluf files start with numbers.
##
###################################################################################################
function find_read_fluf_vendors {
echo #--------------------------------------------
fw_file= find /home/qa/Desktop/mnt -name *.fluf > fw_file.txt
#fw_file= find /mnt/share/versions -name CFGenc.fluf > fw_file.txt

echo $fw_file
############################################################################################################
##read text file to read file path
echo #--------------------------------------------
#input="/home/qa/Desktop/wdckit-2.2.0.0-x86_64-tar-gz-Linux-x86-64/FFU_Automation/Scripts/fw1.txt"
##read text file 
input="fw_file.txt"
while IFS= read -r line
do
  #echo "$line"
  fw_ver_read=$line
done < "$input"
############################################################################################################
}



###################################################################################################
##
## run test ...  device: nvme0n1 
##
###################################################################################################
function run_test_device1 {
echo "###########################################################################"
echo  nvme0n1 : 
echo "###########################################################################"
device="nvme0n1"
##run test
echo -e "\n"
echo "#FW Download"
sudo ./wdckit update /dev/"$device" -f "$fw_ver_read"
echo "#FW Activate"
sudo ./wdckit update /dev/"$device" -s 1 -a -c 3
echo -e "\n"
#echo "##########################################################################"
}



###################################################################################################
##
## run test ...  device:  nvme1n1 
##
###################################################################################################
function run_test_device2 {
  echo "###########################################################################"
  echo  nvme1n1 : 
  echo "###########################################################################"
  device="nvme1n1"
  ##run test
  echo -e "\n"
  echo "#FW Download"
  sudo ./wdckit update /dev/"$device" -f "$fw_ver_read"
  echo "#FW Activate"
  sudo ./wdckit update /dev/"$device" -s 1 -a -c 3
  echo -e "\n"
  #echo "##########################################################################"
}



###################################################################################################
##
## run test ...  device:  nvme0n1 if 1 device connected 
##
###################################################################################################
function ffu_1 {
  #start from base and stay fw in fw1 
  ###############################################
  #BASE FW 
  ###############################################
  bot_versions  
  ###############################################
  #CUSTOMER (GO / DE / LE /HP)
  ###############################################
if [[ $ffu_full = "full" ]]
then
  #save vendor in new varibale 
  vendor_base=$vendor >> $logfile
  if [[ $new_key = "customer" ]]
  then
  echo  "KEY selected  :" $ffu_full 
  unmount_folder >> $logfile
  echo -e "\n"
  
  ##base###########################################################################################
  echo "############################################################"
  echo "#Current to Base: $fw_base  ,  Vendor : $vendor " >> $logfile
  echo "############################################################"

  if [[ $vendor = "GO" ]]
	then 
	  echo  "Vendor selected  :" $vendor 
	  echo -e "\n"
	  vendor="GO"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
	    echo "###############"
		echo "#FW $fw_base Exist"   
        echo "###############"		
		find_read_fluf_vendors
		run_test_device1
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###############"
		echo "###FW $fw_base Not Exist"
		echo "###############"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	   
	elif [[ $vendor = "DE" ]]
	then
	  echo -e "\n"
	  vendor="DE"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
	    echo "###############"
		echo "#FW $fw_base Exist"   
        echo "###############"	
		find_read_fluf_vendors
		run_test_device1
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###############"
		echo "###FW $fw_base Not Exist"
		echo "###############"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  

	elif [[ $vendor = "LE" ]]
	then  
	  echo -e "\n"
	  vendor="LE"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
	    echo "###############"
		echo "#FW $fw_base Exist"   
        echo "###############"	  
		find_read_fluf_vendors
		run_test_device1
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###############"
		echo "###FW $fw_base Not Exist"
		echo "###############"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  
	 
	elif [[ $vendor = "HP" ]]
	then
	  echo -e "\n"
	  vendor="HP"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
	    echo "###############"
		echo "#FW $fw_base Exist"   
        echo "###############"	   
		find_read_fluf_vendors
		run_test_device1
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###############"
		echo "###FW $fw_base Not Exist"
		echo "###############"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  

	elif [[ $vendor = "MSFT" ]]
	then  
	  echo -e "\n"
	  vendor="MSFT"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
	    echo "###############"
		echo "#FW $fw_base Exist"   
        echo "###############"	   
		find_read_fluf_vendors
		run_test_device1
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###############"
		echo "###FW $fw_base Not Exist"
		echo "###############"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	else
	echo -e "\n"
	echo "Vendor : $vendor Error!"
	fi 
	
	
  ##FW1############################################################################################
  echo "##########################################################################"
  echo "#FFU to FW1: $fw_base  ,  Vendor : $vendor " >> $logfile
  echo "##########################################################################"
  
  echo "##Start###################################################################"
  vendor="GO"
  echo "##########################################################################"
  echo "##### FFU - Fw1"
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"

  mount_versions "$fw1"
  
  #######################################################################################################
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then
    echo "###############"
    echo "FW $fw1 Exist"
	echo "###############"  
  	find_read_fluf_vendors
	run_test_device1
	echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi  
  if [[ $mount_status = folder_empty ]]
  then
    echo "###############"
    echo "###FW $fw1 Not Exist"
	echo "###############"
	echo -e "\n"
  fi
  sleep 4
  #######################################################################################################
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="DE"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then
    echo "###############"
    echo "FW $fw1 Exist"
	echo "###############"
  	find_read_fluf_vendors
	run_test_device1
	echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi  
  if [[ $mount_status = folder_empty ]]
  then
    echo "###############"
    echo "###FW $fw1 Not Exist"
	echo "###############"
	echo -e "\n"
  fi
  sleep 4
  #######################################################################################################
  
  #unmount_folder >> $logfile
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="LE"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then
    echo "###############"
    echo "FW $fw1 Exist"
	echo "###############"
  	find_read_fluf_vendors
	run_test_device1
	echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi  
  if [[ $mount_status = folder_empty ]]
  then
    echo "###############"
    echo "###FW $fw1 Not Exist"
	echo "###############"
	echo -e "\n"
  fi
  sleep 4
  #######################################################################################################
  
  #unmount_folder >> $logfile
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="HP"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then
    echo "###############"
    echo "FW $fw1 Exist"
	echo "###############"
  	find_read_fluf_vendors
	run_test_device1
	echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi  
  if [[ $mount_status = folder_empty ]]
  then
    echo "###############"
    echo "###FW $fw1 Not Exist"
	echo "###############"
	echo -e "\n"
  fi
  sleep 4
  #######################################################################################################
  
  #unmount_folder >> $logfile
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="MSFT"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then
    echo "###############"
    echo "FW $fw1 Exist"
	echo "###############"
  	find_read_fluf_vendors
	run_test_device1
	echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi  
  if [[ $mount_status = folder_empty ]]
  then
    echo "###############"
    echo "###FW $fw1 Not Exist"
	echo "###############"
	echo -e "\n"
  fi
  sleep 4
  fi
  
  #######################################################################################################
  #back to base
  #back the saved vendor($vendor_base) in  original variable (Vendor) 

  vendor=$vendor_base >> $logfile
  echo "############################################################"
  echo "#Back to Base: $fw_base  ,  Vendor : $vendor " >> $logfile
  echo "############################################################"

  if [[ $vendor = "GO" ]]
	then 
	  echo  "Vendor selected  :" $vendor 
	  echo -e "\n"
	  vendor="GO"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
	    echo "###############"
		echo "#FW $fw_base Exist"   
        echo "###############"		
		find_read_fluf_vendors
		run_test_device1
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###############"
		echo "###FW $fw_base Not Exist"
		echo "###############"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	   
	elif [[ $vendor = "DE" ]]
	then
	  echo -e "\n"
	  vendor="DE"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
	    echo "###############"
		echo "#FW $fw_base Exist"   
        echo "###############"	
		find_read_fluf_vendors
		run_test_device1
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###############"
		echo "###FW $fw_base Not Exist"
		echo "###############"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  

	elif [[ $vendor = "LE" ]]
	then  
	  echo -e "\n"
	  vendor="LE"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
	    echo "###############"
		echo "#FW $fw_base Exist"   
        echo "###############"	  
		find_read_fluf_vendors
		run_test_device1
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###############"
		echo "###FW $fw_base Not Exist"
		echo "###############"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  
	 
	elif [[ $vendor = "HP" ]]
	then
	  echo -e "\n"
	  vendor="HP"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
	    echo "###############"
		echo "#FW $fw_base Exist"   
        echo "###############"	   
		find_read_fluf_vendors
		run_test_device1
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###############"
		echo "###FW $fw_base Not Exist"
		echo "###############"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  

	elif [[ $vendor = "MSFT" ]]
	then  
	  echo -e "\n"
	  vendor="MSFT"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
	    echo "###############"
		echo "#FW $fw_base Exist"   
        echo "###############"	   
		find_read_fluf_vendors
		run_test_device1
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###############"
		echo "###FW $fw_base Not Exist"
		echo "###############"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	else
	echo -e "\n"
	echo "Vendor : $vendor Error!"
	fi 

  
  
  
  
#E-KEY (Ekey_GO / Ekey_HP / Ekey_MSFT /Ekey_DE /Ekey_LE)
#elif [[ $new_key = "ekey" ]]  
#then
#  echo  "KEY selected  :" $new_key 
#  echo -e "\n"
#  echo "##Start###################################################################"
#  vendor="Ekey_GO"
#  echo "##########################################################################"
#  echo "##### FFU - Base FW "
#  echo "##### Vulcan ver : " $Vulcan_Version 
#  echo "##### Vendor     : " $vendor
#  echo "##### FW check   : " $fw_base
#  echo "##########################################################################"
#  mount_versions "$fw1"
#  find_read_fluf_vendors
#  run_test_device1
#  echo "##End#####################################################################"
#  sleep 4
  
# echo -e "\n"
#  echo "##Start###################################################################"
#  vendor="Ekey_HP"
#  echo "##########################################################################"
#  echo "##### FFU - Base FW "
#  echo "##### Vulcan ver : " $Vulcan_Version 
#  echo "##### Vendor     : " $vendor
#  echo "##### FW check   : " $fw_base
#  echo "##########################################################################"
#  mount_versions "$fw1"
#  find_read_fluf_vendors
#  run_test_device1
#  echo "##End#####################################################################"
#  sleep 4
  
#  echo -e "\n"
#  echo "##Start###################################################################"
#  vendor="Ekey_MSFT"
#  echo "##########################################################################"
#  echo "##### FFU - Base FW "
#  echo "##### Vulcan ver : " $Vulcan_Version 
#  echo "##### Vendor     : " $vendor
#  echo "##### FW check   : " $fw_base
#  echo "##########################################################################"
#  mount_versions "$fw1"
#  find_read_fluf_vendors
#  run_test_device1
#  echo "##End#####################################################################"
#  sleep 4
  
#  echo -e "\n"
#  echo "##Start###################################################################"
#  vendor="Ekey_DE"
#  echo "##########################################################################"
#  echo "##### FFU - Base FW "
#  echo "##### Vulcan ver : " $Vulcan_Version 
#  echo "##### Vendor     : " $vendor
#  echo "##### FW check   : " $fw_base
#  echo "##########################################################################"
#  mount_versions "$fw1"
#  find_read_fluf_vendors
#  run_test_device1
#  echo "##End#####################################################################"
#  sleep 4
  
#  echo -e "\n"
#  echo "##Start###################################################################"
#  vendor="Ekey_LE"
#  echo "##########################################################################"
# echo "##### FFU - Base FW "
#  echo "##### Vulcan ver : " $Vulcan_Version 
#  echo "##### Vendor     : " $vendor
#  echo "##### FW check   : " $fw_base
#  echo "##########################################################################"
#mount_versions "$fw1"
# find_read_fluf_vendors
#  run_test_device1
#  echo "##End#####################################################################"
#  sleep 4
else
  echo "Error input , please Enter vendors/versions in Parmater Number 6"
fi  
  

}




###################################################################################################
##
## run test ...  device:  nvme1n1 if DEVICE 2 SELECTED 
##
###################################################################################################
function ffu_just_2 {
  #FFU Between Vendors
  ###############################################
  #BASE FW 
  ###############################################
  bot_versions  
  ###############################################
  #CUSTOMER (GO / DE / LE /HP)
  ###############################################
if [[ $ffu_full = "full" ]]
then 
  #save vendor in new varibale 
  vendor_base=$vendor >> $logfile
  if [[ $new_key = "customer" ]]
  then
  echo  "KEY selected  :" $ffu_full 
  unmount_folder >> $logfile
  echo -e "\n"
  
  ##base###########################################################################################
  echo "############################################################"
  echo "#Current to Base: $fw_base  ,  Vendor : $vendor " >> $logfile
  echo "############################################################"

  if [[ $vendor = "GO" ]]
	then 
	  echo  "Vendor selected  :" $vendor 
	  echo -e "\n"
	  vendor="GO"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
		echo "#FW $fw_base Exist"   
		find_read_fluf_vendors
		run_test_device2
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###FW $fw_base Not Exist"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	   
	elif [[ $vendor = "DE" ]]
	then
	  echo -e "\n"
	  vendor="DE"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
		echo "#FW $fw_base Exist"   
		find_read_fluf_vendors
		run_test_device2
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###FW $fw_base Not Exist"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  

	elif [[ $vendor = "LE" ]]
	then  
	  echo -e "\n"
	  vendor="LE"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then

		echo "#FW $fw_base Exist"     
		find_read_fluf_vendors
		run_test_device2
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###FW $fw_base Not Exist"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  
	 
	elif [[ $vendor = "HP" ]]
	then
	  echo -e "\n"
	  vendor="HP"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
		echo "#FW $fw_base Exist"      
		find_read_fluf_vendors
		run_test_device2
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###FW $fw_base Not Exist"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  

	elif [[ $vendor = "MSFT" ]]
	then  
	  echo -e "\n"
	  vendor="MSFT"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then
		echo "#FW $fw_base Exist"      
		find_read_fluf_vendors
		run_test_device2
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then
		echo "###FW $fw_base Not Exist"
		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	else
	echo -e "\n"
	echo "Vendor : $vendor Error!"
	fi 
	
	
  ##FW1############################################################################################
  echo "##########################################################################"
  echo "#FFU to FW1: $fw_base  ,  Vendor : $vendor " >> $logfile
  echo "##########################################################################"
  
  
  echo "##Start###################################################################"
  vendor="GO"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"

  mount_versions "$fw1"
  
  #######################################################################################################
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then

    echo "FW $fw1 Exist"  

  	find_read_fluf_vendors
	run_test_device2
	echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi  
  if [[ $mount_status = folder_empty ]]
  then

    echo "###FW $fw1 Not Exist"

	echo -e "\n"
  fi
  sleep 4
  #######################################################################################################
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="DE"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then

    echo "FW $fw1 Exist"  

  	find_read_fluf_vendors
	run_test_device2
	echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi  
  if [[ $mount_status = folder_empty ]]
  then

    echo "###FW $fw1 Not Exist"

	echo -e "\n"
  fi
  sleep 4
  #######################################################################################################
  
  #unmount_folder >> $logfile
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="LE"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then

    echo "FW $fw1 Exist"  

  	find_read_fluf_vendors
	run_test_device2
	echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi  
  if [[ $mount_status = folder_empty ]]
  then

    echo "###FW $fw1 Not Exist"

	echo -e "\n"
  fi
  sleep 4
  #######################################################################################################
  
  #unmount_folder >> $logfile
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="HP"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then

    echo "FW $fw1 Exist"  

  	find_read_fluf_vendors
	run_test_device2
	echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi  
  if [[ $mount_status = folder_empty ]]
  then

    echo "###FW $fw1 Not Exist"

	echo -e "\n"
  fi
  sleep 4
  #######################################################################################################
  
  #unmount_folder >> $logfile
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="MSFT"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then

    echo "FW $fw1 Exist"  

  	find_read_fluf_vendors
	run_test_device2
	echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi  
  if [[ $mount_status = folder_empty ]]
  then

    echo "###FW $fw1 Not Exist"

	echo -e "\n"
  fi
  sleep 4
  fi
  
  #######################################################################################################
  #######################################################################################################
  #back to base
  #back the saved vendor($vendor_base) in  original variable (Vendor) 
  vendor=$vendor_base >> $logfile
  #echo $vendor_base
  #echo $vendor 
  echo "############################################################"
  echo "#Back to Base: $fw_base  ,  Vendor : $vendor " >> $logfile
  echo "############################################################"
  if [ $vendor = "GO" ] || [ $vendor = "go" ]
	then 
	  echo  "Vendor selected  :" $vendor 
	  echo -e "\n"
	  vendor="GO"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then

		echo "#FW $fw_base Exist"
	
		find_read_fluf_vendors
		run_test_device2
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then

		echo "###FW $fw_base Not Exist"

		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	   
	#elif [[ $vendor = "DE" ]]
	elif [ $vendor = "DE" ] || [ $vendor = "de" ]
	then
	  echo -e "\n"
	  vendor="DE"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then

		echo "#FW $fw_base Exist"
 
		find_read_fluf_vendors
		run_test_device2
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then

		echo "###FW $fw_base Not Exist"

		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  

	elif [ $vendor = "LE" ] || [ $vendor = "le" ]
	then  
	  echo -e "\n"
	  vendor="LE"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then

		echo "#FW $fw_base Exist"
  
		find_read_fluf_vendors
		run_test_device2
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then

		echo "###FW $fw_base Not Exist"

		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  
	 
	elif [ $vendor = "HP" ] || [ $vendor = "hp" ]
	then
	  echo -e "\n"
	  vendor="HP"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then

		echo "#FW $fw_base Exist"
   
		find_read_fluf_vendors
		run_test_device2
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then

		echo "###FW $fw_base Not Exist"

		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	  

	elif [ $vendor = "MSFT" ] || [ $vendor = "msft" ]
	then  
	  echo -e "\n"
	  vendor="MSFT"
	  #mount_versions_base "$vendor"
	  mount_direct "$fw_base"
	  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
	  if [[ $mount_status = folder_not_empty ]]
	  then

		echo "#FW $fw_base Exist"

		find_read_fluf_vendors
		run_test_device2
		echo "##End#####################################################################"
		sleep 2
		unmount_folder >> $logfile
	  fi
	  if [[ $mount_status = folder_empty ]]
	  then

		echo "###FW $fw_base Not Exist"

		echo -e "\n"
	  fi
	  sleep 4
	  #######################################################################################################
	else
	echo -e "\n"
	echo "Vendor : $vendor Error!"
	fi 
  
#E-KEY (Ekey_GO / Ekey_HP / Ekey_MSFT /Ekey_DE /Ekey_LE)
#elif [[ $new_key = "ekey" ]]  
#then
#  echo  "KEY selected  :" $new_key 
#  echo -e "\n"
#  echo "##Start###################################################################"
#  vendor="Ekey_GO"
#  echo "##########################################################################"
#  echo "##### FFU - Base FW "
#  echo "##### Vulcan ver : " $Vulcan_Version 
#  echo "##### Vendor     : " $vendor
#  echo "##### FW check   : " $fw_base
#  echo "##########################################################################"
#  mount_versions "$fw1"
#  find_read_fluf_vendors
#  run_test_device1
#  echo "##End#####################################################################"
#  sleep 4
  
# echo -e "\n"
#  echo "##Start###################################################################"
#  vendor="Ekey_HP"
#  echo "##########################################################################"
#  echo "##### FFU - Base FW "
#  echo "##### Vulcan ver : " $Vulcan_Version 
#  echo "##### Vendor     : " $vendor
#  echo "##### FW check   : " $fw_base
#  echo "##########################################################################"
#  mount_versions "$fw1"
#  find_read_fluf_vendors
#  run_test_device1
#  echo "##End#####################################################################"
#  sleep 4
  
#  echo -e "\n"
#  echo "##Start###################################################################"
#  vendor="Ekey_MSFT"
#  echo "##########################################################################"
#  echo "##### FFU - Base FW "
#  echo "##### Vulcan ver : " $Vulcan_Version 
#  echo "##### Vendor     : " $vendor
#  echo "##### FW check   : " $fw_base
#  echo "##########################################################################"
#  mount_versions "$fw1"
#  find_read_fluf_vendors
#  run_test_device1
#  echo "##End#####################################################################"
#  sleep 4
  
#  echo -e "\n"
#  echo "##Start###################################################################"
#  vendor="Ekey_DE"
#  echo "##########################################################################"
#  echo "##### FFU - Base FW "
#  echo "##### Vulcan ver : " $Vulcan_Version 
#  echo "##### Vendor     : " $vendor
#  echo "##### FW check   : " $fw_base
#  echo "##########################################################################"
#  mount_versions "$fw1"
#  find_read_fluf_vendors
#  run_test_device1
#  echo "##End#####################################################################"
#  sleep 4
  
#  echo -e "\n"
#  echo "##Start###################################################################"
#  vendor="Ekey_LE"
#  echo "##########################################################################"
# echo "##### FFU - Base FW "
#  echo "##### Vulcan ver : " $Vulcan_Version 
#  echo "##### Vendor     : " $vendor
#  echo "##### FW check   : " $fw_base
#  echo "##########################################################################"
#mount_versions "$fw1"
# find_read_fluf_vendors
#  run_test_device1
#  echo "##End#####################################################################"
#  sleep 4
else
  echo "Error input , please Enter vendors/versions in Parmater Number 6"
fi  
  

}




###################################################################################################
##
## run test ...  device:  nvme1n1 if 1 device connected 
##
###################################################################################################
function ffu_2 {
  ffu_1 
  ffu_just_2
  
}




###################################################################################################
##
## run test ...  device:  nvme0n1 if 1 device connected - SED NON SED CHECK for FW1 
##
###################################################################################################
function ffu_3 {
  bot_versions2_sed_nonsed
  ###############################################
  #fw1
  ###############################################
  ###############################################
  #CUSTOMER (GO / DE / LE /HP)
  ###############################################
if [[ $new_key = "customer" ]]
then 
  echo  "KEY selected  :" $new_key
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="GO"
  echo "##########################################################################"
  echo "##### FFU - FW1 "
  echo "##### Vulcan ver : " $Vulcan_Version  " -> " $new_Vulcan_Version
  echo "##########################################################################"
  mount_versions_sed_nonsed "fw1"
  find_read_fluf_vendors
  run_test_device1
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="DE"
  echo "##########################################################################"
  echo "##### FFU - FW1 "
  echo "##### Vulcan ver : " $Vulcan_Version  " -> " $new_Vulcan_Version
  echo "##########################################################################"
  mount_versions_sed_nonsed "$fw1"
  find_read_fluf_vendors
  run_test_device1
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="LE"
  echo "##########################################################################"
  echo "##### FFU - FW1 "
  echo "##### Vulcan ver : " $Vulcan_Version  " -> " $new_Vulcan_Version
  echo "##########################################################################"
  mount_versions_sed_nonsed "$fw1"
  find_read_fluf_vendors
  run_test_device1
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="HP"
  echo "##########################################################################"
  echo "##### FFU - FW1 "
  echo "##### Vulcan ver : " $Vulcan_Version  " -> " $new_Vulcan_Version
  echo "##########################################################################"
  mount_versions_sed_nonsed "$fw1"
  find_read_fluf_vendors
  run_test_device1
  echo "##End#####################################################################"
  sleep 4


  #E-KEY (Ekey_GO / Ekey_HP / Ekey_MSFT /Ekey_DE /Ekey_LE)
elif [[ $new_key = "ekey" ]]  
then
  echo  "KEY selected  :" $new_key 
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="Ekey_GO"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  find_read_fluf_vendors
  run_test_device1
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="Ekey_HP"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  find_read_fluf_vendors
  run_test_device1
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="Ekey_MSFT"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  find_read_fluf_vendors
  run_test_device1
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="Ekey_DE"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  find_read_fluf_vendors
  run_test_device1
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="Ekey_LE"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  find_read_fluf_vendors
  run_test_device1
  echo "##End#####################################################################"
  sleep 4
else
  echo "Error input , please Enter Ekey/Customer in Parmater Number 7"
fi  
}



###################################################################################################
##
## run test ...  device:  nvme1n1 if 1 device connected  - SED NON SED CHECK for FW1 
##
###################################################################################################
function ffu_just_4 {
  bot_versions2_sed_nonsed
  ###############################################
  ###############################################
  #CUSTOMER (GO / DE / LE /HP)
  ###############################################
if [[ $new_key = "customer" ]]
then  
  echo  "KEY selected  :" $new_key 
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="GO"
  echo "##########################################################################"
  echo "##### FFU - FW1 "
  echo "##### Vulcan ver : " $Vulcan_Version  " -> " $new_Vulcan_Version
  echo "##########################################################################"
  mount_versions_sed_nonsed "fw1"
  find_read_fluf_vendors
  run_test_device2
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="DE"
  echo "##########################################################################"
  echo "##### FFU - FW1 "
  echo "##### Vulcan ver : " $Vulcan_Version  " -> " $new_Vulcan_Version
  echo "##########################################################################"
  mount_versions_sed_nonsed "fw1"
  find_read_fluf_vendors
  run_test_device2
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="LE"
  echo "##########################################################################"
  echo "##### FFU - FW1 "
  echo "##### Vulcan ver : " $Vulcan_Version  " -> " $new_Vulcan_Version
  echo "##########################################################################"
  mount_versions_sed_nonsed "fw1"
  find_read_fluf_vendors
  run_test_device2
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="HP"
  echo "##########################################################################"
  echo "##### FFU - FW1 "
  echo "##### Vulcan ver : " $Vulcan_Version  " -> " $new_Vulcan_Version
  echo "##########################################################################"
  mount_versions_sed_nonsed "fw1"
  find_read_fluf_vendors
  run_test_device2
  echo "##End#####################################################################"
  sleep 4
  
  #E-KEY (Ekey_GO / Ekey_HP / Ekey_MSFT /Ekey_DE /Ekey_LE)
elif [[ $new_key = "ekey" ]]  
then
  echo  "KEY selected  :" $new_key
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="Ekey_GO"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  find_read_fluf_vendors
  run_test_device2
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="Ekey_HP"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  find_read_fluf_vendors
  run_test_device2
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="Ekey_MSFT"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  find_read_fluf_vendors
  run_test_device2
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="Ekey_DE"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  find_read_fluf_vendors
  run_test_device2
  echo "##End#####################################################################"
  sleep 4
  
  echo -e "\n"
  echo "##Start###################################################################"
  vendor="Ekey_LE"
  echo "##########################################################################"
  echo "##### FFU - Base FW "
  echo "##### Vulcan ver : " $Vulcan_Version 
  echo "##### Vendor     : " $vendor
  echo "##### FW check   : " $fw1
  echo "##########################################################################"
  mount_versions "$fw1"
  find_read_fluf_vendors
  run_test_device2
  echo "##End#####################################################################"
  sleep 4
else
  echo "Error input , please Enter Ekey/Customer in Parmater Number 7"
fi 
}


###################################################################################################
##
## run test ...  device:  nvme1n1 if 1 device connected  - SED NON SED CHECK for FW1 
##
###################################################################################################
function ffu_4 {
  ffu_3
  ffu_just_4
}



###################################################################################################
##
## Run ffu between versions - run device number 1
##
###################################################################################################
function run_ffu1 {
bot_versions
unmount_folder >> $logfile
echo "#FFU Versions loop Numbers:  $loop_END"
if [[ $new_key = "" ]]
  then
  echo -e "\n"
  echo "#FFU Between Versions "
  echo -e "\n"

  ##for loop ########################################################################
  #for i in 1 2 
  for i in $(seq 1 $loop_END)
  do
  echo -e "\n"
  echo "#FFU Loop :  $i "
  ##base#####################################################################################################
  echo -e "\n"
  echo "##Start###################################################################"
  echo "##########################################################################"
  echo "##### FFU - Base "
  echo "##### Vulcan ver      : " $Vulcan_Version 
  echo "##### Base FW check   : " $fw_base
  echo "##########################################################################"  
  mount_versions_base "$fw_base"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then
    echo "FW $fw_base Exist"    
    find_read_fluf
    run_test_device1
    echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi
  if [[ $mount_status = folder_empty ]]
  then
    echo "###############"
    echo "###FW $fw_base Not Exist"
	echo "###############"
	echo -e "\n"
  fi
  sleep 4
  
  ##fw1#####################################################################################################
  echo -e "\n"
  echo "##Start###################################################################"
  echo "##########################################################################"
  echo "##### FFU - FW1"
  echo "##### Vulcan ver      : " $Vulcan_Version 
  echo "##### Base FW check   : " $fw1
  echo "##########################################################################"
  mount_versions_base "$fw1"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then
    echo "FW $fw1 Exist"    
    find_read_fluf
    run_test_device1
    echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi
  if [[ $mount_status = folder_empty ]]
  then
    echo "###############"
    echo "###FW $fw1 Not Exist"
	echo "###############"
	echo -e "\n"
  fi
  sleep 4
  done
  ##done for (for loop)
  
  ##back to base#####################################################################################################
  echo -e "\n"
  echo "############################################################"
  echo "#Back to Base: $fw_base " >> $logfile
  echo "############################################################"
  echo "##Start###################################################################"
  echo "##########################################################################"
  echo "##### FFU -Back to base "
  echo "##### Vulcan ver      : " $Vulcan_Version 
  echo "##### Base FW check   : " $fw_base
  echo "##########################################################################"
    mount_versions_base "$fw_base"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then
    echo "FW $fw_base Exist"    
	echo "#Back to Base FW : $fw_base"	
    find_read_fluf
    run_test_device1
    echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi
  if [[ $mount_status = folder_empty ]]
  then
    echo "###############"
    echo "###FW $fw_base Not Exist"
	echo "###############"
	echo -e "\n"
  fi
  sleep 4
  
##Customer##################################################################################################   
elif [[ $new_key = "customer" ]]
   then
   
   ##for loop ########################################################################
   #seq command in Linux is used to generate numbers from FIRST to LAST in steps of INCREMENT
   #sec mean start from 1 till $loop_END
   #for i in 1 2 
   for i in $(seq 1 $loop_END) 
   do
   echo "FFU Loop :  $i "
   ##base: 
        if [[ $vendor = "GO" ]]
		then 
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"     
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		   
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"  
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"   
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"    
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"   
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
	    else
		echo -e "\n"
		echo "Vendor : $vendor Error!"
		fi 
		
   ##fw1
        if [[ $vendor = "GO" ]]
		then 
		
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"  
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		  
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"  
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  		  
		else
		echo -e "\n"
		echo "Vendor : $vendor Error!"
		fi
		
		done
		## done for (for loop)
		
		########################################################################################################
		##back to base: 
		echo "############################################################"
        echo "#Back to Base: $fw_base  ,  Vendor : $vendor " >> $logfile
        echo "############################################################"
        if [[ $vendor = "GO" ]]
		then 
		  
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"			
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		   
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	    
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	    
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	   
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	   
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
	    else
		echo -e "\n"
		echo "Vendor : $vendor Error!"
		fi 
		
##ekey################################################################################################## 		
elif [[ $new_key = "ekey" ]]
   then
   
   ##for loop ########################################################################
   #for i in 1 2 
   for i in $(seq 1 $loop_END) 
   do
   echo "FFU Loop :  $i "
   ##base: 
        if [[ $vendor = "GO" ]]
		then 
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="Ekey_GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"     
			find_read_fluf_vendors
			run_test_device1
			vendor="GO"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		   
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"  
			find_read_fluf_vendors
			run_test_device1
			vendor="DE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"   
			find_read_fluf_vendors
			run_test_device1
			vendor="LE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"    
			find_read_fluf_vendors
			run_test_device1
			vendor="HP"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"   
			find_read_fluf_vendors
			run_test_device1
			vendor="MSFT"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
	    else
		echo -e "\n"
		echo "Vendor : $vendor Error!"
		fi 
		
   ##fw1
        if [[ $vendor = "GO" ]]
		then 
		
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="Ekey_GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"  
			find_read_fluf_vendors
			run_test_device1
			vendor="GO"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		  
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device1
			vendor="DE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device1
			vendor="LE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device1
			vendor="HP"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"  
			find_read_fluf_vendors
			run_test_device1
			vendor="MSFT"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  		  
		else
		echo -e "\n"
		  echo "Vendor : $vendor Error!"
		fi
		done
		## done for (for loop)
		
		########################################################################################################
		##back to base: 
		echo "############################################################"
        echo "#Back to Base: $fw_base  ,  Vendor : $vendor " >> $logfile
        echo "############################################################"
        if [[ $vendor = "GO" ]]
		then 
		  
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="Ekey_GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"			
			find_read_fluf_vendors
			run_test_device1
			vendor="GO"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		   
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	    
			find_read_fluf_vendors
			run_test_device1
			vendor="DE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	    
			find_read_fluf_vendors
			run_test_device1
			vendor="LE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	   
			find_read_fluf_vendors
			run_test_device1
			vendor="HP"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	   
			find_read_fluf_vendors
			run_test_device1
			vendor="MSFT"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
	    else
		echo -e "\n"
		echo "Vendor : $vendor Error!"
		fi 
   
   
else
   echo "Key ERROR!!, Please Enter right Key (customer/E-key/No key(Empty Parameter)"
 
fi
}

###################################################################################################
##
## Parameter name change after enter parameters - ffu_full_old=$6 
##take parameter from $6 and change it to ... full/notfull
##
###################################################################################################
function parameter_name_change {
if [[ $ffu_full_old = "vendors" ]]   
 then
  ffu_full="full"
elif [[ $ffu_full_old = "versions" ]]
  then
  ffu_full="notfull"
elif [[ $ffu_full_old = "direct" ]]
  then
  ffu_full="direct"
else
  echo "Error : Parameter 6: $ffu_full_old" >> $logfile
  echo "Error : Parameter 6: $ffu_full" >> $logfile
fi


}
###################################################################################################
##
##the test not get small leter .. if got small leter change it to capital letter
##
###################################################################################################
function small_capital_name_change {

if [[ $vendor1 = "de" ]]   
  then
  vendor="DE"
  vendor1="DE"
elif [[ $vendor1 = "go" ]]
  then
  vendor="GO"
  vendor1="GO"
elif [[ $vendor1 = "le" ]]
  then
  vendor="LE"
  vendor1="LE"
elif [[ $vendor1 = "hp" ]]
  then
  vendor="HP"
  vendor1="HP"
elif [[ $vendor1 = "msft" ]]
  then
  vendor="MSFT"
  vendor1="MSFT"
#else
#  echo "parameter_name_change -> Vendor ERROR!!!"
fi
}




###################################################################################################
##
## Run ffu without vendors , between versions - run device number 1 - direct
##
###################################################################################################
function run_ffu1_direct {
  bot_versions >> $logfile
  echo -e "\n"
  echo "## Devices Number 1  Selected"
  echo "##### FFU - FW1 - (direct) "
  echo "##### Vulcan ver      : " $Vulcan_Version 
  echo "##### FW1 check       : " $fw1
  echo "##########################################################################"
  
  
  if_empty >> $logfile 
	if [[ $new_key = "customer" ]]
	then 
		if [[ $vendor = "GO" ]]
		then 
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="GO"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="DE"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="LE"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="HP"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="MSFT"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  		  
		else
		  echo -e "\n"
		  vendor="Error Vendor !"
		fi
	  
	  #E-KEY (Ekey_GO / Ekey_HP / Ekey_MSFT /Ekey_DE /Ekey_LE)
	elif [[ $new_key = "ekey" ]]  
	then
		
		if [[ $vendor = "GO" ]]
		then 
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="Ekey_GO"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  
		  
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_DE"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_LE"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_HP"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_MSFT"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  
		else
		echo -e "\n"
		vendor="Error Vendor!"
		fi
		
	elif [[ $new_key = "" ]]  
	then
		mount_versions_base "$fw1"
		[ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf
			run_test_device1
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################

	else
	  echo "Error input , please Enter the right KEY and Vendor "
	fi  
	

}




###################################################################################################
##
## Run ffu without vendors , between versions - run device number 2
##
###################################################################################################
function run_just_ffu2 {
bot_versions
unmount_folder >> $logfile
echo "#FFU Versions loop Numbers:  $loop_END"
if [[ $new_key = "" ]]
  then
  echo -e "\n"
  echo "#FFU Between Versions "
  echo -e "\n"

  ##for loop ########################################################################
  #for i in 1 2 
  for i in $(seq 1 $loop_END)
  do
  echo -e "\n"
  echo "#FFU Loop :  $i "
  ##base#####################################################################################################
  echo -e "\n"
  echo "##Start###################################################################"
  echo "##########################################################################"
  echo "##### FFU - Base "
  echo "##### Vulcan ver      : " $Vulcan_Version 
  echo "##### Base FW check   : " $fw_base
  echo "##########################################################################"  
  mount_versions_base "$fw_base"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then
    echo "FW $fw_base Exist"    
    find_read_fluf
    run_test_device2
    echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi
  if [[ $mount_status = folder_empty ]]
  then
    echo "###############"
    echo "###FW $fw_base Not Exist"
	echo "###############"
	echo -e "\n"
  fi
  sleep 4
  
  ##fw1#####################################################################################################
  echo -e "\n"
  echo "##Start###################################################################"
  echo "##########################################################################"
  echo "##### FFU - FW1"
  echo "##### Vulcan ver      : " $Vulcan_Version 
  echo "##### Base FW check   : " $fw1
  echo "##########################################################################"
  mount_versions_base "$fw1"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then
    echo "FW $fw1 Exist"    
    find_read_fluf
    run_test_device2
    echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi
  if [[ $mount_status = folder_empty ]]
  then
    echo "###############"
    echo "###FW $fw1 Not Exist"
	echo "###############"
	echo -e "\n"
  fi
  sleep 4
  done
  ##done for (for loop)
  
  ##back to base#####################################################################################################
  echo -e "\n"
  echo "############################################################"
  echo "#Back to Base: $fw_base " >> $logfile
  echo "############################################################"
  echo "##Start###################################################################"
  echo "##########################################################################"
  echo "##### FFU -Back to base "
  echo "##### Vulcan ver      : " $Vulcan_Version 
  echo "##### Base FW check   : " $fw_base
  echo "##########################################################################"
    mount_versions_base "$fw_base"
  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
  if [[ $mount_status = folder_not_empty ]]
  then
    echo "FW $fw_base Exist"    
	echo "#Back to Base FW : $fw_base"	
    find_read_fluf
    run_test_device2
    echo "##End#####################################################################"
	sleep 2
	unmount_folder >> $logfile
  fi
  if [[ $mount_status = folder_empty ]]
  then
    echo "###############"
    echo "###FW $fw_base Not Exist"
	echo "###############"
	echo -e "\n"
  fi
  sleep 4
  
   ##customer###############################################################################
elif [[ $new_key = "customer" ]]
   then
   ##for loop ########################################################################
   #for i in 1 2 
   for i in $(seq 1 $loop_END)
   do
   echo -e "\n"
   echo "#FFU Loop :  $i "
   ##base: 
        if [[ $vendor = "GO" ]]
		then 
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"     
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		   
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"  
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"   
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"    
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"   
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
	    else
		echo -e "\n"
		echo "Vendor : $vendor Error!"
		fi 
		
        ##fw1
        if [[ $vendor = "GO" ]]
		then 
		
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"  
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		  
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"  
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  		  
		else
		echo -e "\n"
		echo "Vendor : $vendor Error!"
		fi
		
		done
		## done for (for loop)
		
		########################################################################################################
		##back to base: 
		echo "############################################################"
        echo "#Back to Base: $fw_base  ,  Vendor : $vendor " >> $logfile
        echo "############################################################"
        if [[ $vendor = "GO" ]]
		then 
		  
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"			
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		   
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	    
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	    
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	   
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	   
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
	    else
		echo -e "\n"
		echo "Vendor : $vendor Error!"
		fi 
		
		
elif [[ $new_key = "ekey" ]]
   then
   
   ##for loop ########################################################################
   #for i in 1 2 
   for i in $(seq 1 $loop_END)
   do
   echo -e "\n"
   echo "#FFU Loop :  $i "
   ##base: 
        if [[ $vendor = "GO" ]]
		then 
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="Ekey_GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"     
			find_read_fluf_vendors
			run_test_device2
			vendor="GO"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		   
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"  
			find_read_fluf_vendors
			run_test_device2
			vendor="DE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"   
			find_read_fluf_vendors
			run_test_device2
			vendor="LE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"    
			find_read_fluf_vendors
			run_test_device2
			vendor="HP"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist"   
			find_read_fluf_vendors
			run_test_device2
			vendor="MSFT"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
	    else
		echo -e "\n"
		echo "Vendor : $vendor Error!"
		fi 
		
   ##fw1
        if [[ $vendor = "GO" ]]
		then 
		
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="Ekey_GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"  
			find_read_fluf_vendors
			run_test_device2
			vendor="GO"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		  
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device2
			vendor="DE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device2
			vendor="LE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"    
			find_read_fluf_vendors
			run_test_device2
			vendor="HP"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw1 Exist"  
			find_read_fluf_vendors
			run_test_device2
			vendor="MSFT"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  		  
		else
		echo -e "\n"
		  echo "Vendor : $vendor Error!"
		fi
		done
		## done for (for loop)
		
		########################################################################################################
		##back to base: 
	    echo "############################################################"
        echo "#Back to Base: $fw_base  ,  Vendor : $vendor " >> $logfile
        echo "############################################################"	
        if [[ $vendor = "GO" ]]
		then 
		  
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="Ekey_GO"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"			
			find_read_fluf_vendors
			run_test_device2
			vendor="GO"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		   
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_DE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	    
			find_read_fluf_vendors
			run_test_device2
			vendor="DE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_LE"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	    
			find_read_fluf_vendors
			run_test_device2
			vendor="LE"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_HP"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	   
			find_read_fluf_vendors
			run_test_device2
			vendor="HP"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_MSFT"
		  #mount_versions_base "$vendor"
		  mount_direct "$fw_base"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "#FW $fw_base Exist" 
			echo "#Back to Base FW : $fw_base"	   
			find_read_fluf_vendors
			run_test_device2
			vendor="MSFT"
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw_base Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #######################################################################################################
	    else
		echo -e "\n"
		echo "Vendor : $vendor Error!"
		fi 
   
   
else
   echo "Key ERROR!!, Please Enter right Key (customer/E-key/No key(Empty Parameter)"
 
fi
}



###################################################################################################
##
## Run ffu without vendors , between versions - run device number 2-direct
##
###################################################################################################
function run_just_ffu2_direct {
bot_versions >> $logfile
  echo -e "\n"
  echo "## Devices Number 2  Selected"
  echo "##### FFU - FW1 - (direct) "
  echo "##### Vulcan ver      : " $Vulcan_Version 
  echo "##### FW1 check       : " $fw1
  echo "##########################################################################"
  
  
  if_empty >> $logfile 
	if [[ $new_key = "customer" ]]
	then 
		if [[ $vendor = "GO" ]]
		then 
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="GO"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="DE"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="LE"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="HP"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="MSFT"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  		  
		else
		  echo -e "\n"
		  vendor="Error Vendor !"
		fi
	  
	  #E-KEY (Ekey_GO / Ekey_HP / Ekey_MSFT /Ekey_DE /Ekey_LE)
	elif [[ $new_key = "ekey" ]]  
	then
		
		if [[ $vendor = "GO" ]]
		then 
		  echo  "Vendor selected  :" $vendor 
		  echo -e "\n"
		  vendor="Ekey_GO"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  
		  
		elif [[ $vendor = "DE" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_DE"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  

		elif [[ $vendor = "LE" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_LE"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  
		 
		elif [[ $vendor = "HP" ]]
		then
		  echo -e "\n"
		  vendor="Ekey_HP"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  

		elif [[ $vendor = "MSFT" ]]
		then  
		  echo -e "\n"
		  vendor="Ekey_MSFT"
		  mount_direct "$fw1"
		  [ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf_vendors
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################
		  
		else
		echo -e "\n"
		vendor="Error Vendor!"
		fi
		
	elif [[ $new_key = "" ]]  
	then
		mount_versions_base "$fw1"
		[ "$(ls -A /home/qa/Desktop/mnt)" ] && mount_status=folder_not_empty || mount_status=folder_empty  
		  if [[ $mount_status = folder_not_empty ]]
		  then
			echo "FW $fw1 Exist"
			find_read_fluf
			run_test_device2
			echo "##End#####################################################################"
			sleep 2
			unmount_folder >> $logfile
		  fi  
		  if [[ $mount_status = folder_empty ]]
		  then
			echo "###############"
			echo "###FW $fw1 Not Exist"
			echo "###############"
			echo -e "\n"
		  fi
		  sleep 4
		  #####################################################################################################

	else
	  echo "Error input , please Enter the right KEY and Vendor "
	fi  



}


###################################################################################################
##
## Run ffu without vendors , between versions - run two devices 
##
###################################################################################################
function run_ffu2 {
  echo "## 2 Devices Selected"
  run_ffu1
  run_just_ffu2
}


###################################################################################################
##
## Run ffu without vendors , between versions - run two devices -direct
##
###################################################################################################
function run_ffu2_direct {
  echo "## 2 Devices Selected"
  run_ffu1_direct
  run_just_ffu2_direct
}

function remove_temp_files {
rm -rf device.txt
rm -rf idntfy.txt
}



function latest_file {
#cd /home/qa/Desktop/wdckit-2.2.0.0-x86_64-tar-gz-Linux-x86-64/wdckit-2.2.0.0-x86_64/
cd "$path"
latest=$(ls -t RESULTS*.log | head -1)
echo $latest

#cat $latest | grep "Error: Update failed on" 
#cat $latest | grep "Success: Update completed on: 21442L640407" 

while latest= read -r line
do
  echo "$line"
  cat $latest | grep "Error: Update failed on" 
done 
#< "$input"
}




###################################################################################################
##
## check_log_folder
##
###################################################################################################
function check_log_folder {
#cd /home/qa/Desktop/wdckit-2.2.0.0-x86_64-tar-gz-Linux-x86-64/FFU_Automation/Scripts/
cd "$path1" 
dir="log_files"
flag1=0
if [ -d "$dir" ]; then
    echo "$dir -> Directory Exists."
    flag1=1
else 
    echo "$dir -> Directory Not Exists."
	sudo mkdir log_files
	echo "$dir -> created , please rerun the test ."
    flag1=0
fi
}


###################################################################################################
##
## sammery
##
###################################################################################################
function check_logs_Results {
##print Date_time to the log file
#current_date=$(date)
echo  "############################################################################################" 
echo "##Date And Time is : $today1" 
echo  "############################################################################################" 

echo "Log File check : "$1 
##grep -> It is used to search text and strings in a given file
##wc -> It is used to find out number of lines, word count, byte and characters count in the files specified in the file arguments
##-l: This option prints the number of lines present in a file
##looking for Failure
Failure=$(grep -w "Failure" $1 | wc -l)
##looking for #FW Activate
Tests_number=$(grep -w "#FW Activate" $1 | wc -l)
##looking for success
success=$(grep -w "successful" $1 | wc -l)



echo -e "\n"
echo "#########################################################"
echo "#Summary:"  
echo "#Test Cases Number:  $Tests_number"
echo "#Activation was Failed in     : $Failure Test Cases"
echo "#Activation was successful in : $success Test Cases "
echo "#########################################################"

#if [ $Failure -gt 0 ]
#then 
#   echo "#Activation was Failed in : $Failure Test Cases"
#fi
#if [ $Failure -eq 0 ]
#then
#   success=$(grep -w "successful" $1 | wc -l)
#   echo "#Activation was successful in $success Test Cases " 
#fi
#echo "#########################################################"
}