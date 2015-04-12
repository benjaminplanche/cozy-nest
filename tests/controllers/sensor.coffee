###
# =================
# Test - Sensor
# =================
# Testing the Sensors Controller.
###

fixtures = require '../fixtures/sensor'
fs = require 'fs'
helpers = require '../helpers'
expect = require('chai').expect


store = {}

describe 'Sensors Controller', ->

    before helpers.clearDB

    before helpers.startServer
    before helpers.makeTestClient
    after  helpers.killServer

    describe 'When we create a Sensor (POST /sensors) which is supported by a Driver', ->

        sensor = fixtures.supportedSensor1

        it 'should allow requests', (done) ->
            @client.post 'sensors', sensor, done

        it 'should reply with the created Sensor', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 201
            expect(@body.customId).to.equal sensor.customId
            expect(@body.name).to.equal sensor.name
            expect(@body.type).to.equal sensor.type
            expect(@body.id).to.exist
            store.sensorId = @body.id
            store.sensorName = @body.name

    describe 'When we try creating a 2nd Sensor (POST /sensors) with the same type and customId', ->

        sensor = fixtures.supportedSensor1
        sensor.name = 'Different Name' # name is not taken into account to evaluate similarity.

        it 'should allow requests', (done) ->
            @client.post 'sensors', sensor, done

        it 'should reply with the previously-created Sensor', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 202
            expect(@body.customId).to.equal sensor.customId
            expect(@body.name).to.equal store.sensorName
            expect(@body.type).to.equal sensor.type
            expect(@body.id).to.equal store.sensorId

    describe 'When we try creating a Sensor (POST /sensors) which isn\'t supported by a Driver', ->

        sensor = fixtures.unsupportedSensor

        it 'should allow requests', (done) ->
            @client.post 'sensors', sensor, done

        it 'should reply with an error', ->
            expect(@body).to.not.exist
            expect(@response.statusCode).to.equal 500
            expect(@err).to.equal 'Server error while creating sensor.'
            
    describe 'When we get a Sensor (GET /sensors/:id) which exists', ->

        id = store.sensorId

        it 'should allow requests', (done) ->
            @client.get "sensors/#{id}", done

        it 'should reply with the corresponding sensor', ->
            expect(@err).to.not.exist
            expect(@body.customId).to.equal fixtures.supportedSensor1.customId
            expect(@body.name).to.equal fixtures.supportedSensor1.sensorName
            expect(@body.type).to.equal fixtures.supportedSensor1.type
            expect(@body.id).to.equal store.sensorId

            
    describe 'When we get a Sensor (GET /sensors/:id) which doesn\'t exist', ->

        id = store.sensorId + 404 # since "store.sensorId" is the only correct ID in DB, "store.sensorId + 404" is not.

        it 'should allow requests', (done) ->
            @client.get "sensors/#{id}", done

        it 'should return an error', ->
            expect(@body).to.not.exist
            expect(@response.statusCode).to.equal 404
            expect(@err).to.equal 'Sensor not found'

    describe 'When we update a Sensor (PUT /sensors/:id) with data considered valid by its Driver', ->

        update = fixtures.validUpdateForTestSensor

        it 'should allow requests', (done) ->
            @client.put "sensors/#{store.sensorId}", update, done

        it 'should reply with the updated sensor', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.customId).to.equal fixtures.validUpdateForTestSensor.customId
            expect(@body.name).to.equal fixtures.validUpdateForTestSensor.sensorName
            expect(@body.type).to.equal fixtures.validUpdateForTestSensor.type
            expect(@body.id).to.equal store.sensorId

        it 'should have updated the Driver\'s data too', ->
            # @todo Implement test
        
    describe 'When we update a Sensor (PUT /sensors/:id) with data considered invalid by its Driver', ->

        update = fixtures.invalidUpdateForTestSensor

        it 'should allow requests', (done) ->
            @client.put "sensors/#{store.sensorId}", update, done

        it 'should return an error', ->
            expect(@body).to.not.exist
            expect(@response.statusCode).to.equal 500
            expect(@err).to.equal 'Server error while saving sensor'

        it 'when we get the targeted Sensor (GET /sensors/:id)', (done) ->
            @client.get "sensors/#{id}", done
            
        it 'should return the unmodified sensor', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.customId).to.equal fixtures.validUpdateForTestSensor.customId
            expect(@body.name).to.equal fixtures.validUpdateForTestSensor.sensorName
            expect(@body.type).to.equal fixtures.validUpdateForTestSensor.type
            expect(@body.id).to.equal store.sensorId

        it 'should not have updated the Driver\'s data too', ->
            # @todo Implement test

    describe 'When we delete a Sensor (DELETE /sensors/:id) and its Driver allows it', ->

        it 'should allow requests', (done) ->
            @client.delete "sensors/#{store.sensorId}", done

        it 'should return a "success"', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.success).to.equal true

        it 'when we try getting the deleted Sensor (GET /sensors/:id)', (done) ->
            @client.get "sensors/#{store.sensorId}", done
            
        it 'should return an error', ->
            expect(@body).to.not.exist
            expect(@response.statusCode).to.equal 404
            expect(@err).to.equal 'Sensor not found'
            
        it 'should have deleted the sensor from the Driver\'s data too', ->
            # @todo Implement test

    describe 'When we delete a Sensor (DELETE /sensors/:id) and its Driver doesn\'t allow it', ->
        
        before(helpers.createSensor(fixtures.supportedSensor1))

        # @todo Modify "remove" function of driver so that it returns an error: before helpers.updateDriver ...

        it 'should allow requests', (done) ->
            @client.delete "sensors/#{@sensor.id}", done

        it 'should return an error', ->
            expect(@body).to.not.exist
            expect(@response.statusCode).to.equal 500
            expect(@err).to.equal 'Server error while deleting sensor'

        it 'when we get the un-deleted Sensor (GET /sensors/:id)', (done) ->
            @client.get "sensors/#{@sensor.id}", done
            
        it 'should return it', ->
            expect(@err).to.not.exist
            expect(@body.customId).to.equal fixtures.supportedSensor1.customId
            expect(@body.name).to.equal fixtures.supportedSensor1.sensorName
            expect(@body.type).to.equal fixtures.supportedSensor1.type
            expect(@body.id).to.equal @sensor.id
            
        it 'should not have deleted the sensor from the Driver\'s data too', ->
            # @todo Implement test
