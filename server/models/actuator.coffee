###
# =================
# SCHEMA - Actuator
# =================
# Defines an Actuator, to apply Rules.
###

cozydb = require 'cozydb'

actuatorsDrivers = null # List of drivers supported by the system - Must be set when server starts.

module.exports = class Actuator extends cozydb.CozyModel
	@schema:
		customId: 	type : String		# not Empty
		name: 		type : String		# not Empty
		driverId: 		type : String		# not Empty
	
	###
	# apply
	# ====
	# Asks the actuator to apply the given value, using its driver as intermediate.
	# @param value (String): 					Value to be applied
	# @param callback (Function(Error):null): 	Callback
	###
	apply: (value, callback) ->
		actuatorsDrivers[@driverId].apply @customId, value, callback
	
	###
	# destroy
	# ====
	# Deletes the Actuator, both from the DB and Driver
	# @param callback (Function(Error):null):		Callback
	###
	destroy: (callback) ->
		superDestroy = (callback) -> super callback
		actuatorsDrivers[@driverId].remove @customId, (err2) ->
			if err2
				callback err2
			else
				# Remove from DB:
				superDestroy (err3) ->
					if err3
						# Cancelling Modif:
						actuatorsDrivers[@driverId].remove prevActuator.customId, id, (err2) ->
							if err2
								callback 'Device removed from system but not DB. Contact Admin (' + err3 + ' AND ' + err2 + ')'
							else 
								callback err3
					else
						callback null
	
	###
	# updateAttributes
	# ====
	# Updates data about the Actuator, both for the DB and Driver
	# @param data (dictionary): 						New data
	# @param callback (Function(Error, Actuator):null):	Callback
	###
	updateAttributes: (data, callback) ->
		superUpdateAttributes = (data, callback) -> super data, callback
		prevData =
			customId: @customId
			name: @name
			driverId: @driverId
		# Update DB:
		superUpdateAttributes data, (err, actuator) ->
			if err
				callback err, actuator
			else
				# Update Driver:	
				actuatorsDrivers[@driverId].update prevData.customId, data.customId, (err2) ->
					if err2
						# Cancelling Modif:
						superUpdateAttributes prevData, (err3, actuator2) ->
							if err3
								callback 'Can\'t update Actuator in Driver & Can\'t reverse update in DB. Contact Admin (' + err2 + ' AND ' + err3 + ')', actuator2
							else
								callback err2, actuator2
					else
						callback null, actuator
	
	###
	# byDriver
	# ====
	# Finds drivers by their name.
	# @param driver (Driver): 								Driver
	# @param callback (Function(Error, Actuator[]):null): 	Callback
	###	
	@byDriver = (driver, callback) ->
		@request 'byDriver', key: driver.id, callback
		
		
	###
	# create
	# ====
	# Adds a actuator to the DB and system, if there is a driver to handle it. If a similar actuator already exists (same customId and driverId), then this actuator is returned.
	# @param data (Object): 							Data defining the actuator
	# @param callback (Function(Error, Actuator):null): 	Callback
	###
	@create: (data, callback) ->
		thisActuator = @
		superCreate = (data, callback) -> super data, callback
		if actuatorsDrivers[data.driverId] # If this kind of device is supported:
			# Check if this actuator isn't already added (the combination driverId + customId should be unique):
			params = key: [data.accountID, data.driverId]
			@request "byCustomIdAndDriver", params, (err, actuators)->
				if err
					callback err, null
				else if actuators.length isnt 0 # Actuator already exists.
					callback 'Device already added', actuators[0]
				else
					superCreate data, (err, actuator) ->
						if err
							callback err, null
							return
						
						# Let the driver handle the integration of the device to the system:
						actuatorsDrivers[driverId].add customId, actuator.id, (err) ->
							if err
								# Cancelling modif:
								thisActuator.requestDestroy "all", {key: actuator.id}, (err) ->
									callback err, null
							else
								callback null, actuator
		else
			callback 'Device not supported', null

	###
	# setDrivers
	# ====
	# Sets the list of Sensors Drivers.
	# @param ref (Object): 	Reference to the list.
	###
	@setDrivers: (ref) -> actuatorsDrivers = ref