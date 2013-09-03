define (require) ->
  router = require('cs!router')
  analytics = require('cs!helpers/handlers/analytics')
  BaseView = require('cs!helpers/backbone/views/base')
  template = require('hbs!./nav-template')
  require('less!./nav')

  return class MediaNavView extends BaseView
    initialize: (options) ->
      super()
      @hideProgress = options.hideProgress

      if not @hideProgress
        @listenTo(@model, 'change:page change:pages', @render)

    render: () ->
      tmplOptions = @model.toJSON()
      tmplOptions._hideProgress = @hideProgress
      @template = template tmplOptions
      super()

    events:
      'click .next': 'nextPage'
      'click .back': 'previousPage'

    nextPage: () ->
      @navigate(@model.nextPage())

    previousPage: () ->
      @navigate(@model.previousPage())

    navigate: (page) ->
      route = "/content/#{router.current().params[0]}/#{page}" # Deterimine the new route
      router.navigate(route) # Update browser URL to reflect the new route
      analytics.send() # Send the analytics information for the new route