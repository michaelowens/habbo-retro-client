nc = require 'ncurses'
Input = require './Input'

module.exports = class GUI
    @headers: {}
    @colors: [1..7]
        # custom: nc.colorPair 1 # black
        # custom: nc.colorPair 2 # red
        # custom: nc.colorPair 3 # green
        # custom: nc.colorPair 4 # yellow
        # custom: nc.colorPair 5 # blue
        # custom: nc.colorPair 6 # purple
        # custom: nc.colorPair 7 # turquoise

    @init: ->
        @win = new nc.Window
        @win.scrollok true
        @win.hline 4, 0, @win.width
        @win.hline @win.height - 2, 0, @win.width
        @win.setscrreg 5, @win.height - 3 # Leave space at the top for the header
        @win.cursor @win.height - 1, 0
        @win.refresh()
        @win.inbuffer = ''

        @win.on 'inputChar', Input.onInput

    @draw: ->
        @win.refresh()

    @appendLine = (message, attrs) ->
        {cury, curx} = @win
        @win.scroll 1
        @win.cursor @win.height - 3, 0
        @win.print '[now] '
        if attrs
            @win.attron attrs
        @win.print message
        if attrs
            @win.attroff attrs
        @win.cursor cury, curx
        @win.refresh()

    @updateHeader = (header, style, clear = true, posy = 0, posx = 0) ->
        {cury, curx} = @win
        style = style || {}
        header = '' + header
        @win.cursor posy, posx
        @win.clrtoeol() if clear
        if style.attrs
            @win.attron style.attrs
        if header.length > 0
            if style.pos is 'center'
                @win.centertext posx, header
            else if style.pos is 'right'
                @win.addstr posx, @win.width - (Math.min(header.length, @win.width)), header, @win.width
            else
                @win.addstr header, @win.width
        if style.attrs
            @win.attroff style.attrs
        @win.cursor cury, curx
        @win.refresh()

    @updateHeaders = (headers, clear = true) ->
        {curx, cury} = @win
        @win.cursor 0, 0
        @win.clrtoeol() if clear
        @win.cursor cury, curx
        @updateHeader header.msg, header.style, false, header.posy, header.posx for k, header of headers

    @drawHeaders = ->
        @updateHeaders @headers
