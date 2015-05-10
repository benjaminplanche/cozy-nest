###
# =================
# Fixtures - Driver
# =================
# Test Fixtures for Drivers.
###

os = require 'os'
fs = require 'fs'

module.exports = 
	basicActuatorDriver:
		name: "basicActuatorDriver"
		file: __dirname + "/basicActuatorDriver.coffee"
	basicSensorDriver:
		name: "basicDriver"
		file: __dirname + "/basicDriver.coffee"
	basicSensorDriverJS:
		name: "basicDriver"
		file: __dirname + "/basicDriver.js"
	basicSensorDriverTar:
		name: "basicDriver"
		file: __dirname + "/basicDriver.tar"
	basicSensorDriverZip:
		name: "basicDriver"
		file: __dirname + "/basicDriver.zip"
	basicSensorDriverTarGz:
		name: "basicDriver"
		file: __dirname + "/basicDriver.tar.gz"
	basicSensorDriverTarBz2:
		name: "basicDriver"
		file: __dirname + "/basicDriver.tar.bz2"
		
	unexistingSensorDriver:
		name: "Unexisting Driver"
		
	driverChunks: {
		isSensor: "module.exports.isSensor = true"
		isActuator: "module.exports.isActuator = true"
		
		init: """
		module.exports.init = (callback) ->
			return callback null
		"""
		
		add: """
		devices = []
		module.exports.add = (customId, id, callback) ->
			if devices[customId]
				callback 'Custom ID already used.'
			else
				devices[customId] = id
				callback null
		"""
		
		remove: """
		module.exports.remove = (customId, id, callback) ->
			delete sensors[customId]
			callback null
		"""
		
		update: """
		module.exports.update = (oldCustomId, newCustomId, callback) ->
			if devices[newCustomId]
				callback 'Custom ID already used.'
			else
				
				if isCustomIDValidExample newCustomId
					devices[newCustomId] = devices[oldCustomId]
					devices[oldCustomId] = null
					callback null
				else
					callback "Invalid CustomId"
		"""
		
		apply: """
		module.exports.apply = (customId, value, callback) ->
			console.log('DRIVER - Applying "+ value +" to Actuator ' + customId)
			callback null
		"""
		
		invalidSyntax: """
		XXXXXXXXXXXXX
		"""
	}
	generateDriver: (name, chunks, callback) ->
		content = ''
		content += @driverChunks[c] + '\n' for c in chunks
		path = os.tmpdir() + "/" + name + ".coffee"
		fs.writeFile path, content, (err) ->
			if err
				return callback null, err
			else
				return callback path, null
		