BaseView = require '../lib/base_view'

module.exports = class SensorProfile extends BaseView
    className: 'device-profile'
    template: require 'templates/sensorProfile'

    initialize: ->
        @listenTo @model, 'change', => @render()

    getRenderData: ->
        out = 
            name: @model.name
            driverName: @model.driver.name
            url: @model.getURL()
			customId: @modeL.customId
        return out