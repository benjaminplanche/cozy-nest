###
# =================
# Fixtures - Rule
# =================
# Test Fixtures for Rules.
###

module.exports = 
	rule1:
		name: "Rule #1"
		
	updateRule1:
		name: "Rule #1 v2"

	actuatorRuleSayHello:
		ruleId:		null
		actuatorId:	null
		value: 		"HELLO"

	actuatorRuleSayBye:
		ruleId:		null
		actuatorId:	null
		value: 		"BYE"

	updateActuatorRule:
		value: 		"HEY"

	sensorRuleIsMoving:
		ruleId:			null
		sensorId:		null
		type: 			"movement"
		intervalStart: 	"5"
		intervalEnd: 	"10"

	sensorRuleIsNotMoving:
		ruleId:			null
		sensorId:		null
		type: 			"movement"
		intervalStart: 	"5"
		intervalEnd: 	"10"

	sensorRuleIsButtonPressed:
		ruleId:			null
		sensorId:		null
		type: 			"button"
		intervalStart: 	"1"
		intervalEnd: 	"1"

	updateSensorRule:
		type: 			"newType"
		intervalStart: 	"-10"
		intervalEnd: 	"10"

