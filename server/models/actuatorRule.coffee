###
# =================
# SCHEMA - ActuatorRule
# =================
# Defines a ActuatorRule, defining which Actuator must be triggered and how, when the conditions of the Rule (SensorRules) are met.
###

cozydb = require 'cozydb'
Actuator = require './actuator'

module.exports = ActuatorRuleModel = cozydb.getModel 'ActuatorRule',
	ruleId		type : String						# not Empty, not Null
	actuatorId	type : String						# not Empty, not Null
    value: 		type : String
    isActive: 	type : Boolean, default : false

###
# createIfActuator
# ====
# Creates an ActuatorRule in the DB, if the actuator it is associated to exists.
# @param data (Object): 								Data defining the ActuatorRule
# @param callback (Function(Error, SensorRule):null): 	Callback
###
ActuatorRuleModel.createIfSensor = (data, callback) ->
	Actuator.find data.sensorId, (err, actuator) ->
		if err
			callback 'Actuator associated to this rule couldn't be found: '+err, null
			return
		if !actuator
			callback 'Actuator associated to this rule doesn't exist', null
			return
		
		ActuatorRuleModel.create data, callback