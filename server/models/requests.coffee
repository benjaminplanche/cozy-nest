###
# =================
# MODELS - REQUESTS
# =================
###

cozydb = require 'cozydb'


byCustomIdAndType = (doc) -> emit [doc.customId, doc.type], doc
bySensorAndTime = (doc) -> emit [doc.sensorId, doc.time], doc
bySensorAndType = (doc) -> emit [doc.sensorId, doc.type], doc
bySensor = (doc) -> emit doc.sensorId, doc
byActuator = (doc) -> emit doc.actuatorId, doc
byRule = (doc) -> emit doc.ruleId, doc

module.exports =
	sensor:
		'all': cozydb.defaultRequests.all
		'byCustomIdAndType': byCustomIdAndType
	
	actuator:
		'all': cozydb.defaultRequests.all
		'byCustomIdAndType': byCustomIdAndType
	
	measure:
		'all': cozydb.defaultRequests.all
		'bySensorAndTime': bySensorAndTime
	
	rule:
		'all': cozydb.defaultRequests.all
	
	sensorRule:
		'all': cozydb.defaultRequests.all
		'byRule': byRule
		'bySensor': bySensor
		'bySensorAndType': bySensorAndType
	
	actuatorRule:
		'all': cozydb.defaultRequests.all
		'byRule': byRule
		'byActuator': byActuator

