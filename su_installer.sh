#!/bin/bash
debug=1
usePyVer='3.6'

function aboutThisScript {
	debugOut "this script is based upon the installation instructions located here:" "white"
	debugOut "https://spinningup.openai.com/en/latest/user/installation.html" "green"
	debugOut " " "black"
	debugout "Notice: this script and its author are not necessarilly endorsed by OpenAI" "yellow"
	debugOut "this script does NOT install the optional MuJuCo component." "yellow"
}

function debugOut() {
debugMessage=$1
thisColor=$2
# $3 is the background color (eventually)
textColor=37 
bgColor=";40"
case  ${thisColor}  in
	Black|black|Blk|blk)       
		textColor="1;30"
	;;
	Red|red|Rd|rd)       
		textColor=31
	;;
	Green|green|Grn|grn)       
		textColor="1;32"
	;;
	Brown|brown|Brn|brn|Brwn|brwn)       
		textColor=33
	;;
	Blue|blue|Blu*|blu*)       
	textColor="1;34"
	;;
	Purple|purple|Pur*|pur*)       
		textColor="1;35"
	;;
	Cyan|cyan|Cyn|cyn|Cya|cya)       
		textColor=36
	;;
	Gray|gray|grey|gray|gry|Gry)       
		textColor=37
	;;
	Yellow|yellow|Ylw|ylw)       
		textColor="1;33"
	;;
	White|white|Wht|wht)       
		textColor="1;37"
	;;
	*)              
		textColor=37
	;;
esac 

if [[ ${debug} == 1 ]] ; then 
	echo -e "\e[${textColor}${bgColor}m ${debugMessage} \e[0m"
fi
}


function UpgradesAndUpdates {
	debugOut "Checking for, and installing OS upgrades:" "green"
	sudo apt-get upgrade -y 
	debugOut "Checking for, and installing required system tools:" "green"
	sudo apt-get install -y vim dos2unix git curl 
	debugOut "Checking for, and installing required libraries:" "green"
	sudo apt-get install -y libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 libopenmpi-dev
	debugOut "Checking for, and installing any lingering package updates updates:" "green"
	sudo apt-get update -y 
	debugOut "apt based updates are complete." "green"
}


function InstallAnacondaAndPython {

	curl https://repo.anaconda.com/archive/ > /tmp/raw.out

	AnacondaFileAndHash=` cat /tmp/raw.out | grep -i '<t[rd]'| sed '1,1d'|paste - - - - - -d, | grep -i 'Linux-x86_64'|awk -F\> '{print $3 $7 $11}'|sed -e 's/<\/td/"/g;'|awk -F\" '{print $2"|"$3"|"$4}'| head -1`

	LatestAnacondaFile=$(echo ${AnacondaFileAndHash} | awk -F\| '{print $1}')
	LatestAnacondaSize=$(echo ${AnacondaFileAndHash} | awk -F\| '{print $2}')
	LatestAnacondaHash=$(echo ${AnacondaFileAndHash} | awk -F\| '{print $3}')

	if [ ! -e ./${LatestAnacondaFile} ]  ; then
		debugOut "Latest Anaconda3 installer is: ${LatestAnacondaFile}" "white"
		debugOut "(size: ${LatestAnacondaSize})- fetching..." "Yellow"
		wget https://repo.anaconda.com/archive/${LatestAnacondaFile}
	else
		debugOut "we already have the file, that will save some time." "green"
	fi

	dlFileHash=$(md5sum Anaconda3-2020.07-Linux-x86_64.sh|awk '{print $1}')

	debugOut "checking that the expected md5 hash (${LatestAnacondaHash}) matches the downloaded file " "Yellow"
	if [ ! "${dlFileHash}" == "${LatestAnacondaHash}" ] ; then
	 debugOut "md5 hashes FAIL - ABORTING" "red"
	 debugOut "expected hash: ${LatestAnacondaHash}" "green"
	 debugOut "received hash: ${dlFileHash}" "yellow"
	 debugOut "md5 hashes FAIL - ABORTING" "red"
	 exit
	else
	 debugOut "md5 hashes MATCH" "cyan"
	 debugOut "expected hash: "${LatestAnacondaHash} "green"
	 debugOut "received hash: "${dlFileHash} "green"
	fi

	debugOut "Please accept all default values while installing Anaconda, Thanks." "white"

	bash ./${LatestAnacondaFile} -u
	debugOut "checking for, and applying conda updates" "white"
	conda update -y -n base -c defaults conda
	debugOut "updating the current shell..." "white"
	source ~/.bashrc

	debugOut "shell has been updated" "white"

	debugOut "running 'conda list'" "brown"
	conda list
	debugOut "launching python to verify Anaconda integration. If Anaconda is installed and working, the version information it displays when it starts up will include 'Anaconda'." "white"
	debugOut " " "black"
	debugOut "To exit the Python shell, enter the command " "white"
	debugOut "quit()" "brown"
	python
	debugOut "Open Anaconda Navigator with the command :" "white"
	debugOut "anaconda-navigator" "brown"

	debugOut "So far, so good.  Now using Anaconda to create a conda Python 3.6 env for organizing packages used in Spinning Up" "white"
	conda create -n spinningup
	debugOut "installing tensorflow via conda" "White"
	conda install tensorflow
	debugOut "To use Python from the environment you just created, activate the environment with: "  "white"
	debugOut "conda activate spinningup"  "brown"
	debugOut "doing that now..." "white"
	conda activate spinningup
}


function InstallSpinningUp {
	
	debugOut "Installing Spinning Up from github"  "white"
	rm -Rf ./spinningup
	git clone https://github.com/openai/spinningup.git
	cd spinningup
	
	pip install -e .

	debugOut "check the install by running PPO in the LunarLander-v2 environment:" "Gry" 
	debugOut "python -m spinup.run ppo --hid \"[32,32]\" --env LunarLander-v2 --exp_name installtest --gamma 0.999" "brown"

	debugOut "watch the output:" "Gry"
	debugOut "python -m spinup.run test_policy data/installtest/installtest_s0" "brown"

	debugOut "plot the results" "Gry"
	debugOut "python -m spinup.run plot data/installtest/installtest_s0" "brown"
}


function Complete {
	debugOut "this system is now in a proper state for using 'SpinningUp'" "yellow"
}

if [[ ${debug} == 1 ]] ; then 
	aboutThisScript
fi

UpgradesAndUpdates
InstallAnacondaAndPython
InstallSpinningUp
Complete
