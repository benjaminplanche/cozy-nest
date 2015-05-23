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
	# create
	# ====
	# Creates a SensorRule in the DB, if the sensor it is associated to exists.
	# @param data (Object): 								Data defining the SensorRule
	# @param callback (Function(Error, SensorRule):null): 	Callback
	###
	@create: (data, callback) ->
		superCreate = (data, callback) => super data, callback
		Sensor.find data.sensorId, (err, sensor) ->
			if err
				callback 'Sensor associated to this rule couldn\'t be found: '+err, null
				return
			unless sensor
				callback 'Sensor associated to this rule doesn\'t exist', null
				return
			
			superCreate data, callback