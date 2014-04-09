debug = require('debug')('app')
WebClient = require './Client/Web'
SocketClient = require './Client/Socket'

debug '', '----------------------'
debug '', '| Habbo Retro Client |'
debug '', '----------------------'

webClient = new WebClient
socketClient = new SocketClient

webClient.login ->
    socketClient.login()
