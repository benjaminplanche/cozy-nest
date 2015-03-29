###
# =================
# SCHEMA - ActuatorRule
# =================
# Defines a ActuatorRule, defining which Actuator must be triggered and how, when the conditions of the Rule (SensorRules) are met.
###

cozydb = require 'cozydb'

module.exports = ActuatorRuleModel = cozydb.getModel 'ActuatorRule',
    value: 		type : Number	# not Empty
    isActive: 	type : Boolean, default : true