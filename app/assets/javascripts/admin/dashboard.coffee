$(document).on 'page:change', ->
  unless $('.sparkline-tag > canvas').length > 0
    $('.sparkline-tag').sparkline('html', { type: 'bar', barColor: '#69915d', barWidth: '6px', chartRangeMin: 0})

