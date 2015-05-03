###
# =================
# Fixtures - Driver File
# =================
# Driver Example for Tests.
###

sensors = []

module.exports.isSensor = true

module.exports.init = (callback) ->
	return callback null

module.exports.add = (customId, id, callback) ->
	if sensors[customId]
		callback 'Custom ID already used.'
	else
		if isCustomIDValidExample customId
			sensors[customId] = id
			callback null
		else
			callback "Invalid CustomId"

module.exports.remove = (customId, id, callback) ->
	delete sensors[customId]
	return callback null

module.exports.update = (oldCustomId, newCustomId, callback) ->
	if sensors[newCustomId]
		callback 'Custom ID already used.'
	else
		
		if isCustomIDValidExample newCustomId
			# console.log("DRIVER - UPDATE IS VALID: " + newCustomId)
			sensors[oldCustomId] = sensors[newCustomId]
			sensors[newCustomId] = null
			callback null
		else
			# console.log("DRIVER - UPDATE IS NOT VALID: " + newCustomId)
			callback "Invalid CustomId"

isCustomIDValidExample = (customId) ->
	return !isNaN(parseInt(customId.split("ID")[1]))
