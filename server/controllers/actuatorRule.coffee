###
# =================
# CONTROLLER - ActuatorRule
# =================
# Operations on ActuatorRules.
###

ActuatorRule = require '../models/actuatorRule'

module.exports.fetch = (req, res, next, id) ->
	ActuatorRule.find id, (err, actuatorRule) ->
		if err or not actuatorRule
			res.send error: "ActuatorRule not found", 404
		else
			req.actuatorRule = actuatorRule
			next()

module.exports.all = (req, res, next) ->
	ActuatorRule.all (err, results) ->
		return next err if err

		res.send 200, results

module.exports.read = (req, res) ->
	res.send req.actuatorRule

module.exports.update = (req, res) ->
	# @todo Prevent from updating ruleId and sensorId (or verify consistency of new ones)
	data = req.body
	req.actuatorRule.update data, (err, actuatorRule) ->
		if err?
			res.send error: "Server error while saving ActuatorRule", 500
		else
			res.send actuatorRule, 200

module.exports.delete = (req, res) ->
	req.actuatorRule.destroy (err) ->
		if err?
			res.send error: "Server error while deleting ActuatorRule", 500
		else
			res.send success: true, 200
