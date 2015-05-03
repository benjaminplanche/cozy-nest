
module.exports = class Sensor extends Backbone.RelationalModel
	relations: [
			type: Backbone.HasOne
			key: 'driver'
			keySource: 'driverId'
			relatedModel: 'Driver'
		,
			type: Backbone.HasMany
			key: 'measures'
			relatedModel: 'Measure'
			autoFetch: false
			includeInJSON: Backbone.Model.prototype.idAttribute
			collectionType: 'MeasureCollection'
	]
	
	urlRoot: 'sensors'

    defaults: ->
        customId:	''
		name: 		''