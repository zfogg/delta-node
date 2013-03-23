#!/usr/bin/coffee


# === Requirements ===
express    = require 'express'
cassets    = require 'connect-assets'

stylus     = require 'stylus'
uglify     = require 'express-uglify'
nib        = require 'nib'

redis      = require 'redis'
RedisStore = require('connect-redis')(express)

util       = require 'util'

app = express()

redisClient = redis.createClient()

log = (x) ->
    console.log util.inspect x,
        colors: true
        depth: 0


# === Configuration ===
app.configure ->
    app.set 'port', process.env.PORT or 8080

    app.set 'views', __dirname + '/views'
    app.set 'view engine', 'jade'

    app.set 'maxAge', 1000*60*60*24
    app.set 'assets', "#{__dirname}/public"
    app.set 'secret', '(y1 - y2)/(x1-x2) = Δy/Δx'

    app.use cassets src: 'public'
    app.use express.static (app.get 'assets'),
        maxAge: app.get 'maxAge'

    app.use express.bodyParser()
    app.use express.cookieParser app.get 'secret'

    app.use stylus.middleware
        src: __dirname
        compile: (str, path) ->
            stylus(str)
                .set('filename', path)
                .set('compress', true)
                .use(nib())

    app.use express.session
        cookie: maxAge: app.get 'maxAge'
        secret: app.get 'secret'
        store: new RedisStore
            client: redisClient

    # Update a session's path on each request.
    app.use (req, res, next) ->
        req.session?.path = req.path
        next()

    # Don't allow trailing slashes.
    app.use (req, res, next) ->
        # Trailing slash plus query string.
        if /^.+\/\?.*$/.test req.url
            res.redirect "#{(req.path.slice 0, -1)}?#{req._parsedUrl.query}"
        # Trailing slash.
        else if /^.+\/$/.test req.path
            res.redirect req.path.slice 0, -1
        next()

    app.use app.router

app.configure 'development', ->
    app.use express.favicon()
    app.use express.logger 'dev'
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true

app.configure 'production', ->


# === Routes ===
app.get '*', (req, res) ->
    res.render ''


# === Start ===
app.listen app.get 'port'

