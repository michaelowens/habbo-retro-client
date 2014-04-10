debug = require('debug')('module:messenger')
Events = require '../Events'
Encoding = require '../../Habbo/Encoding'
Habbo = require '../../Habbo/Users/Habbo'

module.exports = class Messenger
    constructor: (@client) ->
        Events.on 'packet:header-3', @onLogin
        Events.on 'packet:header-12', @onFriendsList
        Events.on 'packet:header-134', @onMessage

    onLogin: =>
        @client.send Encoding.Base64.encode 12 # request friends

    onFriendsList: (data) =>
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
        @client.messenger.add buddies
        debug 'buddies loaded: %d', @client.messenger.length

    onMessage: (data) =>
        user = @client.messenger.findWhere userid: data.readInt()
        message = data.readString()

        debug 'Received message', user.get('username') + ':', message

        # @@J@aYRG@Chey

        # header 33
        useridb64 = Encoding.Wire.encode user.get 'userid'
        msglengthb64 = Encoding.Base64.encode message.length
        @client.send '@a' + useridb64 + msglengthb64 + message
