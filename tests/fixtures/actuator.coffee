###
# =================
# Fixtures - Actuator
# =================
# Test Fixtures for Actuators.
###

module.exports = 
	supportedActuator1:
		customId: "ID1"
		name: "Supported Actuator #1"
		driverId: null
		
	supportedActuator2:
		customId: "ID2"
		name: "Supported Actuator #2"
		driverId: null
		
	unsupportedActuator:
		customId: "ID0"
		name: "Unsupported Actuator"
		driverId: "UnknownType"
		
	validUpdateForTestActuator:
		customId: "ID42"
		name: "Supported Actuator #1 v2"
		
	invalidUpdateForTestActuator:
		customId: "IDDefinitelyNotAValidValue"
		
	validApplyValueForTestActuator:
		value: "FLY"