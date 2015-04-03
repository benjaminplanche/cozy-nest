###
# =================
# CONTROLLER - Rule
# =================
# Operations on Rules.
###

Rule = require '../models/rule'

module.exports.fetch = (req, res, next, id) ->
	Rule.find id, (err, rule) ->
		if err or not rule
			res.send error: "Rule not found", 404
		else
			req.rule = rule
			next()

module.exports.all = (req, res, next) ->
	Rule.all (err, results) ->
		return next err if err

		res.send 200, results

module.exports.read = (req, res) ->
	res.send req.rule

module.exports.create = (req, res) ->
	data = req.body
	Rule.create data, (err, rule) ->
		if err?
			res.send error: "Server error while creating rule.", 500
		else
			res.send rule, 201

module.exports.createSensorRule = (req, res) ->
	data = req.body
	req.rule.createSensorRule data, (err, sensorRule) ->
		if err
			res.send error: "Server error while creating SensorRule.", 500
		else
			res.send sensorRule, 201


module.exports.createActuatorRule = (req, res) ->
	data = req.body
	req.rule.createActuatorRule data, (err, actuatorRule) ->
		if err
			res.send error: "Server error while creating ActuatorRule.", 500
		else
			res.send actuatorRule, 201

module.exports.update = (req, res) ->
	data = req.body
	req.rule.update data, (err, rule) ->
		if err?
			res.send error: "Server error while saving rule", 500
		else
			res.send rule, 200

module.exports.delete = (req, res) ->
	req.rule.destroy (err) ->
		if err?
			res.send error: "Server error while deleting rule", 500
		else
			res.send success: true, 200
