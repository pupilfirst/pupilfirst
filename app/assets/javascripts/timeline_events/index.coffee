$(document).on 'page:change', ->
  $('.startup-grid').masonry
    itemSelector: '.startup-event-entry'
    columnWidth: '.startup-event-entry'

  $('.tab-title').on 'click', ->
    setTimeout ->
      $('.startup-grid').masonry
        itemSelector: '.startup-event-entry'
        columnWidth: '.startup-event-entry'
