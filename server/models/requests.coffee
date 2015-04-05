###
# =================
# MODELS - REQUESTS
# =================
###

cozydb = require 'cozydb'


byCustomIdAndType = (doc) -> emit [doc.customId, doc.type], doc
bySensorAndTime = (doc) -> emit [doc.sensorId, doc.time], doc
byId: (doc) -> emit doc.id, doc
bySensor: (doc) -> emit doc.sensorId, doc
byActuator: (doc) -> emit doc.actuatorId, doc
byRule: (doc) -> emit doc.ruleId, doc

module.exports =
    sensor:
        all: cozydb.defaultRequests.all
		byCustomIdAndType: byCustomIdAndType
		byId: byId
	
	actuator:
        all: cozydb.defaultRequests.all
		byCustomIdAndType: byCustomIdAndType
		byId: byId
	
	measure:
        all: cozydb.defaultRequests.all
		byId: byId
		bySensorAndTime: bySensorAndTime
	
	rule:
        all: cozydb.defaultRequests.all
		byId: byId
	
	sensorRule:
        all: cozydb.defaultRequests.all
		byId: byId
		byRule: byRule
		bySensor: bySensor
	
	actuatorRule:
        all: cozydb.defaultRequests.all
		byId: byId
		byRule: byRule
		byActuator: byActuator
		
	# # create all the requests you want!
	# customRequest:
		# map: (doc) ->
			# # map function
		# reduce: (key, values, rereduce) ->
			# # non mandatory reduce function
