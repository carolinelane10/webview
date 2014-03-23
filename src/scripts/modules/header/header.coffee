define (require) ->
  session  = require('cs!session')
  settings = require('settings')
  BaseView = require('cs!helpers/backbone/views/base')
  template = require('hbs!./header-template')
  require('less!./header')

  return class HeaderView extends BaseView
    template: template
    templateHelpers: () -> {
      page: @page
      url: @url
      username: session.get('username')
    }

    initialize: (options = {}) ->
      super()
      @page = options.page
      @url = @createLink(options.url) if options.url
      session.fetch()
      .fail(() -> console.error('problem fetching session'))
      .done(() => @render())

    setLegacyLink: (url) ->
      if url
        @url = @createLink(url)
      else
        @url = null
      @render()

    removeLegacyLink: (url) ->
      @setLegacyLink()

    createLink: (url) -> "#{location.protocol}//#{settings.legacy}/#{url}"
