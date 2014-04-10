logger = require 'debug'
debug = logger('app')
WebClient = require './Client/Web'
SocketClient = require './Client/Socket'
fs = require 'fs'
net = require 'net'
exec = require('child_process').exec

logger.enable 'app'

webClient = new WebClient

# Client
webClient.login (err, httpResponse, body) ->
    body = body.replace '"connection.info.host" : "holohotel.us",', '"connection.info.host" : "localhost",'
    fs.writeFile 'client.html', body, (err) ->
        return debug('error writing client.html') if err
        debug 'client.html saved, opening...'
        
        exec 'php -S 0.0.0.0:4321' #, (err) ->
        # debug(err) if err
        exec 'open "/Applications/Google Chrome.app" http://localhost:4321/client.html', (err) ->
            return debug(err) if err
            debug 'client opened'

# Proxy
net.createServer (socket) ->
    server = net.connect 30000, 'holohotel.us', ->
        debug 'connection established'

    server.on 'data', (d) ->
        debug '[server > client]', [d.toString()]
        socket.write d

    server.on 'end', ->
        debug('closed');

    socket.on 'data', (d) ->
        debug '[client > server]', [d.toString()]
        server.write d
.listen(30000);
