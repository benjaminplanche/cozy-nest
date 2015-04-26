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
		sensors[customId] = id
		callback null

module.exports.remove = (customId, id, callback) ->
	delete sensors[customId]
	return callback null

module.exports.update = (oldCustomId, newCustomId, callback) ->
	if sensors[newCustomId]
		callback 'Custom ID already used.'
	else
		sensors[oldCustomId] = sensors[newCustomId]
		sensors[newCustomId] = null
		callback null

