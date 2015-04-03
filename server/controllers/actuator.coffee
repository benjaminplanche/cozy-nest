###
# =================
# CONTROLLER - Actuator
# =================
# Operations on Actuators.
###

Actuator = require '../models/actuator'

module.exports.fetch = (req, res, next, id) ->
	Actuator.find id, (err, actuator) ->
		if err or not actuator
			res.send error: "Actuator not found", 404
		else
			req.actuator = actuator
			next()

module.exports.all = (req, res, next) ->
	Actuator.all (err, results) ->
		return next err if err

		res.send 200, results

module.exports.read = (req, res) ->
	res.send req.actuator

module.exports.create = (req, res) ->
	data = req.body
	Actuator.createIfDriver data, actuatorsDrivers, (err, actuator) ->
		if err?
			# @todo Special case when error is 'Device already added'?
			res.send error: "Server error while creating actuator.", 500
		else
			res.send actuator, 201

module.exports.update = (req, res) ->
	data = req.body
	req.actuator.updateAttributesForDBAndDriver data, actuatorsDrivers, (err, actuator) ->
		if err?
			res.send error: "Server error while saving actuator", 500
		else
			res.send actuator, 200

module.exports.delete = (req, res) ->
	req.actuator.destroyFromDBAndDriver actuatorsDrivers, (err) ->
		if err?
			res.send error: "Server error while deleting actuator", 500
		else
			res.send success: true, 200
