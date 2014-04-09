Backbone = require 'backbone'
Messenger = require './Messenger'

module.exports = Habbo = Backbone.Model.extend
    defaults:
        userid: -1
        username: ''
        motto: ''
        figure: ''
        online: false
        inRoom: false
        lastOnline: ''
        messenger: new Messenger()
