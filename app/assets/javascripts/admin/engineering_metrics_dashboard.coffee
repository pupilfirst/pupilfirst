$(document).on 'page:change', ->
  unless $('.sparkline-tag-large > canvas').length > 0
    $('.sparkline-tag-large').sparkline('html', { type: 'bar', height: '40px', barColor: '#69915d', barWidth: '20px', chartRangeMin: 0})
