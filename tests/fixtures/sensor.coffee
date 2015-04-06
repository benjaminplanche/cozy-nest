###
# =================
# Fixtures - Sensor
# =================
# Test Fixtures for Sensors.
###

module.exports.supportedSensor1:
	customId: "ID1"
	name: "Supported Sensor #1"
	type: "TestSensor
	
module.exports.supportedSensor2:
	customId: "ID2"
	name: "Supported Sensor #2"
	type: "TestSensor"
	
module.exports.unsupportedSensor:
	customId: "ID0"
	name: "Unsupported Sensor"
	type: "UnknownType"
	
module.exports.validUpdateForTestSensor:
	customId: "ID42"
	
module.exports.invalidUpdateForTestSensor:
	customId: "IDNaN"
