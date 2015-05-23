###
# =================
# SCHEMA - Rule
# =================
# Defines a Rule, binding Sensors Measures and Actuators together.
###

cozydb = require 'cozydb'
async = require 'async'

SensorRule = require './sensorRule'
ActuatorRule = require './actuatorRule'
Measure = require './measure'

module.exports = class Rule extends cozydb.CozyModel
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
	incrementNbSensorRules: (callback) ->
		@updateAttributes nbSensorRules: @nbSensorRules+1, callback
	
	###
	# decrementNbSensorRules
	# ====
	# Decrements (by 1) the number of SensorRules this rule has.
	# @param callback (Function(Error):null):				Callback
	###
	decrementNbSensorRules: (callback) ->
		@updateAttributes nbSensorRules: @nbSensorRules-1, callback
	
	###
	# incrementNbSensorRulesMet
	# ====
	# Increments (by 1) the number of fulfilled SensorRules this rule has.
	# @param callback (Function(Error):null):				Callback
	###
	incrementNbSensorRulesMet: (callback) ->
		@updateAttributes nbSensorRulesMet: @nbSensorRulesMet+1, callback
	
	###
	# decrementNbSensorRulesMet
	# ====
	# Decrements (by 1) the number of fulfilled SensorRules this rule has.
	# @param callback (Function(Error):null):				Callback
	###
	decrementNbSensorRulesMet: (callback) ->
		@updateAttributes nbSensorRulesMet: @nbSensorRulesMet-1, callback
	
	###
	# createSensorRule
	# ====
	# Generates a SensorRule (ie. condition) associated to this Rule.
	# @param data (dictionary): 							SensorRule's data (sensorId, type, intervalStart, intervalEnd)
	# @param callback (Function(Error, SensorRule):null):	Callback
	###
	createSensorRule: (data, callback) ->
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
				else
					callback null, sensorRule
			# If the SensorRule (ie. condition) is already met, we let the Rule know:
			if sensorRule.met
				rule.incrementNbSensorRulesMet (err2) -> callback err2, sensorRule
		SensorRule.create data, cb

	###
	# destroySensorRule
	# ====
	# Destroys a SensorRule, and updates the information of the Rule it belonged to.
	# @param sensorRule (SensorRule):				SensorRule to be deleted, belonging to the Rule
	# @param callback (Function(Error):null):		Callback
	###
	destroySensorRule: (sensorRule, callback) ->
		rule = @

		# Decrementing the number of SensorRules this rule has:
		unless sensorRule.ruleId == @id
			callback "The SensorRule doesn't belong to this Rule."
			return

		async.parallel [
			(cb) -> rule.decrementNbSensorRules cb
			,
			(cb) ->
				if sensorRule.met
					rule.decrementNbSensorRulesMet cb
				else
					cb null
		 ], (err, res) ->
			if err
				callback err
				return

			sensorRule.destroy (err2) ->
				if err2
					# Cancelling modif:
					rule.incrementNbSensorRules callback
					return
				
				### @todo Think about use-cases before uncommenting below/
				if rule.nbSensorRules == rule.nbSensorRulesMet
					# The remaining conditions are met, so we apply the rule:
					Rule.applyRules [rule], callback
					return
				###

				callback null
	
	###
	# createActuatorRule
	# ====
	# Generates an ActuatorRule (ie. reaction) associated to this Rule.
	# @param data (dictionary): 							ActuatorRule's data (type, value, isActive)
	# @param callback (Function(Error, ActuatorRule):null):	Callback
	###
	createActuatorRule: (data, callback) ->
		data.ruleId = @id
		ActuatorRule.create data, callback
		
	
	###
	# destroy
	# ====
	# Deletes the Rule, and its SensorRules and ActuatorRules
	# @param callback (Function(Error):null):		Callback
	###
	destroy: (callback) ->
		superDestroy = (callback) => super callback

		params = key: @id
		async.parallel [
			(cb) ->
				SensorRule.request "byRule", params, (err, sensorRules)->
					if err
						cb 'Error while deleting the conditions (SensorRules) associated: '+err
					msgErr = ''
					partialCallback = (partialErr) ->
						msgErr += 'Error while deleting SensorRule: ' + partialErr + '\n'
					
					sensorRule.destroy partialCallback for sensorRule in sensorRules
					if msgErr?
						cb msgErr
			,
			(cb) ->
				ActuatorRule.request "byRule", params, (err, actuatorRules)->
					if err
						cb 'Error while deleting the conditions (ActuatorRules) associated: '+err
					msgErr = ''
					partialCallback = (partialErr) ->
						msgErr += 'Error while deleting ActuatorRule: ' + partialErr + '\n'
					
					actuatorRule.destroy partialCallback for actuatorRule in actuatorRules
					if msgErr?
						cb msgErr
		 ], (err, results) ->
		 	return callback err if err
		 	
			superDestroy callback

	###
	# checkMetRules
	# ====
	# Checks the rules which have all their SensorRules (conditions) met when taking into account the given Measure.
	# @param measure (Measure): 						Measure to take into account
	# @param callback (Function(Error, Rule[]):null): 	Callback
	###
	@checkMetRules: (measure, callback) ->
		# First find the SensorRules 
		param =
			key: [measure.sensorId, measure.type]
		SensorRule.request 'bySensorIdAndType', param, (err, sensorRules)->
			if err
				callback err, null
				return
			
			# @todo async.map stops and calls the callback at the first returned error. We might not want such a behavior...
			async.map sensorRules, ((sensorRule, cb) ->
				if (!sensorRule.intervalEnd || measure.value < sensorRule.intervalEnd) && (!sensorRule.intervalStart || measure.value >= sensorRule.intervalStart)
					# If the measure triggers the SensorRule, update the corresponding Rule:
					Rule.find sensorRule.ruleId (err, rule) ->
						if err
							cb 'Error when finding Rule related to SensorRule #'+sensorRule.id+': '+err, null
							return
						if !rule
							cb 'Rule related to SensorRule #'+sensorRule.id+' not found.', null
							return
						
						isRuleMet = (rule.nbSensorRulesMet + 1) == rule.nbSensorRules
						rule.incrementNbSensorRulesMet (err) -> 
							if err
								cb 'Error when updating Rule related to SensorRule #'+sensorRule.id+' (to increment its number of met SensorRules): '+err, isRuleMet? rule:null
								return
							sensorRule.updateAttributes met: true, ((err) -> cb err, isRuleMet? rule:null)
				else
					if sensorRule.met
						# If the conditions was met, it is not the case anymore.
						# We thus have to decrement the number of met SensorRules of the corresponding rule, and update the SensorRule itself:
						Rule.find sensorRule.ruleId (err, rule) ->
							if err
								cb 'Error when finding Rule related to SensorRule #'+sensorRule.id+': '+err, null
								return
							if !rule
								cb 'Rule related to SensorRule #'+sensorRule.id+' not found.', null
								return
							rule.decrementNbSensorRulesMet (err) -> 
								if err
									cb 'Error when updating Rule related to SensorRule #'+sensorRule.id+' (to decrement its number of met SensorRules): '+err, null
									return
								sensorRule.updateAttributes met: false, ((err) -> cb err, null)
					else
						callback null, null
			), callback
			
	###
	# applyRules
	# ====
	# Applies the ActuatorRules (reactions) of the given rules.
	# @param rules (Rules[]): 					Rules
	# @param callback (Function(Error):null): 	Callback
	###
	@applyRules: (rules, callback) ->
		# @todo async.each stops and calls the callback at the first returned error. We might not want such a behavior...
		async.each rules, ((rule, cb) ->
			ActuatorRule.request "byRule", key: rule.id, (err, actuatorRules)->
				if err
					callback 'Error while finding ActuatorRules associated to Rule #'+rule.id+': '+err
					return
				async.each actuatorRules, ((actuatorRule, cb2) ->
					actuatorRule.apply cb2
				), cb
			), callback