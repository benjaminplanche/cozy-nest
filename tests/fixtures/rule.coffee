###
# =================
# Fixtures - Rule
# =================
# Test Fixtures for Rules.
###

module.exports = 
	rule1:
		name: "Rule #1"

	actuatorRuleSayHello:
		ruleId:		null
		actuatorId:	null
		value: 		"HELLO"

	actuatorRuleSayBye:
		ruleId:		null
		actuatorId:	null
		value: 		"BYE"

	sensorRuleIsMoving:
		ruleId:			null
		sensorId:		null
		type: 			"movement"
		intervalStart: 	5
		intervalEnd: 	10

	sensorRuleIsNotMoving:
		ruleId:			null
		sensorId:		null
		type: 			"movement"
		intervalStart: 	5
		intervalEnd: 	10

	sensorRuleIsButtonPressed:
		ruleId:			null
		sensorId:		null
		type: 			"button"
		intervalStart: 	1
		intervalEnd: 	1

