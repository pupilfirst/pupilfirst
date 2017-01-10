loadStatsOnDemand = ->
  $('.js-target-overview__load-stats-link').click (event) ->
    targetStatsUrl = $('#admin-target-overview__index').data('targetStatsUrl')
    clickedLink = $(event.target)
    targetId = clickedLink.data('targetId')

    $.get(
      url: targetStatsUrl
      data: { target_id: targetId }
      success: (data) ->
        row = clickedLink.parent().parent()
        row.find('.js-targets-overview__completed-count').html(data.completed)
        row.find('.js-targets-overview__submitted-count').html(data.submitted)
        row.find('.js-targets-overview__needs-improvement-count').html(data.needs_improvement)
        row.find('.js-targets-overview__not-accepted-count').html(data.not_accepted)
        row.find('.js-targets-overview__unavailable-count').html(data.unavailable)
        row.find('.js-targets-overview__pending-count').html(data.pending)
        row.find('.js-targets-overview__expired-count').html(data.expired)
      beforeSend: ->
        clickedLink.html('Loading...')
      complete: ->
        clickedLink.html('Load')
      error: ->
        alert('Failed to load stats from server!')
    )

$(document).on 'turbolinks:load', ->
  if $('#admin-target-overview__index').length
    loadStatsOnDemand()
