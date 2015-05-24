###
# =================
# Test - sensorRule
# =================
# Testing the sensorRules Controller.
###

fixturesRule = require '../fixtures/rule'
fixturesSensor = require '../fixtures/sensor'
fixturesDriver = require '../fixtures/driver'
fs = require 'fs'
os = require 'os'
copyFile = require('../../server/helpers').copyFile
helpers = require '../helpers'
expect = require('chai').expect

store = {}

describe 'SensorRules Controller', ->

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
            
    before (done) ->
        rule = fixturesRule.rule1
        helpers.createRule(rule) () ->
            store["rule"] = helpers.getInStore 'rule'
            done null

    after helpers.killServer
    after helpers.clearFiles

    describe 'When we create a SensorRule (POST /rules/:ruleId/sensorRules)', ->

        sensorRule = fixturesRule.sensorRuleIsMoving

        before (done) ->
            sensorRule.sensorId = store.sensor.id
            done null

        it 'should allow requests', (done) ->
            @client.post "rules/#{store.rule.id}/sensorRules", sensorRule, done

        it 'should reply with the created SensorRule', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 201
            expect(@body.ruleId).to.equal store.rule.id
            expect(@body.sensorId).to.equal sensorRule.sensorId
            expect(@body.type).to.equal sensorRule.type
            expect(@body.intervalStart).to.equal sensorRule.intervalStart
            expect(@body.intervalEnd).to.equal sensorRule.intervalEnd
            expect(@body.id).to.exist
            store.sensorRuleId = @body.id

        it 'should allow requests on the Rule (GET /rules/:ruleId)', (done) ->
            @client.get "rules/#{store.rule.id}", done

        it 'should reply with the Rule with an incremented number of SensorRules', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.id).to.equal store.rule.id
            expect(@body.nbSensorRules).to.equal 1
            expect(@body.nbSensorRulesMet).to.equal 0


    describe 'When we try creating a SensorRule (POST /rules/:ruleId/sensorRules) associated with an unknown Sensor', ->

        sensorRule = fixturesRule.sensorRuleIsMoving

        before (done) ->
            sensorRule.sensorId = store.sensor.id + 404
            done null

        it 'should allow requests', (done) ->
            @client.post "rules/#{store.rule.id}/sensorRules", sensorRule, done

        it 'should reply with an error', ->
            expect(@response.statusCode).to.equal 500
            expect(@body).to.exist
            expect(@body.error).to.equal 'Sensor associated to this rule doesn\'t exist'

    describe 'When we get a SensorRule (GET /rules/:ruleId/sensorRules/:id) which exists', ->

        it 'should allow requests', (done) ->
            @client.get "rules/#{store.rule.id}/sensorRules/#{store.sensorRuleId}", done

        it 'should reply with the corresponding sensorRule', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.ruleId).to.equal store.rule.id
            expect(@body.sensorId).to.equal store.sensor.id
            expect(@body.type).to.equal fixturesRule.sensorRuleIsMoving.type
            expect(@body.intervalStart).to.equal fixturesRule.sensorRuleIsMoving.intervalStart
            expect(@body.intervalEnd).to.equal fixturesRule.sensorRuleIsMoving.intervalEnd
            expect(@body.id).to.equal store.sensorRuleId

            
    describe 'When we get a SensorRule (GET /rules/:ruleId/sensorRules/:id) which doesn\'t exist', ->
        
        it 'should allow requests', (done) ->
            id = store.sensorRuleId + 404 # since "store.sensorRuleId" is the only correct ID in DB, "store.sensorRuleId + 404" is not.
            @client.get "rules/#{store.rule.id}/sensorRules/#{id}", done

        it 'should return an error', ->
            expect(@response.statusCode).to.equal 404
            expect(@body).to.exist
            expect(@body.error).to.equal 'SensorRule not found'

    describe 'When we update a sensorRule (PUT /rules/:ruleId/sensorRules/:id)', ->

        it 'should allow requests', (done) ->
            @client.put "rules/#{store.rule.id}/sensorRules/#{store.sensorRuleId}", fixturesRule.updateSensorRule, done

        it 'should reply with the updated sensorRule', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.ruleId).to.equal store.rule.id
            expect(@body.sensorId).to.equal store.sensor.id
            expect(@body.type).to.equal fixturesRule.updateSensorRule.type
            expect(@body.intervalStart).to.equal fixturesRule.updateSensorRule.intervalStart
            expect(@body.intervalEnd).to.equal fixturesRule.updateSensorRule.intervalEnd
            expect(@body.id).to.equal store.sensorRuleId

    describe 'When we delete a SensorRule (DELETE /rules/:ruleId/sensorRules/:id)', ->

        it 'should allow requests', (done) ->
            @client.del "rules/#{store.rule.id}/sensorRules/#{store.sensorRuleId}", done

        it 'should return a "success"', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.success).to.equal true

        it 'should allow requests on the parent Rule (GET /rules/:ruleId)', (done) ->
            @client.get "rules/#{store.rule.id}", done

        it 'should reply with the Rule with a decremented number of SensorRules', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.id).to.equal store.rule.id
            expect(@body.nbSensorRules).to.equal 0
            expect(@body.nbSensorRulesMet).to.equal 0

        it 'should allow requests to try getting the deleted sensorRule (GET /rule/:ruleId/sensorRules/:id), but...', (done) ->
            @client.get "rules/#{store.rule.id}/sensorRules/#{store.sensorRuleId}", done
            
        it 'should return an error', ->
            expect(@response.statusCode).to.equal 404
            expect(@body).to.exist
            expect(@body.error).to.equal 'SensorRule not found'