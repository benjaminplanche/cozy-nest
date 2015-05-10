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
	Actuator.create data, (err, actuator) ->
		if err
			if err == 'Device already added'
				res.send actuator, 202
			else
				res.send error: err, 500
		else
			res.send actuator, 201

module.exports.update = (req, res) ->
	data = req.body
	req.actuator.updateAttributes data, (err, actuator) ->
		if err
			res.send error: err, 500
		else
			res.send actuator, 200

module.exports.delete = (req, res) ->
	req.actuator.destroy (err) ->
		if err
			res.send error: err, 500
		else
			res.send success: true, 200