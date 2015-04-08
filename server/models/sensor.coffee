###
# =================
# SCHEMA - Sensor
# =================
# Defines a Sensor, to generate Measures.
###

cozydb = require 'cozydb'
Measure = require './measure'

sensorsDrivers = null # List of drivers supported by the system - Must be set when server starts.
module.exports.setDrivers = (ref) -> sensorsDrivers = ref

module.exports = class Sensor extends cozydb.CozyModel
	@schema:
		customId:	type : String		# not Empty
		name: 		type : String		# not Empty
		type: 		type : String		# not Empty
	
	###
	# destroy
	# ====
	# Deletes the Sensor, both from the DB and Driver
	# @param callback (Function(Error):null):		Callback
	###
	destroy: (callback) ->
		superDestroy = super
		sensorsDrivers[@type].remove @customId, (err2) ->
			if err2
				callback err2
			else
				# Remove from DB:
				superDestroy (err3) ->
					if err3
						# Cancelling Modif:
						sensorsDrivers[@type].remove prevSensor.customId, id, (err2) ->
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
	# @todo Cover special case if "type" is changed -> Then the driver taking care of this device must be changed too!
	updateAttributes: (data, callback) ->
		prevData =
			customId: @customId
			name: @name
			type: @type
		superUpdateAttributes = super
		# Update DB:
		superUpdateAttributes data, (err, sensor) ->
			if err
				callback err, sensor
			# Update Driver:	
			else
				sensorsDrivers[@type].update prevData.customId, data.customId, (err2) ->
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
	# create
	# ====
	# Adds a sensor to the DB and system, if there is a driver to handle it. If a similar sensor already exists (same customId and type), then this sensor is returned.
	# @param data (Object): 							Data defining the sensor
	# @param callback (Function(Error, Sensor):null): 	Callback
	###
	@create: (data, callback) ->
		thisSensor = @
		superCreate = super
		if sensorsDrivers[type] # If this kind of device is supported:
			# Check if this sensor isn't already added (the combination type + customId should be unique):
			params = key: [data.accountID, data.type]
			@request "byCustomIdAndType", params, (err, sensors)->
				if err
					callback err, null
				else if sensors.length isnt 0 # Sensor already exists.
					callback 'Device already added', sensor
				else
					superCreate data, (err, sensor) ->
						# Let the driver handle the integration of the device to the system:
						sensorsDrivers[type].add customId, sensor.id, (err) ->
						if err
							# Cancelling modif:
							thisSensor.requestDestroy "all", {key: sensor.id}, (err) ->
								callback err, null
						else
							callback null, sensor
		else
			callback 'Device not supported', null