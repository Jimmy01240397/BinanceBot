#!/bin/bash

# stop service
sudo systemctl stop binancebot.service

# setup env
set -e
UBUNTU=false
DEBIAN=false
if [ "$(uname)" = "Linux" ]
then
	#LINUX=1
	if type apt-get
	then
		OS_ID=$(lsb_release -is)
		if [ "$OS_ID" = "Debian" ]; then
			DEBIAN=true
		else
			UBUNTU=true
		fi
	fi
fi

UBUNTU_PRE_2004=false
if $UBUNTU
then
	LSB_RELEASE=$(lsb_release -rs)
	# Mint 20.04 repsonds with 20 here so 20 instead of 20.04
	UBUNTU_PRE_2004=$(( $LSB_RELEASE<20 ))
	UBUNTU_2100=$(( $LSB_RELEASE>=21 ))
fi

if [ "$(uname)" = "Linux" ]
then
	#LINUX=1
	if [ "$UBUNTU" = "true" ] && [ "$UBUNTU_PRE_2004" = "1" ]
	then
		# Ubuntu
		echo "Installing on Ubuntu pre 20.04 LTS."
		set +e
		sudo apt-get update
		set -e
		sudo apt-get install -y python3.7-venv python3.7-distutils python3.7-dev
	elif [ "$UBUNTU" = "true" ] && [ "$UBUNTU_PRE_2004" = "0" ] && [ "$UBUNTU_2100" = "0" ]
	then
		echo "Installing on Ubuntu 20.04 LTS."
		set +e
		sudo apt-get update
		set -e
		sudo apt-get install -y python3.8-venv python3-distutils python3.8-dev
	elif [ "$UBUNTU" = "true" ] && [ "$UBUNTU_2100" = "1" ]
	then
		echo "Installing on Ubuntu 21.04 or newer."
		set +e
		sudo apt-get update
		set -e
		sudo apt-get install -y python3.9-venv python3-distutils python3.9-dev
	elif [ "$DEBIAN" = "true" ]
	then
		echo "Installing on Debian."
		set +e
		sudo apt-get update
		set -e
		sudo apt-get install -y python3-venv  python3-dev
	else
		echo "os not support"
		exit 0
	fi
else
	echo "os not support"
    exit 0
fi

sudo apt-get install -y gcc wget

find_python() {
	set +e
	unset BEST_VERSION
	for V in 39 3.9 38 3.8 37 3.7 3; do
		if which python$V >/dev/null; then
			if [ "$BEST_VERSION" = "" ]; then
				BEST_VERSION=$V
			fi
		fi
	done
	echo $BEST_VERSION
	set -e
}

if [ "$INSTALL_PYTHON_VERSION" = "" ]; then
	INSTALL_PYTHON_VERSION=$(find_python)
fi

INSTALL_PYTHON_PATH=python${INSTALL_PYTHON_VERSION:-3.7}

echo "Python version is $INSTALL_PYTHON_VERSION"

arch=$(dpkg --print-architecture)

wget https://github.com/mikefarah/yq/releases/download/v4.17.2/yq_linux_${arch}.tar.gz -O - | tar xz && sudo mv yq_linux_${arch} /usr/bin/yq


# build service dir

dirname=binancebot

set +e
sudo mkdir /etc/$dirname 2> /dev/null
set -e

for filename in binancebot.py binancebot.sh requirements.txt .gitignore
do
	sudo cp -r $filename /etc/$dirname/
done

for filename in config.yaml
do
	if [ ! -f /etc/$dirname/$filename ]
	then
		sudo cp -r $filename /etc/$dirname/
	fi
done

for filename in binancebot.sh
do
	sudo chmod +x /etc/$dirname/$filename
done
sudo cp binancebot.service /etc/systemd/system/binancebot.service

cd /etc/$dirname

$INSTALL_PYTHON_PATH -m venv venv
. ./venv/bin/activate
python -m pip install --upgrade pip
python -m pip install wheel
python -m pip install -r requirements.txt
deactivate

#sudo apt-get install -y iptables ipset net-tools

echo ""
echo ""
echo "Binance Bot Service install.sh complete."
echo "please set your api key at /etc/$dirname/config.yaml."
echo "Then you can use systemctl start binancebot.service"
echo "If you want to auto run on boot please type 'systemctl enable binancebot.service'"
