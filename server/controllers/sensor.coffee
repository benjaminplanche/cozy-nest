Sensor = require '../models/sensor'

module.exports.fetch = (req, res, next, id) ->
	Sensor.find id, (err, sensor) ->
		if err or not sensor
			res.send error: "Sensor not found", 404
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
	Sensor.createIfDriver data, sensorsDrivers, (err, sensor) ->
		if err?
			# @todo Special case when error is 'Device already added'?
			res.send error: "Server error while creating sensor.", 500
		else
			res.send sensor, 201

module.exports.update = (req, res) ->
	data = req.body
	req.sensor.updateAttributes data, (err, sensor) ->
		if err?
			res.send error: "Server error while saving sensor", 500
		else
			res.send sensor, 200

module.exports.delete = (req, res) ->
	req.sensor.destroyFromDBAndDriver sensorsDrivers, (err) ->
		if err?
			res.send error: "Server error while deleting sensor", 500
		else
			res.send success: true, 200