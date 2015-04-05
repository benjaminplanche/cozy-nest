###
# =================
# SCHEMA - ActuatorRule
# =================
# Defines a ActuatorRule, defining which Actuator must be triggered and how, when the conditions of the Rule (SensorRules) are met.
###

cozydb = require 'cozydb'
Actuator = require './actuator'

module.exports = ActuatorRuleModel = cozydb.getModel 'ActuatorRule',
	@schema:
		ruleId		type : String						# not Empty, not Null
		actuatorId	type : String						# not Empty, not Null
		value: 		type : String
		isActive: 	type : Boolean, default : false
	
	###
	# apply
	# ====
	# Applies the ActuatorRule, sending a request to the corresponding Actuator using its Driver.
	# @param actuatorsDrivers (Driver[]): 		List of drivers supported by the system
	# @param callback (Function(Error):null): 	Callback
	###
	@apply(actuatorsDrivers, callback)
		if !@isActive
			actuatorRule = @
			Actuator.find @actuatorId (err, actuator)->
				if err
					callback 'Error while finding the Actuator associated to ActuatorRule #'+actuatorRule.id+': '+err
					return
				if !actuator
					callback 'Actuator associated to ActuatorRule #'+actuatorRule.id+' not found: '+err
					return
				actuatorsDrivers[actuator.type].apply actuator.customId, actuatorRule.value, (err) ->
					if err
						callback 'Error while sending request to the Actuator associated to ActuatorRule #'+actuatorRule.id+': '+err
						return
					actuatorRule.update isActive: true, callback
		else
			callback null
	
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
			callback 'Actuator associated to this rule couldn\'t be found: '+err, null
			return
		if !actuator
			callback 'Actuator associated to this rule doesn\'t exist', null
			return
		
		ActuatorRuleModel.create data, callback