###
# =================
# MODELS - REQUESTS
# =================
###

cozydb = require 'cozydb'


byCustomIdAndDriver = (doc) -> emit [doc.customId, doc.driverId], doc
bySensorAndTime = (doc) -> emit [doc.sensorId, doc.time], doc
bySensorAndType = (doc) -> emit [doc.sensorId, doc.type], doc
bySensor = (doc) -> emit doc.sensorId, doc
byActuator = (doc) -> emit doc.actuatorId, doc
byRule = (doc) -> emit doc.driverId, doc
byDriver = (doc) -> emit doc.driverId, doc
byName = (doc) -> emit doc.name, doc

module.exports =
	sensor:
		'all': cozydb.defaultRequests.all
		'byCustomIdAndDriver': byCustomIdAndDriver
		'byDriver': byDriver
	
	actuator:
		'all': cozydb.defaultRequests.all
		'byCustomIdAndDriver': byCustomIdAndDriver
		'byDriver': byDriver
	
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
	
	driver:
		'all': cozydb.defaultRequests.all
		'byName': byName

