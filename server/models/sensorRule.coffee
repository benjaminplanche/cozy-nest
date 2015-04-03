###
# =================
# SCHEMA - SensorRule
# =================
# Defines a SensorRule, defining the values interval of the Measures of a Sensor to trigger a Rule.
###

cozydb = require 'cozydb'
Sensor = require './sensor'

module.exports = SensorRule = cozydb.getModel 'Rule',
	ruleId			type : String		# not Empty, not Null
	sensorId		type : String		# not Empty, not Null
	type: 			type : String		# not Empty, not Null
	intervalStart: 	type : String
	intervalEnd: 	type : String
	
###
# createIfSensor
# ====
# Creates a SensorRule in the DB, if the sensor it is associated to exists.
# @param data (Object): 								Data defining the SensorRule
# @param callback (Function(Error, SensorRule):null): 	Callback
###
SensorRule.createIfSensor = (data, callback) ->
	Sensor.find data.sensorId, (err, sensor) ->
		if err
			callback 'Sensor associated to this rule couldn't be found: '+err, null
			return
		if !sensor
			callback 'Sensor associated to this rule doesn't exist', null
			return
		
		SensorModel.create data, callback