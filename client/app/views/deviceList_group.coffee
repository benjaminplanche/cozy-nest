ViewCollection = require '../lib/view_collection'

module.exports = class DeviceListGroup extends ViewCollection
    
    className: 'device-list-group'
    itemView: require 'views/albumslist_item'
    template: require 'templates/deviceList_group'
    
    collectionEl: '.collection'
    
    name: ''
    
    initialize: ->
        super
    
    checkIfEmpty: =>
        # @$('.help').toggle _.size(@views) is 0 and app.mode is 'public'
    
    afterRender: ->
        super
    
    getRenderData: ->
        return name: @name