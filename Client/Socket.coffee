debug =
    socket: require('debug')('client:socket')
    incoming: require('debug')('client:socket:incoming')
    outgoing: require('debug')('client:socket:outgoing')
net = require 'net'
config = require '../config'
Encoding = require '../Habbo/Encoding'
ServerMessage = require '../Habbo/ServerMessage'

module.exports = class SocketClient
    socket: null,
    user: null,
    messenger: null,

    login: ->
        debug.socket 'connecting with server: %s:%d', config.host, config.port

        @socket = net.connect config.port, config.host, @onConnect
        @socket.on 'data', @onData
        @socket.on 'end', @onDisconnect

    send: (data) ->
        data = '@' + Encoding.Base64.encode(data) + data
        debug.outgoing [data]
        @socket.write data

    # Callbacks
    onConnect: =>
        debug.socket 'client connected'
        @send 'F_' + Encoding.Base64.encode(config.user.token.length) + config.user.token

    onDisconnect: =>
        debug.socket 'client disconnected'

    onData: (buffer) =>
        data = new ServerMessage buffer.toString()
        debug.incoming data.packet,
            header: data.header

        if data.header is 3
            debug.socket 'authentication successful'
            @send Encoding.Base64.encode 12

        # ping - pong
        if data.header is 50
            @send Encoding.Base64.encode 196

        # friends
        if data.header is 12
            buddies = []
            data.skip 5
            count = data.readInt()
            for i in [0...count]
                buddies.push
                    userid: data.readInt()
                    username: data.readString()
                    online: data.skip().readInt()
                    inRoom: data.readInt()
                    figure: data.readString()
                    motto: data.skip().readString()
                    lastOnline: data.readString()
                data.skip 2 # final char codes
            # @messenger.add buddies
            debug.socket 'buddies loaded: %d', count
