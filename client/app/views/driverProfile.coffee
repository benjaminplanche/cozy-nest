BaseView = require '../lib/base_view'

module.exports = class DriverProfile extends BaseView
    className: 'device-profile'
    template: require 'templates/driverProfile'

    initialize: ->
        @listenTo @model, 'change', => @render()

    getRenderData: ->
        out = 
            name: @model.name
            directory: @model.getDirectory()
        return out