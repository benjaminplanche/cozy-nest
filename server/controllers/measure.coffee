###
# =================
# CONTROLLER - Measure
# =================
# Operations on Measures. Note that Measures are only created through Sensor instances.
###

Measure = require '../models/measure'

module.exports.fetch = (req, res, next, id) ->
	Measure.find id, (err, measure) ->
		if err
			res.send error: err, 500
		else if not measure
			res.send error: "Measure not found", 404
		else
			req.measure = measure
			next()

module.exports.all = (req, res, next) ->
	Measure.all (err, results) ->
		return next err if err

		res.send 200, results

module.exports.read = (req, res) ->
	res.send req.measure

module.exports.update = (req, res) ->
	res.send error: "Measures can't be updated", 401
	###data = req.body
	req.measure.update data, (err, measure) ->
		if err
			res.send error: err, 500
		else
			res.send measure, 200###

module.exports.delete = (req, res) ->
	req.measure.destroy (err) ->
		if err
			res.send error: err, 500
		else
			res.send success: true, 200
