###
# =================
# Fixtures - Sensor
# =================
# Test Fixtures for Sensors.
###

module.exports = 
	supportedSensor1:
		customId: "ID1"
		name: "Supported Sensor #1"
		driverId: null
		
	supportedSensor2:
		customId: "ID2"
		name: "Supported Sensor #2"
		driverId: null
		
	unsupportedSensor:
		customId: "ID0"
		name: "Unsupported Sensor"
		driverId: "UnknownType"
		
	validUpdateForTestSensor:
		customId: "ID42"
		name: "Supported Sensor #1 v2"
		
	invalidUpdateForTestSensor:
		customId: "IDDefinitelyNotAValidValue"
