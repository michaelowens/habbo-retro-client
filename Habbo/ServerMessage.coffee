Encoding = require './Encoding'
Events = require '../Client/Events'
GUI = require '../Client/GUI'

module.exports = class ServerMessage
    packet: ''
    header: ''
    msg: ''
    pointer: 0

    constructor: (@packet) ->
        @header = Encoding.Base64.decode @packet[0...2]
        @msg = @packet.substr 2

    reset: ->
        @pointer = 0

    skip: (n = 1, isString = false) ->
        n = 1 unless n > 1
        while n--
            if isString
                @readString()
            else
                @readInt()
        this

    readInt: ->
        number = Encoding.Wire.decode @msg.substr @pointer, Encoding.Wire.MAX_BYTES
        @pointer += Encoding.Wire.encode(number).length
        number

    readString: ->
        str = ''
        lastChar = ''

        while lastChar isnt String.fromCharCode(2) && @pointer < @msg.length
            str += lastChar = @msg.substr @pointer++, 1

        str.substr 0, str.length - 1
