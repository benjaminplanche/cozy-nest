###
# =================
# Fixtures - Measure
# =================
# Test Fixtures for Rules.
###

module.exports = 
	measureMovement1:
		sensorId:	null
		time:		new Date(2015, 05, 24, 17, 31, 0)
		value: 		"1"
		type: 		"movement"

	measureMovement2:
		sensorId:	null
		time:		new Date(2015, 05, 24, 17, 32, 0)
		value: 		"6"
		type: 		"movement"

	measureMovement3:
		sensorId:	null
		time:		new Date(2015, 05, 24, 17, 33, 0)
		value: 		"0"
		type: 		"movement"
		

	intervalGetRequest:
		minTime: 		new Date(2015, 05, 24, 17, 31, 0)
		maxTime: 		new Date(2015, 05, 24, 17, 33, 0)
		