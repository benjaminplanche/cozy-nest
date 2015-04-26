americano = require 'americano'
RealtimeAdapter = require 'cozy-realtime-adapter'

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
            
            # Load Drivers & Pass their reference to models:
            actuatorsDrivers = {}
            sensorsDrivers = {}

            require('./models/actuator').setDrivers actuatorsDrivers
            require('./models/sensor').setDrivers sensorsDrivers
            require('./models/driver').setDrivers sensorsDrivers, actuatorsDrivers

            # Initialize Realtime
            realtime = RealtimeAdapter server, ['nest.*']
            
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