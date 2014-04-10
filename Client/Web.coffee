debug = require('debug')('client:web')
request = require 'request'
config = require '../config'
Events = require './Events'

request = request.defaults
    jar: true

module.exports = class WebClient
    callback: null

    login: (cb) ->
        @callback = cb || @callback;

        debug 'logging in with: %s', config.user.username
        login = request.post(config.hotel.url + 'frontpage', @onLogin).form()
        login.append 'login-username', config.user.username
        login.append 'login-password', config.user.password

    # Callbacks
    onLogin: (err, httpResponse, body) =>
        throw Error(err) if err

        debug 'logged in, fetching SSO token'
        request config.hotel.url + 'client', @onTokenFetch

    onTokenFetch: (err, httpResponse, body) =>
        config.user.token = body.match(/"sso.ticket" : "(.+?)"/i)?[1]
        throw Error('Token not found') if not config.user.token

        debug 'token: %s', config.user.token

        Events.emit 'client:web:logged-in'
        @callback(err, httpResponse, body) if typeof @callback is 'function'
