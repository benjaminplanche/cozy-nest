###
# =================
# CONTROLLER - SensorRule
# =================
# Operations on SensorRules.
###

SensorRule = require '../models/sensorRule'

module.exports.fetch = (req, res, next, id) ->
	SensorRule.find id, (err, sensorRule) ->
		if err
			res.send error: err, 500
		else if not sensorRule
			res.send error: 'SensorRule not found', 404
		else
			req.sensorRule = sensorRule
			next()

module.exports.all = (req, res, next) ->
	SensorRule.all (err, results) ->
		return next err if err

		res.send 200, results

module.exports.read = (req, res) ->
	res.send req.sensorRule

module.exports.update = (req, res) ->
	# @todo Prevent from updating ruleId and sensorId (or verify consistency of new ones)
	data = req.body
	req.sensorRule.updateAttributes data, (err, sensorRule) ->
		if err
			res.send error: err, 500
		else
			res.send req.sensorRule, 200