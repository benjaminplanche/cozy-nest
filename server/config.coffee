americano = require 'americano'
Realtimer = require 'cozy-realtime-adapter'

config =
	common: 
		use: [
			americano.bodyParser()
			americano.methodOverride()
			americano.errorHandler
				dumpExceptions: true
				showStack: true
			americano.static __dirname + '/../client/public',
				maxAge: 86400000
		]
		afterStart: (app, server) ->

			app.server = server
			
			# @todo Load Drivers
			# actuatorsDrivers = ...
			# sensorsDrivers = ...

			# @todo Pass their reference to controllers:
			# require('./controllers/actuator').setDrivers actuatorsDrivers
			# require('./controllers/sensor').setDrivers sensorsDrivers

			# Initialize Realtime
			realtime = RealtimeAdapter server, ['nest.*']);
			
	development: [
		americano.logger 'dev'
	]

	production: [
		americano.logger 'short'
	]

	plugins: [
		'cozydb'
	]

module.exports = config