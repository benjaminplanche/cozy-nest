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
		
        # # create all the requests you want!
        # customRequest:
            # map: (doc) ->
                # # map function
            # reduce: (key, values, rereduce) ->
                # # non mandatory reduce function
