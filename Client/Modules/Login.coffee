config = require '../../config'
debug = require('debug')('module:login')
Events = require '../Events'
Encoding = require '../../Habbo/Encoding'

module.exports = class Login
    constructor: (@client) ->
        Events.on 'client:socket:connected', @onConnected
        Events.on 'packet:header-3', @onLogin

    onConnected: =>
        debug 'Connected!'
        @client.send 'F_' + Encoding.Base64.encode(config.user.token.length) + config.user.token

    onLogin: =>
        debug 'Logged in!'
        @client.send Encoding.Base64.encode 12
