define [
  'jquery'
  'underscore'
  'backbone'
  'cs!helpers/backbone/views/base'
  'cs!modules/header/header'
  'cs!modules/footer/footer'
  #'cs!modules/splash/splash'
  'hbs!./media-template'
  'less!./media'
], ($, _, Backbone, BaseView, HeaderView, FooterView, template) ->

  return class MediaView extends BaseView
    initialize: (options) ->
      if not options or not options.uuid
        throw new Error('A media view must be instantiated with the uuid of the content to display')

      @uuid = options.uuid

    template: template()

    regions:
      title: '#content-title'
      navTop: '#content-nav-top'
      header: '#content-header'
      body: '#content-body'
      footer: '#content-footer'
      navBottom: '#content-nav-bottom'

    render: () ->
      super()

      @parent?.regions.header.show(new HeaderView({page: 'content'}))
      @parent?.regions.footer.show(new FooterView({page: 'content'}))

      #@regions.title.show(new ContentTitleView({uuid: @uuid}))
      #@regions.navTop.show(new ContentNavView({uuid: @uuid}))
      #@regions.header.show(new ContentHeaderView({uuid: @uuid}))
      #@regions.body.show(new ContentBodyView({uuid: @uuid}))
      #@regions.footer.show(new ContentFooterView({uuid: @uuid}))
      #@regions.navBottom.show(new ContentNavView({uuid: @uuid}))

      return @