# BinanceBot
It is a Binance Bot.
## Install
1. clone this repo and cd into BinanceBot.
```bash
git clone https://github.com/Jimmy01240397/BinanceBot
cd BinanceBot
```

2. run ``install.sh``

```bash
sh install.sh
```

3. set your api key at /etc/binancebot/config.yaml.
``` bash
vi /etc/binancebot/config.yaml
```
``` yaml
BinanceApiKey: '<BinanceApiKey>'
BinanceApiSecret: '<BinanceApiSecret>'
TelegramBotApi: '<TelegramBotApi>'
TelegramUserId: '<TelegramUserId>'
```

4. enable and start your server

```bash
systemctl enable binancebot.service
systemctl start binancebot.service

#when you have change config.yaml remember to restart the server
systemctl restart binancebot.service
```

## Remove
1. cd into BinanceBot and run remove.sh
```
cd BinanceBot
sh remove.sh
```

## Usage
![image](https://user-images.githubusercontent.com/57281249/161380358-9a7a8158-5043-4757-98d2-af8ac4b0c50e.png)


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
