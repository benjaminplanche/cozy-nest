###
# =================
# Test - Sensor
# =================
# Testing the Sensors Controller.
###

fixturesSensor = require '../fixtures/sensor'
fixturesDriver = require '../fixtures/driver'
fs = require 'fs'
helpers = require '../helpers'
expect = require('chai').expect

store = {}

describe 'Sensors Controller', ->

    before helpers.clearDB
    before helpers.startServer
    before helpers.makeTestClient
    before helpers.createDriver fixturesDriver.basicSensorDriver.file
    before (done) ->
        store["driver"] = helpers.getInStore('driver')
        done null

    after  helpers.killServer

    describe 'When we create a Sensor (POST /sensors) which is supported by a Driver', ->

        sensor = fixturesSensor.supportedSensor1

        before (done) ->
            sensor.driverId = store.driver.id
            done null

        it 'should allow requests', (done) ->
            @client.post 'sensors', sensor, done

        it 'should reply with the created Sensor', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 201
            expect(@body.customId).to.equal sensor.customId
            expect(@body.name).to.equal sensor.name
            expect(@body.driverId).to.equal sensor.driverId
            expect(@body.id).to.exist
            store.sensorId = @body.id
            store.sensorName = @body.name

    describe 'When we try creating a 2nd Sensor (POST /sensors) with the same driver and customId', ->

        sensor = fixturesSensor.supportedSensor1

        before (done) ->
	        sensor.driverId = store.driver.id
	        sensor.name = 'Different Name' # name is not taken into account to evaluate similarity.
	        done null

        it 'should allow requests', (done) ->
            @client.post 'sensors', sensor, done

        it 'should reply with the previously-created Sensor', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 202
            expect(@body.customId).to.equal sensor.customId
            expect(@body.name).to.equal store.sensorName
            expect(@body.driverId).to.equal sensor.driverId
            expect(@body.id).to.equal store.sensorId

    describe 'When we try creating a Sensor (POST /sensors) which isn\'t supported by a Driver', ->

        sensor = fixturesSensor.unsupportedSensor

        it 'should allow requests', (done) ->
            @client.post 'sensors', sensor, done

        it 'should reply with an error', ->
            # expect(@body).to.not.exist
            expect(@response.statusCode).to.equal 500
            expect(@body).to.exist
            expect(@body.error).to.exist
            expect(@body.error).to.equal 'Device not supported'
            
    describe 'When we get a Sensor (GET /sensors/:id) which exists', ->

        id = store.sensorId

        it 'should allow requests', (done) ->
            @client.get "sensors/#{id}", done

        it 'should reply with the corresponding sensor', ->
            expect(@err).to.not.exist
            expect(@body.customId).to.equal fixturesSensor.supportedSensor1.customId
            expect(@body.name).to.equal fixturesSensor.supportedSensor1.sensorName
            expect(@body.driverId).to.equal store.driver.id
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

        update = fixturesSensor.validUpdateForTestSensor

        it 'should allow requests', (done) ->
            @client.put "sensors/#{store.sensorId}", update, done

        it 'should reply with the updated sensor', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.customId).to.equal fixturesSensor.validUpdateForTestSensor.customId
            expect(@body.name).to.equal fixturesSensor.validUpdateForTestSensor.sensorName
            expect(@body.driverId).to.equal store.driver.id
            expect(@body.id).to.equal store.sensorId

        it 'should have updated the Driver\'s data too', ->
            # @todo Implement test
        
    describe 'When we update a Sensor (PUT /sensors/:id) with data considered invalid by its Driver', ->

        update = fixturesSensor.invalidUpdateForTestSensor

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
            expect(@body.customId).to.equal fixturesSensor.validUpdateForTestSensor.customId
            expect(@body.name).to.equal fixturesSensor.validUpdateForTestSensor.sensorName
            expect(@body.driverId).to.equal store.driver.id
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
       
        sensor = fixturesSensor.supportedSensor1

        before (done) ->
        	sensor.driverId = store.driver.id
        	helpers.createSensor(sensor)
	        done null

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
            expect(@body.customId).to.equal fixturesSensor.supportedSensor1.customId
            expect(@body.name).to.equal fixturesSensor.supportedSensor1.sensorName
            expect(@body.driverId).to.equal store.driver.id
            expect(@body.id).to.equal @sensor.id
            
        it 'should not have deleted the sensor from the Driver\'s data too', ->
            # @todo Implement test
