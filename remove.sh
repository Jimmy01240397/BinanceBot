#!/bin/bash

sudo systemctl stop binancebot.service
sudo systemctl disable binancebot.service

sudo rm /etc/systemd/system/binancebot.service

dirname=binancebot

for filename in binancebot.py binancebot.sh requirements.txt config.yaml .gitignore venv __pycache__
do
	sudo rm -r /etc/$dirname/$filename
done

if [ "`ls /etc/$dirname`" = "" ]
then
	rm -r /etc/$dirname
fi

echo ""
echo ""
echo "Binance Bot Service remove.sh complete."
