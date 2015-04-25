###
# =================
# SCHEMA - SensorRule
# =================
# Defines a SensorRule, defining the values interval of the Measures of a Sensor to trigger a Rule.
###

cozydb = require 'cozydb'
Sensor = require './sensor'
Rule = require './rule'

# @todo When update type or interval, check if condition is still met (or simply set it to false)
module.exports = class SensorRule extends cozydb.CozyModel
	@schema:
		ruleId:			type : String		# not Empty, not Null
		sensorId:		type : String		# not Empty, not Null
		type: 			type : String		# not Empty, not Null
		intervalStart: 	type : String
		intervalEnd: 	type : String
	
	###
	# destroy
	# ====
	# Deletes the SensorRule, and updates the information of the Rule it belonged to.
	# @param callback (Function(Error):null):		Callback
	###
	destroy: (callback) ->
		sensorRule = @
		superDestroy = (callback) -> super callback
		Rule.find @ruleId, (err, rule) ->
			if err
				callback 'Rule associated to this SensorRule couldn\'t be found: '+err
				return
			if !sensor
				callback 'Rule associated to this SensorRule doesn\'t exist'
				return
			
			rule.decrementNbSensorRules (err) ->
				if err
					callback 'Rule associated to this SensorRule couldn\'t be updated (to decrement its number of SensorRules): '+err
				else
					if sensorRule.met
						rule.decrementNbSensorRulesMet (err) ->
							if err
								callback 'Rule associated to this SensorRule couldn\'t be updated (to decrement its number of met SensorRules): '+err
							else
								superDestroy callback
					else
						superDestroy callback
	
	###
	# create
	# ====
	# Creates a SensorRule in the DB, if the sensor it is associated to exists.
	# @param data (Object): 								Data defining the SensorRule
	# @param callback (Function(Error, SensorRule):null): 	Callback
	###
	@create: (data, callback) ->
		superCreate = (data, callback) -> super data, callback
		Sensor.find data.sensorId, (err, sensor) ->
			if err
				callback 'Sensor associated to this rule couldn\'t be found: '+err, null
				return
			if !sensor
				callback 'Sensor associated to this rule doesn\'t exist', null
				return
			
			superCreate data, callback