debug =
    client: require('debug')('client:socket')
    incoming: require('debug')('client:socket:incoming')
    outgoing: require('debug')('client:socket:outgoing')
net = require 'net'
config = require '../config'
Encoding = require '../Habbo/Encoding'
ServerMessage = require '../Habbo/ServerMessage'
Habbo = require '../Habbo/Users/Habbo'
Events = require './Events'

module.exports = class SocketClient
    socket: null
    user: null
    messenger: null
    modules: {}
    plugins: {}
    modulePaths: ['../Habbo/Login']

    constructor: ->
        debug.client 'Loading modules'
        @loadModules()

        debug.client 'Loading plugins (not really)'
        @loadPlugins()

    loadModules: ->
        for path in @modulePaths
            [parts, ..., name] = path.split '/'
            @modules[name] = new (require path)(this)

    # todo: build this
    loadPlugins: ->

    connect: ->
        debug.client 'connecting with server: %s:%d', config.hotel.host, config.hotel.port

        @user = new Habbo
            username: config.user.username
        @messenger = @user.get 'messenger'

        @socket = net.connect config.hotel.port, config.hotel.host, @onConnect
        @socket.on 'data', @onData
        @socket.on 'end', @onDisconnect

    send: (data) ->
        data = '@' + Encoding.Base64.encode(data) + data
        debug.outgoing [data]
        @socket.write data

    # Callbacks
    onConnect: =>
        debug.client 'client connected'
        Events.emit 'client:socket:connected'

    onDisconnect: =>
        debug.client 'client disconnected'

    onData: (buffer) =>
        data = new ServerMessage buffer.toString()
        debug.incoming data.packet,
            header: data.header

        # if data.header is 3
        #     debug.client 'authentication successful'
        #     @send Encoding.Base64.encode 12

        # ping - pong
        if data.header is 50
            @send Encoding.Base64.encode 196

        # friends
        if data.header is 12
            buddies = []
            data.skip 5
            count = data.readInt()
            for i in [0...count]
                buddies.push new Habbo
                    userid: data.readInt()
                    username: data.readString()
                    online: data.skip().readInt()
                    inRoom: data.readInt()
                    figure: data.readString()
                    motto: data.skip().readString()
                    lastOnline: data.readString()
                data.skip 2 # final char codes
            @messenger.add buddies
            debug.client 'buddies loaded: %d', @messenger.length
