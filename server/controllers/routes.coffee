###
# =================
# CONTROLLER - Routes
# =================
# Routes to call the controllers.
###

sensor			= require './sensor'
actuator		= require './actuator'
measure			= require './measure'
rule			= require './rule'
sensorRule		= require './sensorRule'
actuatorRule	= require './actuatorRule'

module.exports =

    # Fetch on params
    'sensorId': 	param: sensor.fetch
    'actuatorId': 	param: actuator.fetch
    'ruleId': 		param: rule.fetch
    'measureId': 	param: measure.fetch

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