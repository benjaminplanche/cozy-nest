###
# =================
# SCHEMA - Rule
# =================
# Defines a Rule, binding Sensors Measures and Actuators together.
###

cozydb = require 'cozydb'
SensorRule = require './sensorRule'
ActuatorRule = require './actuatorRule'

module.exports = RuleModel = cozydb.getModel 'Rule',
	@schema:
		name: 		type : String		# not Empty
	
	###
	# createSensorRule
	# ====
	# Generates a SensorRule (ie. condition) associated to this Rule.
	# @param data (dictionary): 							SensorRule's data (sensorId, type, intervalStart, intervalEnd)
	# @param callback (Function(Error, SensorRule):null):	Callback
	###
	@createSensorRule = (data, callback) ->
		sanitize data
		data.ruleId = @id
		SensorRule.createIfSensor data callback
	
	###
	# createActuatorRule
	# ====
	# Generates an ActuatorRule (ie. reaction) associated to this Rule.
	# @param data (dictionary): 							ActuatorRule's data (type, value, isActive)
	# @param callback (Function(Error, ActuatorRule):null):	Callback
	###
	@createActuatorRule = (data, callback) ->
		sanitize data
		data.ruleId = @id
		ActuatorRule.createIfActuator data callback
		
	
	###
	# destroy
	# ====
	# Deletes the Rule, and its SensorRules and ActuatorRules
	# @param callback (Function(Error):null):		Callback
	###
	@destroy = (callback) ->
		params = key: @id
		SensorRule.request "byRule", params, (err, sensorRules)->
			if err
				callback 'Error while deleting the conditions (SensorRules) associated: '+err
			msgErr = ''
			partialCallback = partialErr ->
				msgErr += 'Error while deleting SensorRule: ' + partialErr + '\n'
			
			sensorRule.destroy partialCallback for sensorRule in sensorRules
			if msgErr?
				callback msgErr
		
		ActuatorRule.request "byRule", params, (err, actuatorRules)->
			if err
				callback 'Error while deleting the conditions (ActuatorRules) associated: '+err
			msgErr = ''
			partialCallback = partialErr ->
				msgErr += 'Error while deleting ActuatorRule: ' + partialErr + '\n'
			
			actuatorRule.destroy partialCallback for actuatorRule in actuatorRules
			if msgErr?
				callback msgErr
		
		super callback
	