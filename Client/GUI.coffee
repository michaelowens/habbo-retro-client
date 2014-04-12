nc = require 'ncurses'
widgets = require 'ncurses/lib/widgets'

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

        @win.on 'inputChar', (c, i) =>
            {cury, curx} = @win
            if i is nc.keys.LEFT and curx > 0
                @win.cursor @win.height - 1, curx - 1
            else if i is nc.keys.RIGHT and curx < @win.inbuffer.length
                @win.cursor @win.height - 1, curx + 1
            else if i is nc.keys.NEWLINE and @win.inbuffer
                return if not @win.inbuffer.length
                command = @win.inbuffer

                customColor = @colors.custom if nc.hasColors
                @appendLine command, customColor

                @headers.status.msg = 'Status: running'

                if command is 'status'
                    widgets.MessageBox 'Everything is probably broken because of this'

                @win.inbuffer = ''
                @win.cursor @win.height - 1, 0
                @win.clrtoeol()
            else if (i is nc.keys.BACKSPACE or i is 127) and curx > 0 # nc.keys.BACKSPACE = 263, mac gives 127 ??
                @win.inbuffer = @win.inbuffer.substring(0, curx - 1) + @win.inbuffer.substring(curx)
                @win.delch @win.height - 1, curx - 1
            else if i is nc.keys.DEL and curx < @win.inbuffer.length
                @win.inbuffer = @win.inbuffer.substring(0, curx) + @win.inbuffer.substring(curx + 1)
                @win.delch @win.height - 1, curx
            else if i >= 32 and i <= 126 and curx < @win.width-1
                @win.inbuffer = @win.inbuffer.slice(0, curx) + c + @win.inbuffer.slice(curx)
                if curx < @win.inbuffer.length
                    @win.insch i
                    @win.cursor @win.height - 1, curx + 1
                else
                    @win.addch i

            @headers.status.msg = 'Status: typing' if @win.inbuffer

            # setHeaders i + ' === ' + nc.keys.DEL
            @win.refresh()

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
