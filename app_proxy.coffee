# logger = require 'debug'
# debug = logger('app')
WebClient = require './Client/Web'
SocketClient = require './Client/Socket'
fs = require 'fs'
net = require 'net'
exec = require('child_process').exec
GUI = require './Client/GUI'
Input = require './Client/Input'

logo = """ _    _  ____  _      ____
 | |__| |/ __ \\| |    / __ \\
 |  __  | |__| | |___| |__| |
 |_|  |_|\\____/|_____|\\____/"""

GUI.init()
GUI.headers =
    title:
        msg: logo
GUI.drawHeaders()

# i = 1
looper = ->
    GUI.drawHeaders()
    l = setTimeout ->
        looper()
    , 1000

looper()

webClient = new WebClient

Input.setGUI GUI

# Client
webClient.login (err, httpResponse, body) ->
    body = body.replace '"connection.info.host" : "holohotel.us",', '"connection.info.host" : "localhost",'
    fs.writeFile 'client.html', body, (err) ->
        return GUI.appendLine('error writing client.html') if err
        GUI.appendLine 'client.html saved, opening...'
        
        exec 'php -S 0.0.0.0:4321' #, (err) ->
        # GUI.appendLine(err) if err
        exec 'open "/Applications/Google Chrome.app" http://localhost:4321/client.html', (err) ->
            return GUI.appendLine(err) if err
            GUI.appendLine 'client opened'

# Proxy
net.createServer (socket) ->
    server = net.connect 30000, 'holohotel.us', ->
        GUI.appendLine 'connection established'

    server.on 'data', (d) ->
        GUI.appendLine '[server > client] ' + d.toString()
        socket.write d

    server.on 'end', ->
        GUI.appendLine 'closed'

    socket.on 'data', (d) ->
        GUI.appendLine '[client > server] ' + d.toString()
        server.write d
.listen(30000);
