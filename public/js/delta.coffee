window.Delta = Delta =
    replaceClass: (e, oldClass, newClass) ->
        e.className = e.className.replace oldClass, newClass

    RGBA:
        toArray: (s) ->
            vals = s.match /\.?\d+\.?\d*/g
            vals[i] = parseInt vals[i], 10 for i in [0..2]
            vals[3] = parseFloat vals[3]
            vals
        toString: (xs) ->
            "rgba(#{xs.join ','})"
        fromRGB: (rgb, alpha) ->
            "rgba(#{(rgb.match /\.?\d+\.?\d*/g).join ','},#{alpha})"
        fromHex: (hex, alpha) ->
            "rgba(#{(parseInt hex[i...i+2], 16 for i in [1...7] by 2).join ', '}, #{alpha})"

    namespace: (target, name, block) ->
        [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
        top    = target
        target = target[item] or= {} for item in name.split '.'
        block target, top

    getParamByName: (name) ->
        match = (RegExp "[?&]#{name}=([^&]*)").exec window.location.search
        match && decodeURIComponent match[1].replace /\+/g, ' '

    randomID: (words) ->
        S4 = ->
            n = ((1 + Math.random())*0x10000) | 0
            n.toString(16).substring(1)
        Z.Math.sum (S4() for i in [0..words])
    uniqueID: do (cache={}) -> (words) ->
        id = Delta.randomID words
        if cache[id]
            Delta.uniqueID words
        else
            cache[id] = true
            id

