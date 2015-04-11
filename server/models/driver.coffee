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
cozydb = require 'cozydb'

const DRIVERS_DIR = '../drivers/'

sensorsDrivers = null # List of drivers supported by the system - Must be set when server starts.
module.exports.setDrivers = (ref) -> sensorsDrivers = ref

module.exports = class Driver extends cozydb.CozyModel
	@schema:
		name: 		type : String		# not Empty
		
	
	###
	# destroy
	# ====
	# Deletes the Driver, if there is no Sensor depending on it
	# @param callback (Function(Error):null):		Callback
	###
	destroy: (callback) ->
		superDestroy = super
		### 
		# Find if there are still sensors depending on this driver:
		
			# If yes, return an error:
			
			# Else stop the driver and delete it (files + instance in DB):
			
		sensorsDrivers[@type].remove @customId, (err2) ->
			if err2
				callback err2
			else
				# Remove from DB:
				superDestroy (err3) ->
					if err3
						# Cancelling Modif:
						sensorsDrivers[@type].remove prevDriver.customId, id, (err2) ->
							if err2
								callback 'Device removed from system but not DB. Contact Admin (' + err3 + ' AND ' + err2 + ')'
							else
								callback err3
					else
						callback null ###
	
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
	@byCalendar = (name, callback) ->
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
						unless driverModule.add and driverModule.remove and driver.update and driver.init and driver.apply
							callback 'Driver not implementing the interface', null
							
						driverModule.init (err) ->
							if err
								callback 'Error initializing the driver', null
							else
								# If everything worked, save the Driver instance in DB:
								data =
									name: file.name
								superCreate data, callback