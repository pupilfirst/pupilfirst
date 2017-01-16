loadStatsOnDemand = ->
  $('.js-hook.target-overview__load-stats-link').click (event) ->
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

loadDetailedStatsOnDemand = ->
  $('.js-hook.targets-overview__load-details-link').click (event) ->
    targetStatDetailsUrl = $('#admin-target-overview__index').data('targetStatDetailsUrl')
    detailsLink = $(event.target).closest('.targets-overview__load-details-link')
    detailsLinkContent = detailsLink.find('span')
    targetId = detailsLink.data('targetId')
    statType = detailsLink.data('type')
    originalStat = detailsLinkContent.html()

    $.get(
      url: targetStatDetailsUrl
      data: { target_id: targetId, type: statType }
      success: (data) ->
        displayStatDetails(data)
      beforeSend: ->
        detailsLinkContent.html('Loading...')
      complete: ->
        detailsLinkContent.html(originalStat)
      error: ->
        alert('Failed to load stats from server!')
    )

displayStatDetails = (data) ->
  detailsTable = $('.js-hook.target-overview__stat-details-table').show()
  tableBody = detailsTable.find('tbody')

  tableBody.html('')

  for assignee in data
    console.log assignee

    if assignee.product_name
      # Add startup details
      startupLink = "<a href='/admin/startups/#{assignee.id}' target='_blank'>#{assignee.product_name}</a>"
      tableBody.append("<tr><td class='col'>Startup</td><td class='col'>#{startupLink}</td></tr>")
    else
      # Add founder details
      founderLink = "<a href='/admin/founders/#{assignee.id}' target='_blank'>#{assignee.name}</a>"
      tableBody.append("<tr><td class='col'>Founder</td><td class='col'>#{founderLink}</td></tr>")

$(document).on 'turbolinks:load', ->
  if $('#admin-target-overview__index').length
    loadStatsOnDemand()
    loadDetailedStatsOnDemand()
