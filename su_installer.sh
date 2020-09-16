#!/bin/bash

usePyVer='3.6'

sudo apt-get upgrade && sudo apt-get update

sudo apt-get install vim dos2unix libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6

LatestAnaconda=`curl https://repo.anaconda.com/archive/ | \
grep -i '</a>'|\
grep -i 'x86_64'|\
grep -i '.sh'|\
grep -i 'Anaconda3'|\
awk -F\" '{print $2}'|\
head -1`

wget https://repo.anaconda.com/archive/${LatestAnaconda}

echo "Please accept all default values while installing Anaconda, Thanks."

bash ./${LatestAnaconda}
echo "updating the current shell..."
source ~/.bashrc.
echo "shell has been updated"
echo "running 'conda list'"
conda list
echo "launchig python to verify Anaconda integration. If Anaconda is installed and working, the version information it displays when it starts up will include 'Anaconda'."
echo ""
echo "To exit the Python shell, enter the command quit()."
python
echo "Open Anaconda Navigator with the command 'anaconda-navigator'"
anaconda-navigator

echo "So far, so good.  Now using Anaconda to create a conda Python 3.6 env for organizing packages used in Spinning Up"
conda create -n spinningup python=${usePyVer}

echo "To use Python from the environment you just created, activate the environment with: 
conda activate spinningup"

echo "Installing OpenMPI"

sudo apt-get update && sudo apt-get install libopenmpi-dev

echo "Installing Spinning Up"

git clone https://github.com/openai/spinningup.git
cd spinningup
pip install -e .

echo "
check the install by running PPO in the LunarLander-v2 environment 
python -m spinup.run ppo --hid "[32,32]" --env LunarLander-v2 --exp_name installtest --gamma 0.999"

echo "
watch the output:
python -m spinup.run test_policy data/installtest/installtest_s0"

echo "
plot the results
python -m spinup.run plot data/installtest/installtest_s0"


echo "this system is now in a proper state for SpinningUp (in theory)"
