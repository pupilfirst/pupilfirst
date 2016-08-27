handleConversationFetch = ->
  $('#intercom-fetch-button').on "ajax:success", (e, data, status, xhr) ->
    $('#intercom-conversations').html(data)

$(document).on 'page:change', ->
  unless $('.sparkline-tag > canvas').length > 0
    $('.sparkline-tag').sparkline('html', { type: 'bar', barColor: '#69915d', barWidth: '6px', chartRangeMin: 0})
  handleConversationFetch()

