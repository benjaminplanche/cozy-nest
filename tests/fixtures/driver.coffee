###
# =================
# Fixtures - Driver
# =================
# Test Fixtures for Drivers.
###

module.exports = 
	basicSensorDriver:
		name: "basicDriver"
		file: __dirname + "/basicDriver.coffee"
		
	unexistingSensorDriver:
		name: "Unexisting Driver"