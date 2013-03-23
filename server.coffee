#!/usr/bin/coffee


# === Requirements ===
express    = require 'express'
cassets    = require 'connect-assets'
stylus     = require 'stylus'
nib        = require 'nib'
redis      = require 'redis'
RedisStore = require('connect-redis')(express)


app = express()

redisClient = redis.createClient()



# === Configuration ===
app.configure ->
    app.set 'port', process.env.PORT or 8080

    app.set 'views', __dirname + '/views'
    app.set 'view engine', 'jade'

    app.set 'maxAge', 1000*60*60*24

    app.use cassets src: 'public'
    app.use express.static "#{__dirname}/public",
        maxAge: app.get 'maxAge'

    app.use express.bodyParser()
    app.use express.cookieParser()

    app.use stylus.middleware
        src: __dirname
        compile: (str, path) ->
            stylus(str)
                .set('filename', path)
                .set('compress', true)
                .use(nib())

    app.use express.session
        cookie: app.get 'maxAge'
        secret: '(y1 - y2)/(x1-x2) = Δy/Δx'
        store: new RedisStore
            client: redisClient

    app.use app.router

app.configure 'development', ->
    app.use express.favicon()
    app.use express.logger 'dev'
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true


# === Routes ===
app.get '/', (req, res) ->
    res.render ''


# === Start ===
app.listen app.get 'port'

