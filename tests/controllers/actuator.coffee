###
# =================
# Test - Actuator
# =================
# Testing the Actuators Controller.
###

fixturesActuator = require '../fixtures/actuator'
fixturesDriver = require '../fixtures/driver'
fs = require 'fs'
helpers = require '../helpers'
expect = require('chai').expect

store = {}

describe 'Actuators Controller', ->

    before helpers.clearDB
    before helpers.clearFiles
    before helpers.startServer
    before helpers.makeTestClient
    before helpers.createDriver fixturesDriver.basicActuatorDriver.file
    before (done) ->
        store["driver"] = helpers.getInStore('driver')
        store["driverModule"] = require '../../server/drivers/' + fixturesDriver.basicActuatorDriver.name + '/' + fixturesDriver.basicActuatorDriver.name
        done null

    after  helpers.killServer

    describe 'When we create an Actuator (POST /actuators) which is supported by a Driver', ->

        actuator = fixturesActuator.supportedActuator1

        before (done) ->
            actuator.driverId = store.driver.id
            done null

        it 'should allow requests', (done) ->
            @client.post 'actuators', actuator, done

        it 'should reply with the created Actuator', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 201
            expect(@body.customId).to.equal actuator.customId
            expect(@body.name).to.equal actuator.name
            expect(@body.driverId).to.equal actuator.driverId
            expect(@body.id).to.exist
            store.actuatorId = @body.id
            store.actuatorName = @body.name
            
        it 'should have been passed to its driver', ->
            expect(store["driverModule"].getActuator(actuator.customId)).to.equal store.actuatorId

    describe 'When we try creating a 2nd Actuator (POST /actuators) with the same driver and customId', ->

        actuator = fixturesActuator.supportedActuator1

        before (done) ->
	        actuator.driverId = store.driver.id
	        actuator.name = 'Different Name' # name is not taken into account to evaluate similarity.
	        done null

        it 'should allow requests', (done) ->
            @client.post 'actuators', actuator, done

        it 'should reply with the previously-created Actuator', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 202
            expect(@body.customId).to.equal actuator.customId
            expect(@body.name).to.equal store.actuatorName
            expect(@body.driverId).to.equal actuator.driverId
            expect(@body.id).to.equal store.actuatorId

    describe 'When we try creating an Actuator (POST /actuators) which isn\'t supported by a Driver', ->

        actuator = fixturesActuator.unsupportedActuator

        it 'should allow requests', (done) ->
            @client.post 'actuators', actuator, done

        it 'should reply with an error', ->
            # expect(@body).to.not.exist
            expect(@response.statusCode).to.equal 500
            expect(@body).to.exist
            expect(@body.error).to.equal 'Device not supported'
            
    describe 'When we get an Actuator (GET /actuators/:id) which exists', ->

        it 'should allow requests', (done) ->
            @client.get "actuators/#{store.actuatorId}", done

        it 'should reply with the corresponding actuator', ->
            expect(@err).to.not.exist
            expect(@body.customId).to.equal fixturesActuator.supportedActuator1.customId
            expect(@body.name).to.equal store.actuatorName
            expect(@body.driverId).to.equal store.driver.id
            expect(@body.id).to.equal store.actuatorId

            
    describe 'When we get an Actuator (GET /actuators/:id) which doesn\'t exist', ->

        
        it 'should allow requests', (done) ->
            id = store.actuatorId + 404 # since "store.actuatorId" is the only correct ID in DB, "store.actuatorId + 404" is not.
            @client.get "actuators/#{id}", done

        it 'should return an error', ->
            expect(@response.statusCode).to.equal 404
            expect(@body).to.exist
            expect(@body.error).to.equal 'Actuator not found'

    describe 'When we update an Actuator (PUT /actuators/:id) with data considered valid by its Driver', ->

        it 'should allow requests', (done) ->
            @client.put "actuators/#{store.actuatorId}", fixturesActuator.validUpdateForTestActuator, done

        it 'should reply with the updated actuator', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.customId).to.equal fixturesActuator.validUpdateForTestActuator.customId
            expect(@body.name).to.equal fixturesActuator.validUpdateForTestActuator.name
            expect(@body.driverId).to.equal store.driver.id
            expect(@body.id).to.equal store.actuatorId
            store.actuatorName = @body.name

        it 'should have updated the Driver\'s data too', ->
            expect(store["driverModule"].getActuator(fixturesActuator.supportedActuator1.customId)).to.not.exist
            expect(store["driverModule"].getActuator(fixturesActuator.validUpdateForTestActuator.customId)).to.equal store.actuatorId
        
    describe 'When we ask the Actuator to apply a value (PUT /actuators/:id/apply) with data considered valid by its Driver', ->

        it 'should allow requests', (done) ->
            @client.post "actuators/#{store.actuatorId}/apply", fixturesActuator.validApplyValueForTestActuator, done

        it 'should return a "success"', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 202
            expect(@body.success).to.equal true

        it 'should have updated the Driver\'s data too', ->
            driverApplyLog0 = store["driverModule"].getApplyCall 0
            expect(driverApplyLog0).to.exist
            expect(driverApplyLog0.customId).to.equal fixturesActuator.validUpdateForTestActuator.customId
            expect(driverApplyLog0.value).to.equal fixturesActuator.validApplyValueForTestActuator.value
            expect(store["driverModule"].getApplyCall(1)).to.not.exist

    describe 'When we update an Actuator (PUT /actuators/:id) with data considered invalid by its Driver', ->

        update = fixturesActuator.invalidUpdateForTestActuator

        it 'should allow requests', (done) ->
            @client.put "actuators/#{store.actuatorId}", update, done

        it 'should return an error', ->
            expect(@response.statusCode).to.equal 500
            expect(@body).to.exist
            expect(@body.error).to.exist

        it 'when we get the targeted Actuator (GET /actuators/:id)', (done) ->
            @client.get "actuators/#{store.actuatorId}", done
            
        it 'should return the unmodified actuator', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.customId).to.equal fixturesActuator.validUpdateForTestActuator.customId
            expect(@body.name).to.equal fixturesActuator.validUpdateForTestActuator.name
            expect(@body.driverId).to.equal store.driver.id
            expect(@body.id).to.equal store.actuatorId

        it 'should not have updated the Driver\'s data too', ->
            expect(store["driverModule"].getActuator(fixturesActuator.invalidUpdateForTestActuator.customId)).to.not.exist
            expect(store["driverModule"].getActuator(fixturesActuator.validUpdateForTestActuator.customId)).to.equal store.actuatorId

    describe 'When we delete an Actuator (DELETE /actuators/:id) and its Driver allows it', ->

        it 'should allow requests', (done) ->
            @client.del "actuators/#{store.actuatorId}", done

        it 'should return a "success"', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.success).to.equal true

        it 'when we try getting the deleted Actuator (GET /actuators/:id)', (done) ->
            @client.get "actuators/#{store.actuatorId}", done
            
        it 'should return an error', ->
            expect(@response.statusCode).to.equal 404
            expect(@body).to.exist
            expect(@body.error).to.equal 'Actuator not found'
            
        it 'should have deleted the actuator from the Driver\'s data too', ->
            expect(store["driverModule"].getActuator(fixturesActuator.validUpdateForTestActuator.customId)).to.not.exist

    describe 'When we delete an Actuator (DELETE /actuators/:id) and its Driver doesn\'t allow it', ->
       
        actuator = fixturesActuator.supportedActuator1
        
        before (done) ->
            # We modify our test-driver so that it returns errors when asked to remove a device:
            store["driverModule"].setRemovableFlag false
            
            # We add the device to try on:
            actuator.driverId = store.driver.id
            helpers.createActuator(actuator) () ->
                store.actuatorId = helpers.getInStore('actuator').id
                done null

        it 'should allow requests', (done) ->
            @client.del "actuators/#{store.actuatorId}", done

        it 'should return an error', ->
            expect(@response.statusCode).to.equal 500
            expect(@body).to.exist
            expect(@body.error).to.equal 'Device not removable'

        it 'when we get the un-deleted Actuator (GET /actuators/:id)', (done) ->
            @client.get "actuators/#{store.actuatorId}", done
            
        it 'should return it', ->
            expect(@err).to.not.exist
            expect(@body.customId).to.equal fixturesActuator.supportedActuator1.customId
            expect(@body.name).to.equal fixturesActuator.supportedActuator1.name
            expect(@body.driverId).to.equal store.driver.id
            expect(@body.id).to.equal store.actuatorId
            
        it 'should not have deleted the actuator from the Driver\'s data too', ->
            expect(store["driverModule"].getActuator(fixturesActuator.supportedActuator1.customId)).to.equal store.actuatorId
