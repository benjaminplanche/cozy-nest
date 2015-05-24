###
# =================
# CONTROLLER - Sensor
# =================
# Operations on Sensors.
###

Sensor = require '../models/sensor'

module.exports.fetch = (req, res, next, id) ->
	Sensor.find id, (err, sensor) ->
		if err
			res.send error: err, 500
		else if not sensor
			res.send error: 'Sensor not found', 404
		else
			req.sensor = sensor
			next()

module.exports.all = (req, res, next) ->
	Sensor.all (err, results) ->
		return next err if err

		res.send 200, results

module.exports.read = (req, res) ->
	res.send req.sensor

module.exports.create = (req, res) ->
	data = req.body
	Sensor.create data, (err, sensor) ->
		if err
			if err == 'Device already added'
				res.send sensor, 202
			else
				res.send error: err, 500
		else
			res.send sensor, 201

module.exports.createMeasure = (req, res) ->
	data = req.body
	data.sensorId = req.sensor?.id
	req.sensor.createMeasure data, (err, measure) ->
		if err
			res.send error: err, 500
		else
			res.send measure, 201

module.exports.allMeasuresByTimeRange = (req, res) ->
	Measure.allBySensorAndTimeRange req.sensor?.id, req.query?.from, req.query?.to, (err, measures) ->
		if err
			res.send error: err, 500
		else
			res.send measures, 200


module.exports.update = (req, res) ->
	data = req.body
	req.sensor.updateAttributes data, (err, sensor) ->
		if err
			res.send error: err, 500
		else
			res.send sensor, 200

module.exports.delete = (req, res) ->
	req.sensor.destroy (err) ->
		if err
			res.send error: err, 500
		else
			res.send success: true, 200
