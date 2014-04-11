WebClient = require './Client/Web'
SocketClient = require './Client/Socket'
GUI = require './Client/GUI'

logo = """ _    _  ____  _      ____
 | |__| |/ __ \\| |    / __ \\
 |  __  | |__| | |___| |__| |
 |_|  |_|\\____/|_____|\\____/"""

GUI.init()
GUI.headers =
    title:
        msg: logo
    status:
        msg: 'Status: running'
        style:
            pos: 'right'
    memory:
        msg: 'Memory:'
        style:
            pos: 'right'
        posx: 1
GUI.drawHeaders()

# i = 1
looper = ->
    # GUI.appendLine 'test' + i++
    mem = process.memoryUsage().rss
    GUI.headers.memory.msg = 'Memory: ' + (mem / 1024 / 1024).toFixed(2) + 'M'

    # fs.appendFile 'memory.txt', mem + ','

    GUI.drawHeaders()
    l = setTimeout ->
        looper()
    , 1000

looper()

# process.exit()

# console.log '  ----------------------'
# console.log '  | Habbo Retro Client |'
# console.log '  ----------------------'

# if not debug.enabled
#     console.log 'Modify your DEBUG environment variable to see all logs'

# prompt.start()

# prompt.get 'help', (err, result) ->
#     console.log err, result

webClient = new WebClient
socketClient = new SocketClient

webClient.login ->
    socketClient.connect()
