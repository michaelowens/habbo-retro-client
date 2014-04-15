module.exports = Encoding =
    ###
    Base64 encoding
    ###
    Base64:
        encode: (value, length = 2) ->
            length = length || 2 if typeof value is 'number'
            value = value.length unless typeof value is 'number'

            stack = ''
            for x in [1..length]
                offset = 6 * (length - x)
                val = 64 + (value >> offset & 0x3f)
                stack += String.fromCharCode val

            return stack;

        decode: (value) ->
            values = value.split ''
            val = []
            result = 0
            y = 0

            values.forEach (v) ->
                val.push v.charCodeAt 0

            for x in [(val.length - 1)..0]
                tmp = val[x] - 64
                if y > 0
                    tmp *= Math.pow 64, y

                result += tmp
                y++

            return result

    ###
    Wire encoding
    ###
    Wire:
        MAX_BYTES: 6
        
        encode: (number) ->
            str = []
            i = 1
            absolute = Math.abs(number) >> 2

            while absolute > 0
                str[i] = String.fromCharCode 64 | (absolute & 63)
                i++
                absolute >>= 6

            str[0] = String.fromCharCode 64 | i << 3 | (number <= 0 ? 1 : 0) << 2 | (Math.abs(number) & 3)
            return str.join ''

        decode: (str) ->
            ret = 0;
            ctrl = (str.charCodeAt(0) - 64) >> 2
            bytes = (ctrl >> 1) - 1

            while bytes > 0
                ret <<= 6
                ret += str.charCodeAt(bytes) & 63
                bytes--
            
            ret = (ret << 2) + ((str.charCodeAt(0) - 64) & 3)
            if ctrl & 1
                ret *= -1
            
            return ret
