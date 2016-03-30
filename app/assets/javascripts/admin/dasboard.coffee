$(document).on 'page:change', ->
  $('.sparkline-tag').sparkline('html', { type: 'bar', barColor: '#69915d', barWidth: '6px'})
