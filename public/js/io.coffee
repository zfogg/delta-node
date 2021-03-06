Delta.namespace "IO", (IO, top) ->
    IO.io = io = window.io.connect()

    IO.emit = io.emit.bind io

    IO.session =
        set: (key, value) ->
            io.emit 'session:set', {key, value}
        get: (key, cb) ->
            io.emit 'session:get', key, (value) -> cb value

    IO.redis =
        set: (key, value) ->
            io.emit 'redis:set', {key, value}
        get: (key, cb) ->
            io.emit 'redis:get', key, (value) -> cb value

