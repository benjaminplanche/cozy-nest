###
# =================
# SCHEMA - Actuator
# =================
# Defines an Actuator, to apply Rules.
###

cozydb = require 'cozydb'

module.exports = class Actuator extends cozydb.CozyModel
	@schema:
		customId: 	type : String		# not Empty
		name: 		type : String		# not Empty
		type: 		type : String		# not Empty
	
	###
	# destroyFromDBAndDriver
	# ====
	# Deletes the Actuator, both from the DB and Driver
	# @param actuatorsDrivers (Driver[]): 			List of drivers supported by the system
	# @param callback (Function(Error):null):		Callback
	###
	destroyFromDBAndDriver: (actuatorsDrivers, callback) ->
		actuatorsDrivers[@type].remove @customId, (err2) ->
			if err2
				callback err2
			else
				# Remove from DB:
				@destroy (err3) ->
					if err3
						# Cancelling Modif:
						actuatorsDrivers[@type].remove prevActuator.customId, id, (err2) ->
							if err2
								callback 'Device removed from system but not DB. Contact Admin (' + err3 + ' AND ' + err2 + ')'
							else 
								callback err3
					else
						callback null
	
	###
	# updateAttributesForDBAndDriver
	# ====
	# Updates data about the Actuator, both for the DB and Driver
	# @param data (dictionary): 						New data
	# @param actuatorsDrivers (Driver[]): 				List of drivers supported by the system
	# @param callback (Function(Error, Actuator):null):	Callback
	###
	# @todo Cover special case if "type" is changed -> Then the driver taking care of this device must be changed too!
	updateAttributesForDBAndDriver: (data, actuatorsDrivers, callback) ->
		prevData =
			customId: @customId
			name: @name
			type: @type
		# Update DB:
		@updateAttributes data, (err, actuator) ->
			if err
				callback err, actuator
			else
				# Update Driver:	
				actuatorsDrivers[@type].update prevData.customId, data.customId, (err2) ->
					if err2
						# Cancelling Modif:
						@updateAttributes prevData, (err3, actuator2) ->
							if err3
								callback 'Can\'t update Actuator in Driver & Can\'t reverse update in DB. Contact Admin (' + err2 + ' AND ' + err3 + ')', actuator2
							else
								callback err2, actuator2
					else
						callback null, actuator
	
	
	# ###
	# # byId
	# # ====
	# # Gets an Actuator using its ID.
	# # @param id (ID): 							ID
	# # @param callback (Function(Error, Actuator):null): 	Callback
	# ###
	# @byId: (id, callback) ->
		# param =
			# key: [id]
		# ActuatorModel.request 'byId', param, callback
		
	###
	# getOrCreate
	# ====
	# Gets an Actuator, or creates it if not found.
	# @param data (Object): 								Data defining the actuator
	# @param callback (Function(Error, Actuator, bool):null): Callback function. 2nd parameter is the found or created Actuator; 3rd parameter is a boolean set true if created / false if found.
	###
	@getOrCreate: (data, callback) ->
		# customId + type is a primary key.
		params = key: [accountID, type]
		ActuatorModel.request "byCustomIdAndType", params, (err, actuators)->
		if err
			callback err, null, null
		else if actuators.length is 0
			callbackCreate = (err, actuator) ->
				callback err, actuator, true
			ActuatorModel.create data, callbackCreate
		else # Actuator already exists.
			callback err, actuators[0], false
			
	###
	# createIfDriver
	# ====
	# Adds an actuator to the DB and system, if there is a driver to handle it.
	# @param data (Object): 						Data defining the actuator
	# @param actuatorsDrivers (Driver[]): 			List of drivers supported by the system
	# @param callback (Function(Error, Actuator):null): 	Callback
	###
	@createIfDriver: (data, actuatorsDrivers, callback) ->
		if actuatorsDrivers[type] # If this kind of device is supported:
			# Check if this actuator isn't already added (the combination type + customId should be unique):
			Actuator.getOrCreate data, (err, actuator, created) ->
				if err
					callback err, actuator
				else if !created
					callback 'Device already added', actuator
				else	
					# Let the driver handle the integration of the device to the system:
					actuatorsDrivers[type].add customId, actuator.id, (err) ->
						if err
							# Cancelling modif:
							Actuator.requestDestroy "all", {key: actuator.id}, (err) ->
								callback err, null
						else
							callback null, actuator
		else
			callback 'Device not supported', null