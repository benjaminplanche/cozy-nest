
module.exports = class Driver extends Backbone.RelationalModel
	relations: [
			type: Backbone.HasMany
			key: 'sensor'
			relatedModel: 'Sensor'
			autoFetch: false
			includeInJSON: Backbone.Model.prototype.idAttribute
			collectionType: 'SensorCollection'
		,
			type: Backbone.HasMany
			key: 'actuator'
			relatedModel: 'Actuator'
			autoFetch: false
			includeInJSON: Backbone.Model.prototype.idAttribute
			collectionType: 'ActuatorCollection'
			
	]
	
	urlRoot: 'drivers'

    defaults: ->
        name: 		''
		isSensor: 	false
		isActuator: false