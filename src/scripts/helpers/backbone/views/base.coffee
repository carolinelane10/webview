define (require) ->
  $ = require('jquery')
  _ = require('underscore')
  Backbone = require('backbone')
  settings = require('settings')

  dispose = (obj) ->
    delete obj.parent
    delete obj.el
    delete obj.$el
    delete obj.regions

  class Region
    constructor: (@el, @parent) ->

    show: (view) ->
      @empty()
      @append(view)

    append: (view) ->
      @appendAs('div', view)

    appendOnce: (options) ->
      if not (_.find @views, (view) -> options.view instanceof view.constructor)
        if options.as.charAt(0) is '.'
          @appendAs("div class=\"#{options.as.substr(1)}\"", options.view)
        else if options.as.charAt(0) is '#'
          @appendAs("div id=\"#{options.as.substr(1)}\"", options.view)
        else
          @appendAs(options.as, options.view)

    appendAs: (type, view) ->
      @$el = @parent.$el
      if @el then @$el = @parent.$el.find(@el)
      view.parent = @parent
      @views ?= []
      @views.push(view)
      view.setElement($("<#{type}>").appendTo(@$el)).render()
      view.onShow()

    empty: () ->
      _.each @views, (view) ->
        view.close()

      @$el?.empty()
      @$el = null
      @views = null

    close: () ->
      @empty()
      dispose(@)

  class Regions
    constructor: (regions = {}, $context) ->
      _.each _.keys(regions), (region) =>
        @[region] = new Region(regions[region], $context)

      # Add a self-referential region to attach views to
      @self = new Region(null, $context)

  return class BaseView extends Backbone.View
    initialize: () ->
      @regions = new Regions(@regions, @)

    renderDom: () ->
      @$el?.html(@getTemplate())

    # Update page title
    updateTitle: () ->
      document.title = settings.titlePrefix + @pageTitle if @pageTitle

    getTemplate: () -> @template?(@getTemplateData()) or @template

    getTemplateData: () ->
      data = @model?.toJSON() or @collection?.toJSON() or {}

      if typeof @templateHelpers is 'function'
        _.extend(data, @templateHelpers())
      else
        # Add data from template helpers to the model's data
        _.each @templateHelpers, (value, key) =>
          if typeof value is 'function'
            data[key] = value.apply(@)
          else
            data[key] = value

      return data

    _render: () ->
      _.each @regions, (region) -> region.empty()
      @updateTitle()
      @renderDom()

    render: () ->
      @onBeforeRender()
      @_render()
      @onRender()
      if @_rendered then @onDomRefresh() else @_rendered = true
      @onAfterRender()

      return @

    onShow: () -> # noop
    onBeforeRender: () -> # noop
    onRender: () -> # noop
    onAfterRender: () -> # noop
    onDomRefresh: () -> # noop
    onBeforeClose: () -> # noop

    close: () ->
      @onBeforeClose()

      _.each @regions, (region) ->
        region.close()

      @off() # Remove all event listeners
      @remove()
      @unbind()
      dispose(@)
      return @
