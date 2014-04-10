config = require '../../config'
debug = require('debug')('module:login')
Events = require '../Events'
Encoding = require '../../Habbo/Encoding'
Habbo = require '../../Habbo/Users/Habbo'

module.exports = class Login
    constructor: (@client) ->
        Events.on 'client:socket:connected', @onConnected
        Events.on 'packet:header-3', @onLogin
        Events.on 'packet:header-5', @onCredentials

    onConnected: =>
        debug 'Connected!'
        @client.send 'F_' + Encoding.Base64.encode(config.user.token.length) + config.user.token

    onLogin: =>
        debug 'Logged in!'
        @client.send Encoding.Base64.encode 7 # own credentials

    onCredentials: (data) =>
        @client.user = new Habbo
            username: data.skip(1, true).readString()
            figure: data.readString()
            gender: data.readString()
            motto: data.readString()

        @client.messenger = @client.user.get 'messenger'
