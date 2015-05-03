
module.exports = class SensorRule extends Backbone.RelationalModel
	relations: [
			type: Backbone.HasOne
			key: 'rule',
			keySource: 'ruleId'
			relatedModel: 'Rule'
		,
			type: Backbone.HasOne
			key: 'sensor',
			keySource: 'sensorId'
			relatedModel: 'Sensor'
			
	]
	
	urlRoot: 'sensorRules'

    defaults: ->
        type: 			''
		intervalStart: 	''
		intervalEnd: 	''