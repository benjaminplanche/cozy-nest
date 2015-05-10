###
# =================
# SCHEMA - Driver
# =================
# Defines a Driver, interfacing with devices
###

require 'coffee-script/register'
Coffeescript = require 'coffee-script'

fs = require 'fs'
multiparty = require 'multiparty'
path = require 'path'
mkdirp = require 'mkdirp'
async = require 'async'
rimraf = require 'rimraf'
{copyFile, decompress} = require('../helpers')
cozydb = require 'cozydb'

Sensor = require './sensor'
Actuator = require './actuator'

DRIVERS_DIR = __dirname + '/../drivers/'

actuatorsDrivers = null
sensorsDrivers = null # List of drivers supported by the system - Must be set when server starts.

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
		superDestroy = (callback) => super callback
		thisDriver = @
		
		# Find if there are still devices depending on this driver:
		async.parallel [
			(cb) ->
				if thisDriver.isSensor
					# @todo Perf: use a request Sensor.countByDriver (with a reduce) instead?
					Sensor.byDriver thisDriver, (err, sensors) ->
						cb err, sensors?.length
				else cb null, 0
			,
			(cb) ->
				if thisDriver.isActuator
					# @todo Perf: use a request Actuator.countByDriver (with a reduce) instead?
					Actuator.byDriver thisDriver, (err, actuators) ->
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
					(cb) -> superDestroy cb
					,
					(cb) ->
						dirPath = DRIVERS_DIR + thisDriver.name + "/"
						modulePath = path.resolve  dirPath, thisDriver.name
						# Removing module from cache:
						delete require.cache[require.resolve(modulePath)]
						# Deleting module directory:
						rimraf dirPath, cb
					,
					(cb) -> 
						try
							delete sensorsDrivers[thisDriver.id] if thisDriver.isSensor
							delete actuatorsDrivers[thisDriver.id] if thisDriver.isActuator
							cb null, null
						catch err
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
	# @param file (Object): 							Data defining the driver
	# @param callback (Function(Error, Driver):null): 	Callback
	###
	@create: (file, callback) ->
		superCreate = (data, callback) => super data, callback

		file.ext = path.extname(file.path)
		unless file.ext in ['.zip', '.js', '.coffee'] # , '.tar', '.tar.bz2', '.tar.gz']
			return callback 'Unknown file extension', null

		file.name = path.basename(file.originalFilename, file.ext)
		unless file.name
			return callback 'Unknown file name', null
		
		# Check if this driver isn't already added (the name should be unique):
		@byName file.name, (err, drivers)->
			if err
				callback 'DB error', null
			else if drivers.length isnt 0 # Driver already exists.
				callback 'Driver already added', drivers[0]
			else
				# If zipped, unzip. Otherwise copy it to its own folder:
				dirName = DRIVERS_DIR + file.name + "/"
				modulePath = path.resolve dirName, file.name

				if file.ext in ['.zip', '.tar', '.tar.bz2', '.tar.gz']
					# Unzip it:
					decompress file.path, DRIVERS_DIR, file.ext, (err) ->
						if err
							callback 'Error unzipping the driver', null
						else
							initializeDriver()
				else
					mkdirp dirName, (err) ->
						if err
							callback 'Error creating the directory for the driver', null
						else
							copyFile file.path, modulePath + file.ext, initializeDriver
							# fs.createReadStream(file.path).pipe(fs.createWriteStream(dirName + file.name + file.ext))
							# initializeDriver()

				# Initialize the driver:
				
				# js = Coffeescript.compile( path.resolve(dirName, file.name+".coffee"))
				
				initializeDriver = () ->
					try
						driverModule = require modulePath
					catch
						callback 'Couldn\'t find module', null
					console.log "MODULE: " + JSON.stringify driverModule
					
					isActuator = driverModule.isActuator or false
					isSensor = driverModule.isSensor or false
					
					unless isActuator or isSensor # or (!isActuator and !isSensor)
						callback 'Driver not defining if for Sensors and/or Actuators', null
						
					unless driverModule.add and driverModule.remove and driverModule.update and driverModule.init and (isActuator isnt true or driverModule.apply)
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
							
							superCreate data, (err, d) ->
								if err
									callback 'Error saving the driver in DB', null
								else
									sensorsDrivers[d.id] = driverModule if d.isSensor
									actuatorsDrivers[d.id] = driverModule if d.isActuator
									callback null, d

	###
	# reinit
	# ====
	# Re-initializes the drivers and their devices
	# @param callback (Function(Error):null): 	Callback
	###
	@reinit: (callback) ->
		@request 'all', (err, drivers) ->
			return callback err if err
			
			# Clearing the previous drivers arrays (without changing the ref!)
			for k,v in sensorsDrivers
				delete sensorsDrivers[k] if sensorsDrivers.hasOwnProperty(k)

			for k,v in actuatorsDrivers
				delete actuat

			# Refilling them:
			for driver in drivers
				driverModule = require (DRIVERS_DIR + file.name + "/" + file.name) 
				driverModule.init (err) ->
					return callback 'Error initializing the drivers' if err
					
					sensorsDrivers[driver.id] = driverModule if driver.isSensor
					actuatorsDrivers[driver.id] = driverModule if driver.isActuator
			
			# Readding the devices per driver:
			async.parallel [
				(cb) ->
					Sensor.request 'all', (err, sensors) ->
						return cb err, null if err
						
						async.each sensors, (sensor, cb2) ->
							sensorsDrivers[sensor.driverId].add sensor.customId, sensor.id, cb2
						, cb
				, (cb) ->
					Actuator.request 'all', (err, actuators) ->
						return cb err, null if err
						
						async.each actuators, (actuator, cb2) ->
							sensorsDrivers[actuator.driverId].add actuator.customId, actuator.id, cb2
						, cb
			], (err, results) -> callback err
	
	###
	# setDrivers
	# ====
	# Sets the lists of Sensors Drivers and Actuators Drivers.
	# @param refS (Object): 	Reference to the list of Sensors Drivers.
	# @param refA (Object): 	Reference to the list of Actuators Drivers.
	###
	@setDrivers: (refS, refA) ->
		sensorsDrivers = refS
		actuatorsDrivers = refA