ViewCollection = require '../lib/view_collection'

module.exports = class DeviceListGroup extends ViewCollection
    
    className: 'device-list-group'
    itemView: require 'views/albumslist_item'
    template: require 'templates/deviceList_group'
    
    collectionEl: '.collection'
    
    name: ''
    
    initialize: ->
        super
        @collection.comparator = (device) ->
            return device.get "name"
    
    checkIfEmpty: =>
        # @$('.help').toggle _.size(@views) is 0 and app.mode is 'public'
    
    afterRender: ->
        super
    
    getRenderData: ->
        return name: @name
    
    appendView: (view) ->
        # Ensuring lexical sorting:
        index = @collection.indexOf view.model
        previous = @collection.at(index - 1)
        previousView  = previous?.view
        if index == 0 or !previous or !previousView
            @$collectionEl.append view.el
        else
            $(previousView.el).after view.el