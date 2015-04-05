###
# =================
# SCHEMA - Rule
# =================
# Defines a Rule, binding Sensors Measures and Actuators together.
###

cozydb = require 'cozydb'
SensorRule = require './sensorRule'
ActuatorRule = require './actuatorRule'

module.exports = RuleModel = cozydb.getModel 'Rule',
	@schema:
		name: 				type : String		# not Empty
		nbSensorRules:		type : Number, default : 0
		nbSensorRulesMet:	type : Number, default : 0
	
	###
	# incrementNbSensorRules
	# ====
	# Increments (by 1) the number of SensorRules this rule has.
	# @param callback (Function(Error):null):				Callback
	###
	@incrementNbSensorRules(callback)
		@nbSensorRules++
		RuleModel.update @, callback
	
	###
	# decrementNbSensorRules
	# ====
	# Decrements (by 1) the number of SensorRules this rule has.
	# @param callback (Function(Error):null):				Callback
	###
	@decrementNbSensorRules(callback)
		@nbSensorRules--
		RuleModel.update @, callback
	
	###
	# incrementNbSensorRulesMet
	# ====
	# Increments (by 1) the number of fulfilled SensorRules this rule has.
	# @param callback (Function(Error):null):				Callback
	###
	@incrementNbSensorRulesMet(callback)
		@nbSensorRulesMet++
		RuleModel.update @, callback
	
	###
	# decrementNbSensorRulesMet
	# ====
	# Decrements (by 1) the number of fulfilled SensorRules this rule has.
	# @param callback (Function(Error):null):				Callback
	###
	@decrementNbSensorRulesMet(callback)
		@nbSensorRulesMet--
		RuleModel.update @, callback
	
	###
	# createSensorRule
	# ====
	# Generates a SensorRule (ie. condition) associated to this Rule.
	# @param data (dictionary): 							SensorRule's data (sensorId, type, intervalStart, intervalEnd)
	# @param callback (Function(Error, SensorRule):null):	Callback
	###
	@createSensorRule = (data, callback) ->
		sanitize data
		data.ruleId = @id
		rule = @
		cb = (err, sensorRule) ->
			if err
				callback err, sensorRule
				return
			# Incrementing the number of SensorRules this rule has:
			rule.incrementNbSensorRules (err2) ->
				if err2
					# Cancelling modif:
					SensorRule.requestDestroy "all", {key: sensorRule.id}, (err3) ->
						if err3
							err2 += " AND " + err3
						callback err2, null
					return
				callback null, sensorRule
			# If the SensorRule (ie. condition) is already met, we let the Rule know:
			if sensorRule.met
				rule.incrementNbSensorRulesMet (err2) -> callback err2, sensorRule
		SensorRule.createIfSensor data cb
	
	###
	# createActuatorRule
	# ====
	# Generates an ActuatorRule (ie. reaction) associated to this Rule.
	# @param data (dictionary): 							ActuatorRule's data (type, value, isActive)
	# @param callback (Function(Error, ActuatorRule):null):	Callback
	###
	@createActuatorRule = (data, callback) ->
		sanitize data
		data.ruleId = @id
		ActuatorRule.createIfActuator data callback
		
	
	###
	# destroy
	# ====
	# Deletes the Rule, and its SensorRules and ActuatorRules
	# @param callback (Function(Error):null):		Callback
	###
	@destroy = (callback) ->
		params = key: @id
		SensorRule.request "byRule", params, (err, sensorRules)->
			if err
				callback 'Error while deleting the conditions (SensorRules) associated: '+err
			msgErr = ''
			partialCallback = partialErr ->
				msgErr += 'Error while deleting SensorRule: ' + partialErr + '\n'
			
			sensorRule.destroy partialCallback for sensorRule in sensorRules
			if msgErr?
				callback msgErr
		
		ActuatorRule.request "byRule", params, (err, actuatorRules)->
			if err
				callback 'Error while deleting the conditions (ActuatorRules) associated: '+err
			msgErr = ''
			partialCallback = partialErr ->
				msgErr += 'Error while deleting ActuatorRule: ' + partialErr + '\n'
			
			actuatorRule.destroy partialCallback for actuatorRule in actuatorRules
			if msgErr?
				callback msgErr
		
		super callback
	