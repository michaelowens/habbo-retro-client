Events = require '../Events'
Encoding = require '../../Habbo/Encoding'

module.exports = class Core
    constructor: (@client) -> Events.on 'packet:header-50', @onPing
    onPing: (data) => @client.send Encoding.Base64.encode 196
