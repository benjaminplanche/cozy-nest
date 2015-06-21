
module.exports = class Measure extends Backbone.RelationalModel
	relations: [
			type: Backbone.HasOne
			key: 'sensor'
			keySource: 'sensorId'
			relatedModel: 'Sensor'
	]
	
	urlRoot: 'measures'

    defaults: ->
        time:		null
		value: 		''
		type: 		''