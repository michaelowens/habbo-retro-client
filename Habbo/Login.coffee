config = require '../config'
debug = require('debug')('module:login')
Events = require '../Client/Events'
Encoding = require './Encoding'

module.exports = class Login
    constructor: (@socketClient) ->
        Events.on 'client:socket:connected', @onConnected
        Events.on 'packet:header-3', @onLogin

    onConnected: =>
        debug 'Connected!'
        @socketClient.send 'F_' + Encoding.Base64.encode(config.user.token.length) + config.user.token

    onLogin: =>
        debug 'Logged in!'
        @socketClient.send Encoding.Base64.encode 12
