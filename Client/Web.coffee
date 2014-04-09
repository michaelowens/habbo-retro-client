debug = require('debug')('client:web')
request = require 'request'
config = require '../config'

request = request.defaults
    jar: true

module.exports = class WebClient
    callback: null

    login: (cb) ->
        @callback = cb || @callback;

        debug 'logging in with: %s', config.user.username
        login = request.post(config.url + 'frontpage', @onLogin).form()
        login.append 'login-username', config.user.username
        login.append 'login-password', config.user.password

    # Callbacks
    onLogin: (err, httpResponse, body) =>
        throw Error(err) if err

        debug 'logged in, fetching SSO token'
        request config.url + 'client', @onTokenFetch

    onTokenFetch: (err, httpResponse, body) =>
        config.user.token = body.match(/"sso.ticket" : "(.+?)"/i)?[1]
        throw Error('Token not found') if not config.user.token

        debug 'token: %s', config.user.token

        @callback(err, httpResponse, body) if typeof @callback is 'function'
