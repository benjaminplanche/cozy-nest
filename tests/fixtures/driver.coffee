###
# =================
# Fixtures - Driver
# =================
# Test Fixtures for Drivers.
###

module.exports = 
	basicSensorDriver:
		name: "BasicDriver"
		file: __dirname + "/basicDriver.coffee"
		
	unexistingSensorDriver:
		name: "Unexisting Driver"