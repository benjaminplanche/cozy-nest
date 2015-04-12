###
# =================
# TEST - Helper
# =================
# Script from https://github.com/cozy/cozy-contacts/blob/eacd17cb0e420a95d2f96a21474201f84d7c52e9/tests/helpers.coffee
# by @aenario, @jsilvestre, @frankrousseau
###

path = require 'path'
fixtures = require 'cozy-fixtures'
if process.env.USE_JS
    prefix = path.join __dirname, '../build/'
else
    prefix = path.join __dirname, '../'

Client = require('request-json').JsonClient
ds = require 'cozydb/lib/utils/client'

Sensor = require "#{prefix}server/models/sensor"

TESTPORT = process.env.PORT or 8013

module.exports =
    prefix: prefix

    startServer: (done) ->
        @timeout 6000
        option =
            host: 'localhost'
            port: TESTPORT
        start = require("#{prefix}server").start
        start option, (app, server) =>
            console.log('APP: ' + app)
            console.log('SERVER: ' + server)
            @server = server
            done err

    killServer: ->
        @server.close()

    clearDB: (done) ->
         fixtures.resetDatabase callback: done
	
	# cleanDBWithRequests: (done) ->
 #        fixtures.resetDatabase removeAllRequests: true, callback: done

    createSensor: (data) ->
        (done) ->
            console.log 'CREATING SENSOR'
            baseSensor = new Sensor(data)
            Sensor.create baseSensor, (err, sensor) =>
                console.log 'CREATED SENSOR'
                @sensor = sensor
                done err

    makeTestClient: (done) ->
        old = new Client "http://localhost:#{TESTPORT}/"
        old.headers['accept'] = 'application/json'

        store = this # this will be the common scope of tests

        callbackFactory = (done) -> (error, response, body) =>
            return done error if error
            console.log("ERROR: " + error)
            console.log("RESPONSE: " + response)
            console.log("BODY: " + body)
            store.response = response
            store.body = body
            done()

        clean = ->
            store.response = null
            store.body = null

        store.client =
            get: (url, done, parse) ->
                clean()
                old.get url, callbackFactory(done), parse
            post: (url, data, done) ->
                clean()
                old.post url, data, callbackFactory(done)
            put: (url, data, done) ->
                clean()
                old.put url, data, callbackFactory(done)
            del: (url, done) ->
                clean()
                old.del url, callbackFactory(done)
            sendFile: (url, path, done) ->
                old.sendFile url, path, callbackFactory(done)
            saveFile: (url, path, done) ->
                old.saveFile url, path, callbackFactory(done)

        done()
