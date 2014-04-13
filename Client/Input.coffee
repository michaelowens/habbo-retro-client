nc = require 'ncurses'
widgets = require 'ncurses/lib/widgets'

module.exports = class Input
    @setClient: (@client) ->
    @setGUI: (@GUI) ->
    @onInput: (c, i) =>
        {cury, curx} = @GUI.win
        if i is nc.keys.LEFT and curx > 0
            @GUI.win.cursor @GUI.win.height - 1, curx - 1
        else if i is nc.keys.RIGHT and curx < @GUI.win.inbuffer.length
            @GUI.win.cursor @GUI.win.height - 1, curx + 1
        else if i is nc.keys.NEWLINE and @GUI.win.inbuffer
            return if not @GUI.win.inbuffer.length
            command = @GUI.win.inbuffer

            customColor = @GUI.colors.custom if nc.hasColors
            @GUI.appendLine command, customColor

            @GUI.headers.status.msg = 'Status: running'

            if command is 'status'
                widgets.MessageBox 'Everything is probably broken because of this'

            @GUI.win.inbuffer = ''
            @GUI.win.cursor @GUI.win.height - 1, 0
            @GUI.win.clrtoeol()
        else if (i is nc.keys.BACKSPACE or i is 127) and curx > 0 # nc.keys.BACKSPACE = 263, mac gives 127 ??
            @GUI.win.inbuffer = @GUI.win.inbuffer.substring(0, curx - 1) + @GUI.win.inbuffer.substring(curx)
            @GUI.win.delch @GUI.win.height - 1, curx - 1
        else if i is nc.keys.DEL and curx < @GUI.win.inbuffer.length
            @GUI.win.inbuffer = @GUI.win.inbuffer.substring(0, curx) + @GUI.win.inbuffer.substring(curx + 1)
            @GUI.win.delch @GUI.win.height - 1, curx
        else if i >= 32 and i <= 126 and curx < @GUI.win.width-1
            @GUI.win.inbuffer = @GUI.win.inbuffer.slice(0, curx) + c + @GUI.win.inbuffer.slice(curx)
            if curx < @GUI.win.inbuffer.length
                @GUI.win.insch i
                @GUI.win.cursor @GUI.win.height - 1, curx + 1
            else
                @GUI.win.addch i

        @GUI.headers.status.msg = 'Status: typing' if @GUI.win.inbuffer

        # setHeaders i + ' === ' + nc.keys.DEL
        @GUI.win.refresh()