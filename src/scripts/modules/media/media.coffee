define (require) ->
  $ = require('jquery')
  router = require('cs!router')
  analytics = require('cs!helpers/handlers/analytics')
  Content = require('cs!models/content')
  BaseView = require('cs!helpers/backbone/views/base')
  MediaEndorsedView = require('cs!./endorsed/endorsed')
  LatestView = require('cs!./latest/latest')
  MediaTitleView = require('cs!./title/title')
  MediaTabsView = require('cs!./tabs/tabs')
  MediaNavView = require('cs!./nav/nav')
  MediaHeaderView = require('cs!./header/header')
  MediaBodyView = require('cs!./body/body')
  MediaFooterView = require('cs!./footer/footer')
  template = require('hbs!./media-template')
  require('less!./media')

  return class MediaView extends BaseView
    template: template

    regions:
      media: '.media'
      editbar: '.editbar'

    initialize: (options) ->
      super()

      if not options or not options.uuid
        throw new Error('A media view must be instantiated with the uuid of the media to display')

      @uuid = options.uuid
      @model = new Content({id: @uuid, page: options.page})

      @listenTo(@model, 'change:googleAnalytics', @trackAnalytics)
      @listenTo(@model, 'change:title', @updateTitle)
      @listenTo(@model, 'change:legacy_id change:legacy_version change:currentPage pageLoaded', @updateLegacyLink)
      @listenTo(@model, 'change:error', @displayError)
      @listenTo(@model, 'change:editable', @toggleEditor)

    onRender: () ->
      @regions.media.append(new MediaEndorsedView({model: @model}))
      @regions.media.append(new LatestView({model: @model}))
      @regions.media.append(new MediaTitleView({model: @model}))
      @regions.media.append(new MediaTabsView({model: @model}))
      @regions.media.append(new MediaNavView({model: @model}))
      @regions.media.append(new MediaHeaderView({model: @model}))
      @regions.media.append(new MediaBodyView({model: @model}))
      @regions.media.append(new MediaFooterView({model: @model}))
      @regions.media.append(new MediaNavView({model: @model, hideProgress: true}))

    trackAnalytics: () ->
      # Track loading using the media's own analytics ID, if specified
      analyticsID = @model.get('googleAnalytics')
      analytics.send(analyticsID) if analyticsID

    scrollToTop: () ->
      $mediaNav = $('.media-nav').first()
      maxY = $mediaNav.offset().top + $mediaNav.height()
      y = window.pageYOffset or document.documentElement.scrollTop

      $('html, body').animate({scrollTop: $mediaNav.offset().top}, '500', 'swing') if y > maxY

    updateTitle: () ->
      @pageTitle = @model.get('title')
      super()

    updateLegacyLink: () ->
      headerView = @parent.parent.regions.header.views[0]
      id = @model.get('legacy_id')
      version = @model.get('legacy_version')

      if @model.isBook()
        currentPage = @model.asPage()
        if currentPage
          pageId = currentPage.get('legacy_id')
          pageVersion = currentPage.get('legacy_version')
          if pageId and pageVersion
            headerView.setLegacyLink("content/#{pageId}/#{pageVersion}/?collection=#{id}/#{version}")
        return

      headerView.setLegacyLink("content/#{id}/#{version}") if id and version

    displayError: () ->
      error = arguments[1] # @model.get('error')
      router.appView.render('error', {code: error}) if error

    toggleEditor: () -> if @editing then @closeEditor() else @loadEditor()

    # FIX: How much of loadEditor and closeEditor can be merged into the editbar?
    loadEditor: () ->
      @editing = true

      require ['cs!./editbar/editbar'], (EditbarView) =>
        @regions.editbar.show(new EditbarView({model: @model}))
        height = @regions.editbar.$el.find('.navbar').outerHeight()
        $('body').css('padding-top', height) # Don't cover the page header
        window.scrollBy(0, height) # Prevent viewport from jumping

    closeEditor: () ->
      @editing = false
      height = @regions.editbar.$el.find('.navbar').outerHeight()
      @regions.editbar.empty()
      $('body').css('padding-top', '0') # Remove added padding
      window.scrollBy(0, -height) # Prevent viewport from jumping

    onBeforeClose: () ->
      if @model.get('editable')
        @model.set('editable', false, {silent: true})
        @closeEditor()

