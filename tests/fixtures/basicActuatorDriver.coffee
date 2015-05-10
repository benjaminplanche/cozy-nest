###
# =================
# Fixtures - Actuator Driver File
# =================
# Actuator Driver Example for Tests.
###

actuators = {}
applyCalls = []

module.exports.isActuator = true

areDevicesRemovable = true 
module.exports.setRemovableFlag = (flag) -> areDevicesRemovable = flag

module.exports.getSensor = (customId) -> return actuators[customId]
module.exports.getApplyCall = (num) -> return applyCalls[num]

module.exports.init = (callback) ->
	return callback null

module.exports.add = (customId, id, callback) ->
	if actuators[customId]
		callback 'Custom ID already used.'
	else
		if isCustomIDValidExample customId
			actuators[customId] = id
			callback null
		else
			callback "Invalid CustomId"

module.exports.remove = (customId, id, callback) ->
	if areDevicesRemovable
		delete actuators[customId]
		callback null
	else
		callback "Device not removable"

module.exports.apply = (customId, value, callback) ->
	applyCalls.push [customId, value]
	callback null

module.exports.update = (oldCustomId, newCustomId, callback) ->
	if actuators[newCustomId]
		callback 'Custom ID already used.'
	else
		
		if isCustomIDValidExample newCustomId
			# console.log("DRIVER - UPDATE IS VALID: " + newCustomId)
			actuators[newCustomId] = actuators[oldCustomId]
			actuators[oldCustomId] = null
			callback null
		else
			# console.log("DRIVER - UPDATE IS NOT VALID: " + newCustomId)
			callback "Invalid CustomId"

isCustomIDValidExample = (customId) ->
	return !isNaN(parseInt(customId.split("ID")[1]))
