###
# =================
# Test - measure
# =================
# Testing the measures Controller.
###

fixtureMeasure = require '../fixtures/measure'
fixturesSensor = require '../fixtures/sensor'
fixturesDriver = require '../fixtures/driver'
fs = require 'fs'
os = require 'os'
copyFile = require('../../server/helpers').copyFile
helpers = require '../helpers'
expect = require('chai').expect

store = {}

describe 'Measures Controller', ->

    before helpers.clearDB
    before helpers.clearFiles
    before helpers.startServer
    before helpers.makeTestClient

    before (done) ->
        helpers.createDriver(fixturesDriver.basicSensorDriver.file) () ->
            store["driverSensor"] =
                instance: helpers.getInStore 'driver'
                module: require '../../server/drivers/' + fixturesDriver.basicSensorDriver.name + '/' + fixturesDriver.basicSensorDriver.name
            done null
   
    before (done) ->
        sensor = fixturesSensor.supportedSensor1
        sensor.driverId = store.driverSensor.instance.id
        helpers.createSensor(sensor) () ->
            store["sensor"] = helpers.getInStore('sensor')
            done null

    after helpers.killServer
    after helpers.clearFiles

    describe 'When we create a Measure (POST /sensors/:sensorId/measures)', ->

        measure = fixtureMeasure.measureMovement1

        before (done) ->
            measure.sensorId = store.sensor.id
            done null

        it 'should allow requests', (done) ->
            @client.post "sensors/#{store.rule.id}/measures", measure, done

        it 'should reply with the created Measure', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 201
            expect(@body.sensorId).to.equal measure.sensorId
            expect(@body.type).to.equal measure.type
            expect(@body.value).to.equal measure.value
            expect(@body.time).to.equal measure.time
            expect(@body.id).to.exist
            store.measureId = @body.id


    describe 'When we try creating a Measure (POST /sensors/:sensorId/measures) associated with an unknown Sensor', ->

        measure = fixtureMeasure.measureMovement1

        before (done) ->
            measure.sensorId = store.sensor.id + 404
            done null

        it 'should allow requests', (done) ->
            @client.post "sensors/#{measure.sensorId}/measures", measure, done

        it 'should reply with an error', ->
            expect(@response.statusCode).to.equal 404
            expect(@body).to.exist
            expect(@body.error).to.equal 'Sensor not found'

    describe 'When we get a Measure (GET /sensors/:sensorId/measures/:id) which exists', ->

        it 'should allow requests', (done) ->
            @client.get "sensors/#{store.rule.id}/measures/#{store.measureId}", done

        it 'should reply with the corresponding measure', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.sensorId).to.equal store.sensor.id
            expect(@body.type).to.equal fixtureMeasure.measureMovement1.type
            expect(@body.value).to.equal fixtureMeasure.measureMovement1.value
            expect(@body.time).to.equal fixtureMeasure.measureMovement1.time
            expect(@body.id).to.equal store.measureId

            
    describe 'When we get a Measure (GET /sensors/:sensorId/measures/:id) which doesn\'t exist', ->
        
        it 'should allow requests', (done) ->
            id = store.measureId + 404 # since "store.measureId" is the only correct ID in DB, "store.measureId + 404" is not.
            @client.get "sensors/#{store.rule.id}/measures/#{id}", done

        it 'should return an error', ->
            expect(@response.statusCode).to.equal 404
            expect(@body).to.exist
            expect(@body.error).to.equal 'Measure not found'

    describe 'When we update a measure (PUT /sensors/:sensorId/measures/:id)', ->

        it 'should allow requests', (done) ->
            @client.put "sensors/#{store.rule.id}/measures/#{store.measureId}", fixtureMeasure.updateMeasure, done

        it 'should return an unauthorized error', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 401
            expect(@body).to.exist
            expect(@body.error).to.equal "Measures can't be updated"

    describe 'When we delete a Measure (DELETE /sensors/:sensorId/measures/:id)', ->

        it 'should allow requests', (done) ->
            @client.del "sensors/#{store.rule.id}/measures/#{store.measureId}", done

        it 'should return a "success"', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.success).to.equal true

        it 'should allow requests to try getting the deleted measure (GET /rule/:sensorId/measures/:id), but...', (done) ->
            @client.get "sensors/#{store.rule.id}/measures/#{store.measureId}", done
            
        it 'should return an error', ->
            expect(@response.statusCode).to.equal 404
            expect(@body).to.exist
            expect(@body.error).to.equal 'Measure not found'