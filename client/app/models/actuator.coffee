
module.exports = class Actuator extends Backbone.RelationalModel
	relations: [
			type: Backbone.HasOne
			key: 'driver'
			keySource: 'driverId'
			relatedModel: 'Driver'
	]
	
	urlRoot: 'actuators'

    defaults: ->
        customId: 	'Undefined'
		name: 		'Undefined'
		url:		'actuators/'
		
	getURL: ->
		return "actuators/#{@id}"