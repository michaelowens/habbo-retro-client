# debug =
#     client: require('debug')('client:socket')
#     incoming: require('debug')('client:socket:incoming')
#     outgoing: require('debug')('client:socket:outgoing')
net = require 'net'
config = require '../config'
Encoding = require '../Habbo/Encoding'
ServerMessage = require '../Habbo/ServerMessage'
Events = require './Events'
GUI = require './GUI'

module.exports = class SocketClient
    socket: null
    user: null
    messenger: null
    modules: {}
    plugins: {}

    constructor: ->
        # debug.client 'Loading modules'
        GUI.appendLine 'loading modules'
        @loadModules()

        # debug.client 'Loading plugins (not really)'
        GUI.appendLine 'loading plugins (not really)'
        @loadPlugins()

    loadModules: ->
        for name in config.modules
            @modules[name] = new (require './modules/' + name)(this)

    # todo: build this
    loadPlugins: ->

    connect: ->
        # debug.client 'connecting with server: %s:%d', config.hotel.host, config.hotel.port
        GUI.appendLine 'connecting with server: ' + config.hotel.host + ':' + config.hotel.port

        @socket = net.connect config.hotel.port, config.hotel.host, @onConnect
        @socket.on 'data', @onData
        @socket.on 'end', @onDisconnect

    send: (data) ->
        data = '@' + Encoding.Base64.encode(data) + data
        # debug.outgoing [data]
        GUI.appendLine data
        @socket.write data

    # Callbacks
    onConnect: =>
        # debug.client 'client connected'
        GUI.appendLine 'client connected'
        Events.emit 'client:socket:connected'

    onDisconnect: =>
        # debug.client 'client disconnected'
        GUI.appendLine 'client disconnected'

    onData: (buffer) =>
        data = new ServerMessage buffer.toString()
        # debug.incoming data.header, data.packet
        GUI.appendLine 'incoming: header-' + data.header
        Events.emit 'packet:header-' + data.header, data
