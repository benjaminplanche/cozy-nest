###
# =================
# SCHEMA - SensorRule
# =================
# Defines a SensorRule, defining the values interval of the Measures of a Sensor to trigger a Rule.
###

cozydb = require 'cozydb'

module.exports = SensorModel = cozydb.getModel 'Sensor',
	customId:	type : String		# not Empty
	name: 		type : String		# not Empty
	type: 		type : String		# not Empty
	
###
# getOrCreate
# ====
# Gets a Sensor, or creates it if not found.
# @param data (Object): 							Data defining the sensor
# @param callback (Function(Sensor, bool):null): 	Callback function. First parameter if the found or created Sensor; Second parameter is a boolean set true if created / false if found.
###
SensorModel.getOrCreate = (data, callback) ->
	# customId + type is a primary key.
	params = key: [accountID, type]
	SensorModel.request "byCustomIdAndType", params, (err, sensors)->
	if err
		log.error err
		callbackCreate = (sensor) ->
			callback sensor, true
		SensorModel.create data, callbackCreate
	else if sensors.length is 0
		callbackCreate = (sensor) ->
			callback sensor, true
		SensorModel.create data, callbackCreate
	else # Sensor already exists.
		callback sensors[0], false
		
###
# createSensor
# ====
# Add a sensor to the DB and system, if there is a driver to handle it.
# @param data (Object): 						Data defining the sensor
# @param sensorsDrivers (Driver[]): 			List of drivers supported by the system
# @param callback (Function(Error, ID):null): 	Callback
###
SensorModel.createSensor = (data, sensorsDrivers, callback) ->
	if sensorsDrivers[type] # If this kind of device is supported:
		# Check if this sensor isn't already added (the combination type + customId should be unique):
		Sensor.getOrCreate data, (sensor, created, err) ->
			if !created
				callback 'Device already added', sensor.id
				return
			# Let the driver handle the integration of the device to the system:
			sensorsDrivers[type].add customId, sensor.id, (err) ->
				if err
					# Cancelling modif:
					Sensor.requestDestroy "all", {key: sensor.id}, (err) ->
						callback err, null
						return
				else
					callback null, sensor.id
				return
			return
	else
		callback 'Device not supported', null
	return