###
# =================
# SCHEMA - Actuator
# =================
# Defines an Actuator, to apply Rules.
###

cozydb = require 'cozydb'

module.exports = ActuatorModel = cozydb.getModel 'Actuator',
    customId: 	type : String		# not Empty
    name: 		type : String		# not Empty
    type: 		type : String		# not Empty
