
module.exports = class Rule extends Backbone.RelationalModel
	relations: [
			type: Backbone.HasMany
			key: 'sensorRules'
			relatedModel: 'SensorRule'
			autoFetch: true
			includeInJSON: Backbone.Model.prototype.idAttribute
			collectionType: 'SensorRuleCollection'
		,
			type: Backbone.HasMany
			key: 'actuatorRules'
			relatedModel: 'ActuatorRule'
			autoFetch: true
			includeInJSON: Backbone.Model.prototype.idAttribute
			collectionType: 'ActuatorRuleCollection'
	]
	
	urlRoot: 'rules'

    defaults: ->
        name: 				''
		nbSensorRules:		0
		nbSensorRulesMet:	0