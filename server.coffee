###
# =================
# LAUNCHER - Server
# =================
# Launches the application.
###

americano = require 'americano'
	
module.exports.start = start = (options, callback) ->
	
	options ?= {}
	options.name = 'Nest'
	options.root ?= __dirname
	options.port ?= process.env.PORT or 9250
	options.host = process.env.HOST or '127.0.0.1'

	americano.start options, (err, app, server) ->
		return callback err if err
		
		module.exports.app = app
		cb?(null, app, server)


	if not module.parent
		application()