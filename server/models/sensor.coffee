##
# =================
# SCHEMA - SensorRule
# =================
# Defines a SensorRule, defining the values interval of the Measures of a Sensor to trigger a Rule.
##

cozydb = require 'cozydb'

module.exports = SensorModel = cozydb.getModel 'Sensor',
	customId:	type : String		# not Empty
	name: 		type : String		# not Empty
	type: 		type : String		# not Empty