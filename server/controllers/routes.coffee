###
# =================
# CONTROLLER - Routes
# =================
# Routes to call the controllers.
###

sensor			= require './sensor'
actuator		= require './actuator'
measure         = require './measure'
driver          = require './driver'
rule			= require './rule'
sensorRule		= require './sensorRule'
actuatorRule	= require './actuatorRule'

module.exports =

    # Fetch on params
    'sensorId': 	param: sensor.fetch
    'actuatorId': 	param: actuator.fetch
    'ruleId': 		param: rule.fetch
    'measureId':    param: measure.fetch
    'driverId':     param: driver.fetch
    'sensorRuleId': param: sensorRule.fetch

    'sensors/?':
        get: sensor.all
        post: sensor.create

    'sensors/:sensorId/measures?':
        # @todo Get by Sensor + Date (opt): get: sensor.getMeasuresByDate
        post: sensor.createMeasure

    'sensors/:sensorId/?':
        get: sensor.read
        put: sensor.update
        delete: sensor.delete

    'actuators/?':
        get: actuator.all
        post: actuator.create

    'actuators/:actuatorId/apply?':
        post: actuator.apply

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

    'rules/:ruleId/sensorRules/?':
        # @todo Get by Rule: get: sensor.getSensorRules
        post: rule.createSensorRule

    'rules/:ruleId/sensorRules/:sensorRuleId?':
        # @todo Get by Rule: get: sensor.getSensorRules
        get: sensorRule.read
        put: sensorRule.update
        delete: rule.deleteSensorRule
    

    'rules/:ruleId/actuatorRules/?':
        # @todo Get by Rule: get: sensor.getActuatorRules
        post: rule.createActuatorRule

    'rules/?':
        get: rule.all
        post: rule.create

    'rules/:ruleId/?':
        get: rule.read
        put: rule.update
        delete: rule.delete