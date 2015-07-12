BaseView = require '../lib/base_view'

module.exports = class ActuatorProfile extends BaseView
    className: 'device-profile'
    template: require 'templates/actuatorProfile'

    initialize: ->
        @listenTo @model, 'change', => @render()

    getRenderData: ->
        out = 
            name: @model.name
            driverName: @model.driver.name
			customId: @modeL.customId
            url: @model.getURL()
        return out