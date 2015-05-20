###
# =================
# Test - rule
# =================
# Testing the rules Controller.
###

fixturesRule = require '../fixtures/rule'
fixturesSensor = require '../fixtures/sensor'
fixturesActuator = require '../fixtures/actuator'
fixturesDriver = require '../fixtures/driver'
fs = require 'fs'
os = require 'os'
copyFile = require('../../server/helpers').copyFile
helpers = require '../helpers'
expect = require('chai').expect

store = {}

###
@todo Tests:
    [ ] Create Rule
    [ ] Update Rule
    [ ] Delete Rule
    [ ] Create Rule & SensorRule
        - Check increment
    [ ] Create Rule & SensorRule
        - Check doesn't work if Sensor doesn't exist
    [ ] Delete SensorRule
        - Check Decrement
    [ ] Create Rule & ActuatorRule
        - Check increment
    [ ] Create Rule & ActuatorRule
        - Check doesn't work if Actuator doesn't exist
    [ ] Delete ActuatorRule
        - Check Decrement
    [ ] Delete Rule with ActuatorRules & SensorRules

    [ ] Add Measure & Check MetSensorRules
        - Check increment
    [ ] Add Measure & Check MetSensorRules
        - Check decrement
    [ ] Add Measure & Check met Rules
    [ ] Check ActuatorRule.apply
###

describe 'Rules Controller', ->

    before helpers.clearDB
    before helpers.clearFiles
    before helpers.startServer
    before helpers.makeTestClient

    before (done) ->
        helpers.createDriver(fixturesDriver.basicSensorDriver.file) () ->
            store["driverSensor"] =
                instance: helpers.getInStore('driver')
                module: require '../../server/drivers/' + fixturesDriver.basicSensorDriver.name + '/' + fixturesDriver.basicSensorDriver.name
            done null

    before (done) ->
        helpers.createDriver(fixturesDriver.basicActuatorDriver.file) () ->
            store["driverActuator"] =
                instance: helpers.getInStore('driver')
                module: require '../../server/drivers/' + fixturesDriver.basicActuatorDriver.name + '/' + fixturesDriver.basicActuatorDriver.name
            done null


    after helpers.killServer
    after helpers.clearFiles

    describe 'When we create a Rule (POST /rules)', ->

        rule = fixturesRule.rule1

        it 'should allow requests', (done) ->
            @client.post 'rules', rule, done

        it 'should reply with the created Rule', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 201
            expect(@body.name).to.equal rule.name
            expect(@body.nbSensorRulesMet).to.equal 0
            expect(@body.nbSensorRules).to.equal 0
            expect(@body.id).to.exist
            store.ruleId = @body.id

    describe 'When we get a Rule (GET /rules/:id) which exists', ->

        it 'should allow requests', (done) ->
            @client.get "rules/#{store.ruleId}", done

        it 'should reply with the corresponding rule', ->
            expect(@err).to.not.exist
            expect(@body.name).to.equal fixturesRule.rule1.name
            expect(@body.nbSensorRulesMet).to.equal 0
            expect(@body.nbSensorRules).to.equal 0
            expect(@body.id).to.equal store.ruleId

            
    describe 'When we get a Rule (GET /rules/:id) which doesn\'t exist', ->
        
        it 'should allow requests', (done) ->
            id = store.ruleId + 404 # since "store.ruleId" is the only correct ID in DB, "store.ruleId + 404" is not.
            @client.get "rules/#{id}", done

        it 'should return an error', ->
            expect(@response.statusCode).to.equal 404
            expect(@body).to.exist
            expect(@body.error).to.equal 'Rule not found'

    describe 'When we update a rule (PUT /rules/:id)', ->

        it 'should allow requests', (done) ->
            @client.put "rules/#{store.ruleId}", fixturesRule.updateRule1, done

        it 'should reply with the updated rules', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.name).to.equal fixturesRule.updateRule1.name
            expect(@body.nbSensorRulesMet).to.equal 0
            expect(@body.nbSensorRules).to.equal 0
            expect(@body.id).to.equal store.ruleId

    describe 'When we delete an empty Rule (DELETE /rules/:id)', ->

        it 'should allow requests', (done) ->
            @client.del "rules/#{store.ruleId}", done

        it 'should return a "success"', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.success).to.equal true

        it 'when we try getting the deleted rule (GET /rules/:id)', (done) ->
            @client.get "rules/#{store.ruleId}", done
            
        it 'should return an error', ->
            expect(@response.statusCode).to.equal 404
            expect(@body).to.exist
            expect(@body.error).to.equal 'Rule not found'

    ###describe 'When we delete a Rule (DELETE /rules/:id) with devices still depending on it', ->


        before helpers.createRule fixturesRule.basicSensorRule.file
        before (done) ->
            # We add the rule:
            store.ruleId = helpers.getInStore('rule').id
            done null

        before (done) ->
            # We add the depending device:
            sensor = fixturesSensor.supportedSensor1
            sensor.ruleId = store.ruleId
            helpers.createSensor(sensor) () ->
                store.sensorId = helpers.getInStore('sensor').id
                done null

        it 'should allow requests', (done) ->
            @client.del "rules/#{store.ruleId}", done

        it 'should return an error', ->
            expect(@response.statusCode).to.equal 500
            expect(@body).to.exist
            expect(@body.error).to.equal 'Devices still using this rule'

        it 'when we try deleting the sensor first (DELETE /sensors/:id)', (done) ->
            @client.del "sensors/#{store.sensorId}", done
            
        it '... then the rule (DELETE /rules/:id)', (done) ->
            @client.del "rules/#{store.ruleId}", done

        it 'should return a "success"', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.success).to.equal true
###