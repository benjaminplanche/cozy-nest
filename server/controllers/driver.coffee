###
# =================
# CONTROLLER - Driver
# =================
# Operations on Drivers.
###

logger = require('printit')
	prefix: 'driver'

fs = require 'fs'
multiparty = require 'multiparty'
path = require 'path'
mkdirp = require 'mkdirp'
decompress = require 'decompress'
async = require 'async'
rimraf = require 'rimraf'
Driver = require '../models/driver'

DRIVERS_DIR = __dirname + '/../drivers/'

module.exports.fetch = (req, res, next, id) ->
	Driver.find id, (err, driver) ->
		if err or not driver
			res.send error: 'Driver not found', 404
		else
			req.driver = driver
			next()

module.exports.all = (req, res, next) ->
	Driver.all (err, results) ->
		return next err if err

		res.send 200, results

module.exports.read = (req, res) ->
	res.send req.driver

module.exports.create = (req, res, next) ->
		
		# Parse form:
		form = new multiparty.Form
			keepExtensions: true
			maxFieldsSize: 10 * 1024 * 1024
			
		form.parse req, (err, fields, files) ->
			return next err if err
		
			cleanUp = ->
				for key, arrfile of files
					for file in arrfile
						fs.unlink file.path, (err) ->
							if err
								logger.error "Failed to cleanup file", file.path, err
			
			unless file = files['file']?[0]
				res.send error: 'No file sent', 400
				return cleanUp()

			data = 
				path : file
				
			Driver.create data, (err, driver) ->
				if err?
					if err == 'Driver already added'
						res.send driver, 202
					else
						res.send error: 'Server error while creating Driver.', 500
				else
					res.send driver, 201
				
				cleanUp()

module.exports.update = (req, res) ->
	data = req.body
	req.driver.updateAttributes data, (err, driver) ->
		if err?
			res.send error: 'Server error while saving Driver', 500
		else
			res.send driver, 200

module.exports.delete = (req, res) ->
	req.driver.destroy (err) ->
		if err?
			res.send error: 'Server error while deleting Driver', 500
		else
			res.send success: true, 200