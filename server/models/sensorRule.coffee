##
# =================
# SCHEMA - SensorRule
# =================
# Defines a SensorRule, defining the values interval of the Measures of a Sensor to trigger a Rule.
##

cozydb = require 'cozydb'

module.exports = RuleModel = cozydb.getModel 'Rule',
	type: 			type : String		# not Empty, not Null
	intervalStart: 	type : Number		# not Empty
	intervalEnd: 	type : Number		# not Empty