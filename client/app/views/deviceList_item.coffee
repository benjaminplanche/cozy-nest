BaseView = require '../lib/base_view'

module.exports = class DeviceListItem extends BaseView
    className: 'device-list-Item'
    template: require 'templates/deviceList_item'

    initialize: ->
        @listenTo @model, 'change', => @render()

    getRenderData: ->
        out = 
            name: @model.name
            driverName: @model.driver.name
            url: @model.getURL()
        return out