###
# =================
# Fixtures - Driver File
# =================
# Driver Example for Tests.
###

sensors = []

module.export.init = (callback) ->
	return callback null

modul.export.add = (customId, id, callback) ->
	if sensors[customId]
		callback 'Custom ID already used.'
	else
		sensors[customId] = id
		callback null

module.export.remove = (customId, id, callback) ->
	delete sensors[customId]
	return callback null

module.export.update = (oldCustomId, newCustomId, callback) ->
	if sensors[newCustomId]
		callback 'Custom ID already used.'
	else
		sensors[oldCustomId] = sensors[newCustomId]
		sensors[newCustomId] = null
		callback null

