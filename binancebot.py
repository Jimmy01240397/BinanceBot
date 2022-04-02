import json
import yaml
import threading
import time
import uuid

from telegram.ext import Updater 
from telegram.ext import CommandHandler, CallbackQueryHandler 
from telegram.ext import MessageHandler, Filters

from binance.client import Client

with open('config.yaml', 'r') as f:
        config = yaml.load(f, Loader=yaml.FullLoader)

updater = Updater(token=config['TelegramBotApi'].strip(), use_context=False)
dispatcher = updater.dispatcher
client = Client(config['BinanceApiKey'], config['BinanceApiSecret'])

lock = threading.Lock()
jobs = {'notifi': {}, 'setorder': {}}
messageid = {}


def help(bot, update):
    update.message.reply_text('/notifi <symbol> <price>')

def showjobs(bot, update):
    update.message.reply_text('```\n' + json.dumps(jobs, indent=2) + '\n```', parse_mode='Markdown')

def clearjobs(bot, update):
    lock.acquire()
    alljobs = list(jobs.keys())
    for job in alljobs:
        jobs[job].clear()
    messageid.clear()
    lock.release()
    update.message.reply_text('clear jobs success')

def clearnotifis(bot, update):
    lock.acquire()
    allsymbols=list(jobs['notifi'].keys())
    for symbol in allsymbols:
        alluuids = list(jobs['notifi'][symbol].keys())
        for uuid in alluuids:
            del messageid[uuid]
    jobs['notifi'].clear()
    lock.release()
    update.message.reply_text('clear jobs success')

def clearsetorders(bot, update):
    pass

def removejob(bot, update, args):
    lock.acquire()
    uuid = str(args[0])
    for job in alljobs:
        allsymbols=list(jobs[job].keys())
        for symbol in allsymbols:
            if jobs[job][symbol].has_key(uuid):
                del jobs[job][symbol][uuid]

    del messageid[uuid]
    lock.release()
    update.message.reply_text('remove job success')
    pass

def notifi(bot, update, args):
    locked = False
    try:
        symbol = str(args[0]).upper()
        price = float(args[1])
        nowprice = float(client.futures_symbol_ticker(symbol=symbol)['price'])
        if nowprice == price:
            update.message.reply_text('now ' + symbol + ' price is: ' + price)
            return
        lock.acquire()
        locked = True
        larger = price > nowprice
        if not jobs['notifi'].__contains__(symbol):
            jobs['notifi'][symbol] = {}
        nowuuid = str(uuid.uuid4())
        messageid[nowuuid] = update.message
        jobs['notifi'][symbol][nowuuid]({'price':price,'larger':larger})
        update.message.reply_text('setup success, job uuid is: ' + nowuuid + ', notifi price is: ' + str(price) + ', now price is: ' + str(nowprice))
        lock.release()
        locked = False
    except:
        if locked:
            lock.release()
            locked = False
        update.message.reply_text('bad args...')


def runnotifi():
    lock.acquire()
    allsymbols=list(jobs['notifi'].keys())
    for symbol in allsymbols:
        nowprice = float(client.futures_symbol_ticker(symbol=symbol)['price'])
        alluuids = list(jobs['notifi'][symbol].keys())
        for uuid in alluuids:
            data = jobs['notifi'][symbol][uuid]
            if (data['price'] <= nowprice and data['larger']) or (data['price'] >= nowprice and not data['larger']):
                messageid[uuid].reply_text('now ' + symbol + ' price is: ' + str(nowprice))
                del messageid[uuid]
                del jobs['notifi'][symbol][uuid]
    lock.release()
def run():
    while True:
        runnotifi()
        time.sleep(0.01)

def main():
    t = threading.Thread(target = run)
    t.start()
    dispatcher.add_handler(CommandHandler("help", help))
    dispatcher.add_handler(CommandHandler("showjobs", showjobs))
    dispatcher.add_handler(CommandHandler("clearjobs", clearjobs))
    dispatcher.add_handler(CommandHandler("clearnotifis", clearnotifis))
    dispatcher.add_handler(CommandHandler("clearsetorders", clearsetorders))
    dispatcher.add_handler(CommandHandler("removejob", removejob, pass_args=True))
    dispatcher.add_handler(CommandHandler("notifi", notifi, pass_args=True))
    updater.start_polling()
    updater.idle()

if __name__ == '__main__':
    main()




#client.futures_create_order(symbol='BTCUSDT',side='BUY',positionSide='LONG',type='TAKE_PROFIT',quantity='0.05',price='10000',stopPrice='10000',priceProtect=True)
#print(json.dumps(client.futures_get_open_orders(symbol='BTCUSDT')))
#print(json.dumps(client.futures_symbol_ticker(symbol='BTCUSDT')))


#print(json.dumps(client.futures_coin_historical_trades(symbol='BTCUSD_PERP')))
#print(json.dumps(client.futures_coin_exchange_info()))
#print(json.dumps(client.futures_coin_order_book()))



#print(json.dumps(client.futures_coin_account_balance()))
#print(json.dumps(client.futures_account_balance()))
#print(json.dumps(client.futures_account()))

#print(json.dumps(client.get_symbol_ticker(symbol='BTCUSDT')))

#print(json.dumps(dir(client)))

#[a for a in client.get_all_tickers()]


#print(client.get_account())

#print(json.dumps(client.get_all_tickers()))
#print(client.get_all_tickers())
