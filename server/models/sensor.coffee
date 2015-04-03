###
# =================
# SCHEMA - Sensor
# =================
# Defines a Sensor, to generate Measures.
###

cozydb = require 'cozydb'
Measure = require './measure'

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
	# updateAttributesForDBAndDriver
	# ====
	# Updates data about the Sensor, both for the DB and Driver
	# @param data (dictionary): 						New data
	# @param sensorsDrivers (Driver[]): 				List of drivers supported by the system
	# @param callback (Function(Error, Sensor):null):	Callback
	###
	# @todo Conver special case if "type" is changed -> Then the driver taking care of this device must be changed too!
	@updateAttributesForDBAndDriver = (data, sensorsDrivers, callback) ->
		prevData =
			customId: @customId
			name: @name
			type: @type
		# Update DB:
		@updateAttributes data, (err, sensor) ->
			if err
				callback err, sensor
				return
			# Update Driver:	
			sensorsDrivers[@type].update prevData.customId, data.customId, (err2) ->
				if err2:
					# Cancelling Modif:
					@updateAttributes prevData, (err3, sensor2) ->
						if err3
							callback 'Can't update Sensor in Driver & Can't reverse update in DB. Contact Admin', sensor2
							return
						callback err2, sensor2
						return
				callback null, sensor
				return
			return
		return
	
	
	###
	# createMeasure
	# ====
	# Generates a measure for this Sensor.
	# @param data (dictionary): 						Measure's data (value, time, type)
	# @param callback (Function(Error, Measure):null):	Callback
	###
	@createMeasure = (data, callback) ->
		sanitize data
		data.sensorId = @id
		Measure.create data callback
		
	
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
# @param data (Object): 								Data defining the sensor
# @param callback (Function(Error, Sensor, bool):null): Callback function. 2nd parameter is the found or created Sensor; 3rd parameter is a boolean set true if created / false if found.
###
SensorModel.getOrCreate = (data, callback) ->
	# customId + type is a primary key.
	params = key: [accountID, type]
	SensorModel.request "byCustomIdAndType", params, (err, sensors)->
	if err
		callback err, null, null
	else if sensors.length is 0
		callbackCreate = (err, sensor) ->
			callback err, sensor, true
		SensorModel.create data, callbackCreate
	else # Sensor already exists.
		callback err, sensors[0], false
		
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
		Sensor.getOrCreate data, (err, sensor, created, err) ->
			if err
				callback err, sensor
				return
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