###
# =================
# SCHEMA - Sensor
# =================
# Defines a Sensor, to generate Measures.
###

cozydb = require 'cozydb'
Measure = require './measure'

sensorsDrivers = null # List of drivers supported by the system - Must be set when server starts.

module.exports = class Sensor extends cozydb.CozyModel
	@schema:
		customId:	type : String		# not Empty
		name: 		type : String		# not Empty
		driverId: 	type : String		# not Empty
	
	###
	# destroy
	# ====
	# Deletes the Sensor, both from the DB and Driver
	# @param callback (Function(Error):null):		Callback
	###
	destroy: (callback) ->
		superDestroy = (callback) => super callback
		sensorsDrivers[@driverId].remove @customId, (err2) ->
			if err2
				callback err2
			else
				# Remove from DB:
				superDestroy (err3) ->
					if err3
						# Cancelling Modif:
						sensorsDrivers[@driverId].remove prevSensor.customId, id, (err2) ->
							if err2
								callback 'Device removed from system but not DB. Contact Admin (' + err3 + ' AND ' + err2 + ')'
							else
								callback err3
					else
						callback null
	
	###
	# updateAttributes
	# ====
	# Updates data about the Sensor, both for the DB and Driver
	# @param data (dictionary): 						New data
	# @param callback (Function(Error, Sensor):null):	Callback
	###
	updateAttributes: (data, callback) ->
		prevData =
			customId: @customId
			name: @name
			driverId: @driverId
		superUpdateAttributes = (data, callback) => super data, callback
		# Update DB:
		superUpdateAttributes data, (err, sensor) ->
			if err
				callback err, sensor
			# Update Driver:	
			else
				sensorsDrivers[@driverId].update prevData.customId, data.customId, (err2) ->
					if err2
						# Cancelling Modif:
						superUpdateAttributes prevData, (err3, sensor2) ->
							if err3
								callback 'Can\'t update Sensor in Driver & Can\'t reverse update in DB. Contact Admin (' + err2 + ' AND ' + err3 + ')', sensor2
								return
							callback err2, sensor2
					else
						callback null, sensor
	
	
	###
	# createMeasure
	# ====
	# Generates a measure for this Sensor.
	# @param data (dictionary): 						Measure's data (value, time, type)
	# @param callback (Function(Error, Measure):null):	Callback
	###
	createMeasure: (data, callback) ->
		sanitize data
		data.sensorId = @id
		Measure.create data callback
	
	
	###
	# byDriver
	# ====
	# Finds drivers by their name.
	# @param driver (Driver): 								Driver
	# @param callback (Function(Error, Sensor[]):null): 	Callback
	###	
	@byDriver = (driver, callback) ->
		@request 'byDriver', key: driver.id, callback
		
	###
	# create
	# ====
	# Adds a sensor to the DB and system, if there is a driver to handle it. If a similar sensor already exists (same customId and driverId), then this sensor is returned.
	# @param data (Object): 							Data defining the sensor
	# @param callback (Function(Error, Sensor):null): 	Callback
	###
	@create: (data, callback) ->
		thisSensor = @
		superCreate = (data, callback) => super data, callback

		if sensorsDrivers[data.driverId] # If this kind of device is supported:
			# Check if this sensor isn't already added (the combination driverId + customId should be unique):
			params = key: [data.customId, data.driverId]
			@request "byCustomIdAndDriver", params, (err, sensors)->
				if err
					callback err, null
				else if sensors.length isnt 0 # Sensor already exists.
					callback 'Device already added', sensors[0]
				else
					superCreate data, (err, sensor) ->
						return callback err, null if err
						
						# Let the driver handle the integration of the device to the system:
						sensorsDrivers[data.driverId].add data.customId, sensor.id, (err) ->
							if err
								# Cancelling modif:
								thisSensor.requestDestroy "all", {key: sensor.id}, (err) ->
									callback err, null
							else
								callback null, sensor
		else
			callback 'Device not supported', null

	###
	# setDrivers
	# ====
	# Sets the list of Sensors Drivers.
	# @param ref (Object): 	Reference to the list.
	###
	@setDrivers: (ref) -> sensorsDrivers = ref