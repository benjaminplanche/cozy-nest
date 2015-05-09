###
# =================
# CONTROLLER - Routes
# =================
# Routes to call the controllers.
###

sensor			= require './sensor'
actuator		= require './actuator'
measure         = require './measure'
driver         = require './driver'
rule			= require './rule'
sensorRule		= require './sensorRule'
actuatorRule	= require './actuatorRule'

module.exports =

    # Fetch on params
    'sensorId': 	param: sensor.fetch
    'actuatorId': 	param: actuator.fetch
    'ruleId': 		param: rule.fetch
    'measureId': 	param: measure.fetch
    'driverId':     param: driver.fetch

    'sensors/?':
        get: sensor.all
        post: sensor.create

    'sensors/:sensorId/?':
        get: sensor.read
        put: sensor.update
        delete: sensor.delete

    'sensors/:sensorId/measures?':
        # @todo Get by Sensor + Date (opt): get: sensor.getMeasuresByDate
        post: sensor.createMeasure

    'actuators/?':
        get: actuator.all
        post: actuator.create

    'actuators/:actuatorId/?':
        get: actuator.read
        put: actuator.update
        delete: actuator.delete

    'drivers/?':
        get: driver.all
        post: driver.create

    'drivers/:driverId/?':
        get: driver.read
        put: driver.update
        delete: driver.delete

    'rules/?':
        get: rule.all
        post: rule.create

    'rules/:ruleId/?':
        get: rule.read
        put: rule.update
        delete: rule.delete

    'rules/:ruleId/sensorRules?':
        # @todo Get by Rule: get: sensor.getSensorRules
        post: rule.createSensorRule
	

    'rules/:ruleId/actuatorRules?':
        # @todo Get by Rule: get: sensor.getActuatorRules
        post: rule.createActuatorRule