ViewCollection = require '../lib/view_collection'

module.exports = class DeviceList extends ViewCollection
    
    className: 'device-list'
    itemView: require 'views/deviceList_category'
    template: require 'templates/deviceList'
    
    collectionEl: '.collapsible'
    
    groupingAttribute: null
    
    initialize: ->
        super
        
    checkIfEmpty: =>
       #  @$('.help').toggle _.size(@views) is 0 and app.mode is 'public'
    
    afterRender: ->
        super
    
    addItem: (model) =>
        modelGroup = model[@groupingAttribute]
        if modelGroup not in @views
            # Create a group view to add this device:
            options = _.extend {}, {name: modelGroup, collection:[model]}, @itemViewOptions(model)
            view = new @itemview(options)
            @views[modelGroup] = view.render()
            @appendView view
        else
            @views[modelGroup].collection.add @model
        
        @onChange @views
        
    removeItem: (model) =>
        modelGroup = model[@groupingAttribute]
        @views[modelGroup].collection.remove @model
        
        if @views[modelGroup].collection.length == 0
            @views[modelGroup].remove()
            delete @views[modelGroup]
            @onChange @views