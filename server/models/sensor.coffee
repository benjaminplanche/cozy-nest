###
# =================
# SCHEMA - SensorRule
# =================
# Defines a SensorRule, defining the values interval of the Measures of a Sensor to trigger a Rule.
###

cozydb = require 'cozydb'

module.exports = SensorModel = cozydb.getModel 'Sensor',
	@schema:
		customId:	type : String		# not Empty
		name: 		type : String		# not Empty
		type: 		type : String		# not Empty
	
	###
	# destroyFromDBAndDriver
	# ====
	# Deletes the Sensor, both from the DB and Driver
	# @param sensorsDrivers (Driver[]): 			List of drivers supported by the system
	# @param callback (Function(Error):null):		Callback
	###
	@destroyFromDBAndDriver = (sensorsDrivers, callback) ->
		sensorsDrivers[@type].remove @customId, (err2) ->
			if err2
				callback err2
				return
			# Remove from DB:
			@destroy (err3) ->
				if err3:
					# Cancelling Modif:
					sensorsDrivers[@type].add prevSensor.customId, id, (err2) ->
						if err2
							callback 'Device removed from system but not DB. Contact Admin'
							return
						callback err3
						return
				callback null
				return
			return
		return
	
	
	
###
# byId
# ====
# Gets a Sensor using its ID.
# @param id (ID): 							ID
# @param callback (Function(Error, Sensor):null): 	Callback
###
SensorModel.byId = (id, callback) ->
    param =
        key: [id]
    SensorModel.request 'byId', param, callback
	
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
# createIfDriver
# ====
# Adds a sensor to the DB and system, if there is a driver to handle it.
# @param data (Object): 						Data defining the sensor
# @param sensorsDrivers (Driver[]): 			List of drivers supported by the system
# @param callback (Function(Error, Sensor):null): 	Callback
###
SensorModel.createIfDriver = (data, sensorsDrivers, callback) ->
	if sensorsDrivers[type] # If this kind of device is supported:
		# Check if this sensor isn't already added (the combination type + customId should be unique):
		Sensor.getOrCreate data, (sensor, created, err) ->
			if !created
				callback 'Device already added', sensor
				return
			# Let the driver handle the integration of the device to the system:
			sensorsDrivers[type].add customId, sensor.id, (err) ->
				if err
					# Cancelling modif:
					Sensor.requestDestroy "all", {key: sensor.id}, (err) ->
						callback err, null
						return
				else
					callback null, sensor
				return
			return
	else
		callback 'Device not supported', null
	return