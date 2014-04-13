Events = require '../Events'
Encoding = require '../../Habbo/Encoding'
# nc = require 'ncurses'
widgets = require 'ncurses/lib/widgets'

module.exports = class Core
    constructor: (@client) ->
        Events.on 'packet:header:50', @onPing
        Events.on 'input:command:help', @onHelp

    onPing: (data) => @client.send Encoding.Base64.encode 196

    onHelp: (cmd) =>
        helpMsg = """help

msg <user> <msg>  Send a message
r <msg>           Reply to last received message
reply <msg>
        """
        widgets.MessageBox helpMsg,
            textAlign: 'left'
            buttons: ['OK']

