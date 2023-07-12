#!/bin/bash
source ./config.sh
source ./functions.sh
#path="/home/qa/Desktop/wdckit-2.13.0.0-x86_64"
#path1="$path/FFU_Automation/Scripts/"
#path_wdckit="$path/wdckit"

####################################################################################################
#take varible from config.txt file 
#the text come with \r after the number in defult becuase it a string ..
loop_END=${FFU_loop_number%_*}
#echo "var 2=       $loop_END"
#loop_END=2

####################################################################################################

#Automaticlly path take
#SCRIPT_DIR:
#/home/qa/Desktop/wdckit-2.13.0.0-x86_64/Vulcan_FFU_LINUX_Automation_0.8/
path1=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$path1"
cd .. 

#########################################################################
#/home/qa/Desktop/wdckit-2.13.0.0-x86_64/
#tool_DIR1:
path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#wdckit path: 
path_wdckit="$path/wdckit"
#echo "SCRIPT DIR->           $path1"
#echo "wdckit File->           $path_wdckit"
#echo "tool DIR->          $path"
####################################################################################################

cd "$path1"
echo "Working Directory is: $path1"
#cd /home/qa/Desktop/wdckit-2.13.0.0-x86_64/FFU_Automation/Scripts/



#cd /home/qa/Desktop/wdckit-2.2.0.0-x86_64-tar-gz-Linux-x86-64/wdckit-2.2.0.0-x86_64/
#cd /home/qa/Desktop/wdckit-2.13.0.0-x86_64/
cd "$path"

##save file with Date_time########################################################
today=`date +%d_%m_%y_%H_%M_%S`
today1=`date +%d-%m-%y.%H:%M:%S`
if [ $5 = "direct" ] || [ $6 = "direct" ]
then
 logfile=$(echo "RESULTS_FFU_Test_"$3"_Device_"$4"_"$today".log")
 latest_log=$logfile
 summary=$(echo "summary_FFU_Test_"$3"_Device_"$4"_"$today".log")
else
 logfile=$(echo "RESULTS_FFU_Test_FROM_"$3"_TO_"$4"_Device_"$5"_"$today".log")
 latest_log=$logfile
 summary=$(echo "summary_FFU_Test_FROM_"$3"_TO_"$4"_Device_"$5"_"$today".log")
fi


####################################################################################

##print Date_time to the log file############################
#current_date=$(date)
echo  "############################################################################################" > $logfile
echo "##Date And Time is : $today1" >> $logfile
echo  "############################################################################################" >> $logfile
echo -e "\n" >> $logfile
echo  "############################################################################################" >> $logfile

echo "#Information: " >> $logfile
echo "Working Directory is: $path1" >> $logfile
echo "#Wdckit File: " >> $logfile
If_wdckit_Exist  >> $logfile
##check if exist, if not exit form code 
if [[ $flag = 0 ]]
then
    echo "Wdckit File Not Exist" >> $logfile
    exit 0
fi

#################################################
#latest_file
#################################################
##check device
echo -e "\n" >> $logfile
echo "#Device Information:"  >> $logfile
checkDevice >> $logfile
echo "Device            : " $numOfDevices_full_line  >> $logfile
echo "Connected Devices : "$numOfDevices >> $logfile

##unmount
mount_folder_check >> $logfile
echo  "############################################################################################" >> $logfile


#################################################
##check parameterss number 
#check_parameters >> $logfile

if  [ $# ]
then
echo "Parameters Entered: "$#
fi

if [ $5 = "direct" ] || [ $6 = "direct" ]
then
	##Varibales
	echo "#Direct FFU" 
	#echo "#Direct FFU" >> $logfile
	project=$1
	Vulcan_Version=$2
	#fw_base=$3
	fw1=$3
	device=$4
	ffu_full_old=$5
	new_key=$6
	vendor1=$7
	vendor=$vendor1
	
	##check if one of the parameters not entered 
	if  [ $1 ]
	then
		echo ""
	else
		echo "please Enter project!(For Example : vulcan) " 
		exit 0
	fi

	if  [ $2 ]
	then
		echo ""
	else
		echo "please Enter project Version! (For Example : Performance_Version)" 
		exit 0
	fi


	if  [ $3 ]
	then
		echo ""
	else
		echo "please Enter FW 1! (For Example : AO047VCP / ... ) "
		exit 0
	fi

	if  [ $4 ]
	then
		echo ""
	else
		echo "please Enter Device Number! (1/2/all) "
		exit 0
	fi

	if  [ $5 ]
	then
		echo ""
	else
		echo "please Enter FFU! (versions / vendors / Direct) "
		exit 0
	fi

	if  [ $6 ]
	then
		echo ""
	#else
		#echo "please Enter KEY! (customer/ekey)"
		#exit 0
	fi 
	
	if  [ $7 ]
	then
		echo ""
	#else
		#echo "please Enter Vendor! (GO / LE / DE / MSFT)"
	fi
	
	echo "############################################"
	echo "# Direct FFU Test Parameters  : "
	echo "# project          : $project" 
	echo "# Vulcan Version   : $Vulcan_Version" 
	echo "# KEY              : $new_key" 
	echo "# Selected device  : $device" 
	echo "# FW 1             : $fw1" 
	echo "# Vendor           : $vendor1"  
	echo "# The Test Is Running !!!"                      
	echo "############################################"

	echo "# Direct FFU Test Parameters  : " >> $logfile
	echo "# project            : $project" >> $logfile
	echo "# Vulcan Version     : $Vulcan_Version" >> $logfile
	echo "# KEY                : $new_key" >> $logfile
	echo "# Selected device    : $device" >> $logfile
	echo "# FW 1               : $fw1" >> $logfile
	echo "# Vendor             : $vendor1" >> $logfile
	echo "############################################################################################" >> $logfile
	

elif [ $5 = "vendors" ] || [ $6 = "vendors" ]
then
	##Varibales 
	echo "#Vendors FFU"
	#echo "#Vendors FFU" >> $logfile
	project=$1
	Vulcan_Version=$2
	fw_base=$3
	fw1=$4
	device=$5
	ffu_full_old=$6
	new_key=$7
	vendor1=$8
	vendor=$vendor1
	##check if one of theparameters not entered 
	if  [ $1 ]
	then
		echo ""
	else
		echo "please Enter project!(For Example : vulcan) " 
		exit 0
	fi

	if  [ $2 ]
	then
		echo ""
	else
		echo "please Enter project Version! (For Example : Performance_Version)" 
		exit 0
	fi

	if  [ $3 ]
	then
		echo ""
	else
		echo "please Enter FW BASE! (For Example : AO047VCP / ... ) "
		exit 0
	fi

	if  [ $4 ]
	then
		echo ""
	else
		echo "please Enter FW 1! (For Example : AO047VCP / ... ) "
		exit 0
	fi

	if  [ $5 ]
	then
		echo ""
	else
		echo "please Enter Device Number! (1/2/all) "
		exit 0
	fi

	if  [ $6 ]
	then
		echo ""
	else
		echo "please Enter FFU! (Versions / Vendors) "
		exit 0
	fi

	if  [ $7 ]
	then
		echo ""
	else
		echo "please Enter KEY! (customer/ekey)"
		exit 0
	fi
	
		if  [ $8 ]
	then
		echo ""
	else
		echo "please Enter Vendor! (GO / LE / DE / HP/ MSFT)"
		exit 0
	fi
	
	echo "############################################"
	echo "# Vendors FFU Test Parameters  : "
	echo "# project          : $project" 
	echo "# Vulcan Version   : $Vulcan_Version" 
	echo "# Selected device  : $device" 
	echo "# Base FW          : $fw_base" 
	echo "# FW 1             : $fw1" 
	echo "# KEY              : $new_key" 
	echo "# vendor           : $vendor1" 
	echo "# The Test Is Running !!!"                      
	echo "############################################"

	echo "# Vendors FFU Test Parameters  : " >> $logfile
	echo "# project            : $project" >> $logfile
	echo "# Vulcan Version     : $Vulcan_Version" >> $logfile
	echo "# Selected device    : $device" >> $logfile
	echo "# Base FW            : $fw_base" >> $logfile
	echo "# FW 1               : $fw1" >> $logfile
	echo "# KEY                : $new_key" >> $logfile
	echo "# vendor             : $vendor1" >> $logfile
	echo "############################################################################################" >> $logfile
	
	
elif [ $5 = "versions" ] || [ $6 = "versions" ]
then	
    ##Varibales 
	echo "#Versions FFU"
	#echo "#Versions FFU" >> $logfile
	project=$1
	Vulcan_Version=$2
	fw_base=$3
	fw1=$4
	device=$5
	ffu_full_old=$6
	new_key=$7
	vendor1=$8
	vendor=$vendor1
	##check if one of theparameters not entered 
	if  [ $1 ]
	then
		echo ""
	else
		echo "please Enter project!(For Example : vulcan) " 
		exit 0
	fi

	if  [ $2 ]
	then
		echo ""
	else
		echo "please Enter project Version! (For Example : Performance_Version)" 
		exit 0
	fi

	if  [ $3 ]
	then
		echo ""
	else
		echo "please Enter FW BASE! (For Example : AO047VCP / ... ) "
		exit 0
	fi

	if  [ $4 ]
	then
		echo ""
	else
		echo "please Enter FW 1! (For Example : AO047VCP / ... ) "
		exit 0
	fi

	if  [ $5 ]
	then
		echo ""
	else
		echo "please Enter Device Number! (1/2/all) "
		exit 0
	fi

	if  [ $6 ]
	then
		echo ""
	else
		echo "please Enter FFU! (Versions / Vendors) "
		exit 0
	fi

	#if  [ $7 ]
	#then
	#	echo ""
	#else
	#	echo "please Enter KEY! (customer/ekey)"
	#	exit 0
	#fi
	
	echo "############################################"
	echo "# Versions FFU Test Parameters  : "
	echo "# project          : $project" 
	echo "# Vulcan Version   : $Vulcan_Version" 
	echo "# Selected device  : $device" 
	echo "# Base FW          : $fw_base" 
	echo "# FW 1             : $fw1" 
	echo "# KEY              : $new_key" 
	echo "# vendor           : $vendor1" 
	echo "# The Test Is Running !!!"                      
	echo "############################################"

	echo "# Versions FFU Test Parameters  : " >> $logfile
	echo "# project            : $project" >> $logfile
	echo "# Vulcan Version     : $Vulcan_Version" >> $logfile
	echo "# Selected device    : $device" >> $logfile
	echo "# Base FW            : $fw_base" >> $logfile
	echo "# FW 1               : $fw1" >> $logfile
	echo "# KEY                : $new_key" >> $logfile
	echo "# vendor             : $vendor1" >> $logfile
	echo "############################################################################################" >> $logfile
			
else	
	echo "Parameters Are missing!! "
	exit 0
fi


##the test not get small leter .. if got small leter change it to capital letter
small_capital_name_change

##parameter name change & small/capital letter  #########################################################
parameter_name_change >> $logfile  


#cd /home/qa/Desktop/wdckit-2.2.0.0-x86_64-tar-gz-Linux-x86-64/wdckit-2.2.0.0-x86_64/
cd "$path"
## check if logs directory exist - cd to /home/qa/Desktop/wdckit-2.2.0.0-x86_64-tar-gz-Linux-x86-64/FFU_Automation/Scripts/ if need to change log folder change cd inside the func
#check_log_folder


#ffu between Vendors of fw1	
##if $5 == full run all between Vendors  // else  (not full) between versions // else (direct) run just from FW to another one-back to base
if [[ $ffu_full = "full" ]]
then
  if [[ $device = "1" ]]   #numOfDevices
	then
	  echo -e "\n"
	  echo "#Device Number 1 Selected-Vendors FFU" >> $logfile
	  ffu_1 >> $logfile
	  #checkDevice
	  sudo nvme list >> $logfile
	  sudo nvme list
	elif [[ $device = "2" ]]
	then
	  echo -e "\n" >> $logfile
	  echo "#Device Number 2 Selected-Vendors FFU"  >> $logfile
	  ffu_just_2 >> $logfile
	  #checkDevice 
	  sudo nvme list >> $logfile
	  sudo nvme list
	  #remove_temp_files
	elif [[ $device = "all" ]]
	then
	  echo -e "\n" >> $logfile
	  echo "#2 Devices Selected-Vendors FFU"  >> $logfile
	  ffu_2 >> $logfile
	  #checkDevice 
	  sudo nvme list >> $logfile
	  sudo nvme list
	  #remove_temp_files
	else
	  echo "Number Of Devices Error: "$device  >> $logfile
	  echo "Number Of Devices Error: "$device
	fi

	#echo -e "\n \n"
	#echo "###Sed-Non SED check#####################################################" >> $logfile
	##Run the test 2
    #if [[ $device = "1" ]]
    #then
    # echo "### Device Number 1 Selected" >> $logfile
	#  ffu_3 >> $logfile
	#  #echo "Device         : " $numOfDevices_full_line "\n "
	#  sudo nvme list >> $logfile
	#  sudo nvme list
	#elif [[ $device = "2" ]]
	#then
	#  #echo "sed-non sed - devices 2 "
    #echo "### Device Number 2 Selected" >> $logfile
	#  ffu_just_4 >> $logfile
	#  sudo nvme list >> $logfile
	#  sudo nvme list
	#  #remove_temp_files   
	#elif [[ $device = "all" ]]
	#then
	# #echo "sed-non sed - devices 2 "
    #echo "### 2 Devices Selected ###"  >> $logfile
	#  ffu_4 >> $logfile
	#  sudo nvme list >> $logfile
	#  sudo nvme list
	#  #remove_temp_files
	#else
	#  echo "Number Of Devices Error: " $device  >> $logfile
	# echo "Number Of Devices Error: " $device
	#fi
	
#ffu between versions 48 -> 47 fluf to fluf	
#check ffu versions 
elif [[ $ffu_full = "notfull" ]]
then
	  
	if [[ $device = "1" ]]
	then
    echo "#Device Number 1 Selected-versions FFU" >> $logfile
	  run_ffu1 >> $logfile
	  sudo nvme list >> $logfile
	  sudo nvme list
	elif [[ $device = "2" ]]
	then  
    echo "#Device Number 2 Selected-versions FFU" >> $logfile
	  run_just_ffu2  >> $logfile
	  sudo nvme list >> $logfile
	  sudo nvme list
	elif [[ $device = "all" ]]
	then  
    echo "#2 Devices Selected-versions FFU"  >> $logfile
	  run_ffu2  >> $logfile
	  sudo nvme list >> $logfile
	  sudo nvme list
	else
	  echo "Number Of Devices Error: "$device  >> $logfile
	  echo "Number Of Devices Error: "$device
	fi

elif [[ $ffu_full = "direct" ]]
then	
	#ffu between versions 48 -> 47 fluf to fluf one time no repeat+no downgrade 
	if [[ $device = "1" ]]
	then
    echo "#Device Number 1 Selected-direct FFU" >> $logfile
	  run_ffu1_direct >> $logfile
	  sudo nvme list >> $logfile
	  sudo nvme list 
	elif [[ $device = "2" ]]
	then  
    echo "#Device Number 2 Selected-direct FFU" >> $logfile
	  run_just_ffu2_direct  >> $logfile
	  sudo nvme list >> $logfile
	  sudo nvme list
	elif [[ $device = "all" ]]
	then  
    echo "#2 Devices Selected-direct FFU"  >> $logfile
	  run_ffu2_direct  >> $logfile
	  sudo nvme list >> $logfile
	  sudo nvme list
	else
	  echo "Number Of Devices Error: "$device  >> $logfile
	  echo "Number Of Devices Error: "$device
	fi
else 
	echo " " >> $logfile
	echo " " 
	echo "Please Select vendors/versions/direct in parameter number 6 " >> $logfile
	echo "Please Select vendors/versions/direct in parameter number 6 "
	echo " " >> $logfile
	echo " " 
fi

##unmount
#logfile_FFU=$(echo "testLogs/FFU_AC0_FROM_"$baseFW"_TO_"$newFw".log")
#log= $(ls -t | head -1 )
#thefile=$(ls -t -U | grep -m 1 "Screen Shot")
#new_log=$latest_log
#logfile_FFU= $latest_log
#errorLog1=$(grep -w "successful" $new_log | wc -l) >> $logfile
#echo $latest_log
check_logs_Results $latest_log > $summary


unmount_folder >> $logfile


##############################################################################################################################################################################################################
#cd /home/qa/Desktop/wdckit-2.2.0.0-x86_64-tar-gz-Linux-x86-64/FFU_Automation/Scripts/
#cd /home/qa/Desktop/wdckit-2.13.0.0-x86_64/Vulcan_FFU_LINUX_Automation_0.8/
#/mnt/share/
#$5 -> DEVICE = ( 1 / 2/ ALL)
#$6 -> ffu_full=(vendors / versions / Direct)
#$7 -> (customer/ekey)
#$8 -> (LE/HP)
#vendors
#sudo ./FFU_TEST.sh vulcan Performance_Version AO050VCP AO067VCP 1 vendors customer DE
#sudo ./FFU_TEST.sh vulcan Performance_Version AO050VCP AO067VCP 2 vendors customer DE

#versions
#sudo ./FFU_TEST.sh vulcan Performance_Version AO067VCP AO050VCP 1 versions 
#sudo ./FFU_TEST.sh vulcan Performance_Version AO068VCP AO067VCP 1 versions customer DE
#sudo ./FFU_TEST.sh vulcan Performance_Version AO068VCP AO050VCP 1 versions customer DE
#sudo ./FFU_TEST.sh vulcan Performance_Version AO068VCP AO067VCP 1 versions ekey DE
#sudo ./FFU_TEST.sh vulcan Performance_Version AO068VCP AO050VCP 1 versions ekey DE
#sudo ./FFU_TEST.sh vulcan SED_Performance_Version AO065vcp AO049VCO 1 versions 
#sudo ./FFU_TEST.sh vulcan Performance_Version AO065vcp AO061vcp 1 versions
#sudo ./FFU_TEST.sh vulcan Debug_Version AO064VCN AO051VCN 2 versions ekey

#direct
#$4 -> DEVICE = ( 1 / 2/ ALL)
#$5 -> ffu_full=(vendors / versions / Direct)
#$6 -> (customer/ekey)
#$7 -> (de/le)

#sudo ./FFU_TEST.sh vulcan Debug_Version AO066vcn 1 direct 
#sudo ./FFU_TEST.sh vulcan Performance_Version AO062vcp 1 direct
#sudo ./FFU_TEST.sh vulcan Performance_Version AO062vcp 1 direct ekey LE 
#sudo ./FFU_TEST.sh vulcan Performance_Version AO067vcp 1 direct ekey DE 
#sudo ./FFU_TEST.sh vulcan Performance_Version AO067vcp 1 direct customer DE
#sudo ./FFU_TEST.sh vulcan Performance_Version AO050vcp 2 direct customer DE
#sudo ./FFU_TEST.sh vulcan Performance_Version AO062vcp 2 direct customer HP

