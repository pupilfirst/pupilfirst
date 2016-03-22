$(document).on 'page:change', ->
  $('.sparkline-tag').sparkline('html', { type: 'bar'})
