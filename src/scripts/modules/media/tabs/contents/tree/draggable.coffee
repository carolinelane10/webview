define (require) ->
  BaseView = require('cs!helpers/backbone/views/base')

  return class TocDraggableView extends BaseView
    onDragStart: (e) ->
      e.originalEvent.dataTransfer.effectAllowed = 'move'
      TocDraggableView.dragging = @model # Track the model being dragged on this class

    onDragEnter: (e) ->
      # Display a green border to represent where the model will be moved
      e.currentTarget.style.borderBottom = '3px solid #6ea244'

    onDragLeave: (e) ->
      e.currentTarget.style.borderBottom = '3px solid transparent'

    onDrop: (e) ->
      if e.stopPropagation then e.stopPropagation()

      # Reorganize the content's toc internal data representation
      if TocDraggableView.dragging isnt @model
        @model = @content.move(TocDraggableView.dragging, @model, 'after')

      return false
