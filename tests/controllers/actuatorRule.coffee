###
# =================
# Test - actuatorRule
# =================
# Testing the actuatorRules Controller.
###

fixturesRule = require '../fixtures/rule'
fixturesActuator = require '../fixtures/actuator'
fixturesDriver = require '../fixtures/driver'
fs = require 'fs'
os = require 'os'
copyFile = require('../../server/helpers').copyFile
helpers = require '../helpers'
expect = require('chai').expect

store = {}

describe 'ActuatorRules Controller', ->

    before helpers.clearDB
    before helpers.clearFiles
    before helpers.startServer
    before helpers.makeTestClient

    before (done) ->
        helpers.createDriver(fixturesDriver.basicActuatorDriver.file) () ->
            store["driverActuator"] =
                instance: helpers.getInStore 'driver'
                module: require '../../server/drivers/' + fixturesDriver.basicActuatorDriver.name + '/' + fixturesDriver.basicActuatorDriver.name
            done null
   
    before (done) ->
        actuator = fixturesActuator.supportedActuator1
        actuator.driverId = store.driverActuator.instance.id
        helpers.createActuator(actuator) () ->
            store["actuator"] = helpers.getInStore('actuator')
            done null
            
    before (done) ->
        rule = fixturesRule.rule1
        helpers.createRule(rule) () ->
            store["rule"] = helpers.getInStore 'rule'
            done null

    after helpers.killServer
    after helpers.clearFiles

    describe 'When we create a ActuatorRule (POST /rules/:ruleId/actuatorRules)', ->

        actuatorRule = fixturesRule.actuatorRuleSayHello

        before (done) ->
            actuatorRule.actuatorId = store.actuator.id
            done null

        it 'should allow requests', (done) ->
            @client.post "rules/#{store.rule.id}/actuatorRules", actuatorRule, done

        it 'should reply with the created ActuatorRule', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 201
            expect(@body.ruleId).to.equal store.rule.id
            expect(@body.actuatorId).to.equal actuatorRule.actuatorId
            expect(@body.value).to.equal actuatorRule.value
            expect(@body.id).to.exist
            store.actuatorRuleId = @body.id

    describe 'When we try creating a ActuatorRule (POST /rules/:ruleId/actuatorRules) associated with an unknown Actuator', ->

        actuatorRule = fixturesRule.actuatorRuleSayHello

        before (done) ->
            actuatorRule.actuatorId = store.actuator.id + 404
            done null

        it 'should allow requests', (done) ->
            @client.post "rules/#{store.rule.id}/actuatorRules", actuatorRule, done

        it 'should reply with an error', ->
            expect(@response.statusCode).to.equal 500
            expect(@body).to.exist
            expect(@body.error).to.equal 'Actuator associated to this rule doesn\'t exist'

    describe 'When we get a ActuatorRule (GET /rules/:ruleId/actuatorRules/:id) which exists', ->

        it 'should allow requests', (done) ->
            @client.get "rules/#{store.rule.id}/actuatorRules/#{store.actuatorRuleId}", done

        it 'should reply with the corresponding actuatorRule', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.ruleId).to.equal store.rule.id
            expect(@body.actuatorId).to.equal store.actuator.id
            expect(@body.value).to.equal fixturesRule.actuatorRuleSayHello.value
            expect(@body.id).to.equal store.actuatorRuleId

            
    describe 'When we get a ActuatorRule (GET /rules/:ruleId/actuatorRules/:id) which doesn\'t exist', ->
        
        it 'should allow requests', (done) ->
            id = store.actuatorRuleId + 404 # since "store.actuatorRuleId" is the only correct ID in DB, "store.actuatorRuleId + 404" is not.
            @client.get "rules/#{store.rule.id}/actuatorRules/#{id}", done

        it 'should return an error', ->
            expect(@response.statusCode).to.equal 404
            expect(@body).to.exist
            expect(@body.error).to.equal 'ActuatorRule not found'

    describe 'When we update a actuatorRule (PUT /rules/:ruleId/actuatorRules/:id)', ->

        it 'should allow requests', (done) ->
            @client.put "rules/#{store.rule.id}/actuatorRules/#{store.actuatorRuleId}", fixturesRule.updateActuatorRule, done

        it 'should reply with the updated actuatorRule', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.ruleId).to.equal store.rule.id
            expect(@body.actuatorId).to.equal store.actuator.id
            expect(@body.value).to.equal fixturesRule.updateActuatorRule.value
            expect(@body.id).to.equal store.actuatorRuleId

    describe 'When we delete a ActuatorRule (DELETE /rules/:ruleId/actuatorRules/:id)', ->

        it 'should allow requests', (done) ->
            @client.del "rules/#{store.rule.id}/actuatorRules/#{store.actuatorRuleId}", done

        it 'should return a "success"', ->
            expect(@err).to.not.exist
            expect(@response.statusCode).to.equal 200
            expect(@body.success).to.equal true

        it 'when we try getting the deleted actuatorRule (GET /rule/:ruleId/actuatorRules/:id)', (done) ->
            @client.get "rules/#{store.rule.id}/actuatorRules/#{store.actuatorRuleId}", done
            
        it 'should return an error', ->
            expect(@response.statusCode).to.equal 404
            expect(@body).to.exist
            expect(@body.error).to.equal 'ActuatorRule not found'