Backbone = require 'backbone'
Habbo = require './Habbo'

module.exports = Messenger = Backbone.Collection.extend
    model: Habbo
