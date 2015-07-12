BaseView = require '../lib/base_view'
DeviceList = require 'deviceList'
SensorProfile = require 'sensorProfile'
ActuatorProfile = require 'actuatorProfile'
DriverProfile = require 'driverProfile'

module.exports = class Device extends BaseView
    template: require 'templates/device'
    
    sensorList: null
    actuatorList: null
    driverList: null

    initialize: ->
        @subviews =
            sensorList: {view: new DeviceList collection: @sensorList, el: '#sensorList'}
            actuatorList: {view: new DeviceList collection: @actuatorList, el: '#actuatorList'}
            driverList: {view: new DeviceList collection: @driverList, el: '#driverList'}
            # @todo Condition to know if SensorProfile or ActuatorProfile or DriverProfile:
            deviceProfile: {view: new SensorProfile model: @model, el: '#deviceProfile'}
        # @listenTo @model, 'change', => @render()

    render: ->
        super
        for sub in @subviews
            sub.view.$el = sub.el
		    sub.view.render()
		    sub.view.delegateEvents()