##
# =================
# SCHEMA - Rule
# =================
# Defines a Rule, binding Sensors Measures and Actuators together.
##

cozydb = require 'cozydb'

module.exports = RuleModel = cozydb.getModel 'Rule',
	name: 		type : String		# not Empty