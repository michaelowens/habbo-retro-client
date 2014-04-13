Events = require '../Events'
Encoding = require '../../Habbo/Encoding'
Habbo = require '../../Habbo/Users/Habbo'
GUI = require '../GUI'
Input = require '../Input'

module.exports = class Messenger
    lastUser: null

    constructor: (@client) ->
        Events.on 'packet:header:3', @onLogin
        Events.on 'packet:header:12', @onFriendsList
        Events.on 'packet:header:134', @onMessage
        Events.on 'input:command:reply', @onReply
        Events.on 'input:command:r', @onReply
        Events.on 'input:command:msg', @onMsg

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
        GUI.appendLine 'buddies loaded: ' + @client.messenger.length

    onMessage: (data) =>
        @lastUser = @client.messenger.findWhere userid: data.readInt()
        message = data.readString()
        GUI.appendLine '[' + @lastUser.get('username') + '] ' + message

    send: (user, message) ->
        return GUI.appendLine 'No user to send a message to' if not user
        return GUI.appendLine 'No message to send' if not message
        useridb64 = Encoding.Wire.encode user.get 'userid'
        msglengthb64 = Encoding.Base64.encode message.length
        @client.send '@a' + useridb64 + msglengthb64 + message

    onReply: (msg) =>
        return GUI.appendLine 'No user to reply to' if not @lastUser or not msg
        @send @lastUser, msg

    onMsg: (msg) =>
        [username, msg] = Input.splitCommand msg
        user = @client.messenger.findWhere username: username
        @send user, msg
