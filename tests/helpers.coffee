###
# =================
# TEST - Helper
# =================
# Script from https://github.com/cozy/cozy-contacts/blob/eacd17cb0e420a95d2f96a21474201f84d7c52e9/tests/helpers.coffee
# by @aenario, @jsilvestre, @frankrousseau
###

path = require 'path'
os = require 'os'
fs = require 'fs'
mkdirp = require 'mkdirp'
rimraf = require 'rimraf'
fixtures = require 'cozy-fixtures'
if process.env.USE_JS
    prefix = path.join __dirname, '../build/'
else
    prefix = path.join __dirname, '../'

Client = require('request-json').JsonClient
ds = require 'cozydb/lib/utils/client'

Sensor = require "#{prefix}server/models/sensor"
Driver = require "#{prefix}server/models/driver"

TESTPORT = process.env.PORT or 8013
DRIVERS_DIR = __dirname + '/../server/drivers'


store = {}

module.exports =
    prefix: prefix

    startServer: (done) ->
        @timeout 100000
        option =
            host: 'localhost'
            port: TESTPORT
        start = require("#{prefix}server").start
        start option, (app, server) =>
            @server = server
            done null

    killServer: ->
        @server.close()

    clearFiles: (done) ->
        rimraf DRIVERS_DIR, done

    clearDB: (done) ->
         fixtures.resetDatabase callback: done
	
	# cleanDBWithRequests: (done) ->
 #        fixtures.resetDatabase removeAllRequests: true, callback: done

    createSensor: (data) ->
        (done) ->
            baseSensor = new Sensor(data)
            Sensor.create baseSensor, (err, sensor) ->
                store.sensor = sensor
                done err

    createDriver: (filename) ->
        (done) ->

            mkdirp DRIVERS_DIR, (err) ->
                return done err if err

                # Copy file so the original doesn't get deleted during the creation:
                extName = path.basename(filename) 
                fs.createReadStream(filename).pipe(fs.createWriteStream(os.tmpdir() + "/" + extName))
                
                fileData =
                    path: os.tmpdir() + "/" + extName

                Driver.create fileData, (err, driver) ->
                    store.driver = driver
                    done err

    getInStore: (el) ->
        return store[el]

    makeTestClient: (done) ->
        old = new Client "http://localhost:#{TESTPORT}/"
        old.headers['accept'] = 'application/json'

        store = this # this will be the common scope of tests

        callbackFactory = (done) -> (error, response, body) ->
            return done error if error
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
                c = old.headers['Content-Type']
                old.headers['Content-Type'] = 'multipart/form-data;'
                old.sendFile url, path, callbackFactory(done)
                old.headers['Content-Type'] =  c
            saveFile: (url, path, done) ->
                old.saveFile url, path, callbackFactory(done)

        done()
