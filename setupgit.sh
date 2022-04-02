#!/bin/bash
cd /tmp

rm -r BinanceBot

git clone https://github.com/jimmy01240397/BinanceBot

cd BinanceBot

dirname=binancebot

for a in $(ls -a)
do
    if [ "$a" != "." ] && [ "$a" != ".." ] && [ "$a" != ".git" ] && [ "$a" != "README.md" ] && [ "$a" != "install.sh" ] && [ "$a" != "remove.sh" ] && [ "$a" != "setupgit.sh" ] && [ "$a" != "config.yaml" ]
    then
        rm -rf $a
    fi
done

for a in $(ls -a /etc/$dirname)
do
    if [ "$a" != "." ] && [ "$a" != ".." ] && [ "$a" != "config.yaml" ] && [ "$(cat /etc/$dirname/.gitignore | sed 's/\/.*//g' | sed '/^!.*/d' | grep -P "^$(echo "$a" | sed 's/\./\\\./g')$")" == "" ]
    then
        sudo cp -r /etc/$dirname/$a $a
    fi
done

sudo cp /etc/systemd/system/binancebot.service binancebot.service
