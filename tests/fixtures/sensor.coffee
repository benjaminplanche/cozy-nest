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
		type: "TestSensor"
		
	supportedSensor2:
		customId: "ID2"
		name: "Supported Sensor #2"
		type: "TestSensor"
		
	unsupportedSensor:
		customId: "ID0"
		name: "Unsupported Sensor"
		type: "UnknownType"
		
	validUpdateForTestSensor:
		customId: "ID42"
		
	invalidUpdateForTestSensor:
		customId: "IDNaN"
