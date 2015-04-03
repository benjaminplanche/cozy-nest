###
# =================
# MODELS - REQUESTS
# =================
###

cozydb = require 'cozydb'


byCustomIdAndType = (doc) -> emit [doc.customId, doc.type], doc
byId: (doc) -> emit doc.id, doc

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
		# @todo byDateAndSensor
		
	# # create all the requests you want!
	# customRequest:
		# map: (doc) ->
			# # map function
		# reduce: (key, values, rereduce) ->
			# # non mandatory reduce function
