debug = require('debug')('app')
WebClient = require './Client/Web'
SocketClient = require './Client/Socket'

console.log '  ----------------------'
console.log '  | Habbo Retro Client |'
console.log '  ----------------------'

if not debug.enabled
    console.log 'Modify your DEBUG environment variable to see all logs'

webClient = new WebClient
socketClient = new SocketClient

webClient.login ->
    socketClient.connect()
