###
# =================
# SCHEMA - Driver
# =================
# Defines a Driver, interfacing with devices
###

fs = require 'fs'
multiparty = require 'multiparty'
path = require 'path'
mkdirp = require 'mkdirp'
decompress = require 'decompress'
async = require 'async'
rimraf = require 'rimraf'
cozydb = require 'cozydb'

Sensor = require './sensor'
Actuator = require './actuator'

const DRIVERS_DIR = '../drivers/'

actuatorsDrivers = null
sensorsDrivers = null # List of drivers supported by the system - Must be set when server starts.
module.exports.setDrivers = (refS, refA) -> 
	sensorsDrivers = refS
	actuatorsDrivers = refA

module.exports = class Driver extends cozydb.CozyModel
	@schema:
		name: 		type : String		# not Empty
		isActuator:	type : Boolean		# not Empty
		isSensor:	type : Boolean		# not Empty
		
	
	###
	# destroy
	# ====
	# Deletes the Driver, if there is no Sensor depending on it
	# @param callback (Function(Error):null):		Callback
	###
	destroy: (callback) ->
		superDestroy = super
		thisDriver = @
		
		# Find if there are still devices depending on this driver:
		async.parallel [
			(cb) ->
				if thisDriver.isSensor
					# @todo Perf: use a request Sensor.countByDriver (with a reduce) instead?
					Sensor.byDriver thisDriver (err, sensors) ->
						cb err, sensors?.length
				else cb null, 0
			,
			(cb) ->
				if thisDriver.isActuator
					# @todo Perf: use a request Actuator.countByDriver (with a reduce) instead?
					Actuator.byDriver thisDriver (err, actuators) ->
						cb err, actuators?.length
				else cb null, 0
		 ], (err, results) ->
			if err
				callback 'DB Error'
			else if (results[0] + results[1]) > 0
				callback 'Devices still using this driver'
			else
				# Stop the driver and delete it (files + instance in DB):
				async.parallel [
					(cb) -> superDestroy ((err) -> cb 'Error removing driver from DB', null)
					,
					(cb) -> rimraf (DRIVERS_DIR + thisDriver.name), ((err) -> cb 'Error removing driver\'s files', null)
					,
					(cb) -> 
						err = null
						try
							delete sensorsDrivers[thisDriver.id] if thisDriver.isSensor
							delete actuatorsDrivers[thisDriver.id] if thisDriver.isActuator
						catch e
							err = 'Error removing driver\'s module'
						finally
							cb err, null
				], (err, results) ->
					callback err
	
	###
	# updateAttributes
	# ====
	# Prevents updates on the object.
	# @param data (dictionary): 						New data
	# @param callback (Function(Error, Driver):null):	Callback
	###
	updateAttributes: (data, callback) ->
		callback 'Drivers can\'t be updated', driver


	###
	# byName
	# ====
	# Finds drivers by their name.
	# @param name (string): 								Name
	# @param callback (Function(Error, Driver[]):null): 	Callback
	###	
	@byName = (name, callback) ->
		@request 'byName', key: name, callback

	###
	# create
	# ====
	# Adds a driver to the DB and system (unzipping its files and initializing its node module). If a similar driver already exists (same name), then this driver is returned.
	# @param data (Object): 							Data defining the driver
	# @param callback (Function(Error, Driver):null): 	Callback
	###
	@create: (data, callback) ->
		superCreate = super
		
		file = data.file
		unless file.ext = path.extname(file.originalFilename) and file.ext in ['.zip', '.tar', '.tar.bz2', '.tar.gz']
			callback 'Unknown file extension', null
			return cleanUp()
		unless file.name = path.basename(file.originalFilename, file.ext)
			callback 'Unknown file name', null
			return cleanUp()
		
		# Check if this driver isn't already added (the name should be unique):
		@byName file.name (err, drivers)->
			if err
				callback 'DB error', null
			else if drivers.length isnt 0 # Driver already exists.
				callback 'Driver already added', drivers[0]
			else
				# Create directory for the driver's files:
				dirName = DRIVERS_DIR+file.name
				mkdirp(dirName, (err) ->
					if err
						callback 'Error creating the directory for the driver', null
						return
						
					# Unzip in it:
					plug = [
						'.zip' : decompress.zip,
						'.tar' : decompress.tar,
						'.tar.bz2' : decompress.tarbz2,
						'.tar.gz' : decompress.targz][file.ext]
						
					new decompress( mode: '755' )
					 .src file.path
					 .dest dirName
					 .use plug strip: 1
					 .run (err) ->
						if err
							callback 'Error unzipping the driver', null
							return
				
						# Initialize the driver:
						unless driverModule = require dirName + file.name
							callback 'Couldn\'t find module', null
						unless isActuator = driverModule.isActuator or isSensor = driverModule.isSensor # or (!isActuator and !isSensor)
							callback 'Driver not defining if for Sensors and/or Actuators', null
							
						unless driverModule.add and driverModule.remove and driver.update and driver.apply and (!isActuator or driver.init)
							callback 'Driver not implementing the interface', null
							
						driverModule.init (err) ->
							if err
								callback 'Error initializing the driver', null
							else
								# If everything worked, save the Driver instance in DB:
								data =
									name: file.name
									isSensor: isSensor
									isActuator: isActuator
								superCreate data, (err, driver) ->
									if err
										callback 'Error saving the driver in DB', null
									else
										sensorsDrivers[driver.id] = driverModule if driver.isSensor
										actuatorsDrivers[driver.id] = driverModule if driver.isActuator
										callback null, driver
								