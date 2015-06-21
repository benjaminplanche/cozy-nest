
module.exports = class ActuatorRule extends Backbone.RelationalModel
	relations: [
			type: Backbone.HasOne
			key: 'rule',
			keySource: 'ruleId'
			relatedModel: 'Rule'
		,
			type: Backbone.HasOne
			key: 'actuator',
			keySource: 'actuatorId'
			relatedModel: 'Actuator'
			
	]
	
	urlRoot: 'actuatorRules'

    defaults: ->
        value: 		''
		isActive: 	false